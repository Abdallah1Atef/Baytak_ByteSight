import csv
import random
from datetime import datetime, timedelta
import os # Import the os module

# Static data for return reasons (as in your original script)
RETURN_REASON_DATA = [
    {"reason_id": 1, "reason_details": "Damaged"},
    {"reason_id": 2, "reason_details": "Wrong Item Delivered"},
    {"reason_id": 3, "reason_details": "Does Not Match Description"},
    {"reason_id": 4, "reason_details": "Due to Delay"},
]

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

def generate_delivery_table_new(orders_data, num_explicitly_delayed_for_returns=120, num_total_delayed_deliveries=150):
    """
    Generates a delivery table based on new rules for scheduled and actual delivery dates.
    Identifies orders that are explicitly delayed for return linking, and other delayed orders.

    Args:
        orders_data (list): List of lists, representing rows from the order table.
        num_explicitly_delayed_for_returns (int): The number of orders that should be
                                                  explicitly delayed to be linked to returns (reason_id 4).
        num_total_delayed_deliveries (int): The total number of orders that should have a deliver_date
                                            later than scheduled_deliver_date.

    Returns:
        tuple: A tuple containing:
            - list: The generated delivery data.
            - set: A set of order_ids that were explicitly delayed for return linking.
    """
    deliveries = []
    explicitly_delayed_order_ids_for_returns = set() # To store order_ids that are explicitly delayed for returns
    
    # Get all order IDs from the input data and shuffle them
    all_order_ids = [int(order_row[0]) for order_row in orders_data if order_row[0].isdigit()]
    random.shuffle(all_order_ids)
    
    # Ensure targets are not more than available orders
    num_explicitly_delayed_for_returns = min(num_explicitly_delayed_for_returns, len(all_order_ids))
    num_total_delayed_deliveries = min(num_total_delayed_deliveries, len(all_order_ids))

    # Select orders for explicit delay and return linking
    selected_explicitly_delayed_ids = set(all_order_ids[:num_explicitly_delayed_for_returns])
    
    # Get remaining order IDs for other delays or early deliveries
    remaining_order_ids_for_other_delays = [oid for oid in all_order_ids if oid not in selected_explicitly_delayed_ids]
    random.shuffle(remaining_order_ids_for_other_delays) # Shuffle again for fair selection

    # Select additional orders for delay (not linked to specific return reason)
    num_additional_delays = max(0, num_total_delayed_deliveries - num_explicitly_delayed_for_returns)
    selected_other_delayed_ids = set(remaining_order_ids_for_other_delays[:min(num_additional_delays, len(remaining_order_ids_for_other_delays))])

    for order_row in orders_data:
        order_id_str = order_row[0]
        if not order_id_str.isdigit():
            # print(f"Skipping row due to invalid Order_id: {order_row}") # Can uncomment for debugging
            continue
        order_id = int(order_id_str)
        
        order_date_str = order_row[3]
        order_datetime = None
        try:
            order_datetime = datetime.strptime(order_date_str, '%Y-%m-%d %H:%M:%S')
        except ValueError:
            try:
                order_datetime = datetime.strptime(order_date_str, '%m/%d/%Y')
            except ValueError as e:
                # print(f"Error parsing date '{order_date_str}' for order_id {order_id}: {e}") # Can uncomment for debugging
                continue

        # Determine scheduled_deliver_date
        delay_range_days = random.randint(20, 30)
        if random.random() < 0.1: # 10% chance for special case (30 to 50 days)
            delay_range_days = random.randint(30, 50)
        
        scheduled_deliver_date = order_datetime + timedelta(days=delay_range_days)
        
        # Determine deliver_date
        deliver_date = scheduled_deliver_date # Default to scheduled

        if order_id in selected_explicitly_delayed_ids:
            # For orders explicitly chosen to be delayed for return linking
            delay_days_actual = random.randint(1, 10) # 1 to 10 days delay
            deliver_date = scheduled_deliver_date + timedelta(days=delay_days_actual)
            explicitly_delayed_order_ids_for_returns.add(order_id) # Mark as actually delayed
        elif order_id in selected_other_delayed_ids:
            # For other orders chosen to be delayed (not linked to specific return reason)
            delay_days_actual = random.randint(1, 10) # 1 to 10 days delay
            deliver_date = scheduled_deliver_date + timedelta(days=delay_days_actual)
        else:
            # For other orders, deliver early or on time
            early_days = random.randint(0, 3) # 0 to 3 days early
            deliver_date = scheduled_deliver_date - timedelta(days=early_days)
            # Ensure deliver_date is not before order_datetime
            if deliver_date < order_datetime:
                deliver_date = order_datetime

        deliveries.append([
            order_id,
            scheduled_deliver_date.strftime('%Y-%m-%d'),
            deliver_date.strftime('%Y-%m-%d')
        ])
    
    deliveries.sort(key=lambda x: x[0])

    return deliveries, explicitly_delayed_order_ids_for_returns

