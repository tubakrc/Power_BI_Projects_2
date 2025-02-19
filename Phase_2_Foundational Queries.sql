--Phase 2: Foundational Queries
--	1. Basic Queries
SELECT *
FROM olist_customers_dataset;

SELECT *
FROM olist_geolocation_dataset;

SELECT *
FROM olist_order_items_dataset;

SELECT *
FROM olist_order_payments_dataset;

SELECT *
FROM olist_order_reviews_dataset;

SELECT *
FROM olist_orders_dataset;

SELECT *
FROM olist_products_dataset;

SELECT *
FROM olist_sellers_dataset;

SELECT *
FROM product_category_name_translation;

SELECT TOP 10 *
FROM olist_customers_dataset;

SELECT TOP 10 *
FROM olist_geolocation_dataset;

SELECT TOP 10 *
FROM olist_order_items_dataset;

SELECT TOP 10 *
FROM olist_order_payments_dataset;

SELECT TOP 10 *
FROM olist_order_reviews_dataset;

SELECT TOP 10 *
FROM olist_orders_dataset;

SELECT TOP 10 *
FROM olist_products_dataset;

SELECT TOP 10 *
FROM olist_sellers_dataset;

SELECT TOP 10 *
FROM product_category_name_translation;

SELECT COUNT(*) AS total_orders
FROM olist_orders_dataset;

--List unique customer states available in the dataset.
SELECT DISTINCT customer_state
FROM olist_customers_dataset;

--List all customers from a specific city
SELECT *
FROM olist_customers_dataset
WHERE customer_city = 'sao paulo';

--Retrieve all orders with payment details for a given date range.
SELECT o.order_id
	,o.order_purchase_timestamp
	,PD.payment_type
	,PD.payment_value
FROM olist_orders_dataset AS O
INNER JOIN olist_order_payments_dataset AS PD ON O.order_id = PD.order_id
WHERE O.order_purchase_timestamp BETWEEN '2017-01-01'
		AND '2018-02-01'
ORDER BY O.order_purchase_timestamp ASC;

-- List the top 5 most expensive orders based on payment value.
SELECT TOP 5 O.order_id
	,SUM(OP.payment_value) AS TotalPayment
FROM olist_orders_dataset O
INNER JOIN olist_order_payments_dataset OP ON O.order_id = OP.order_id
GROUP BY O.order_id
ORDER BY TotalPayment DESC;

--2. Joins
--Query orders with customer and seller details.
SELECT O.order_id
	,C.customer_unique_id
	,C.customer_city
	,S.seller_id
	,S.seller_city
FROM olist_orders_dataset O
INNER JOIN olist_order_items_dataset OI ON O.order_id = OI.order_id
INNER JOIN olist_customers_dataset C ON C.customer_id = O.customer_id
INNER JOIN olist_sellers_dataset S ON S.seller_id = OI.seller_id;

--Retrieve product details for all items for a specific order.
SELECT DISTINCT OI.order_id
	,P.product_id
	,P.product_category_name
	,P.product_weight_g
	,P.product_photos_qty
FROM olist_products_dataset P
INNER JOIN olist_order_items_dataset OI ON P.product_id = OI.product_id
WHERE OI.order_id = '0008288aa423d2a3f00fcb17cd7d8719';

--Find the number of sellers operating in each state.
SELECT seller_state
	,COUNT(DISTINCT seller_id) AS NumberOfSellers
FROM olist_sellers_dataset
GROUP BY seller_state

--Find the most frequently ordered product category.
SELECT TOP (1) P.product_category_name
	,COUNT(OI.order_id) AS OrderCount
FROM olist_products_dataset P
INNER JOIN olist_order_items_dataset OI ON P.product_id = OI.product_id
GROUP BY P.product_category_name
ORDER BY OrderCount DESC;

--	3. Filtering
--Filter orders with reviews below a certain rating.
SELECT O.order_id
	,R.review_score
	,R.review_comment_message
FROM olist_orders_dataset O
INNER JOIN olist_order_reviews_dataset R ON O.order_id = R.order_id
WHERE review_score < 3;

--List products sold by sellers in a specific region.
SELECT DISTINCT P.product_category_name
	,S.seller_state
FROM olist_products_dataset P
INNER JOIN olist_order_items_dataset OI ON P.product_id = OI.product_id
INNER JOIN olist_sellers_dataset S ON OI.seller_id = S.seller_id
WHERE S.seller_state = 'SP'
GROUP BY P.product_category_name
	,S.seller_state;

--List customers who gave a 5-star rating along with their location.
SELECT DISTINCT r.review_score
	,C.customer_unique_id
	,C.customer_city
	,C.customer_state
FROM olist_order_reviews_dataset R
INNER JOIN olist_orders_dataset O ON O.order_id = R.order_id
INNER JOIN olist_customers_dataset C ON C.customer_id = O.customer_id
WHERE R.review_score = 5

--Find sellers with the highest number of orders and their locations.
SELECT TOP (5) S.seller_id
	,S.seller_state
	,S.seller_city
	,COUNT(OI.order_id) AS TotalOrder
FROM olist_order_items_dataset OI
INNER JOIN olist_sellers_dataset S ON OI.seller_id = S.seller_id
GROUP BY S.seller_id
	,S.seller_state
	,S.seller_city
ORDER BY TotalOrder DESC;
1