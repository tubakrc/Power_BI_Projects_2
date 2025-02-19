--Phase 5: Business Insights

--1. Revenue Analysis

--Identify top-performing categories, sellers, and regions.
CREATE VIEW v_top_performing AS
SELECT 
    P.product_category_name, 
    OI.seller_id, 
    C.customer_state AS region, 
    SUM(OI.price) AS total_revenue
FROM olist_order_items_dataset OI
JOIN olist_products_dataset P ON OI.product_id = P.product_id
JOIN olist_orders_dataset O ON OI.order_id = O.order_id
JOIN olist_customers_dataset C ON O.customer_id = C.customer_id
GROUP BY P.product_category_name, OI.seller_id, C.customer_state;
--ORDER BY total_revenue DESC;

--Find the most profitable product categories by month.
CREATE VIEW v_most_profit_product AS
SELECT 
    FORMAT(O.order_purchase_timestamp, 'yyyy-MM') AS month,
    P.product_category_name,
    SUM(OI.price) AS total_revenue
FROM olist_order_items_dataset OI
JOIN olist_products_dataset P ON OI.product_id = P.product_id
JOIN olist_orders_dataset O ON OI.order_id = O.order_id
GROUP BY FORMAT(O.order_purchase_timestamp, 'yyyy-MM'), P.product_category_name;
--ORDER BY total_revenue DESC;

--Analyze seasonal trends in sales and customer activity.
CREATE VIEW v_seasonal_trends AS
SELECT 
    DATEPART(YEAR, O.order_purchase_timestamp) AS year,
    DATEPART(MONTH, O.order_purchase_timestamp) AS month,
    COUNT(O.order_id) AS total_orders,
    SUM(OI.price) AS total_sales
FROM olist_orders_dataset O
JOIN olist_order_items_dataset OI ON O.order_id = OI.order_id
GROUP BY DATEPART(YEAR, O.order_purchase_timestamp), DATEPART(MONTH, O.order_purchase_timestamp);
--ORDER BY year, month;


--2. Customer Segmentation

--Identify high-value customers based on order frequency and value.
CREATE VIEW v_high_value_customers AS
SELECT 
    O.customer_id, 
    COUNT(O.order_id) AS total_orders, 
    SUM(OI.price) AS total_spent
FROM olist_orders_dataset O
JOIN olist_order_items_dataset OI ON O.order_id = OI.order_id
GROUP BY O.customer_id
HAVING COUNT(O.order_id) > 10; -- Considered a frequent customer
--ORDER BY total_spent DESC;

select distinct(customer_tier) from v_customer_tiers
--Use SQL to classify customers into tiers (e.g., Bronze, Silver, Gold).
CREATE VIEW v_customer_tiers AS
SELECT 
    C.customer_id,
    C.customer_unique_id,
    SUM(OI.price) AS total_spent,
    CASE 
        WHEN SUM(OI.price) > 5000 THEN 'Gold'
        WHEN SUM(OI.price) BETWEEN 2000 AND 5000 THEN 'Silver'
        ELSE 'Bronze'
    END AS customer_tier
FROM olist_customers_dataset C
JOIN olist_orders_dataset O ON C.customer_id = O.customer_id
JOIN olist_order_items_dataset OI ON O.order_id = OI.order_id
GROUP BY C.customer_id, C.customer_unique_id;
--ORDER BY total_spent DESC;

--RFM Analysis

--RFM (Recency, Frequency, Monetary) is used to segment customers based on:

--Recency (R) → How recently a customer made a purchase
--Frequency (F) → How often they purchase
--Monetary (M) → How much they spend
--Each customer is assigned a score for R, F, and M, and classified into groups like loyal, high-value, at-risk, churned, etc.

--Insights from RFM Analysis
--Best Customers → Offer loyalty rewards, upsell/cross-sell strategies.
--Loyal Customers → Provide exclusive deals to maintain engagement.
--At-Risk Customers → Target with reactivation campaigns.
--Lost Customers → Identify reasons for churn and recover them.

