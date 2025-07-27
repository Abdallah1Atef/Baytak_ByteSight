USE Baytak;
GO

-- Temporarily disable all foreign key constraints before data insertion
-- This allows data to be loaded even if some foreign key references are not yet valid.
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
GO

-- Drop all staging tables to ensure a clean slate for each run
DROP TABLE IF EXISTS CUSTOMER_Staging;
DROP TABLE IF EXISTS BRANCHES_Staging;
DROP TABLE IF EXISTS DELIVERY_Staging;
DROP TABLE IF EXISTS DESIGN_Staging;
DROP TABLE IF EXISTS DISCOUNT_Staging;
DROP TABLE IF EXISTS LEADS_Staging;
DROP TABLE IF EXISTS LOCATION_Staging;
DROP TABLE IF EXISTS MARKETING_Staging;
DROP TABLE IF EXISTS MARKETING_CHANNEL_Staging;
DROP TABLE IF EXISTS ORDER_Staging;
DROP TABLE IF EXISTS ORDER_LINE_Staging;
DROP TABLE IF EXISTS PRODUCT_Staging;
DROP TABLE IF EXISTS PRODUCT_SUPPLIER_Staging;
DROP TABLE IF EXISTS REVIEW_Staging;
DROP TABLE IF EXISTS RETURN_Staging;
DROP TABLE IF EXISTS RETURN_REASON_Staging;
DROP TABLE IF EXISTS SUPPLIERS_Staging;
DROP TABLE IF EXISTS BRANCH_VISITS_LOG_Staging;
DROP TABLE IF EXISTS CHANNEL_Staging;
GO

-- Step 4: Bulk insert data into tables using staging tables for date conversions and FK handling
-- The order of inserts is crucial to satisfy foreign key constraints.
-- Assumes all CSV files are located at 'D:\FCDS\semester 6\Jdara\database\'
-- Ensure 'D:\FCDS\semester 6\Jdara\database\errors\' directory exists and SQL Server has write permissions.

-- Level 0: Tables with no foreign key dependencies
-- ======================================
-- Table: 14_location.csv → LOCATION
-- ======================================
CREATE TABLE LOCATION_Staging (
    location_id INT,
    city VARCHAR(255),
    region VARCHAR(255),
    zip_code VARCHAR(255)
);
TRUNCATE TABLE LOCATION_Staging;
BULK INSERT LOCATION_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\14_location.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\location_error.csv'
);
INSERT INTO LOCATION (location_id, city, region, zip_code)
SELECT location_id, city, region, zip_code
FROM LOCATION_Staging;
GO

-- ======================================
-- Table: 5_leads.csv → LEADS
-- Fields needing conversion: date
-- ======================================
CREATE TABLE LEADS_Staging (
    lead_id INT,
    phone VARCHAR(50),
    gender VARCHAR(10),
    date VARCHAR(50)
);
TRUNCATE TABLE LEADS_Staging;
BULK INSERT LEADS_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\5_leads.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\leads_error.csv'
);
INSERT INTO LEADS (lead_id, phone, gender, date)
SELECT lead_id, phone, gender, TRY_CONVERT(DATE, date, 103)
FROM LEADS_Staging
WHERE TRY_CONVERT(DATE, date, 103) IS NOT NULL; -- Filter out bad dates
GO

-- ======================================
-- Table: 13_return_reasons.csv → RETURN_REASON
-- ======================================
CREATE TABLE RETURN_REASON_Staging (
    reason_id INT,
    reason_detail VARCHAR(255)
);
TRUNCATE TABLE RETURN_REASON_Staging;
BULK INSERT RETURN_REASON_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\13_return_reasons.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\return_reason_error.csv'
);
INSERT INTO RETURN_REASON (reason_id, reason_detail)
SELECT reason_id, reason_detail
FROM RETURN_REASON_Staging;
GO

-- ======================================
-- Table: 15_Marketing_table.csv → MARKETING
-- Fields needing conversion: campaign_start_date, campaign_end_date
-- ======================================
CREATE TABLE MARKETING_Staging (
    campaign_id INT,
    campaign_start_date VARCHAR(50),
    campaign_end_date VARCHAR(50),
    campgain_cost INT
);
TRUNCATE TABLE MARKETING_Staging;
BULK INSERT MARKETING_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\15_Marketing_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\marketing_error.csv'
);
INSERT INTO MARKETING (campaign_id, campaign_start_date, campaign_end_date, campgain_cost)
SELECT campaign_id, TRY_CONVERT(DATE, campaign_start_date, 103), TRY_CONVERT(DATE, campaign_end_date, 103), campgain_cost
FROM MARKETING_Staging
WHERE TRY_CONVERT(DATE, campaign_start_date, 103) IS NOT NULL
  AND TRY_CONVERT(DATE, campaign_end_date, 103) IS NOT NULL; -- Filter out bad dates
