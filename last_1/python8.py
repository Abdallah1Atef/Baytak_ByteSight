import csv
import random
from datetime import datetime, timedelta
from faker import Faker

fake = Faker()

# --- Configuration and Static Data ---

# Egyptian phone number prefixes (already include '0')
EGYPTIAN_PHONE_PREFIXES = ['010', '011', '012', '015']

# Fixed data for tables
BRANCHES_DATA = [
    {"branch_id": 100, "location_id": 2, "opening_date": datetime(2021, 2, 15)},
    {"branch_id": 200, "location_id": 5, "opening_date": datetime(2022, 6, 23)},
    {"branch_id": 300, "location_id": 8, "opening_date": datetime(2023, 9, 3)},
]

CHANNEL_DATA = [
    {"channel_id": 1, "channel_type": "Facebook"},
    {"channel_id": 2, "channel_type": "Instagram"},
    {"channel_id": 3, "channel_type": "X"},
    {"channel_id": 4, "channel_type": "TV Channels"},
    {"channel_id": 5, "channel_type": "Billboards"},
    {"channel_id": 6, "channel_type": "YouTube"},
    {"channel_id": 7, "channel_type": "TikTok"},
]

MARKETING_DATA = [
    {"Campaign_Id": 101, "start": datetime(2024, 1, 1, 9, 0), "end": datetime(2024, 4, 1, 9, 0), "market_cost": 60000}, # Added market_cost
    {"Campaign_Id": 102, "start": datetime(2024, 4, 10, 8, 0), "end": datetime(2024, 7, 10, 8, 0), "market_cost": 100000}, # Added market_cost
    {"Campaign_Id": 103, "start": datetime(2024, 7, 20, 10, 0), "end": datetime(2024, 10, 20, 10, 0), "market_cost": 80000}, # Added market_cost
    {"Campaign_Id": 104, "start": datetime(2024, 10, 1, 18, 0), "end": datetime(2025, 1, 1, 18, 0), "market_cost": 140000}, # Added market_cost
    {"Campaign_Id": 105, "start": datetime(2025, 1, 15, 0, 0), "end": datetime(2025, 4, 15, 0, 0), "market_cost": 120000}, # Added market_cost
    {"Campaign_Id": 106, "start": datetime(2025, 4, 25, 12, 0), "end": datetime(2025, 7, 25, 12, 0), "market_cost": 160000}, # Added market_cost
    {"Campaign_Id": 107, "start": datetime(2025, 5, 30, 9, 30), "end": datetime(2025, 8, 30, 9, 30), "market_cost": 200000}, # Added market_cost
]

LOCATION_DATA = [
    {"location_id": 1, "City": "Alexandria", "Region": "Sidi Gaber", "Zip_code": "6277"},
    {"location_id": 2, "City": "Alexandria", "Region": "Smouha", "Zip_code": "1398"},
    {"location_id": 3, "City": "Alexandria", "Region": "Gleem", "Zip_code": "8057"},
    {"location_id": 4, "City": "Alexandria", "Region": "Stanley", "Zip_code": "4005"},
    {"location_id": 5, "City": "Alexandria", "Region": "San Stefano", "Zip_code": "8376"},
    {"location_id": 6, "City": "Alexandria", "Region": "Roushdy", "Zip_code": "6157"},
    {"location_id": 7, "City": "Alexandria", "Region": "Miami", "Zip_code": "2174"},
    {"location_id": 8, "City": "Alexandria", "Region": "Laurent", "Zip_code": "2683"},
    {"location_id": 9, "City": "Alexandria", "Region": "El Mandara", "Zip_code": "9503"},
    {"location_id": 10, "City": "Alexandria", "Region": "Agami", "Zip_code": "7745"},
    {"location_id": 11, "City": "Alexandria", "Region": "Bolkly", "Zip_code": "1839"},
    {"location_id": 12, "City": "Alexandria", "Region": "Sporting", "Zip_code": "8125"},
    {"location_id": 13, "City": "Alexandria", "Region": "Camp Caesar", "Zip_code": "9454"},
    {"location_id": 14, "City": "Alexandria", "Region": "Shatby", "Zip_code": "5281"},
    {"location_id": 15, "City": "Alexandria", "Region": "El Ibrahimia", "Zip_code": "8612"},
]

SUPPLIERS_DATA = [
    {"supplier_id": 10, "location_id": 1, "supplier_name": "NileWood", "phone": "01038427654"},
    {"supplier_id": 20, "location_id": 9, "supplier_name": "DeltaCraft", "phone": "01267583941"},
    {"supplier_id": 30, "location_id": 10, "supplier_name": "al-sharq", "phone": "01149832760"},
]