CREATE VIEW v_RFM_analysis AS
WITH RFM_Calculations AS (
    SELECT 
        O.customer_id,
        DATEDIFF(DAY, MAX(O.order_purchase_timestamp), GETDATE()) AS recency,  -- Days since last purchase
        COUNT(DISTINCT O.order_id) AS frequency,  -- Total number of orders
        SUM(P.payment_value) AS monetary  -- Total spending
    FROM olist_orders_dataset O
    JOIN olist_order_payments_dataset P ON O.order_id = P.order_id
    GROUP BY O.customer_id
),
RFM_Scored AS (
    SELECT 
        customer_id,
        recency,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency ASC) AS recency_score,  -- Lower recency = Higher score
        NTILE(5) OVER (ORDER BY frequency DESC) AS frequency_score,  -- Higher frequency = Higher score
        NTILE(5) OVER (ORDER BY monetary DESC) AS monetary_score  -- Higher spending = Higher score
    FROM RFM_Calculations
)
SELECT 
    customer_id,
    recency, frequency, monetary,
    recency_score, frequency_score, monetary_score,
    (recency_score + frequency_score + monetary_score) AS rfm_total_score,
    CASE 
        WHEN (recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4) THEN 'Best Customers'
        WHEN (recency_score >= 4 AND frequency_score >= 3) THEN 'Loyal Customers'
        WHEN (recency_score >= 3 AND frequency_score <= 2) THEN 'At Risk'
        WHEN (recency_score = 1) THEN 'Lost Customers'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM RFM_Scored
--ORDER BY rfm_total_score DESC;

--Customer Lifetime Value (CLV) Analysis

--CLV=(AverageOrderValue)×(PurchaseFrequency)×(CustomerLifespan)

--Where:
--Average Order Value (AOV) = Total Revenue / Total Orders
--Purchase Frequency (PF) = Total Orders / Unique Customers
--Customer Lifespan (CL) = Average time (in months/years) a customer remains active

--CLV Components
--Recency: Days since last purchase.
--Frequency: Total number of orders.
--Monetary: Total revenue from the customer.
--Avg Order Value = SUM(payment_value) / COUNT(orders).
--Customer Lifespan (Years) = How many years the customer has been active.
--Purchase Frequency = frequency / lifespan.

--CLV=Average Order Value × Purchase Frequency
--This predicts future spending of a customer based on past behavior.

--Classify Customers Based on CLV
--High CLV (>500$): VIP Customers, should get premium services.
--Medium CLV (200-500$): Retarget with personalized offers.
--Low CLV (<200$): Could be at risk of churn.

--Loyalty Strategy?
--Best Customers (High RFM & High CLV) → VIP Programs, Exclusive Offers.
--Loyal Customers (Medium CLV, High Frequency) → Rewards for repeated purchases.
--At-Risk Customers (High Recency, Low Frequency, Low CLV) → Reactivation Campaigns.
--Churned Customers (Low CLV & RFM) → Discounts & Win-Back Emails.

CREATE VIEW v_CLV AS
WITH RFM_Calculations AS (
    SELECT 
        O.customer_id,
        DATEDIFF(DAY, MAX(O.order_purchase_timestamp), GETDATE()) AS recency,
        COUNT(DISTINCT O.order_id) AS frequency,
        SUM(P.payment_value) AS monetary,
        AVG(P.payment_value) AS avg_order_value
    FROM olist_orders_dataset O
    JOIN olist_order_payments_dataset P ON O.order_id = P.order_id
    GROUP BY O.customer_id
),
Customer_Lifespan AS (
    SELECT 
        customer_id,
        COUNT(DISTINCT YEAR(order_purchase_timestamp)) AS customer_lifespan_years
    FROM olist_orders_dataset
    GROUP BY customer_id
),
CLV_Calculation AS (
    SELECT 
        RFM_Calculations.customer_id,
        RFM_Calculations.recency,
        RFM_Calculations.frequency,
        RFM_Calculations.monetary,
        RFM_Calculations.avg_order_value,
        Customer_Lifespan.customer_lifespan_years,
        (RFM_Calculations.frequency / NULLIF(Customer_Lifespan.customer_lifespan_years, 0)) AS purchase_frequency,
        (RFM_Calculations.avg_order_value * (RFM_Calculations.frequency / NULLIF(Customer_Lifespan.customer_lifespan_years, 0))) AS clv
    FROM RFM_Calculations
    JOIN Customer_Lifespan ON RFM_Calculations.customer_id = Customer_Lifespan.customer_id
)
SELECT 
    customer_id,
    recency, frequency, monetary, avg_order_value, customer_lifespan_years,
    purchase_frequency, clv,
    CASE 
        WHEN clv > 500 THEN 'High Value'
        WHEN clv BETWEEN 200 AND 500 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CLV_Category
FROM CLV_Calculation
--ORDER BY clv DESC;


--3. Logistics Insights

