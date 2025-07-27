USE Baytak;
GO

-- Step 1: Drop all foreign key constraints
DECLARE @sql NVARCHAR(MAX) = N'';

SELECT @sql += '
ALTER TABLE ' + QUOTENAME(s.name) + '.' + QUOTENAME(t.name) + ' DROP CONSTRAINT ' + QUOTENAME(f.name) + ';'
FROM sys.foreign_keys f
INNER JOIN sys.tables t ON f.parent_object_id = t.object_id
INNER JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;
GO

-- Step 2: Now drop all tables (your original reverse order)
IF OBJECT_ID('dbo.REVIEW', 'U') IS NOT NULL DROP TABLE dbo.REVIEW;
IF OBJECT_ID('dbo.RETURN1', 'U') IS NOT NULL DROP TABLE dbo.RETURN1;
IF OBJECT_ID('dbo.DELIVERY', 'U') IS NOT NULL DROP TABLE dbo.DELIVERY;
IF OBJECT_ID('dbo.ORDER_LINE', 'U') IS NOT NULL DROP TABLE dbo.ORDER_LINE;
IF OBJECT_ID('dbo.BRANCH_VISITS_LOG', 'U') IS NOT NULL DROP TABLE dbo.BRANCH_VISITS_LOG;
IF OBJECT_ID('dbo.[ORDER]', 'U') IS NOT NULL DROP TABLE dbo.[ORDER];
IF OBJECT_ID('dbo.CUSTOMER', 'U') IS NOT NULL DROP TABLE dbo.CUSTOMER;
IF OBJECT_ID('dbo.MARKETING_CHANNEL', 'U') IS NOT NULL DROP TABLE dbo.MARKETING_CHANNEL;
IF OBJECT_ID('dbo.DISCOUNT', 'U') IS NOT NULL DROP TABLE dbo.DISCOUNT;
IF OBJECT_ID('dbo.PRODUCT_SUPPLIER', 'U') IS NOT NULL DROP TABLE dbo.PRODUCT_SUPPLIER;
IF OBJECT_ID('dbo.BRANCHES', 'U') IS NOT NULL DROP TABLE dbo.BRANCHES;
IF OBJECT_ID('dbo.LEADS', 'U') IS NOT NULL DROP TABLE dbo.LEADS;
IF OBJECT_ID('dbo.RETURN_REASON', 'U') IS NOT NULL DROP TABLE dbo.RETURN_REASON;
IF OBJECT_ID('dbo.SUPPLIERS', 'U') IS NOT NULL DROP TABLE dbo.SUPPLIERS;
IF OBJECT_ID('dbo.PRODUCT', 'U') IS NOT NULL DROP TABLE dbo.PRODUCT;
IF OBJECT_ID('dbo.DESIGN', 'U') IS NOT NULL DROP TABLE dbo.DESIGN;
IF OBJECT_ID('dbo.CHANNEL', 'U') IS NOT NULL DROP TABLE dbo.CHANNEL;
IF OBJECT_ID('dbo.MARKETING', 'U') IS NOT NULL DROP TABLE dbo.MARKETING;
IF OBJECT_ID('dbo.LOCATION', 'U') IS NOT NULL DROP TABLE dbo.LOCATION;
GO

-- Create tables
CREATE TABLE LOCATION (
    location_id INT PRIMARY KEY,
    city VARCHAR(255),
    region VARCHAR(255),
    zip_code VARCHAR(255)
);

CREATE TABLE CHANNEL (
    channel_id INT PRIMARY KEY,
    channal_type VARCHAR(255)
);

CREATE TABLE MARKETING (
    campaign_id INT PRIMARY KEY,
    campaign_start_date DATE,
    campaign_end_date DATE,
    campgain_cost INT
);

CREATE TABLE MARKETING_CHANNEL (
    marketing_channel_id INT PRIMARY KEY,
    channel_id INT NOT NULL FOREIGN KEY REFERENCES CHANNEL(channel_id),
    campaign_Id INT NOT NULL FOREIGN KEY REFERENCES MARKETING(campaign_id),
    channel_cost INT
);

CREATE TABLE CUSTOMER (
    customer_id INT PRIMARY KEY,
    location_id INT NOT NULL FOREIGN KEY REFERENCES LOCATION(location_id),
    marketing_channel_id INT FOREIGN KEY REFERENCES MARKETING_CHANNEL(marketing_channel_id),
    age INT,
    gender VARCHAR(255),
    Phone VARCHAR(255),
    register_date DATE
);