RETURN_REASON_DATA = [
    {"reason_id": 1, "reason_details": "Damaged"},
    {"reason_id": 2, "reason_details": "Wrong Item Delivered"},
    {"reason_id": 3, "reason_details": "Does Not Match Description"},
    {"reason_id": 4, "reason_details": "Due to Delay"},
    {"reason_id": 5, "reason_details": "Defective product"},
    {"reason_id": 6, "reason_details": "Too large/small"},
]

PRODUCT_NAMES_AND_CATEGORIES = {
    "Office chair": "Office", "Large rug": "Rugs", "Bed sheets": "Bedroom",
    "Wall clock": "Decor", "Wall lamp": "Lighting", "Recliner": "Living Room",
    "Sun lounger": "Outdoor", "Sectional sofa": "Living Room", "Desk": "Office",
    "Dining bench": "Dining", "Pillow": "Bedroom", "Runner rug": "Rugs",
    "Side table": "Living Room", "Decorative mirror": "Decor", "Bedroom Sets": "Bedroom",
    "Decorative light": "Lighting", "Shelving unit": "Storage", "Hanging lamp": "Lighting",
    "Storage cabinet": "Storage", "Table clock": "Decor", "Patio chair": "Outdoor",
    "Clock": "Decor", "Accent table": "Decor", "Quilt": "Bedroom",
    "Kids’ desk": "Bedroom", "Medium rug": "Rugs", "Small rug": "Rugs",
    "Garden bench": "Outdoor", "Table lamp": "Lighting", "Crockery unit": "Dining",
    "Outdoor sofa": "Outdoor", "Kids’ dresser": "Bedroom", "Dining set (4-seater)": "Dining",
    "Pouf": "Decor", "King bed": "Bedroom", "Patio table": "Outdoor",
    "TV stand": "Living Room", "Bedside table": "Bedroom", "Loveseat": "Living Room",
    "Sideboard": "Dining", "Accent chair": "Decor", "Chest of drawers": "Bedroom",
    "File cabinet": "Office", "Coffee table": "Living Room", "Dining set (8-seater)": "Dining",
    "Coverlet": "Bedroom", "Storage Furniture": "Storage", "Sand clock": "Decor",
    "Queen bed": "Bedroom", "Twin bed": "Bedroom", "Bunk bed": "Bedroom",
    "Storage bed": "Bedroom", "Canopy bed": "Bedroom", "Dresser": "Bedroom",
    "Nightstand": "Bedroom", "Wardrobe": "Bedroom", "Armoire": "Bedroom",
    "Coat rack": "Decor", "Kids’ bed": "Bedroom", "Crib": "Bedroom",
    "Kids’ storage": "Storage", "Comforter set": "Bedroom", "Blanket": "Bedroom",
    "Throw": "Bedroom", "Pillowcase": "Bedroom", "Mattress protector": "Bedroom",
    "Round rug": "Rugs", "Floor lamp": "Lighting", "Photo frame": "Decor",
    "Poster": "Decor", "Wall art": "Decor", "Framed artwork": "Decor",
    "Dining chair": "Dining", "Buffet": "Dining", "Armchair": "Living Room",
    "Bookcase": "Office", "Console table": "Living Room",
}

# Define logical cost ranges for product categories, multiplied by 4
PRODUCT_COST_RANGES = {
    "Office": (200 * 4, 1000 * 4), "Rugs": (100 * 4, 900 * 4), "Bedroom": (50 * 4, 2500 * 4),
    "Decor": (50 * 4, 400 * 4), "Lighting": (80 * 4, 500 * 4), "Living Room": (200 * 4, 2000 * 4),
    "Outdoor": (300 * 4, 1500 * 4), "Dining": (200 * 4, 1500 * 4), "Storage": (300 * 4, 1000 * 4),
}

# Overall date range for data generation
START_DATE = datetime(2021, 2, 15) # First branch opening
END_DATE = datetime(2025, 7, 1)

# --- Helper Functions ---

def generate_egyptian_phone():
    """Generates a random Egyptian phone number, ensuring it starts with '0' and is 11 digits."""
    prefix = random.choice(EGYPTIAN_PHONE_PREFIXES)
    # Generate remaining digits to make total length 11 (prefix is 3 chars, so 8 more needed)
    number_suffix = ''.join([str(random.randint(0, 9)) for _ in range(8)])
    return prefix + number_suffix