--Calculate the average delivery time per region.
CREATE VIEW v_avg_delivery_time AS
SELECT 
    C.customer_state AS region, 
    AVG(DATEDIFF(DAY, O.order_purchase_timestamp, O.order_delivered_customer_date)) AS avg_delivery_days
FROM olist_orders_dataset O
JOIN olist_customers_dataset C ON O.customer_id = C.customer_id
WHERE O.order_status = 'delivered'
GROUP BY C.customer_state;
--ORDER BY avg_delivery_days;


--Analyze delivery delays by product or seller.
CREATE VIEW v_avg_delivery_delays AS
SELECT 
    P.product_category_name, 
    OI.seller_id, 
    AVG(DATEDIFF(DAY, O.order_estimated_delivery_date, O.order_delivered_customer_date)) AS avg_delay_days
FROM olist_orders_dataset O
JOIN olist_order_items_dataset OI ON O.order_id = OI.order_id
JOIN olist_products_dataset P ON OI.product_id = P.product_id
WHERE O.order_delivered_customer_date > O.order_estimated_delivery_date
GROUP BY P.product_category_name, OI.seller_id;
--ORDER BY avg_delay_days DESC;


--4. Marketing Insights

--Find products frequently purchased together.
CREATE VIEW v_cross_sell AS
SELECT 
    OI1.product_id AS product_A,
    OI2.product_id AS product_B,
    COUNT(*) AS purchase_count
FROM olist_order_items_dataset OI1
JOIN olist_order_items_dataset OI2 
    ON OI1.order_id = OI2.order_id 
    AND OI1.product_id < OI2.product_id
GROUP BY OI1.product_id, OI2.product_id;
--ORDER BY purchase_count DESC;

--Find top cross-sell product recommendations.
CREATE VIEW v_top_cross_sell AS
SELECT 
    P1.product_category_name AS product_A, 
    P2.product_category_name AS product_B, 
    COUNT(*) AS purchase_count
FROM olist_order_items_dataset OI1
JOIN olist_order_items_dataset OI2 
    ON OI1.order_id = OI2.order_id 
    AND OI1.product_id < OI2.product_id
JOIN olist_products_dataset P1 ON OI1.product_id = P1.product_id
JOIN olist_products_dataset P2 ON OI2.product_id = P2.product_id
GROUP BY P1.product_category_name, P2.product_category_name;
--ORDER BY purchase_count DESC;


--Analyze customer churn based on order history.
CREATE VIEW v_customer_churn AS
WITH MaxOrderDate AS (
    SELECT DATEADD(DAY, 2, MAX(order_purchase_timestamp)) AS dataset_max_date
    FROM olist_orders_dataset
)
SELECT 
    C.customer_unique_id, 
    MAX(O.order_purchase_timestamp) AS last_order_date,
    DATEDIFF(DAY, MAX(O.order_purchase_timestamp), M.dataset_max_date) AS days_since_last_order,
    CASE 
        WHEN DATEDIFF(DAY, MAX(O.order_purchase_timestamp), M.dataset_max_date) > 180 THEN 'Churned'
        WHEN DATEDIFF(DAY, MAX(O.order_purchase_timestamp), M.dataset_max_date) BETWEEN 90 AND 180 THEN 'At-Risk'
        ELSE 'Active'
    END AS churn_status
FROM olist_customers_dataset C
JOIN olist_orders_dataset O ON C.customer_id = O.customer_id
CROSS JOIN MaxOrderDate M
GROUP BY C.customer_unique_id, M.dataset_max_date;


--Find sellers with the highest customer retention rate

--Retention Criteria:
--Returning Customers: Customers who placed more than one order.
--Long-Term Retention: Customers who placed an order at least 90+ days after their first purchase.

