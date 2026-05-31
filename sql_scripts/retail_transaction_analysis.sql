-- ==============================================================================
-- PROJECT: Retail Customer Behavior & Revenue Analytics
-- AUTHOR: Karthik Yelugam
-- DESCRIPTION: End-to-end exploratory data analysis (EDA), data quality 
--              validation, and demographic segmentation.
-- RESTRICTION: Read-Only Database Constraints (Strictly SELECT operations)
-- ==============================================================================

-- ==============================================================================
-- SECTION 1: DATABASE EXPLORATION & STRUCTURAL OVERVIEW
-- ==============================================================================

-- 1.1 Structural Verification & Sample Data Preview
DESCRIBE customer;

SELECT * FROM customer 
LIMIT 10;

-- 1.2 Unique Customer Footprint
SELECT 
    COUNT(DISTINCT customer_id) AS total_unique_customers 
FROM customer;


-- ==============================================================================
-- SECTION 2: DATA QUALITY & ANOMALY DETECTION
-- ==============================================================================

-- 2.1 Duplicate Invoice Check
SELECT
    invoice_no,
    COUNT(*) AS duplicate_count
FROM customer
GROUP BY invoice_no
HAVING COUNT(*) > 1;

-- 2.2 Comprehensive Null & Missing Value Audit across all critical columns
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN invoice_no IS NULL THEN 1 ELSE 0 END) AS null_invoice,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer,
    SUM(CASE WHEN gender IS NULL OR gender = '' THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_age,
    SUM(CASE WHEN category IS NULL OR category = '' THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN payment_method IS NULL THEN 1 ELSE 0 END) AS null_payment,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN shopping_mall IS NULL THEN 1 ELSE 0 END) AS null_mall
FROM customer;

-- 2.3 Invalid Values & Numeric Range Detection (Age, Quantity, Price boundaries)
SELECT 'Age Constraints' AS metric, MIN(age) AS min_val, MAX(age) AS max_val, ROUND(AVG(age), 2) AS avg_val FROM customer
UNION ALL
SELECT 'Quantity Constraints', MIN(quantity), MAX(quantity), ROUND(AVG(quantity), 2) FROM customer
UNION ALL
SELECT 'Price Constraints', MIN(price), MAX(price), ROUND(AVG(price), 2) FROM customer;

-- 2.4 Price vs. Revenue Verification
-- Confirms 'price' column acts as total transaction revenue rather than unit price
SELECT
    category,
    quantity,
    price AS total_transaction_value,
    (price / quantity) AS derived_unit_price
FROM customer
LIMIT 10;


-- ==============================================================================
-- SECTION 3: DEMOGRAPHIC & SEGMENTATION ANALYSIS
-- ==============================================================================

-- 3.1 Comprehensive Gender Metrics (Transactions, Quantity, Revenue, & Distribution)
SELECT 
    gender,
    COUNT(invoice_no) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 2) AS transaction_pct,
    SUM(quantity) AS total_items_sold,
    SUM(price) AS total_revenue
FROM customer
GROUP BY gender
ORDER BY total_revenue DESC;

-- 3.2 Comprehensive Age Group Metrics (Transactions, Quantity, Revenue, & Distribution)
SELECT 
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    COUNT(invoice_no) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 2) AS transaction_pct,
    SUM(quantity) AS total_items_sold,
    SUM(price) AS total_revenue
FROM customer
GROUP BY 
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END
ORDER BY total_revenue DESC;


-- ==============================================================================
-- SECTION 4: PRODUCT CATEGORY PERFORMANCE
-- ==============================================================================

-- 4.1 Overall Category Metrics (Quantity and Revenue)
SELECT 
    category,
    SUM(quantity) AS total_quantity_sold,
    SUM(price) AS total_revenue
FROM customer
GROUP BY category
ORDER BY total_revenue DESC;

-- 4.2 Category Preference by Gender
SELECT 
    category,
    gender,
    COUNT(invoice_no) AS total_transactions
FROM customer
GROUP BY category, gender
ORDER BY category ASC, total_transactions DESC;

-- 4.3 Category Preference by Age Group
SELECT 
    category,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    COUNT(*) AS transactions
FROM customer
GROUP BY 
    category,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END
ORDER BY category ASC, transactions DESC;


-- ==============================================================================
-- SECTION 5: PAYMENT BEHAVIOR ANALYSIS
-- ==============================================================================

-- 5.1 Comprehensive Payment Method Metrics (Transactions, Quantity, Revenue, & Distribution)
SELECT 
    payment_method,
    COUNT(invoice_no) AS total_transactions,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customer), 2) AS transaction_pct,
    SUM(quantity) AS total_items_purchased,
    SUM(price) AS total_revenue
FROM customer
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 5.2 Payment Method Distribution by Gender
SELECT 
    payment_method,
    gender,
    COUNT(invoice_no) AS total_transactions
FROM customer
GROUP BY payment_method, gender
ORDER BY payment_method ASC, total_transactions DESC;


-- ==============================================================================
-- SECTION 6: DATA EXPORT SCRIPT (ETL EXTRACT)
-- ==============================================================================

-- 6.1 Final Transformed Dataset Query for Power BI Integration
-- Renames 'price' to 'revenue' and materializes 'age_group'
SELECT 
    invoice_no,
    customer_id,
    gender,
    age,
    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '60+'
    END AS age_group,
    category,
    quantity,
    price AS revenue,
    payment_method,
    invoice_date,
    shopping_mall
FROM customer;