GO

-- ======================================
-- Table: 16_Channel_table 2.csv → CHANNEL
-- ======================================
CREATE TABLE CHANNEL_Staging (
    channel_id INT,
    channal_type VARCHAR(255)
);
TRUNCATE TABLE CHANNEL_Staging;
BULK INSERT CHANNEL_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\16_Channel_table 2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\channel_error.csv'
);
INSERT INTO CHANNEL (channel_id, channal_type)
SELECT channel_id, channal_type
FROM CHANNEL_Staging;
GO

-- ======================================
-- Table: 06_product_table.csv → PRODUCT
-- Fields needing conversion: start_date
-- ======================================
CREATE TABLE PRODUCT_Staging (
    product_id INT,
    category VARCHAR(255),
    product_name VARCHAR(255),
    start_date VARCHAR(50),
    Unit_price DECIMAL,
    Unit_cost DECIMAL
);
TRUNCATE TABLE PRODUCT_Staging;
BULK INSERT PRODUCT_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\06_product_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\product_error.csv'
);
INSERT INTO PRODUCT (product_id, category, product_name, start_date, Unit_price, Unit_cost)
SELECT product_id, category, product_name, TRY_CONVERT(DATE, start_date, 103), Unit_price, Unit_cost
FROM PRODUCT_Staging
WHERE TRY_CONVERT(DATE, start_date, 103) IS NOT NULL; -- Filter out bad dates
GO

-- ======================================
-- Table: 09_design_table.csv → DESIGN
-- ======================================
CREATE TABLE DESIGN_Staging (
    design_id INT,
    material VARCHAR(255),
    style VARCHAR(255),
    color VARCHAR(255)
);
TRUNCATE TABLE DESIGN_Staging;
BULK INSERT DESIGN_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\09_design_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\design_error.csv'
);
INSERT INTO DESIGN (design_id, material, style, color)
SELECT design_id, material, style, color
FROM DESIGN_Staging;
GO

-- Level 1: Tables depending on Level 0 tables (User-specified order)
-- ======================================
-- Table: 01_suppliers.csv → SUPPLIERS
-- Depends on LOCATION
-- ======================================
CREATE TABLE SUPPLIERS_Staging (
    supplier_id INT,
    location_id INT,
    supplier_name VARCHAR(255),
    phone VARCHAR(255)
);
TRUNCATE TABLE SUPPLIERS_Staging;
BULK INSERT SUPPLIERS_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\01_suppliers.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\suppliers_error.csv'
);
INSERT INTO SUPPLIERS (supplier_id, location_id, supplier_name, phone)
SELECT ss.supplier_id, ss.location_id, ss.supplier_name, ss.phone
FROM SUPPLIERS_Staging ss
WHERE EXISTS (SELECT 1 FROM LOCATION l WHERE l.location_id = ss.location_id); -- Filter for FK integrity
GO

-- ======================================
-- Table: 17_Marketing_channel table 2.csv → MARKETING_CHANNEL
-- Depends on CHANNEL, MARKETING
-- ======================================
CREATE TABLE MARKETING_CHANNEL_Staging (
    marketing_channel_id INT,
    channel_id INT,
    campaign_Id INT,
    channel_cost INT
);
TRUNCATE TABLE MARKETING_CHANNEL_Staging;
BULK INSERT MARKETING_CHANNEL_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\17_Marketing_channel table 2.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\marketing_channel_error.csv'
);
INSERT INTO MARKETING_CHANNEL (marketing_channel_id, channel_id, campaign_Id, channel_cost)
SELECT mcs.marketing_channel_id, mcs.channel_id, mcs.campaign_Id, mcs.channel_cost
FROM MARKETING_CHANNEL_Staging mcs
WHERE EXISTS (SELECT 1 FROM CHANNEL c WHERE c.channel_id = mcs.channel_id)
  AND EXISTS (SELECT 1 FROM MARKETING m WHERE m.campaign_id = mcs.campaign_Id); -- Filter for FK integrity