def get_random_date_in_range(start, end):
    """Generates a random date within a given range."""
    delta = end - start
    random_days = random.randint(0, delta.days)
    return start + timedelta(days=random_days)

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

def calculate_daily_activity_weights(start_date, end_date, branches_data, marketing_data):
    """
    Calculates a weight for each day based on branch openings and marketing campaigns.
    Higher weight means more activity expected on that day.
    """
    daily_weights = {}
    current_date = start_date
    while current_date <= end_date:
        weight = 1.0 # Base weight

        # Impact of Branch Openings
        for branch in branches_data:
            if current_date.date() >= branch['opening_date'].date():
                weight += 0.5 # Each open branch adds to activity weight

        # Impact of Marketing Campaigns
        for campaign in marketing_data:
            if campaign['start'].date() <= current_date.date() <= campaign['end'].date():
                weight += 1.0 # Each active campaign adds to activity weight

        daily_weights[current_date.date()] = weight
        current_date += timedelta(days=1)

    # Normalize weights so they can be used with random.choices
    total_weight = sum(daily_weights.values())
    if total_weight > 0:
        for date, weight in daily_weights.items():
            daily_weights[date] = weight / total_weight
    else:
        # If for some reason total_weight is 0 (e.g., no dates in range), assign equal weights
        if daily_weights:
            equal_weight = 1.0 / len(daily_weights)
            for date in daily_weights:
                daily_weights[date] = equal_weight
        else:
            # Fallback for empty daily_weights (shouldn't happen with valid date range)
            pass

    return daily_weights

# --- Table Generation Functions ---

def generate_design_table():
    designs = []
    design_id = 1
    
    materials = ['Wood', 'Metal', 'Plastic', 'Glass', 'Fabric']
    styles = ['Modern', 'Classic']
    
    primary_colors = ['White', 'Black', 'Brown']
    secondary_colors = ['Red', 'Yellow', 'Maroon', 'Light Blue', 'Gray', 'Olive Green',
                        'Mint Green', 'Dark Green', 'Baby Blue', 'Royal Blue', 'Navy Blue', 'Clear']

    material_target_counts = {'Wood': 50, 'Metal': 30, 'Plastic': 15, 'Glass': 10, 'Fabric': 40}
    material_current_counts = {mat: 0 for mat in materials}

    for material in materials:
        for style in styles:
            for color in primary_colors:
                if material_current_counts[material] < material_target_counts[material]:
                    designs.append([design_id, material, style, color])
                    material_current_counts[material] += 1
                    design_id += 1
            
            num_secondary_colors = random.randint(3, 7)
            if material == 'Glass':
                glass_colors = [c for c in secondary_colors if c in ['Clear', 'Black', 'White', 'Light Blue', 'Dark Green']]
                selected_secondary = random.sample(glass_colors, min(num_secondary_colors, len(glass_colors)))
            elif material == 'Plastic':
                plastic_colors = [c for c in secondary_colors if c in ['White', 'Black', 'Gray', 'Red', 'Blue']]
                selected_secondary = random.sample(plastic_colors, min(num_secondary_colors, len(plastic_colors)))
            else:
                selected_secondary = random.sample(secondary_colors, num_secondary_colors)

            for color in selected_secondary:
                if material_current_counts[material] < material_target_counts[material]:
                    designs.append([design_id, material, style, color])
                    material_current_counts[material] += 1
                    design_id += 1
    
    for material in materials:
        while material_current_counts[material] < material_target_counts[material]:
            style = random.choice(styles)
            color = random.choice(primary_colors + secondary_colors)
            
            if material == 'Glass' and color not in ['Clear', 'Black', 'White', 'Light Blue', 'Dark Green']:
                color = random.choice(['Clear', 'Black', 'White'])
            if material == 'Plastic' and color not in ['White', 'Black', 'Gray', 'Red', 'Blue']:
                color = random.choice(['White', 'Black', 'Gray'])

            designs.append([design_id, material, style, color])
            material_current_counts[material] += 1
            design_id += 1

    random.shuffle(designs)
    for i, d in enumerate(designs):
        d[0] = i + 1

    return designs

