-- SQL Server Script for Baytak Furniture and Home Accessories Database Schema
--create database Baytak;
use Baytak;
-- SQL Server Script for Baytak Furniture and Home Accessories Database Schema
-- SQL Server Database Creation Script
GO

-- Drop tables in reverse dependency order to avoid foreign key constraint issues
IF OBJECT_ID('dbo.REVIEW', 'U') IS NOT NULL DROP TABLE dbo.REVIEW;
IF OBJECT_ID('dbo.RETURN1', 'U') IS NOT NULL DROP TABLE dbo.RETURN1;
IF OBJECT_ID('dbo.DELIVERY', 'U') IS NOT NULL DROP TABLE dbo.DELIVERY;
IF OBJECT_ID('dbo.ORDER_LINE', 'U') IS NOT NULL DROP TABLE dbo.ORDER_LINE;
IF OBJECT_ID('dbo.BRANCH_VISITS_LOG', 'U') IS NOT NULL DROP TABLE dbo.BRANCH_VISITS_LOG;
IF OBJECT_ID('dbo."ORDER"', 'U') IS NOT NULL DROP TABLE dbo."ORDER";
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

-- Create Tables

CREATE TABLE [dbo].[LOCATION] (
    location_id INT PRIMARY KEY,
    City VARCHAR(255),
    Region VARCHAR(255),
    Zip_code VARCHAR(20)
);

CREATE TABLE [dbo].[CHANNEL] (
    channel_id INT PRIMARY KEY,
    channal_type VARCHAR(255)
);

CREATE TABLE [dbo].[DESIGN] (
    design_id INT PRIMARY KEY,
    material VARCHAR(255),
    style VARCHAR(255),
    color VARCHAR(50)
);

CREATE TABLE [dbo].[PRODUCT] (
    product_id INT PRIMARY KEY,
    category VARCHAR(255),
    product_name VARCHAR(255),
    start_date DATE,
    sale_price DECIMAL(10, 2),
    cost DECIMAL(10, 2)
);

CREATE TABLE [dbo].[SUPPLIERS] (
    supplier_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    supplier_name VARCHAR(255),
    phone VARCHAR(50),
    FOREIGN KEY (location_id) REFERENCES [dbo].[LOCATION](location_id)
);

CREATE TABLE [dbo].[RETURN_REASON] (
    reason_id INT PRIMARY KEY,
    reason_detail VARCHAR(255)
);

CREATE TABLE [dbo].[LEADS] (
    leads_id INT PRIMARY KEY,
    phone VARCHAR(50),
    gender VARCHAR(10),
    date DATE -- Changed to DATE
);

CREATE TABLE [dbo].[BRANCHES] (
    branch_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    opening_date DATE,
    FOREIGN KEY (location_id) REFERENCES [dbo].[LOCATION](location_id)
);

CREATE TABLE [dbo].[MARKETING] (
    Campaign_Id INT PRIMARY KEY,
    start DATE, -- Changed to DATE
    [end] DATE, -- Changed to DATE (using [] for keyword)
    market_cost INT
);

CREATE TABLE [dbo].[PRODUCT_SUPPLIER] (
    product_supplier_id INT PRIMARY KEY, -- New primary key
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    FOREIGN KEY (supplier_id) REFERENCES [dbo].[SUPPLIERS](supplier_id),
    FOREIGN KEY (product_id) REFERENCES [dbo].[PRODUCT](product_id)
);

CREATE TABLE [dbo].[DISCOUNT] (
    dis_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    start_date DATE, -- Changed to DATE
    end_date DATE,   -- Changed to DATE
    dis_precent DECIMAL(5, 2),
    FOREIGN KEY (product_id) REFERENCES [dbo].[PRODUCT](product_id)
);

CREATE TABLE [dbo].[MARKETING_CHANNEL] (
    Marketing_channel_id INT PRIMARY KEY,
    channel_id INT NOT NULL,
    Campaign_Id INT NOT NULL,
    cost INT, -- New column added
    FOREIGN KEY (channel_id) REFERENCES [dbo].[CHANNEL](channel_id),
    FOREIGN KEY (Campaign_Id) REFERENCES [dbo].[MARKETING](Campaign_Id)
);

CREATE TABLE [dbo].[CUSTOMER] (
    customer_id INT PRIMARY KEY,
    location_id INT NOT NULL,
    Marketing_channel_id INT, -- Updated to link to MARKETING_CHANNEL
    Age INT,
    Gender VARCHAR(50),
    Phone VARCHAR(50),
    SignUpDate DATE,
    FOREIGN KEY (location_id) REFERENCES [dbo].[LOCATION](location_id),
    FOREIGN KEY (Marketing_channel_id) REFERENCES [dbo].[MARKETING_CHANNEL](Marketing_channel_id)
);

CREATE TABLE [dbo].["ORDER"] ( -- Quoted because ORDER is a reserved keyword
    Order_id INT PRIMARY KEY,
    branch_id INT NOT NULL,
    customer_id INT NOT NULL,
    date DATETIME, -- Remains DATETIME as requested
    payment_method VARCHAR(50),
    stuats_order VARCHAR(50),
    FOREIGN KEY (branch_id) REFERENCES [dbo].[BRANCHES](branch_id),
    FOREIGN KEY (customer_id) REFERENCES [dbo].[CUSTOMER](customer_id)
);