GO

-- ======================================
-- Table: 02_branches.csv → BRANCHES
-- Fields needing conversion: opening_date
-- Depends on LOCATION
-- ======================================
CREATE TABLE BRANCHES_Staging (
    branch_id INT,
    location_id INT,
    opening_date VARCHAR(50)
);
TRUNCATE TABLE BRANCHES_Staging;
BULK INSERT BRANCHES_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\02_branches.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\branches_error.csv'
);
INSERT INTO BRANCHES (branch_id, location_id, opening_date)
SELECT bs.branch_id, bs.location_id, TRY_CONVERT(DATE, bs.opening_date, 103)
FROM BRANCHES_Staging bs
WHERE TRY_CONVERT(DATE, bs.opening_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM LOCATION l WHERE l.location_id = bs.location_id); -- Filter for FK integrity and bad dates
GO

-- ======================================
-- Table: 001_product_supplier_table.csv → PRODUCT_SUPPLIER
-- Depends on SUPPLIERS, PRODUCT
-- ======================================
CREATE TABLE PRODUCT_SUPPLIER_Staging (
    product_supplier_id INT,
    supplier_id INT,
    product_id INT
);
TRUNCATE TABLE PRODUCT_SUPPLIER_Staging;
BULK INSERT PRODUCT_SUPPLIER_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\001_product_supplier_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\product_supplier_error.csv'
);
INSERT INTO PRODUCT_SUPPLIER (product_supplier_id, supplier_id, product_id)
SELECT pss.product_supplier_id, pss.supplier_id, pss.product_id
FROM PRODUCT_SUPPLIER_Staging pss
WHERE EXISTS (SELECT 1 FROM SUPPLIERS s WHERE s.supplier_id = pss.supplier_id)
  AND EXISTS (SELECT 1 FROM PRODUCT p WHERE p.product_id = pss.product_id); -- Filter for FK integrity
GO

-- ======================================
-- Table: 10_discount_table.csv → DISCOUNT
-- Fields needing conversion: discount_start_date, discount_end_date
-- Depends on PRODUCT
-- ======================================
CREATE TABLE DISCOUNT_Staging (
    discount_id INT,
    product_id INT,
    discount_start_date VARCHAR(50),
    discount_end_date VARCHAR(50),
    discount_precentage DECIMAL
);
TRUNCATE TABLE DISCOUNT_Staging;
BULK INSERT DISCOUNT_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\10_discount_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\discount_error.csv'
);
INSERT INTO DISCOUNT (discount_id, product_id, discount_start_date, discount_end_date, discount_precentage)
SELECT ds.discount_id, ds.product_id, TRY_CONVERT(DATE, ds.discount_start_date, 103), TRY_CONVERT(DATE, ds.discount_end_date, 103), ds.discount_precentage
FROM DISCOUNT_Staging ds
WHERE TRY_CONVERT(DATE, ds.discount_start_date, 103) IS NOT NULL
  AND TRY_CONVERT(DATE, ds.discount_end_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM PRODUCT p WHERE p.product_id = ds.product_id); -- Filter for FK integrity and bad dates
GO


-- Level 2: Tables depending on Level 0 and 1 tables (User-specified order)
-- ======================================
-- Table: 04_customer_table.csv → CUSTOMER
-- Fields needing conversion: register_date
-- Depends on LOCATION, MARKETING_CHANNEL
-- ======================================
CREATE TABLE CUSTOMER_Staging (
    customer_id INT,
    location_id INT,
    marketing_channel_id INT,
    age INT,
    gender VARCHAR(10),
    Phone VARCHAR(50),
    register_date VARCHAR(50)
);
TRUNCATE TABLE CUSTOMER_Staging;
BULK INSERT CUSTOMER_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\04_customer_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\customer_error.csv'
);
INSERT INTO CUSTOMER (customer_id, location_id, marketing_channel_id, age, gender, Phone, register_date)
SELECT
    cs.customer_id,
    cs.location_id,
    cs.marketing_channel_id,
    cs.age,
    cs.gender,
    cs.Phone,
    TRY_CONVERT(DATE, cs.register_date, 103)