def generate_product_table(designs_data):
    products = []
    product_id = 1
    
    design_map = {d[0]: {'material': d[1], 'style': d[2], 'color': d[3]} for d in designs_data}

    def find_suitable_design(product_category, product_name):
        suitable_designs = []
        for d_id, d_info in design_map.items():
            material = d_info['material']
            is_suitable = True
            if product_category in ["Bedroom", "Living Room", "Dining", "Office", "Storage"]:
                if material not in ['Wood', 'Metal', 'Plastic']:
                    is_suitable = False
            elif product_category == "Rugs":
                if material != 'Fabric':
                    is_suitable = False
            elif product_category == "Decor":
                if "clock" in product_name.lower() or "mirror" in product_name.lower():
                    if material == 'Fabric':
                        is_suitable = False
                elif "pouf" in product_name.lower() or "accent chair" in product_name.lower():
                    if material not in ['Fabric', 'Wood', 'Metal']:
                        is_suitable = False
            elif product_category == "Lighting":
                if material not in ['Metal', 'Plastic', 'Glass']:
                    is_suitable = False
            elif product_category == "Outdoor":
                if material not in ['Metal', 'Plastic', 'Wood']:
                    is_suitable = False
            
            if any(kw in product_name.lower() for kw in ["bed", "dresser", "nightstand", "wardrobe", "armoire", "desk", "table", "chair", "sofa", "bench", "cabinet", "shelving", "unit", "stand", "buffet", "sideboard", "bookcase", "console"]):
                if material == 'Glass':
                    is_suitable = False
            
            if any(kw in product_name.lower() for kw in ["pillow", "quilt", "coverlet", "sheets", "blanket", "throw", "comforter", "mattress protector"]):
                if material != 'Fabric':
                    is_suitable = False
            
            if "rug" in product_name.lower():
                if material != 'Fabric':
                    is_suitable = False

            if is_suitable:
                suitable_designs.append(d_id)
        
        return random.choice(suitable_designs) if suitable_designs else None

    for p_name, p_category in PRODUCT_NAMES_AND_CATEGORIES.items():
        cost_min, cost_max = PRODUCT_COST_RANGES.get(p_category, (50, 1000))
        cost = round(random.uniform(cost_min, cost_max), 2)
        sale_price = round(cost * random.uniform(1.5, 1.7), 2)
        
        start_date = get_random_date_in_range(START_DATE, END_DATE)
        
        design_id = find_suitable_design(p_category, p_name)
        if design_id is None:
            design_id = random.choice(list(design_map.keys()))

        products.append([
            product_id, design_id, p_category, p_name,
            start_date.strftime('%Y-%m-%d'), sale_price, cost
        ])
        product_id += 1
    
    return products

def generate_customer_table(num_customers, daily_weights_map):
    customers_raw = []
    dates = list(daily_weights_map.keys())
    weights = list(daily_weights_map.values())

    for _ in range(num_customers):
        # Choose a signup date based on daily activity weights
        signup_date = random.choices(dates, weights=weights, k=1)[0]

        if random.random() < 0.75:
            age = random.randint(18, 35)
        else:
            age = random.randint(36, 60)
        
        gender = random.choice(['Male', 'Female'])
        phone = generate_egyptian_phone()
        
        location_id = random.choice([loc['location_id'] for loc in LOCATION_DATA])
        channel_id = random.choice([ch['channel_id'] for ch in CHANNEL_DATA])
        
        customers_raw.append({
            "location_id": location_id,
            "channel_id": channel_id,
            "Age": age,
            "Gender": gender,
            "Phone": phone,
            "SignUpDate": signup_date # Keep as date object for sorting
        })
    
    customers_raw.sort(key=lambda x: x["SignUpDate"])

    customers = []
    for i, customer_data in enumerate(customers_raw):
        customers.append([
            i + 1, # customer_id (chronological)
            customer_data["location_id"],
            customer_data["channel_id"],
            customer_data["Age"],
            customer_data["Gender"],
            customer_data["Phone"],
            customer_data["SignUpDate"].strftime('%Y-%m-%d') # Format date without time
        ])
    return customers

def generate_leads_table(num_leads):
    leads_raw = []
    
    for _ in range(num_leads):
        phone = generate_egyptian_phone()
        gender = random.choice(['Male', 'Female'])
        
        lead_datetime = get_random_date_in_range(START_DATE, END_DATE)
        
        leads_raw.append({
            "phone": phone,
            "gender": gender,
            "datetime": lead_datetime # Keep as datetime object for sorting
        })
    
    leads_raw.sort(key=lambda x: x["datetime"])

    leads = []
    for i, lead_data in enumerate(leads_raw):
        leads.append([
            i + 1, # leads_id (chronological)
            lead_data["phone"],
            lead_data["gender"],
            lead_data["datetime"].strftime('%Y-%m-%d') # Format date without time
        ])
    return leads

