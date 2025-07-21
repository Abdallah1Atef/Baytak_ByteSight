import csv
import random
from datetime import datetime, timedelta
import os

def read_csv(filename):
    """Reads a CSV file and returns its content as a list of lists."""
    data = []
    try:
        with open(filename, mode='r', newline='', encoding='utf-8') as file:
            reader = csv.reader(file)
            header = next(reader)  # Read header
            for row in reader:
                data.append(row)
        return header, data
    except FileNotFoundError:
        print(f"Error: The file '{filename}' was not found. Please ensure it's in the correct directory.")
        return [], []
    except Exception as e:
        print(f"An error occurred while reading '{filename}': {e}")
        return [], []

def write_to_csv(filename, header, data):
    """Writes data to a CSV file."""
    try:
        with open(filename, mode='w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(header)
            writer.writerows(data)
        print(f"Generated {filename} with {len(data)} rows.")
    except IOError as e:
        print(f"Error writing to {filename}: {e}")
        print("Please check if you have write permissions in the directory where you are running the script.")
    except Exception as e:
        print(f"An unexpected error occurred while writing to {filename}: {e}")

def generate_review_table(delivery_data, order_line_data, order_data, num_reviews_target=2500):
    """
    Generates a review table based on delivery, order line, and order data.
    Reviews are after delivery date and have integer scores from 1 to 5.

    Args:
        delivery_data (list): List of lists from the delivery table.
        order_line_data (list): List of lists from the order line table.
        order_data (list): List of lists from the order table.
        num_reviews_target (int): The target number of reviews to generate.

    Returns:
        list: The generated review data.
    """
    reviews = []
    
    # Create a dictionary for quick lookup of deliver_date by Order_id
    # Assuming delivery_data format: [Order_id, scheduled_deliver_date, deliver_date]
    delivery_dates_map = {}
    for row in delivery_data:
        if len(row) >= 3 and row[0].isdigit():
            try:
                delivery_dates_map[int(row[0])] = datetime.strptime(row[2], '%Y-%m-%d')
            except ValueError as e:
                print(f"Warning: Could not parse deliver_date '{row[2]}' for Order_id {row[0]} in delivery table: {e}")
                continue
    print(f"DEBUG: Parsed {len(delivery_dates_map)} unique Order_ids into delivery_dates_map.")

    # Create a dictionary for quick lookup of order_date by Order_id
    # Assuming order_data format: [Order_id, branch_id, customer_id, orderDate, payment_method]
    order_dates_map = {}
    for row in order_data:
        if len(row) >= 4 and row[0].isdigit():
            order_id = int(row[0])
            order_date_str = row[3]
            parsed_date = None

            # Try parsing common formats
            try:
                parsed_date = datetime.strptime(order_date_str, '%Y-%m-%d %H:%M:%S') # YYYY-MM-DD HH:MM:SS
            except ValueError:
                try:
                    parsed_date = datetime.strptime(order_date_str, '%Y-%m-%d') # YYYY-MM-DD
                except ValueError:
                    # Fallback for M/D/YYYY with non-padded month/day (e.g., '7/4/2025')
                    parts = order_date_str.split('/')
                    if len(parts) == 3:
                        try:
                            month = int(parts[0])
                            day = int(parts[1])
                            year = int(parts[2])
                            parsed_date = datetime(year, month, day)
                        except ValueError:
                            pass # Still failed to parse
            
            if parsed_date:
                order_dates_map[order_id] = parsed_date
            else:
                print(f"Warning: Could not parse orderDate '{order_date_str}' for Order_id {order_id} in order table: All formats failed.")
                continue # Skip this row if parsing fails
    print(f"DEBUG: Parsed {len(order_dates_map)} unique Order_ids into order_dates_map.")

    # Create a list of eligible order lines (those with a corresponding delivery date AND order date)
    # Assuming order_line_data format (adjusted based on user feedback): 
    # [Order_line_id, Order_id, product_id, quantity, dis_id, design_id] OR
    # [Order_line_id, product_id, Order_id, quantity, dis_id, design_id] (if my initial assumption was wrong)
    # User stated "the order id is the second colunm in order line table", meaning row[1]
    eligible_order_lines = []
    skipped_inconsistent_dates = 0
    skipped_missing_ids_delivery = 0
    skipped_missing_ids_order = 0

    for row in order_line_data:
        if len(row) >= 2 and row[0].isdigit() and row[1].isdigit(): # Check row[1] for order_id
            # Extract Order_id from order_line_data. User confirmed this is row[1] (second column).
            order_id = int(row[1]) 
            order_line_id = int(row[0]) # Assuming Order_line_id is always the first column
            
            # Ensure both delivery date and order date are available for this order_id
            delivery_date_found = order_id in delivery_dates_map
            order_date_found = order_id in order_dates_map

            if delivery_date_found and order_date_found:
                deliver_date = delivery_dates_map[order_id]
                order_date = order_dates_map[order_id]

                # Critical check: Ensure deliver_date is not before order_date
                # Compare only the date component to avoid issues with time differences
                if deliver_date.date() < order_date.date():
                    skipped_inconsistent_dates += 1
                    continue # Skip this order line if dates are inconsistent
                
                eligible_order_lines.append({
                    'order_line_id': order_line_id,
                    'order_id': order_id,
                    'deliver_date': deliver_date,
                    'order_date': order_date # Include order_date for reference
                })
            else:
                if not delivery_date_found:
                    skipped_missing_ids_delivery += 1
                if not order_date_found:
                    skipped_missing_ids_order += 1

    print(f"DEBUG: Skipped {skipped_inconsistent_dates} order lines due to deliver_date < order_date inconsistency.")
    print(f"DEBUG: Skipped {skipped_missing_ids_delivery} order lines due to missing Order_id in delivery_dates_map.")
    print(f"DEBUG: Skipped {skipped_missing_ids_order} order lines due to missing Order_id in order_dates_map.")
    print(f"DEBUG: Found {len(eligible_order_lines)} eligible order lines for review generation.")

    # If there are fewer eligible order lines than the target reviews, adjust the target
    if len(eligible_order_lines) < num_reviews_target:
        print(f"Warning: Not enough eligible order lines ({len(eligible_order_lines)}) to generate {num_reviews_target} reviews. Generating {len(eligible_order_lines)} reviews instead.")
        num_reviews_target = len(eligible_order_lines)
    
    if num_reviews_target == 0:
        print("DEBUG: num_reviews_target is 0, no reviews will be generated.")
        return [] # Return empty list if no reviews can be generated

    # Randomly select order lines to generate reviews for
    random.shuffle(eligible_order_lines)
    selected_order_lines_for_reviews = eligible_order_lines[:num_reviews_target]

    review_id_counter = 1
    
    # Optional: Print a sample of selected items for debugging
    print(f"\n--- Sample of selected order lines for review generation ({min(5, len(selected_order_lines_for_reviews))} items) ---")
    for i, item in enumerate(selected_order_lines_for_reviews[:5]): # Print first 5
        print(f"  Order_line_id: {item['order_line_id']}, Order_id: {item['order_id']}, Order_Date: {item['order_date'].strftime('%Y-%m-%d')}, Deliver_Date: {item['deliver_date'].strftime('%Y-%m-%d')}")
    print(f"----------------------------------------------------------\n")

    for item in selected_order_lines_for_reviews:
        order_line_id = item['order_line_id']
        deliver_date = item['deliver_date']

        # Review date: 1 to 30 days after delivery, without time component
        # This ensures review_date is ALWAYS after deliver_date
        review_date_dt = deliver_date + timedelta(days=random.randint(1, 30))
        
        # Generate integer ratings from 1 to 5
        delevery_rating = random.randint(1, 5)
        branch_rating = random.randint(1, 5)
        product_rating = random.randint(1, 5)
        customer_service_rating = random.randint(1, 5)

        reviews.append([
            review_id_counter,
            order_line_id,
            delevery_rating,
            branch_rating,
            product_rating,
            customer_service_rating,
            review_date_dt.strftime('%Y-%m-%d') # Format as date string (YYYY-MM-DD)
        ])
        
        # Log generated review details for verification
        if review_id_counter % 500 == 0 or review_id_counter == 1: # Log every 500th review and the first one
            print(f"  Generated Review {review_id_counter}: Order_line_id={order_line_id}, Deliver_Date={deliver_date.strftime('%Y-%m-%d')}, Review_Date={review_date_dt.strftime('%Y-%m-%d')}")

        review_id_counter += 1

    # Sort reviews by review_date to ensure chronological IDs
    reviews.sort(key=lambda x: datetime.strptime(x[6], '%Y-%m-%d')) # Sort by the formatted date string

    # Re-assign review_id after sorting to maintain chronological IDs
    final_reviews = []
    for i, review_data in enumerate(reviews):
        review_data[0] = i + 1 # Update review_id
        final_reviews.append(review_data)

    return final_reviews

# --- Main Execution ---
if __name__ == "__main__":
    # Input CSV file paths (ensure these paths are correct for your environment)
    DELIVERY_TABLE_INPUT_PATH = 'new_delivery_table.csv'
    ORDER_LINE_TABLE_INPUT_PATH = 'order_line_table.csv'
    ORDER_TABLE_INPUT_PATH = 'order_table.csv' 
    
    # Output CSV file path
    REVIEW_TABLE_OUTPUT_PATH = 'review_table.csv'
    
    # Target number of reviews
    NUM_REVIEWS_TARGET = 2500

    print(f"Starting review table generation...")
    print(f"Current working directory: {os.getcwd()}") # Print current working directory

    print(f"Reading delivery data from {DELIVERY_TABLE_INPUT_PATH}...")
    delivery_header, delivery_data = read_csv(DELIVERY_TABLE_INPUT_PATH)
    
    print(f"Reading order line data from {ORDER_LINE_TABLE_INPUT_PATH}...")
    order_line_header, order_line_data = read_csv(ORDER_LINE_TABLE_INPUT_PATH)

    print(f"Reading order data from {ORDER_TABLE_INPUT_PATH}...") 
    order_header, order_data = read_csv(ORDER_TABLE_INPUT_PATH) 

    if not delivery_data or not order_line_data or not order_data: 
        print("Required input data not found or could not be read. Cannot generate review table.")
    else:
        print(f"Successfully read {len(delivery_data)} rows from delivery table, {len(order_line_data)} rows from order line table, and {len(order_data)} rows from order table.")

        print(f"Generating {NUM_REVIEWS_TARGET} reviews...")
        reviews_data = generate_review_table(delivery_data, order_line_data, order_data, NUM_REVIEWS_TARGET)
        review_header = ["review_id", "order_line_id", "delevery_rating", "branch_rating", "product_rating", "customer_service_rating", "review_date"]
        write_to_csv(REVIEW_TABLE_OUTPUT_PATH, review_header, reviews_data)

        print("\nProcessing complete. Check the generated 'review_table.csv' file.")