FROM CUSTOMER_Staging cs
WHERE TRY_CONVERT(DATE, cs.register_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM LOCATION l WHERE l.location_id = cs.location_id)
  AND (cs.marketing_channel_id IS NULL OR EXISTS (SELECT 1 FROM MARKETING_CHANNEL mc WHERE mc.marketing_channel_id = cs.marketing_channel_id));
GO

-- Level 3: Tables depending on Level 0, 1, and 2 tables (User-specified order)
-- ======================================
-- Table: 07_order_table.csv → [ORDER]
-- Fields needing conversion: order_date
-- Depends on BRANCHES, CUSTOMER
-- ======================================
CREATE TABLE ORDER_Staging (
    order_id INT,
    branch_id INT,
    customer_id INT,
    order_date VARCHAR(50),
    payment_method VARCHAR(50)
);
TRUNCATE TABLE ORDER_Staging;
BULK INSERT ORDER_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\07_order_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\order_error.csv'
);
INSERT INTO [ORDER] (order_id, branch_id, customer_id, order_date, payment_method)
SELECT os.order_id, os.branch_id, os.customer_id, TRY_CONVERT(DATETIME, os.order_date, 103), os.payment_method
FROM ORDER_Staging os
WHERE TRY_CONVERT(DATETIME, os.order_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM BRANCHES b WHERE b.branch_id = os.branch_id)
  AND EXISTS (SELECT 1 FROM CUSTOMER c WHERE c.customer_id = os.customer_id);
GO

-- ======================================
-- Table: 03_branch_visit_log.csv → BRANCH_VISITS_LOG
-- Fields needing conversion: visit_date, purchased
-- Depends on CUSTOMER, LEADS, BRANCHES
-- ======================================
CREATE TABLE BRANCH_VISITS_LOG_Staging (
    visit_id INT,
    customer_id INT,
    lead_id INT,
    branch_id INT,
    visit_date VARCHAR(50),
    entring_time TIME,
    leaving_time TIME,
    purchased VARCHAR(50)
);
TRUNCATE TABLE BRANCH_VISITS_LOG_Staging;
BULK INSERT BRANCH_VISITS_LOG_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\03_branch_visit_log.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\branch_visits_log_error.csv'
);
INSERT INTO BRANCH_VISITS_LOG (visit_id, customer_id, lead_id, branch_id, visit_date, entring_time, leaving_time, purchased)
SELECT
    bvls.visit_id,
    bvls.customer_id,
    bvls.lead_id,
    bvls.branch_id,
    TRY_CONVERT(DATE, bvls.visit_date, 103),
    bvls.entring_time,
    bvls.leaving_time,
    CASE
        WHEN bvls.purchased IN ('1', 'TRUE', 'true', 'yes', 'Yes') THEN 1
        WHEN bvls.purchased IN ('0', 'FALSE', 'false', 'no', 'No') THEN 0
        ELSE NULL
    END
FROM BRANCH_VISITS_LOG_Staging bvls
WHERE TRY_CONVERT(DATE, bvls.visit_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM BRANCHES b WHERE b.branch_id = bvls.branch_id)
  AND (bvls.customer_id IS NULL OR EXISTS (SELECT 1 FROM CUSTOMER c WHERE c.customer_id = bvls.customer_id))
  AND (bvls.lead_id IS NULL OR EXISTS (SELECT 1 FROM LEADS l WHERE l.lead_id = bvls.lead_id));
GO

-- Level 4: Tables depending on Level 0, 1, 2, and 3 tables (User-specified order)
-- ======================================
-- Table: 18_delivery_table.csv → DELIVERY
-- Fields needing conversion: sechedul_deliver_date, Deliver_Date
-- Depends on [ORDER]
-- ======================================
CREATE TABLE DELIVERY_Staging (
    order_id INT,
    sechedul_deliver_date VARCHAR(50),
    Deliver_Date VARCHAR(50)
);
TRUNCATE TABLE DELIVERY_Staging;
BULK INSERT DELIVERY_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\18_delivery_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\delivery_error.csv'
);
INSERT INTO DELIVERY (order_id, sechedul_deliver_date, Deliver_Date)
SELECT ds.order_id, TRY_CONVERT(DATE, ds.sechedul_deliver_date, 103), TRY_CONVERT(DATE, ds.Deliver_Date, 103)
FROM DELIVERY_Staging ds
WHERE TRY_CONVERT(DATE, ds.sechedul_deliver_date, 103) IS NOT NULL
  AND TRY_CONVERT(DATE, ds.Deliver_Date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM [ORDER] o WHERE o.order_id = ds.order_id);