def generate_order_table(num_orders, customers_data, daily_weights_map):
    orders_raw = []
    customer_signup_dates = {c[0]: datetime.strptime(c[6], '%Y-%m-%d').date() for c in customers_data}

    dates = list(daily_weights_map.keys())
    weights = list(daily_weights_map.values())

    for _ in range(num_orders):
        # Choose an order date based on daily activity weights
        order_date_chosen = random.choices(dates, weights=weights, k=1)[0]

        available_branches = [b for b in BRANCHES_DATA if b['opening_date'].date() <= order_date_chosen]
        if not available_branches:
            continue
        branch = random.choice(available_branches)
        
        eligible_customers = [
            cid for cid, sdate in customer_signup_dates.items()
            if sdate <= order_date_chosen
        ]
        
        if not eligible_customers:
            continue
        customer_id = random.choice(eligible_customers)
        
        order_time_of_day = fake.time_object()
        order_datetime = datetime.combine(order_date_chosen, order_time_of_day)
        
        payment_method = random.choice(['Cash', 'Debit Card'])
        
        orders_raw.append({
            "branch_id": branch['branch_id'],
            "customer_id": customer_id,
            "time": order_datetime,
            "payment_method": payment_method
        })
    
    orders_raw.sort(key=lambda x: x["time"])

    orders = []
    for i, order_data in enumerate(orders_raw):
        orders.append([
            i + 1, # Order_id (chronological)
            order_data["branch_id"],
            order_data["customer_id"],
            order_data["time"].strftime('%Y-%m-%d %H:%M:%S'), # Format with time
            order_data["payment_method"]
        ])
    return orders

def generate_delivery_table(orders_data, num_delayed_deliveries=150):
    deliveries = []
    
    # Get all order IDs and shuffle them to pick random ones for delay
    all_order_ids = [order[0] for order in orders_data]
    random.shuffle(all_order_ids)
    
    # Select a subset of order IDs to be delayed
    delayed_order_ids = set(all_order_ids[:min(num_delayed_deliveries, len(all_order_ids))])

    for order in orders_data:
        order_id = order[0]
        order_datetime = datetime.strptime(order[3], '%Y-%m-%d %H:%M:%S')
        
        # Scheduled delivery date: 2-7 days after order
        scheduled_deliver_date = order_datetime + timedelta(days=random.randint(2, 7))
        
        deliver_date = scheduled_deliver_date # Default: no delay

        if order_id in delayed_order_ids:
            # Apply a delay for selected orders (1 to 10 days after scheduled)
            delay_days = random.randint(1, 10)
            deliver_date = scheduled_deliver_date + timedelta(days=delay_days)
        
        deliveries.append([
            order_id,
            scheduled_deliver_date.strftime('%Y-%m-%d'),
            deliver_date.strftime('%Y-%m-%d')
        ])
    return deliveries

def generate_discount_table(products_data):
    discounts_raw = []
    percentages = [10, 15, 20, 25, 30, 35, 40]
    
    all_product_ids = [p[0] for p in products_data]
    
    for percent in percentages:
        for _ in range(5):
            product_id = random.choice(all_product_ids)
            
            start_time = get_random_date_in_range(START_DATE, END_DATE - timedelta(days=60))
            end_time = start_time + timedelta(days=random.randint(10, 20))

            discounts_raw.append({
                "product_id": product_id,
                "start_time": start_time,
                "end_time": end_time,
                "dis_precent": percent
            })
    
    discounts_raw.sort(key=lambda x: x["start_time"])

    discounts = []
    for i, discount_data in enumerate(discounts_raw):
        discounts.append([
            i + 1, # dis_id (chronological)
            discount_data["product_id"],
            discount_data["start_time"].strftime('%Y-%m-%d %H:%M:%S'), # Retain time for discounts
            discount_data["end_time"].strftime('%Y-%m-%d %H:%M:%S'), # Retain time for discounts
            discount_data["dis_precent"]
        ])
    return discounts