CREATE TABLE SUPPLIERS (
    supplier_id INT PRIMARY KEY,
    location_id INT NOT NULL FOREIGN KEY REFERENCES LOCATION(location_id),
    supplier_name VARCHAR(255),
    phone VARCHAR(255)
);

CREATE TABLE PRODUCT (
    product_id INT PRIMARY KEY,
    category VARCHAR(255),
    product_name VARCHAR(255),
    start_date DATE,
    Unit_price DECIMAL(18,2),
    Unit_cost DECIMAL(18,2)
);

CREATE TABLE PRODUCT_SUPPLIER (
    product_supplier_id INT PRIMARY KEY,
    supplier_id INT NOT NULL FOREIGN KEY REFERENCES SUPPLIERS(supplier_id),
    product_id INT NOT NULL FOREIGN KEY REFERENCES PRODUCT(product_id)
);

CREATE TABLE DESIGN (
    design_id INT PRIMARY KEY,
    material VARCHAR(255),
    style VARCHAR(255),
    color VARCHAR(255)
);

CREATE TABLE DISCOUNT (
    discount_id INT PRIMARY KEY,
    product_id INT NOT NULL FOREIGN KEY REFERENCES PRODUCT(product_id),
    discount_start_date DATE,
    discount_end_date DATE,
    discount_precentage DECIMAL(5,2)
);

CREATE TABLE BRANCHES (
    branch_id INT PRIMARY KEY,
    location_id INT NOT NULL FOREIGN KEY REFERENCES LOCATION(location_id),
    opening_date DATE
);

CREATE TABLE [ORDER] (
    order_id INT PRIMARY KEY,
    branch_id INT NOT NULL FOREIGN KEY REFERENCES BRANCHES(branch_id),
    customer_id INT NOT NULL FOREIGN KEY REFERENCES CUSTOMER(customer_id),
    order_date DATETIME,
    payment_method VARCHAR(255)
);

CREATE TABLE ORDER_LINE (
    order_line_id INT PRIMARY KEY,
    product_supplier_id INT NOT NULL FOREIGN KEY REFERENCES PRODUCT_SUPPLIER(product_supplier_id),
    order_id INT NOT NULL FOREIGN KEY REFERENCES [ORDER](order_id),
    quantity INT,
    discount_id INT FOREIGN KEY REFERENCES DISCOUNT(discount_id),
    design_id INT FOREIGN KEY REFERENCES DESIGN(design_id)
);

CREATE TABLE DELIVERY (
    order_id INT PRIMARY KEY FOREIGN KEY REFERENCES [ORDER](order_id),
    sechedul_deliver_date DATE,
    Deliver_Date DATE
);

CREATE TABLE RETURN_REASON (
    reason_id INT PRIMARY KEY,
    reason_detail VARCHAR(255)
);

CREATE TABLE RETURN1 (
    return_id INT PRIMARY KEY,
    order_id INT NOT NULL FOREIGN KEY REFERENCES [ORDER](order_id),
    reason_id INT NOT NULL FOREIGN KEY REFERENCES RETURN_REASON(reason_id),
    return_date DATE
);

CREATE TABLE REVIEW (
    order_line_id INT PRIMARY KEY FOREIGN KEY REFERENCES ORDER_LINE(order_line_id),
    delivery_rating DECIMAL(3,2),
    branch_rating DECIMAL(3,2),
    product_rating DECIMAL(3,2),
    customer_service_rating DECIMAL(3,2),
    review_date DATE
);

CREATE TABLE LEADS (
    lead_id INT PRIMARY KEY,
    phone VARCHAR(255),
    gender VARCHAR(255),
    date DATE
);

CREATE TABLE BRANCH_VISITS_LOG (
    visit_id INT PRIMARY KEY,
    customer_id INT FOREIGN KEY REFERENCES CUSTOMER(customer_id),
    lead_id INT FOREIGN KEY REFERENCES LEADS(lead_id),
    branch_id INT NOT NULL FOREIGN KEY REFERENCES BRANCHES(branch_id),
    visit_date DATE,
    entring_time TIME,
    leaving_time TIME,
    purchased BIT
);
GO


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

-- Bulk insert with staging and transformation for all tables
-- Assumes all files are in: D:\FCDS\semester 6\Jdara\database\

-- ======================================
-- Table: 06_product_table.csv ? PRODUCT
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
BULK INSERT PRODUCT_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\06_product_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO PRODUCT (product_id, category, product_name, start_date, Unit_price, Unit_cost)
SELECT product_id, category, product_name, CONVERT(DATE, start_date, 103), Unit_price, Unit_cost
FROM PRODUCT_Staging;

