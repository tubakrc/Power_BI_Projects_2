--Phase 3: Advanced Analysis
--1. Aggregations
--Calculate total revenue per month.
SELECT MONTH(O.order_purchase_timestamp) AS Month
	,SUM(P.payment_value) AS TotalPayment
FROM olist_order_payments_dataset P
INNER JOIN olist_orders_dataset O ON P.order_id = O.order_id
GROUP BY MONTH(O.order_purchase_timestamp)
ORDER BY Month;

--Calculate total revenue per seller per month.
SELECT OI.seller_id
	,MONTH(O.order_purchase_timestamp) AS Month
	,SUM(P.payment_value) AS TotalPayment
FROM olist_order_payments_dataset P
INNER JOIN olist_orders_dataset O ON P.order_id = O.order_id
INNER JOIN olist_order_items_dataset OI ON OI.order_id = O.order_id
GROUP BY MONTH(O.order_purchase_timestamp)
	,OI.seller_id
ORDER BY Month
	,TotalPayment DESC;

--Determine average review scores for each seller.
SELECT DISTINCT OI.seller_id
	,AVG(R.review_score) AS AverageScore
FROM olist_order_reviews_dataset R
INNER JOIN olist_order_items_dataset OI ON R.order_id = OI.order_id
GROUP BY OI.seller_id
ORDER BY AverageScore DESC;

--Find the top 5 sellers with the highest average review scores (min. 10 reviews).
SELECT TOP (5) OI.seller_id
	,AVG(R.review_score) AS AverageScore
	,COUNT(DISTINCT R.review_id) AS ReviewCount
FROM olist_order_reviews_dataset R
INNER JOIN olist_order_items_dataset OI ON R.order_id = OI.order_id
GROUP BY OI.seller_id
HAVING COUNT(DISTINCT R.review_id) > = 10
ORDER BY AverageScore DESC;

--2. Nested Queries
--Find the top 5 products with the highest total sales.
SELECT TOP (5) product_id
	,SUM(price * order_item_id) AS TotalSales
FROM olist_order_items_dataset
GROUP BY product_id
ORDER BY TotalSales DESC;

--Find the top 5 product categories generating the highest total payment value.
SELECT DISTINCT TOP (5) P.product_category_name
	,P.product_id
	,SUM(OP.payment_value) AS TotalPayment
FROM olist_products_dataset P
INNER JOIN olist_order_items_dataset OI ON OI.product_id = P.product_id
INNER JOIN olist_order_payments_dataset OP ON OP.order_id = OI.order_id
GROUP BY P.product_category_name
	,P.product_id
ORDER BY TotalPayment DESC;

--Find the product category with the highest total sales.
SELECT TOP (1) p.product_category_name
	,SUM(oi.price * oi.order_item_id) AS total_sales
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC;

--List customers who have ordered more than 10 times.
SELECT DISTINCT O.customer_id
	,COUNT(O.order_id) AS OrderNum
FROM olist_orders_dataset O
GROUP BY O.customer_id
HAVING COUNT(O.order_id) > 10;

--List customers with the highest total spending.
SELECT TOP (1) o.customer_id
	,SUM(p.payment_value) AS total_spent
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
GROUP BY o.customer_id
ORDER BY total_spent DESC;

--3. Window Functions
--Rank sellers by revenue within each region.
SELECT s.seller_state
	,s.seller_id
	,SUM(p.payment_value) AS total_revenue
	,RANK() OVER (
		PARTITION BY s.seller_state ORDER BY SUM(p.payment_value) DESC
		) AS rank
FROM olist_order_items_dataset oi
JOIN olist_sellers_dataset s ON oi.seller_id = s.seller_id
JOIN olist_order_payments_dataset p ON oi.order_id = p.order_id
GROUP BY s.seller_state
	,s.seller_id;

--Rank customers by total spending.
SELECT O.customer_id
	,SUM(P.payment_value) AS total_spent
	,RANK() OVER (
		ORDER BY SUM(P.payment_value) DESC
		) AS rank
FROM olist_order_payments_dataset P
INNER JOIN olist_orders_dataset O ON P.order_id = O.order_id
GROUP BY O.customer_id;

--Calculate the cumulative sales per customer.
SELECT o.customer_id
	,o.order_purchase_timestamp
	,SUM(p.payment_value) OVER (
		PARTITION BY o.customer_id ORDER BY o.order_purchase_timestamp
		) AS cumulative_sales
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id;

--4. Subqueries
--Identify products with sales greater than the average.
SELECT product_id
	,SUM(price) AS total_sales
FROM olist_order_items_dataset
GROUP BY product_id
HAVING SUM(price) > (
		SELECT AVG(total_sales)
		FROM (
			SELECT SUM(price) AS total_sales
			FROM olist_order_items_dataset
			GROUP BY product_id
			) AS avg_sales
		);

--Retrieve orders with more items than the average order size.
SELECT order_id
	,COUNT(order_item_id) AS total_items
FROM olist_order_items_dataset
GROUP BY order_id
HAVING COUNT(order_item_id) > (
		SELECT AVG(total_items)
		FROM (
			SELECT COUNT(order_item_id) AS total_items
			FROM olist_order_items_dataset
			GROUP BY order_id
			) AS avg_order
		);

--5. Views
--Create a view for monthly sales performance.
CREATE VIEW monthly_sales
AS
SELECT MONTH(order_purchase_timestamp) AS Month
	,SUM(payment_value) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
GROUP BY MONTH(order_purchase_timestamp);

SELECT *
FROM monthly_sales
ORDER BY Month;

--Create a view for top-selling products by category.
CREATE VIEW top_selling_products
AS
SELECT p.product_category_name
	,p.product_id
	,SUM(oi.price) AS total_sales
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
	,p.product_id;

SELECT *
FROM top_selling_products
ORDER BY total_sales DESC;
1