def generate_order_line_table(num_order_lines, orders_data, products_data, discounts_data):
    order_lines_raw = []
    
    product_details = {p[0]: {'sale_price': p[5], 'design_id': p[1]} for p in products_data}
    all_product_ids = [p[0] for p in products_data]

    discount_lookup_by_product = {}
    for d in discounts_data:
        prod_id = d[1]
        if prod_id not in discount_lookup_by_product:
            discount_lookup_by_product[prod_id] = []
        discount_lookup_by_product[prod_id].append({
            'dis_id': d[0],
            'start_time': datetime.strptime(d[2], '%Y-%m-%d %H:%M:%S'),
            'end_time': datetime.strptime(d[3], '%Y-%m-%d %H:%M:%S'),
            'percent': d[4]
        })

    sorted_orders = orders_data
    
    order_line_counter = 0
    for order in sorted_orders:
        order_id = order[0]
        order_time = datetime.strptime(order[3], '%Y-%m-%d %H:%M:%S')
        
        products_in_this_order = set()
        
        num_unique_products_in_order = random.randint(1, 5)
        
        remaining_order_lines_needed = num_order_lines - order_line_counter
        if remaining_order_lines_needed <= 0:
            break
        
        remaining_orders_count = len(sorted_orders) - sorted_orders.index(order)
        if remaining_orders_count > 0:
            avg_lines_per_remaining_order = remaining_order_lines_needed / remaining_orders_count
            num_unique_products_in_order = int(max(1, min(15, round(avg_lines_per_remaining_order))))

        current_available_products = [p_id for p_id in all_product_ids if p_id not in products_in_this_order]
        if not current_available_products:
            break

        eligible_discounted_products = []
        for prod_id in current_available_products:
            if prod_id in discount_lookup_by_product:
                for disc_info in discount_lookup_by_product[prod_id]:
                    if disc_info['start_time'] <= order_time <= disc_info['end_time']:
                        eligible_discounted_products.append((prod_id, disc_info['dis_id']))
                        break
        
        if eligible_discounted_products and random.random() < 0.7:
            chosen_product_id, active_discount_for_this_product = random.choice(eligible_discounted_products)
        else:
            chosen_product_id = random.choice(current_available_products)
            active_discount_for_this_product = None
        
        products_in_this_order.add(chosen_product_id)

        quantity = random.randint(1, 5)
        if random.random() < 0.1:
            quantity = random.randint(6, 10)
        
        design_id = product_details[chosen_product_id]['design_id']

        order_lines_raw.append({
            "product_id": chosen_product_id,
            "Order_id": order_id,
            "quantity": quantity,
            "dis_id": active_discount_for_this_product,
            "design_id": design_id,
            "order_time": order_time # Use order_time for implicit chronological sorting
        })
        order_line_counter += 1
            
    order_lines_raw.sort(key=lambda x: (x["order_time"], x["product_id"]))

    order_lines = []
    for i, ol_data in enumerate(order_lines_raw):
        order_lines.append([
            i + 1, # Order_line_id (chronological)
            ol_data["product_id"],
            ol_data["Order_id"],
            ol_data["quantity"],
            ol_data["dis_id"],
            ol_data["design_id"]
        ])
    return order_lines

def generate_branch_visits_log_table(num_visits, customers_data, leads_data, daily_weights_map):
    visits_raw = []
    customer_signup_dates = {c[0]: datetime.strptime(c[6], '%Y-%m-%d').date() for c in customers_data}
    lead_datetimes = {l[0]: datetime.strptime(l[3], '%Y-%m-%d').date() for l in leads_data}

    branch_ids = [b['branch_id'] for b in BRANCHES_DATA]

    dates = list(daily_weights_map.keys())
    weights = list(daily_weights_map.values())

    for _ in range(num_visits):
        # Choose a visit date based on daily activity weights
        visit_date_chosen = random.choices(dates, weights=weights, k=1)[0]
        visit_time_of_day = fake.time_object()
        visit_datetime = datetime.combine(visit_date_chosen, visit_time_of_day)

        customer_id = None
        lead_id = None
        
        eligible_customers_for_visit = [
            cid for cid, sdate in customer_signup_dates.items()
            if sdate <= visit_date_chosen
        ]
        eligible_leads_for_visit = [
            lid for lid, ldt in lead_datetimes.items()
            if ldt <= visit_date_chosen
        ]

        if not eligible_customers_for_visit and not eligible_leads_for_visit:
            continue

        if random.random() < 0.7 and eligible_customers_for_visit:
            customer_id = random.choice(eligible_customers_for_visit)
        elif eligible_leads_for_visit:
            lead_id = random.choice(eligible_leads_for_visit)
        else:
            if eligible_customers_for_visit:
                customer_id = random.choice(eligible_customers_for_visit)
            else:
                continue

        visits_raw.append({
            "branch_id": random.choice(branch_ids),
            "customer_id": customer_id,
            "lead_id": lead_id,
            "visit_time": visit_datetime # Retain time for branch visits
        })

    visits_raw.sort(key=lambda x: x["visit_time"])

    visits = []
    for i, visit_data in enumerate(visits_raw):
        visits.append([
            i + 1, # visit_id (chronological)
            visit_data["branch_id"],
            visit_data["customer_id"],
            visit_data["lead_id"],
            visit_data["visit_time"].strftime('%Y-%m-%d %H:%M:%S') # Format with time
        ])
    return visits

