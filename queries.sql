CREATE TABLE dim_customers AS
SELECT
    "Customer ID" AS Customer_ID,
    MAX("Customer Name") AS Customer_Name,
    MAX(Segment) AS Segment,
    MAX(Country) AS Country
FROM Sample
GROUP BY "Customer ID";

CREATE TABLE dim_products AS
SELECT DISTINCT "Product ID" AS Product_ID, Category, "Sub-Category" AS Sub_Category, "Product Name" AS Product_Name
FROM Sample;

CREATE TABLE sales_orders AS
SELECT
    "Order ID" AS Order_ID,
    "Order Date" AS Order_Date,
    "Customer ID" AS Customer_ID,
    "Product ID" AS Product_ID,
    City,
    Region,
    Country,
    Sales,
    Quantity,
    Discount,
    Profit
FROM Sample;

CREATE TABLE dim_date AS
SELECT DISTINCT 
    "Order_Date" AS Date,
    substr("Order_Date", -4) AS Year,
    REPLACE(substr("Order_Date", 1, 2), '/', '') AS Month_Number,
    CASE 
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 1 THEN 'January'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 2 THEN 'February'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 3 THEN 'March'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 4 THEN 'April'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 5 THEN 'May'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 6 THEN 'June'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 7 THEN 'July'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 8 THEN 'August'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 9 THEN 'September'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 10 THEN 'October'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) = 11 THEN 'November'
        ELSE 'December'
    END AS Month_Name,
    CASE 
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) <= 3 THEN 'Q1'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) <= 6 THEN 'Q2'
        WHEN CAST(REPLACE(substr("Order_Date", 1, 2), '/', '') AS INTEGER) <= 9 THEN 'Q3'
        ELSE 'Q4'
    END AS Quarter
FROM sales_orders;

-- BLOCK1 — KPI

SELECT 
    SUM(sales) AS Total_Sales,
    SUM(profit) AS Total_Profit,
    (SUM(profit) / SUM(sales)) * 100 AS Profit_Margin,
    COUNT(DISTINCT order_id) AS Number_of_Orders,
    SUM(sales) / COUNT(DISTINCT order_id) AS Average_Order_Value
FROM sales_orders;

-- BLOCK 2 — SALES ANALYSIS
-- Sales by Region
SELECT so.region, SUM(so.sales) AS Total_Sales
FROM sales_orders so
GROUP BY so.region
ORDER BY Total_Sales DESC;

-- Sales by Category

SELECT dp.category, SUM(so.sales) AS Total_Sales
FROM dim_products dp 
JOIN sales_orders so USING (product_id)
GROUP BY dp.category
ORDER BY Total_Sales;

-- Sales by Sub-Category
-- High vs Low discount performance
SELECT dp.sub_category, SUM(so.sales) AS Total_Sales
FROM dim_products dp 
JOIN sales_orders so USING (product_id)
GROUP BY dp.sub_category
ORDER BY Total_Sales;

-- Discount impact by category
SELECT 
    dp.category,
    ROUND(AVG(so.discount), 3) AS avg_discount,
    SUM(so.sales) AS total_sales,
    SUM(so.profit) AS total_profit,
    ROUND((SUM(so.profit) / SUM(so.sales)) * 100, 2) AS profit_margin
FROM sales_orders so
JOIN dim_products dp USING (product_id)
GROUP BY dp.category;

-- Discount vs sales/profit
SELECT 
    discount,
    SUM(sales),
    SUM(profit)
FROM sales_orders
GROUP BY discount;

-- High vs Low discount impact
SELECT 
    CASE WHEN discount >= 0.3 THEN 'High' 
    ELSE 'Low' 
    END AS discount_group,
    SUM(sales),
    SUM(profit)
FROM sales_orders
GROUP BY discount_group;

-- BLOCK 3 — CUSTOMER ANALYSIS
-- Top 10 Customers by Sales
SELECT * FROM (
    SELECT 
        dc.customer_Name, 
        SUM(so.sales) AS Total_Sales,
        DENSE_RANK() OVER (ORDER BY SUM(so.sales) DESC) as ranking
    FROM sales_orders so
    JOIN dim_customers dc USING (customer_id)
    GROUP BY dc.customer_Name
) WHERE ranking <= 10;

-- Top 10 Customers by Profit
SELECT * FROM (
	SELECT
		dc.customer_name, 
		SUM(so.profit) AS Total_Profit,
		DENSE_RANK() OVER (ORDER BY SUM(so.profit) DESC) as ranking
	FROM dim_customers dc
	JOIN sales_orders so USING (customer_id)
    GROUP BY dc.customer_Name
) WHERE ranking <= 10;

-- Repeat Customers
SELECT dc.customer_name, COUNT(so.customer_id) AS Amount_of_orders
FROM dim_customers dc
JOIN sales_orders so USING (customer_id)
GROUP BY dc.customer_name
HAVING COUNT(so.customer_id) >= 2
ORDER BY 2 DESC;