CREATE TABLE [dbo].[BRANCH_VISITS_LOG] (
    visit_id INT PRIMARY KEY,
    customer_id INT,
    lead_id INT,
    branch_id INT NOT NULL,
    date DATE, -- New column for date only
    entring TIME, -- Changed to TIME
    leaving TIME, -- Changed to TIME
    purchased BIT,
    FOREIGN KEY (customer_id) REFERENCES [dbo].[CUSTOMER](customer_id),
    FOREIGN KEY (lead_id) REFERENCES [dbo].[LEADS](leads_id),
    FOREIGN KEY (branch_id) REFERENCES [dbo].[BRANCHES](branch_id)
);

CREATE TABLE [dbo].[DELIVERY] (
    Order_id INT NOT NULL PRIMARY KEY, -- One-to-one relationship with "ORDER"
    sechedul_deliver_date DATE,
    Deliver_Date DATE,
    FOREIGN KEY (Order_id) REFERENCES [dbo].["ORDER"](Order_id)
);

CREATE TABLE [dbo].[ORDER_LINE] (
    Order_line_id INT PRIMARY KEY,
    product_supplier_id INT NOT NULL, -- Updated to link to PRODUCT_SUPPLIER
    Order_id INT NOT NULL,
    quantity INT,
    dis_id INT,
    design_id INT,
    FOREIGN KEY (product_supplier_id) REFERENCES [dbo].[PRODUCT_SUPPLIER](product_supplier_id),
    FOREIGN KEY (Order_id) REFERENCES [dbo].["ORDER"](Order_id),
    FOREIGN KEY (dis_id) REFERENCES [dbo].[DISCOUNT](dis_id),
    FOREIGN KEY (design_id) REFERENCES [dbo].[DESIGN](design_id)
);

CREATE TABLE [dbo].[RETURN1] (
    return_id INT PRIMARY KEY,
    Order_id INT NOT NULL, -- Updated to link to ORDER table
    reason_id INT NOT NULL,
    return_date DATE,
    units_return INT,
    refund_amount DECIMAL(10, 2),
    FOREIGN KEY (Order_id) REFERENCES [dbo].["ORDER"](Order_id),
    FOREIGN KEY (reason_id) REFERENCES [dbo].[RETURN_REASON](reason_id)
);

CREATE TABLE [dbo].[REVIEW] (
    review_id INT PRIMARY KEY,
    order_line_id INT NOT NULL,
    delevery_rating DECIMAL(3, 1),
    branch_rating DECIMAL(3, 1),
    product_rating DECIMAL(3, 1),
    customer_service_rating DECIMAL(3, 1),
    review_date DATE, -- Changed to DATE
    FOREIGN KEY (order_line_id) REFERENCES [dbo].[ORDER_LINE](Order_line_id)
);
GO

-- ***************************************************************************************************
-- BULK INSERT SECTION
--
-- IMPORTANT:
-- 1. Replace 'C:\Path\To\Your\File.csv' with the actual path to your CSV files.
-- 2. Ensure the SQL Server service account has read permissions on the specified file paths.
-- 3. The CSV files should have headers that match the column names in the tables,
--    or you can use a FORMATFILE for more complex mapping.
-- 4. If your CSVs use a different field terminator (e.g., tab), adjust FIELDTERMINATOR.
-- 5. If your CSVs use a different row terminator (e.g., LF instead of CRLF), adjust ROWTERMINATOR.
-- 6. Uncomment the BULK INSERT statements for the tables you want to populate.
--
-- Example for a CSV file named 'leads.csv' with comma-separated values and a header row:
-- BULK INSERT dbo.LEADS
-- FROM 'C:\YourDataFolder\leads.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2 -- Skip header row
-- );
-- ***************************************************************************************************

-- Uncomment and modify the following statements to bulk insert your data

-- BULK INSERT dbo.LOCATION
-- FROM 'C:\Path\To\Your\location.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.CHANNEL
-- FROM 'C:\Path\To\Your\channel.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.DESIGN
-- FROM 'C:\Path\To\Your\design.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.PRODUCT
-- FROM 'C:\Path\To\Your\product.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.SUPPLIERS
-- FROM 'C:\Path\To\Your\suppliers.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.RETURN_REASON
-- FROM 'C:\Path\To\Your\return_reason.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.LEADS
-- FROM 'C:\Path\To\Your\leads.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.BRANCHES
-- FROM 'C:\Path\To\Your\branches.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.MARKETING
-- FROM 'C:\Path\To\Your\marketing.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.PRODUCT_SUPPLIER
-- FROM 'C:\Path\To\Your\product_supplier.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.DISCOUNT
-- FROM 'C:\Path\To\Your\discount.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.MARKETING_CHANNEL
-- FROM 'C:\Path\To\Your\marketing_channel.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.CUSTOMER
-- FROM 'C:\Path\To\Your\customer.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo."ORDER"
-- FROM 'C:\Path\To\Your\order.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.BRANCH_VISITS_LOG
-- FROM 'C:\Path\To\Your\branch_visits_log.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.DELIVERY
-- FROM 'C:\Path\To\Your\delivery.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.ORDER_LINE
-- FROM 'C:\Path\To\Your\order_line.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.RETURN1
-- FROM 'C:\Path\To\Your\return.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );

-- BULK INSERT dbo.REVIEW
-- FROM 'C:\Path\To\Your\review.csv'
-- WITH (
--     FORMAT = 'CSV',
--     FIRSTROW = 2
-- );