def generate_return_table(deliveries_data, return_reason_data, num_returns=200, num_delayed_returns_to_link=120):
    returns = []
    return_id_counter = 1

    reason_details_map = {r['reason_id']: r['reason_details'] for r in return_reason_data}

    delayed_orders = []
    non_delayed_orders = []

    for order_id, scheduled_date_str, actual_date_str in deliveries_data:
        scheduled_date = datetime.strptime(scheduled_date_str, '%Y-%m-%d')
        actual_date = datetime.strptime(actual_date_str, '%Y-%m-%d')
        if actual_date > scheduled_date:
            delayed_orders.append(order_id)
        else:
            non_delayed_orders.append(order_id)

    # Ensure we don't try to sample more delayed orders than available
    if len(delayed_orders) < num_delayed_returns_to_link:
        print(f"Warning: Not enough delayed orders ({len(delayed_orders)}) to link {num_delayed_returns_to_link} returns to delay reason. Linking all available delayed orders.")
        num_delayed_returns_to_link = len(delayed_orders)

    # Randomly select orders to link to "Due to Delay" reason
    linked_delayed_orders = random.sample(delayed_orders, num_delayed_returns_to_link)

    for order_id in linked_delayed_orders:
        delivery_record = next((d for d in deliveries_data if d[0] == order_id), None)
        if delivery_record:
            actual_delivery_date = datetime.strptime(delivery_record[2], '%Y-%m-%d')
            return_date = actual_delivery_date + timedelta(days=random.randint(1, 5)) # Return soon after delivery
            returns.append([
                return_id_counter,
                order_id,
                return_date.strftime('%Y-%m-%d'),
                4 # reason_id for "Due to Delay"
            ])
            return_id_counter += 1

    # Generate remaining returns with other reasons
    remaining_returns_count = num_returns - len(returns)
    if remaining_returns_count < 0:
        remaining_returns_count = 0

    # Get all order IDs that haven't been linked to a delayed return
    all_available_order_ids = [d[0] for d in deliveries_data]
    unlinked_order_ids = [oid for oid in all_available_order_ids if oid not in linked_delayed_orders]

    # Filter out reason_id 4 for other returns
    other_reason_ids = [r['reason_id'] for r in return_reason_data if r['reason_id'] != 4]

    for _ in range(remaining_returns_count):
        if not unlinked_order_ids:
            # If we run out of unlinked orders, reuse from all available orders
            unlinked_order_ids = list(all_available_order_ids)
            if not unlinked_order_ids:
                break

        order_id = random.choice(unlinked_order_ids)
        # Remove the chosen order_id to avoid immediate duplicates if possible
        if order_id in unlinked_order_ids:
            unlinked_order_ids.remove(order_id)

        delivery_record = next((d for d in deliveries_data if d[0] == order_id), None)
        if delivery_record:
            actual_delivery_date = datetime.strptime(delivery_record[2], '%Y-%m-%d')
            return_date = actual_delivery_date + timedelta(days=random.randint(1, 10)) # Return within 1-10 days
            reason_id = random.choice(other_reason_ids)
            returns.append([
                return_id_counter,
                order_id,
                return_date.strftime('%Y-%m-%d'),
                reason_id
            ])
            return_id_counter += 1

    return returns

# --- Main Data Generation and File Output ---