GO

-- ======================================
-- Table: 12_return_table.csv → RETURN1
-- Field needing conversion: reason_id, return_date
-- Depends on [ORDER], RETURN_REASON
-- ======================================
CREATE TABLE RETURN_Staging (
    return_id INT,
    order_id INT,
    reason_id VARCHAR(50),
    return_date VARCHAR(50)
);
TRUNCATE TABLE RETURN_Staging;
BULK INSERT RETURN_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\12_return_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\return_error.csv'
);
INSERT INTO RETURN1 (return_id, order_id, reason_id, return_date)
SELECT rs.return_id, rs.order_id, TRY_CONVERT(INT, rs.reason_id), TRY_CONVERT(DATE, rs.return_date, 103)
FROM RETURN_Staging rs
WHERE TRY_CONVERT(INT, rs.reason_id) IS NOT NULL
  AND TRY_CONVERT(DATE, rs.return_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM [ORDER] o WHERE o.order_id = rs.order_id)
  AND EXISTS (SELECT 1 FROM RETURN_REASON rr WHERE rr.reason_id = TRY_CONVERT(INT, rs.reason_id));
GO

-- ======================================
-- Table: 08_order_line_table.csv → ORDER_LINE
-- No date fields
-- Depends on PRODUCT_SUPPLIER, [ORDER], DISCOUNT, DESIGN
-- ======================================
CREATE TABLE ORDER_LINE_Staging (
    order_line_id INT,
    product_supplier_id INT,
    order_id INT,
    quantity INT,
    discount_id INT,
    design_id INT
);
TRUNCATE TABLE ORDER_LINE_Staging;
BULK INSERT ORDER_LINE_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\08_order_line_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\order_line_error.csv'
);
INSERT INTO ORDER_LINE (order_line_id, product_supplier_id, order_id, quantity, discount_id, design_id)
SELECT ols.order_line_id, ols.product_supplier_id, ols.order_id, ols.quantity, ols.discount_id, ols.design_id
FROM ORDER_LINE_Staging ols
WHERE EXISTS (SELECT 1 FROM PRODUCT_SUPPLIER ps WHERE ps.product_supplier_id = ols.product_supplier_id)
  AND EXISTS (SELECT 1 FROM [ORDER] o WHERE o.order_id = ols.order_id)
  AND (ols.discount_id IS NULL OR EXISTS (SELECT 1 FROM DISCOUNT d WHERE d.discount_id = ols.discount_id))
  AND (ols.design_id IS NULL OR EXISTS (SELECT 1 FROM DESIGN de WHERE de.design_id = ols.design_id));
GO

-- Level 5: Tables depending on Level 0, 1, 2, 3, and 4 tables (User-specified order)
-- ======================================
-- Table: 11_Reviews.csv → REVIEW
-- Field needing conversion: review_date
-- Depends on ORDER_LINE
-- ======================================
CREATE TABLE REVIEW_Staging (
    order_line_id INT,
    delivery_rating DECIMAL,
    branch_rating DECIMAL,
    product_rating DECIMAL,
    customer_service_rating DECIMAL,
    review_date VARCHAR(50)
);
TRUNCATE TABLE REVIEW_Staging;
BULK INSERT REVIEW_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\11_Reviews.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a', -- Use '0x0d0a' for Windows-style line endings if '0x0a' fails
    CODEPAGE = '65001',
    DATAFILETYPE = 'char',
    TABLOCK,
    ERRORFILE = 'D:\FCDS\semester 6\Jdara\database\errors\review_error.csv'
);
INSERT INTO REVIEW (order_line_id, delivery_rating, branch_rating, product_rating, customer_service_rating, review_date)
SELECT rws.order_line_id, rws.delivery_rating, rws.branch_rating, rws.product_rating, rws.customer_service_rating, TRY_CONVERT(DATE, rws.review_date, 103)
FROM REVIEW_Staging rws
WHERE TRY_CONVERT(DATE, rws.review_date, 103) IS NOT NULL
  AND EXISTS (SELECT 1 FROM ORDER_LINE ol WHERE ol.order_line_id = rws.order_line_id);
GO

-- Re-enable and check all foreign key constraints after data insertion
-- This step will report any data integrity issues that exist after loading.
EXEC sp_MSforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT ALL";
GO