-- Customer Segmentation by purchase volume
SELECT customer_id, SUM(sales) AS purchase_volume,
	CASE WHEN SUM(sales) > 10000 THEN 'VIP'
	 	WHEN SUM(Sales) >= 5000 THEN 'Premium'
     	WHEN SUM(Sales) >= 1000 THEN 'Regular'
     	ELSE 'Low Value'
    END AS Customer_Segment
FROM sales_orders so
GROUP BY Customer_id
ORDER BY 2 DESC;

-- Profitability-based segmentation
SELECT customer_id, SUM(profit) AS profitability,
	CASE WHEN SUM(Profit) > 3000 THEN 'Highly Profitable'
    WHEN SUM(Profit) > 1000 THEN 'Profitable'
    WHEN SUM(Profit) > 0 THEN 'Low Profit'
    ELSE 'Loss-making'
    END AS Customer_Segment
FROM sales_orders so
GROUP BY Customer_id
ORDER BY 2 DESC;

-- RFM analysis
SELECT 
    customer_id, 
    R_score, F_score, M_score,
    CASE 
        WHEN F_score = 1 AND R_score >= 4 THEN 'First-timers'
        WHEN F_score = 1 AND R_score < 4 THEN 'One-timers'
        WHEN R_score = 5 AND F_score >= 4 THEN 'Top Tier'
        WHEN R_score >= 3 AND F_score >= 3 THEN 'Repeat Buyers'
        WHEN R_score <= 2 THEN 'Departing'
        ELSE 'Other'
    END AS Segment
FROM (
    SELECT 
        customer_id,
        NTILE(5) OVER (ORDER BY MAX(order_date) ASC) AS R_score,
        NTILE(5) OVER (ORDER BY COUNT(order_id) DESC) AS F_score,
        NTILE(5) OVER (ORDER BY SUM(sales) DESC) AS M_score
    FROM sales_orders
    GROUP BY customer_id
) AS rfm_scores
ORDER BY Segment DESC;

-- Customer profitability + margin
SELECT 
    customer_id,
    SUM(sales),
    SUM(profit),
    (SUM(profit)/SUM(sales))*100 AS margin
FROM sales_orders
GROUP BY customer_id;

-- BLOCK 4 — TIME ANALYSIS
-- Monthly Sales Trend
SELECT ROUND(SUM(sales), 0), dd.month_name
FROM sales_orders so
JOIN dim_date dd ON so.Order_Date = dd.Date
GROUP BY dd.month_name
ORDER BY 1 DESC;
-- Quarterly Growth
SELECT ROUND(SUM(sales), 0), dd.quarter
FROM sales_orders so
JOIN dim_date dd ON so.Order_Date = dd.Date
GROUP BY dd.quarter
ORDER BY 1;
-- YoY / MoM Growth
WITH MonthlySales AS (
    SELECT 
        dd.Year, 
        dd.Month_Number, 
        dd.Month_Name, 
        SUM(so.sales) AS current_sales
    FROM sales_orders so
    JOIN dim_date dd ON so.Order_Date = dd.Date
    GROUP BY dd.Year, dd.Month_Number, dd.Month_Name
)
SELECT 
    Year, 
    Month_Name, 
    current_sales,
    LAG(current_sales) OVER (ORDER BY Year, Month_Number) AS previous_sales,
    ROUND((current_sales - LAG(current_sales) OVER (ORDER BY Year, Month_Number)) 
          / LAG(current_sales) OVER (ORDER BY Year, Month_Number) * 100, 2) AS pct_growth
FROM MonthlySales;

-- BLOCK 5 — BUSINESS INSIGHTS
-- Which 20% of customers generate 80% revenue?
WITH CustomerRevenue AS (
    SELECT 
        customer_id, 
        SUM(sales) AS total_customer_sales
    FROM sales_orders
    GROUP BY customer_id
),
RunningTotal AS (
    SELECT 
        customer_id,
        total_customer_sales,
        SUM(total_customer_sales) OVER (ORDER BY total_customer_sales DESC) AS running_sales,
        SUM(total_customer_sales) OVER () AS grand_total
    FROM CustomerRevenue
)
SELECT 
    customer_id,
    total_customer_sales
FROM RunningTotal
WHERE running_sales <= (grand_total * 0.8)
ORDER BY total_customer_sales;

-- Which products are loss-making?
SELECT dp.product_name, ROUND(SUM(profit), 2) AS loss
FROM dim_products dp 
JOIN sales_orders so USING (product_id)
GROUP BY 1
HAVING SUM(profit) < 0
ORDER BY 2;
-- Which region is most profitable?
SELECT so.region, ROUND(SUM(profit), 2) AS profit
FROM sales_orders so
GROUP BY 1
ORDER BY 2 DESC;

-- Product profitability
SELECT 
    product_id,
    SUM(sales) AS total_sales,
    SUM(profit) AS total_profit
FROM sales_orders
GROUP BY product_id;



SELECT Product_ID, COUNT(*)
FROM dim_products
GROUP BY Product_ID
HAVING COUNT(*) > 1;