-- ======================================
-- Table: 04_customer_table.csv ? CUSTOMER
-- Fields needing conversion: register_date
-- ======================================
DROP TABLE IF EXISTS CUSTOMER_Staging;

CREATE TABLE CUSTOMER_Staging (
    customer_id INT,
    location_id INT,
    marketing_channel_id INT,
    age INT,
    gender VARCHAR(10),
    Phone VARCHAR(50),
    register_date VARCHAR(50)  -- Stored as string to convert later
);

BULK INSERT CUSTOMER_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\04_customer_table.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

INSERT INTO CUSTOMER (customer_id, location_id, marketing_channel_id, age, gender, Phone, register_date)
SELECT 
    customer_id, 
    location_id, 
    marketing_channel_id, 
    age, 
    gender, 
    Phone, 
    TRY_CONVERT(DATE, register_date, 103)  -- Safe conversion
FROM CUSTOMER_Staging
WHERE TRY_CONVERT(DATE, register_date, 103) IS NOT NULL;  -- Ignore bad values


-- ======================================
-- Table: 07_order_table.csv ? ORDER
-- Fields needing conversion: order_date
-- ======================================
CREATE TABLE ORDER_Staging (
    order_id INT,
    branch_id INT,
    customer_id INT,
    order_date VARCHAR(50),
    payment_method VARCHAR(50)
);
BULK INSERT ORDER_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\07_order_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO [ORDER] (order_id, branch_id, customer_id, order_date, payment_method)
SELECT order_id, branch_id, customer_id, CONVERT(DATETIME, order_date, 103), payment_method
FROM ORDER_Staging;

-- ======================================
-- Table: 08_order_line_table.csv ? ORDER_LINE
-- No date fields
-- ======================================
BULK INSERT ORDER_LINE
FROM 'D:\FCDS\semester 6\Jdara\database\08_order_line_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 09_design_table.csv ? DESIGN
-- No date fields
-- ======================================
BULK INSERT DESIGN
FROM 'D:\FCDS\semester 6\Jdara\database\09_design_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 10_discount_table.csv ? DISCOUNT
-- Fields needing conversion: discount_start_date, discount_end_date
-- ======================================
CREATE TABLE DISCOUNT_Staging (
    discount_id INT,
    product_id INT,
    discount_start_date VARCHAR(50),
    discount_end_date VARCHAR(50),
    discount_precentage DECIMAL
);
BULK INSERT DISCOUNT_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\10_discount_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO DISCOUNT (discount_id, product_id, discount_start_date, discount_end_date, discount_precentage)
SELECT discount_id, product_id, CONVERT(DATE, discount_start_date, 103), CONVERT(DATE, discount_end_date, 103), discount_precentage
FROM DISCOUNT_Staging;

-- ======================================
-- Table: 11_Reviews.csv ? REVIEW
-- Field needing conversion: review_date
-- ======================================
CREATE TABLE REVIEW_Staging (
    order_line_id INT,
    delivery_rating DECIMAL,
    branch_rating DECIMAL,
    product_rating DECIMAL,
    customer_service_rating DECIMAL,
    review_date VARCHAR(50)
);
BULK INSERT REVIEW_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\11_Reviews.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO REVIEW (order_line_id, delivery_rating, branch_rating, product_rating, customer_service_rating, review_date)
SELECT order_line_id, delivery_rating, branch_rating, product_rating, customer_service_rating, CONVERT(DATE, review_date, 103)
FROM REVIEW_Staging;

-- ======================================
-- Table: 12_return_table.csv ? RETURN
-- Field needing conversion: return_date
-- ======================================
CREATE TABLE RETURN_Staging (
    return_id INT,
    order_id INT,
    reason_id INT,
    return_date VARCHAR(50)
);
BULK INSERT RETURN_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\12_return_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO [RETURN] (return_id, order_id, return_date, reason_id)
SELECT return_id, order_id, reason_id, CONVERT(DATE, return_date, 103)
FROM RETURN_Staging;

