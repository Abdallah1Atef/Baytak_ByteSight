import pandas as pd
import random
from datetime import datetime, timedelta

# --- 1. Define Table Schemas and Data ---

# BRANCHES Table
# branch_id, location_id, opening_date
branches_data = [
    {'branch_id': 100, 'location_id': 2, 'opening_date': '15/2/2021'},
    {'branch_id': 200, 'location_id': 5, 'opening_date': '23/6/2022'},
    {'branch_id': 300, 'location_id': 8, 'opening_date': '3/9/2023'},
]
df_branches = pd.DataFrame(branches_data)
df_branches['opening_date'] = pd.to_datetime(df_branches['opening_date'], format='%d/%m/%Y')

# CAMPAIGNS Table
# Campaign_ID, start_date, end_date, market_cost
campaigns_data = [
    {'Campaign_ID': 101, 'start_date': '1/1/2024', 'end_date': '4/1/2024', 'market_cost': '60,000'},
    {'Campaign_ID': 102, 'start_date': '4/10/2024', 'end_date': '7/10/2024', 'market_cost': '70,000'},
    {'Campaign_ID': 103, 'start_date': '7/20/2024', 'end_date': '10/20/2024', 'market_cost': '80,000'},
    {'Campaign_ID': 104, 'start_date': '10/1/2024', 'end_date': '1/1/2025', 'market_cost': '120,000'},
    {'Campaign_ID': 105, 'start_date': '1/15/2025', 'end_date': '4/15/2025', 'market_cost': '140,000'},
    {'Campaign_ID': 106, 'start_date': '4/25/2025', 'end_date': '7/25/2025', 'market_cost': '160,000'},
    {'Campaign_ID': 107, 'start_date': '5/30/2025', 'end_date': '8/30/2025', 'market_cost': '200,000'},
]
df_campaigns = pd.DataFrame(campaigns_data)
df_campaigns['start_date'] = pd.to_datetime(df_campaigns['start_date'], format='%m/%d/%Y')
df_campaigns['end_date'] = pd.to_datetime(df_campaigns['end_date'], format='%m/%d/%Y')
df_campaigns['market_cost'] = df_campaigns['market_cost'].str.replace(',', '').astype(int)

# LEADS Table structure (will be populated dynamically)
# leads_id, phone, gender, datetime

# --- 2. Simulation Parameters ---
# These parameters are tuned to generate approximately 1000 leads across the entire simulation period
INITIAL_BASE_LEADS_PER_DAY = 0.25 # Base leads per day (can be fractional)
LEADS_PER_BRANCH_OPENING = 0.05   # Permanent daily increase from a new branch
LEADS_PER_ACTIVE_CAMPAIGN_DAY = 0.5 # Temporary daily increase during a campaign
CAMPAIGN_RESIDUAL_FACTOR = 0.15 # Percentage of campaign boost that becomes permanent after it ends

# Determine simulation period
simulation_start_date = min(df_branches['opening_date'].min(), df_campaigns['start_date'].min())
simulation_end_date = datetime(2025, 8, 1) # User specified end date

all_leads = []
leads_id_counter = 1
permanent_daily_boost = 0.0 # Cumulative permanent boost from branches and past campaigns (can be float)
accumulated_fractional_leads = 0.0 # To handle fractional leads and ensure total count is accurate

# --- 3. Leads Generation Logic ---
current_date = simulation_start_date
# Loop now runs until the simulation_end_date is reached
while current_date <= simulation_end_date:
    # Check for new branch openings on this day and apply permanent boost
    for _, branch in df_branches.iterrows():
        if current_date == branch['opening_date']:
            permanent_daily_boost += LEADS_PER_BRANCH_OPENING

    # Check for campaigns ending yesterday and apply residual permanent boost
    for _, campaign in df_campaigns.iterrows():
        if current_date == campaign['end_date'] + timedelta(days=1):
            permanent_daily_boost += LEADS_PER_ACTIVE_CAMPAIGN_DAY * CAMPAIGN_RESIDUAL_FACTOR

    # Calculate base leads for the day including permanent boosts
    daily_leads_rate = INITIAL_BASE_LEADS_PER_DAY + permanent_daily_boost

    # Add temporary leads from active campaigns for this day
    for _, campaign in df_campaigns.iterrows():
        if campaign['start_date'] <= current_date <= campaign['end_date']:
            daily_leads_rate += LEADS_PER_ACTIVE_CAMPAIGN_DAY

    # Accumulate fractional leads and determine integer leads to generate today
    accumulated_fractional_leads += daily_leads_rate
    num_leads_to_generate = int(accumulated_fractional_leads)
    accumulated_fractional_leads -= num_leads_to_generate # Subtract generated integer part

    # Generate individual lead records for the day
    for _ in range(num_leads_to_generate):
        # Generate random phone number (simple 10-digit string)
        phone = ''.join([str(random.randint(0, 9)) for _ in range(10)])
        
        # Random gender: now 'Female' is twice as likely as 'Male'
        gender = random.choice(['Male', 'Female', 'Female'])
        
        # Date: now only the date part without time
        date_only = current_date.date()
        
        all_leads.append({
            'leads_id': leads_id_counter,
            'phone': phone,
            'gender': gender,
            'datetime': date_only # Storing only the date
        })
        leads_id_counter += 1
    
    current_date += timedelta(days=1)

df_leads = pd.DataFrame(all_leads)

# This line is removed to allow the simulation to run for the full duration
# df_leads = df_leads.head(1000)

# If the simulation generates slightly more than 1000 due to fractional accumulation,
# we can trim it here to ensure it's exactly 1000 if needed, but the tuning aims for ~1000
# by the end date without a hard cap during generation.
# If you need *exactly* 1000, uncomment the line below. It will then be 1000 leads,
# but the last lead's date might be slightly before 2025-08-01 if 1000 is hit early.
# For the current request, the goal is to reach *around* 1000 by 2025-08-01.
# If len(df_leads) > 1000:
#     df_leads = df_leads.head(1000)


# --- 4. Save to CSV Files ---
df_leads.to_csv('leads.csv', index=False)
df_branches.to_csv('branches.csv', index=False)
df_campaigns.to_csv('campaigns.csv', index=False)

print("Data generation complete!")
print(f"Generated {len(df_leads)} leads records.")
print("Files saved: leads.csv, branches.csv, campaigns.csv")

# Display a sample of the generated leads
print("\nSample of Generated Leads:")
print(df_leads.head())