if __name__ == "__main__":
    # Define the number of rows for each table
    NUM_CUSTOMERS = 3000
    NUM_LEADS = 1000
    NUM_ORDERS = 10000
    NUM_ORDER_LINES = 15000
    NUM_BRANCH_VISITS = 15000 # Increased to 15000 as requested

    print("Generating data...")

    # Calculate daily activity weights based on branches and marketing campaigns
    daily_weights = calculate_daily_activity_weights(START_DATE, END_DATE, BRANCHES_DATA, MARKETING_DATA)

    # 1. Generate Design Table
    designs_data = generate_design_table()
    write_to_csv('design_table.csv', ["design_id", "material", "style", "color"], designs_data)

    # 2. Generate Product Table
    products_data = generate_product_table(designs_data)
    write_to_csv('product_table.csv', ["product_id", "design_id", "category", "product_name", "start_date", "sale_price", "cost"], products_data)

    # 3. Generate Customer Table
    customers_data = generate_customer_table(NUM_CUSTOMERS, daily_weights)
    write_to_csv('customer_table.csv', ["customer_id", "location_id", "ChannelID", "Age", "Gender", "Phone", "RegisterDate"], customers_data)

    # 4. Generate Leads Table
    leads_data = generate_leads_table(NUM_LEADS)
    write_to_csv('leads_table.csv', ["leads_id", "phone", "gender", "datetime"], leads_data)

    # 5. Generate Order Table
    orders_data = generate_order_table(NUM_ORDERS, customers_data, daily_weights)
    write_to_csv('order_table.csv', ["Order_id", "branch_id", "customer_id", "time", "payment_method"], orders_data)

    # 6. Generate Delivery Table
    deliveries_data = generate_delivery_table(orders_data, num_delayed_deliveries=150) # Pass the number of delayed deliveries
    write_to_csv('delivery_table.csv', ["Order_id", "scheduled_deliver_date", "deliver_date"], deliveries_data)

    # 7. Generate Discount Table
    discounts_data = generate_discount_table(products_data)
    write_to_csv('discount_table.csv', ["dis_id", "product_id", "start_time", "end_time", "dis_precent"], discounts_data)

    # 8. Generate Order Line Table
    order_lines_data = generate_order_line_table(NUM_ORDER_LINES, orders_data, products_data, discounts_data)
    write_to_csv('order_line_table.csv', ["Order_line_id", "product_id", "Order_id", "quantity", "dis_id", "design_id"], order_lines_data)

    # 9. Generate Branch Visits Log Table
    branch_visits_data = generate_branch_visits_log_table(NUM_BRANCH_VISITS, customers_data, leads_data, daily_weights)
    write_to_csv('branch_visits_log_table.csv', ["visit_id", "branch_id", "customer_id", "lead_id", "visit_time"], branch_visits_data)

    # 10. Generate Location Table (static data)
    location_header = ["location_id", "City", "Region", "Zip_code"]
    location_rows = [[loc["location_id"], loc["City"], loc["Region"], loc["Zip_code"]] for loc in LOCATION_DATA]
    write_to_csv('location_table.csv', location_header, location_rows)

    # 11. Generate Channel Table (static data)
    channel_header = ["channel_id", "channel_type"]
    channel_rows = [[ch["channel_id"], ch["channel_type"]] for ch in CHANNEL_DATA]
    write_to_csv('channel_table.csv', channel_header, channel_rows)

    # 12. Generate Marketing Table (static data)
    marketing_header = ["Campaign_Id", "start", "end", "market_cost"] # Added market_cost to header
    marketing_rows = [[m["Campaign_Id"], m["start"].strftime('%Y-%m-%d %H:%M:%S'), m["end"].strftime('%Y-%m-%d %H:%M:%S'), m["market_cost"]] for m in MARKETING_DATA] # Included market_cost in rows
    write_to_csv('marketing_table.csv', marketing_header, marketing_rows)

    # 13. Generate Branches Table (static data)
    branches_header = ["branch_id", "location_id", "opening_date"]
    branches_rows = [[b["branch_id"], b["location_id"], b["opening_date"].strftime('%Y-%m-%d')] for b in BRANCHES_DATA]
    write_to_csv('branches_table.csv', branches_header, branches_rows)

    # 14. Generate Suppliers Table (static data)
    suppliers_header = ["supplier_id", "location_id", "supplier_name", "phone"]
    suppliers_rows = [[s["supplier_id"], s["location_id"], s["supplier_name"], s["phone"]] for s in SUPPLIERS_DATA]
    write_to_csv('suppliers_table.csv', suppliers_header, suppliers_rows)

    # 15. Generate Return Reason Table (static data)
    return_reason_header = ["reason_id", "reason_details"]
    return_reason_rows = [[r["reason_id"], r["reason_details"]] for r in RETURN_REASON_DATA]
    write_to_csv('return_reason_table.csv', return_reason_header, return_reason_rows)

    # 16. Generate Return Table (dynamic data, linked to deliveries)
    returns_data = generate_return_table(deliveries_data, RETURN_REASON_DATA)
    write_to_csv('return_table.csv', ["return_id", "order_id", "return_date", "reason_id"], returns_data)

    print("\nAll tables generated successfully!")
    print("The 'order_table.csv' generated by this script will have customer IDs based on the new logic.")
    print("You can find the generated CSV files in the same directory as this script.")