select distinct(retention_rate_percent) from v_retention_rate
CREATE VIEW v_retention_rate AS
WITH CustomerFirstLastOrder AS (
    SELECT 
        OI.seller_id, 
        O.customer_id, 
        MIN(O.order_purchase_timestamp) AS first_order,
        MAX(O.order_purchase_timestamp) AS last_order,
        COUNT(O.order_id) AS total_orders,
        DATEDIFF(DAY, MIN(O.order_purchase_timestamp), MAX(O.order_purchase_timestamp)) AS retention_days
    FROM olist_orders_dataset O
    JOIN olist_order_items_dataset OI ON O.order_id = OI.order_id
    GROUP BY OI.seller_id, O.customer_id
)
SELECT 
    seller_id,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS returning_customers,
    SUM(CASE WHEN retention_days >= 90 THEN 1 ELSE 0 END) AS long_term_retained_customers,
    ROUND(100.0 * SUM(CASE WHEN retention_days >= 90 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS retention_rate_percent
FROM CustomerFirstLastOrder
GROUP BY seller_id;
--ORDER BY retention_rate_percent DESC;


SELECT customer_id, COUNT(order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY customer_id
ORDER BY total_orders DESC;


--Conclusion
--Why is Retention 0?
--Since there are no repeat purchases, it means:
--Each customer only bought once in the dataset.
--returning_customers will always be 0.
--long_term_retained_customers will also be 0.
--Retention rate = 0%, because no one made a second purchase.

--5. Time-Series Analysis

--Monthly Revenue Trends
CREATE VIEW v_monthly_revenue_trends AS
SELECT 
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
    SUM(payment_value) AS total_revenue
FROM olist_orders_dataset O
JOIN olist_order_payments_dataset OP ON O.order_id = OP.order_id
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM');
--ORDER BY order_month;

--Year-over-Year (YoY) Growth
--The year-over-year revenue growth rate.

CREATE VIEW v_YOY_growth AS
WITH RevenueByYear AS (
    SELECT 
        YEAR(order_purchase_timestamp) AS order_year,
        SUM(payment_value) AS total_revenue
    FROM olist_orders_dataset O
    JOIN olist_order_payments_dataset OP ON O.order_id = OP.order_id
    GROUP BY YEAR(order_purchase_timestamp)
)
SELECT 
    order_year,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_year) AS previous_year_revenue,
    ROUND(100.0 * (total_revenue - LAG(total_revenue) OVER (ORDER BY order_year)) / NULLIF(LAG(total_revenue) OVER (ORDER BY order_year), 0), 2) AS yoy_growth_rate
FROM RevenueByYear;


--Weekday vs. Weekend Sales Performance
CREATE VIEW v_weekday_vs_weekend AS
SELECT 
    DATENAME(WEEKDAY, order_purchase_timestamp) AS day_of_week,
    COUNT(DISTINCT OP.order_id) AS total_orders,
    SUM(payment_value) AS total_revenue
FROM olist_orders_dataset O
JOIN olist_order_payments_dataset OP ON O.order_id = OP.order_id
GROUP BY DATENAME(WEEKDAY, order_purchase_timestamp)
--ORDER BY total_orders DESC;


--6. Predictive Modeling Queries

--Expected Sales Growth (Moving Average)
--A 3-month moving average to smooth sales trends and predict future values.
--Insight: This moving average helps predict short-term trends.

CREATE VIEW v_expected_sales_growth AS
WITH MonthlySales AS (
    SELECT 
        FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
        SUM(payment_value) AS total_revenue
    FROM olist_orders_dataset O
    JOIN olist_order_payments_dataset OP ON O.order_id = OP.order_id
    GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
)
SELECT 
    order_month,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_sales
FROM MonthlySales;


--Forecast Next Month’s Sales (Linear Growth Model)
--Predicts sales for the next month using a simple linear regression approximation.
--Insight: Helps estimate next month’s sales based on past trends.

--Column        ||	Explanation
--order_month   || The sales month (yyyy-MM).
--total_revenue	|| Total sales for that month.
--moving_avg_sales || 3-month Moving Average: The average of this month and the previous two months (AVG() OVER()).
--predicted_growth || Sales Growth Prediction: Difference between next month (LEAD()) and last month (LAG()), divided by 2 (to get an estimate of the trend).
--next_month_forecast || Next Month’s Sales Forecast: Current sales + predicted growth.

CREATE VIEW v_linear_growth_model AS
WITH MonthlySales AS (
    SELECT 
        YEAR(order_purchase_timestamp) * 12 + MONTH(order_purchase_timestamp) AS time_index,
        FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
        SUM(payment_value) AS total_revenue
    FROM olist_orders_dataset O
    JOIN olist_order_payments_dataset OP ON O.order_id = OP.order_id
    GROUP BY YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp), FORMAT(order_purchase_timestamp, 'yyyy-MM')
)
SELECT 
    order_month,
    total_revenue,
    ROUND(AVG(total_revenue) OVER (ORDER BY time_index ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_sales,
    ROUND((LEAD(total_revenue) OVER (ORDER BY time_index) - LAG(total_revenue) OVER (ORDER BY time_index)) / 2, 2) AS predicted_growth,
    ROUND(total_revenue + (LEAD(total_revenue) OVER (ORDER BY time_index) - LAG(total_revenue) OVER (ORDER BY time_index)) / 2, 2) AS next_month_forecast
FROM MonthlySales;