-- ======================================
-- Table: 13_return_reasons.csv ? RETURN_REASON
-- No date fields
-- ======================================
BULK INSERT RETURN_REASON
FROM 'D:\FCDS\semester 6\Jdara\database\13_return_reasons.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 14_location.csv ? LOCATION
-- No date fields
-- ======================================
BULK INSERT LOCATION
FROM 'D:\FCDS\semester 6\Jdara\database\14_location.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 15_Marketing_table.csv ? MARKETING
-- Fields needing conversion: campaign_start_date, campaign_end_date
-- ======================================
CREATE TABLE MARKETING_Staging (
    campaign_id INT,
    campaign_start_date VARCHAR(50),
    campaign_end_date VARCHAR(50),
    campgain_cost INT
);
BULK INSERT MARKETING_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\15_Marketing_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO MARKETING (campaign_id, campaign_start_date, campaign_end_date, campgain_cost)
SELECT campaign_id, CONVERT(DATE, campaign_start_date, 103), CONVERT(DATE, campaign_end_date, 103), campgain_cost
FROM MARKETING_Staging;

-- ======================================
-- Table: 16_Channel_table 2.csv ? CHANNEL
-- No date fields
-- ======================================
BULK INSERT CHANNEL
FROM 'D:\FCDS\semester 6\Jdara\database\16_Channel_table 2.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 17_Marketing_channel table 2.csv ? MARKETING_CHANNEL
-- No date fields
-- ======================================
BULK INSERT MARKETING_CHANNEL
FROM 'D:\FCDS\semester 6\Jdara\database\17_Marketing_channel table 2.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 18_delivery_table.csv ? DELIVERY
-- Fields needing conversion: sechedul_deliver_date, Deliver_Date
-- ======================================
CREATE TABLE DELIVERY_Staging (
    order_id INT,
    sechedul_deliver_date VARCHAR(50),
    Deliver_Date VARCHAR(50)
);
BULK INSERT DELIVERY_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\18_delivery_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO DELIVERY (order_id, sechedul_deliver_date, Deliver_Date)
SELECT order_id, CONVERT(DATE, sechedul_deliver_date, 103), CONVERT(DATE, Deliver_Date, 103)
FROM DELIVERY_Staging;

-- ======================================
-- Table: 01_suppliers.csv ? SUPPLIERS
-- No date fields
-- ======================================
BULK INSERT SUPPLIERS
FROM 'D:\FCDS\semester 6\Jdara\database\01_suppliers.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);

-- ======================================
-- Table: 02_branches.csv ? BRANCHES
-- Fields needing conversion: opening_date
-- ======================================
CREATE TABLE BRANCHES_Staging (
    branch_id INT,
    location_id INT,
    opening_date VARCHAR(50)
);
BULK INSERT BRANCHES_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\02_branches.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO BRANCHES (branch_id, location_id, opening_date)
SELECT branch_id, location_id, CONVERT(DATE, opening_date, 103)
FROM BRANCHES_Staging;

-- ======================================
-- Table: 03_branch_visit_log.csv ? BRANCH_VISITS_LOG
-- Fields needing conversion: visit_date
-- ======================================
CREATE TABLE BRANCH_VISITS_LOG_Staging (
    visit_id INT,
    customer_id INT,
    lead_id INT,
    branch_id INT,
    visit_date VARCHAR(50),
    entring_time TIME,
    leaving_time TIME,
    purchased BIT
);
BULK INSERT BRANCH_VISITS_LOG_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\03_branch_visit_log.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO BRANCH_VISITS_LOG (visit_id, customer_id, lead_id, branch_id, visit_date, entring_time, leaving_time, purchased)
SELECT visit_id, customer_id, lead_id, branch_id, CONVERT(DATE, visit_date, 103), entring_time, leaving_time, purchased
FROM BRANCH_VISITS_LOG_Staging;

-- ======================================
-- Table: 5_leads.csv ? LEADS
-- Fields needing conversion: date
-- ======================================
CREATE TABLE LEADS_Staging (
    lead_id INT,
    phone VARCHAR(50),
    gender VARCHAR(10),
    date VARCHAR(50)
);
BULK INSERT LEADS_Staging
FROM 'D:\FCDS\semester 6\Jdara\database\5_leads.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);
INSERT INTO LEADS (lead_id, phone, gender, date)
SELECT lead_id, phone, gender, CONVERT(DATE, date, 103)
FROM LEADS_Staging;

-- ======================================
-- Table: 001_product_supplier_table.csv ? PRODUCT_SUPPLIER
-- No date fields
-- ======================================
BULK INSERT PRODUCT_SUPPLIER
FROM 'D:\FCDS\semester 6\Jdara\database\001_product_supplier_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', CODEPAGE = '65001', TABLOCK);


-- ============================================================================================================================================