def generate_return_table_new(deliveries_data, explicitly_delayed_order_ids_for_returns, total_returns_target=200):
    """
    Generates a return table, ensuring specific delayed orders are linked to the 'Due to Delay' reason.
    
    Args:
        deliveries_data (list): The generated delivery data (list of lists).
        explicitly_delayed_order_ids_for_returns (set): Set of order_ids that were explicitly delayed
                                                        and should be linked to reason_id 4.
        total_returns_target (int): The total number of returns to generate.

    Returns:
        list: The generated return data.
    """
    returns = []
    return_id_counter = 1

    # Create a map for quick lookup of delivery dates by order_id
    delivery_date_map = {d[0]: datetime.strptime(d[2], '%Y-%m-%d') for d in deliveries_data}

    # Filter out reason_id 4 for other returns
    other_reason_ids = [r['reason_id'] for r in RETURN_REASON_DATA if r['reason_id'] != 4]
    
    # First, generate returns for the explicitly delayed orders, linking them to reason_id 4
    # Ensure we only process unique order IDs to avoid duplicate returns for the same order
    processed_order_ids = set()
    for order_id in explicitly_delayed_order_ids_for_returns:
        if order_id in delivery_date_map and order_id not in processed_order_ids:
            actual_delivery_date = delivery_date_map[order_id]
            return_date = actual_delivery_date + timedelta(days=random.randint(1, 5)) # Return soon after delivery
            returns.append([
                return_id_counter,
                order_id,
                return_date.strftime('%Y-%m-%d'),
                4 # reason_id for "Due to Delay"
            ])
            return_id_counter += 1
            processed_order_ids.add(order_id)
    
    # Now, generate additional returns for other orders with other reasons
    remaining_returns_count = total_returns_target - len(returns)
    if remaining_returns_count < 0:
        remaining_returns_count = 0

    # Get all order IDs that haven't been linked to a delayed return
    all_available_order_ids = [d[0] for d in deliveries_data]
    unlinked_order_ids = [oid for oid in all_available_order_ids if oid not in processed_order_ids]
    random.shuffle(unlinked_order_ids) # Shuffle to pick randomly for the remaining returns

    for _ in range(remaining_returns_count):
        if not unlinked_order_ids:
            break # No more unlinked orders to generate returns from

        order_id = unlinked_order_ids.pop(0) # Get and remove an order_id to avoid duplicates for this loop

        if order_id in delivery_date_map:
            actual_delivery_date = delivery_date_map[order_id]
            return_date = actual_delivery_date + timedelta(days=random.randint(1, 10)) # Return within 1-10 days
            reason_id = random.choice(other_reason_ids)
            returns.append([
                return_id_counter,
                order_id,
                return_date.strftime('%Y-%m-%d'),
                reason_id
            ])
            return_id_counter += 1

    # Sort returns by return_id for consistency
    returns.sort(key=lambda x: x[0])
    return returns

# --- Main Execution ---
if __name__ == "__main__":
    # Path to the provided order table CSV
    ORDER_TABLE_CSV_PATH = 'order_table.csv' # Or provide an absolute path like 'C:/Users/YourUser/Documents/07_order_table.csv'
    DELIVERY_TABLE_OUTPUT_PATH = 'new_delivery_table.csv' # Or provide an absolute path
    RETURN_TABLE_OUTPUT_PATH = 'new_return_table.csv' # Or provide an absolute path
    
    # Number of orders to explicitly delay for linking to return reason 'Due to Delay'
    NUM_DELAYED_FOR_RETURNS = 120
    # Total number of delayed deliveries (including those linked to returns)
    NUM_TOTAL_DELAYED_DELIVERIES = 150
    # Total number of returns to generate (can be adjusted)
    TOTAL_RETURNS_TARGET = 200

    print(f"Starting data generation for delivery and return tables...")
    print(f"Current working directory: {os.getcwd()}") # Print current working directory
    print(f"Reading order data from {ORDER_TABLE_CSV_PATH}...")
    order_header, order_data = read_csv(ORDER_TABLE_CSV_PATH)
    
    if not order_data:
        print("No order data found or an error occurred. Cannot generate delivery and return tables.")
    else:
        print(f"Successfully read {len(order_data)} rows from {ORDER_TABLE_CSV_PATH}.")

        # Generate the new delivery table
        print(f"Generating new delivery table with {NUM_TOTAL_DELAYED_DELIVERIES} total delayed orders ({NUM_DELAYED_FOR_RETURNS} explicitly for returns)...")
        deliveries_data, explicitly_delayed_order_ids = generate_delivery_table_new(order_data, NUM_DELAYED_FOR_RETURNS, NUM_TOTAL_DELAYED_DELIVERIES)
        delivery_header = ["Order_id", "scheduled_deliver_date", "deliver_date"]
        write_to_csv(DELIVERY_TABLE_OUTPUT_PATH, delivery_header, deliveries_data)

        # Generate the new return table, linking to the explicitly delayed orders
        print(f"Generating new return table with a target of {TOTAL_RETURNS_TARGET} returns...")
        returns_data = generate_return_table_new(deliveries_data, explicitly_delayed_order_ids, TOTAL_RETURNS_TARGET)
        return_header = ["return_id", "order_id", "return_date", "reason_id"]
        write_to_csv(RETURN_TABLE_OUTPUT_PATH, return_header, returns_data)

        print("\nProcessing complete. Check the generated 'new_delivery_table.csv' and 'new_return_table.csv' files.")
