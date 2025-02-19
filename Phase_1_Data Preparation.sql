--STEP 1 : CREATE THE DATABASE
CREATE DATABASE Olist_Ecommerce;
GO

USE Olist_Ecommerce;
GO

--STEP 2 : CREATE TABLES
--2.1 olist_orders_dataset
CREATE TABLE olist_orders_dataset (
	order_id NVARCHAR(50) PRIMARY KEY
	,customer_id NVARCHAR(50) NOT NULL
	,order_status NVARCHAR(20)
	,order_purchase_timestamp DATETIME
	,order_approved_at DATETIME
	,order_delivered_carrier_date DATETIME
	,order_delivered_customer_date DATETIME
	,order_estimated_delivery_date DATETIME
	);

--ALTER OF TABLE ORDERS
ALTER TABLE olist_orders_dataset

ALTER COLUMN order_estimated_delivery_date DATETIME NULL;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_estimated_delivery_date NVARCHAR(50);

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_purchase_timestamp DATETIME NULL;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_approved_at DATETIME NULL;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_delivered_carrier_date DATETIME NULL;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_delivered_customer_date DATETIME NULL;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_estimated_delivery_date NVARCHAR(50);

SELECT *
FROM olist_orders_dataset;

--2.2 olist_products_dataset
CREATE TABLE olist_products_dataset (
	product_id NVARCHAR(50) PRIMARY KEY
	,product_category_name NVARCHAR(50)
	,product_name_lenght INT
	,product_description_lenght INT
	,product_photos_qty INT
	,product_weight_g INT
	,product_length_cm INT
	,product_height_cm INT
	,product_width_cm INT
	);

--alter of table products
-- Add column product_name_lenght
ALTER TABLE olist_products_dataset

ALTER COLUMN product_name_lenght INT;

-- Add column product_description_lenght
ALTER TABLE olist_products_dataset

ALTER COLUMN product_description_lenght INT;

-- Add column product_photos_qty
ALTER TABLE olist_products_dataset

ALTER COLUMN product_photos_qty INT;

-- Add column product_weight_g
ALTER TABLE olist_products_dataset

ALTER COLUMN product_weight_g INT;

-- Add column product_length_cm
ALTER TABLE olist_products_dataset

ALTER COLUMN product_length_cm INT;

-- Add column product_height_cm
ALTER TABLE olist_products_dataset

ALTER COLUMN product_height_cm INT;

-- Add column product_width_cm
ALTER TABLE olist_products_dataset

ALTER COLUMN product_width_cm INT;

SELECT *
FROM olist_products_dataset;

--2.3 olist_sellers_dataset
CREATE TABLE olist_sellers_dataset (
	seller_id NVARCHAR(50) PRIMARY KEY
	,seller_zip_code_prefix NVARCHAR(10)
	,seller_city NVARCHAR(50)
	,seller_state NVARCHAR(50)
	);

SELECT *
FROM olist_sellers_dataset;

--2.4 product_category_name_translation
CREATE TABLE product_category_name_translation (
	product_category_name NVARCHAR(50) PRIMARY KEY
	,product_category_name_english NVARCHAR(50)
	);

--2.5 olist_order_items_dataset
CREATE TABLE olist_order_items_dataset (
	order_id NVARCHAR(50) NOT NULL
	,order_item_id INT NOT NULL
	,product_id NVARCHAR(50)
	,seller_id NVARCHAR(50)
	,shipping_limit_date DATETIME
	,price DECIMAL(10, 2)
	,freight_value DECIMAL(10, 2)
	,PRIMARY KEY (
		order_id
		,order_item_id
		)
	,FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id)
	,FOREIGN KEY (product_id) REFERENCES olist_products_dataset(product_id)
	,FOREIGN KEY (seller_id) REFERENCES olist_sellers_dataset(seller_id)
	);

--Alters of table olist_order_items_dataset
-- Add column geolocation_lat
ALTER TABLE olist_order_items_dataset

ALTER COLUMN price DECIMAL(10, 2);

-- Add column geolocation_lng
ALTER TABLE olist_order_items_dataset

ALTER COLUMN freight_value DECIMAL(10, 2);

SELECT *
FROM olist_order_items_dataset;

--2.6 olist_order_payments_dataset
CREATE TABLE olist_order_payments_dataset (
	order_id NVARCHAR(50) NOT NULL
	,payment_sequential INT NOT NULL
	,payment_type NVARCHAR(20)
	,payment_installments INT
	,payment_value DECIMAL(10, 2)
	,PRIMARY KEY (
		order_id
		,payment_sequential
		)
	,FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id)
	);

--Alters of olist_order_payments_dataset
ALTER TABLE olist_order_payments_dataset

ALTER COLUMN payment_value DECIMAL(10, 2);

SELECT *
FROM olist_order_payments_dataset;

--2.7 olist_order_reviews_dataset
CREATE TABLE olist_order_reviews_dataset (
	review_id NVARCHAR(50) PRIMARY KEY
	,order_id NVARCHAR(50) NOT NULL
	,review_score INT
	,review_comment_title NVARCHAR(255)
	,review_comment_message NVARCHAR(MAX)
	,review_creation_date DATETIME
	,review_answer_timestamp DATETIME
	,FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id)
	);

--2.8 olist_customers_dataset
CREATE TABLE olist_customers_dataset (
	customer_id NVARCHAR(50) PRIMARY KEY
	,customer_unique_id NVARCHAR(50)
	,customer_zip_code_prefix NVARCHAR(10)
	,customer_city NVARCHAR(50)
	,customer_state NVARCHAR(50)
	);

--2.9 olist_geolocation_dataset
CREATE TABLE olist_geolocation_dataset (
	geolocation_zip_code_prefix NVARCHAR(10)
	,geolocation_lat DECIMAL(10, 6)
	,geolocation_lng DECIMAL(10, 6)
	,geolocation_city NVARCHAR(50)
	,geolocation_state NVARCHAR(50)
	);

--Alters of table geolocation
-- Add column geolocation_lat
ALTER TABLE olist_geolocation_dataset

ALTER COLUMN geolocation_lat DECIMAL(10, 6);

-- Add column geolocation_lng
ALTER TABLE olist_geolocation_dataset

ALTER COLUMN geolocation_lng DECIMAL(10, 6);

SELECT *
FROM olist_geolocation_dataset;

--STEP 3 : IMPORTS
---C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets
BULK INSERT olist_orders_dataset
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\olist_orders_dataset.csv'
	--FROM 'C:\Users\Tuba\AppData\Local\Microsoft\SQL Server Management Studio\18.0_IsoShell\Settings\SQL Server Management Studio\datasets\olist_orders_dataset.csv'
	WITH (
		FIRSTROW = 2
		,-- Skip the header
		FIELDTERMINATOR = ','
		,-- Use a comma as the column delimiter
		ROWTERMINATOR = '\r\n'
		,-- Use newline as the row delimiter
		TABLOCK -- Locks the table during bulk load
		);

-- For olist_orders_dataset
BULK INSERT olist_orders_dataset
FROM 'path_to_file/olist_orders_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_products_dataset
BULK INSERT olist_products_dataset
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\olist_products_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_sellers_dataset
BULK INSERT olist_sellers_dataset
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\olist_sellers_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For product_category_name_translation
BULK INSERT product_category_name_translation
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\product_category_name_translation.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_order_items_dataset
BULK INSERT olist_order_items_dataset
FROM 'path_to_file/olist_order_items_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_order_payments_dataset
BULK INSERT olist_order_payments_dataset
FROM 'path_to_file/olist_order_payments_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_order_reviews_dataset
BULK INSERT olist_order_reviews_dataset
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\olist_order_reviews_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_customers_dataset
BULK INSERT olist_customers_dataset
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\olist_customers_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

-- For olist_geolocation_dataset
BULK INSERT olist_geolocation_dataset
FROM 'path_to_file/olist_geolocation_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\n'
		,FIRSTROW = 2 -- Skip header row
		);

--Queries
SELECT *
FROM olist_orders_dataset
WHERE order_id = '53cdb2fc8bc7dce0b6741e2150273451' 53 cdb2fc8bc7dce0b6741e2150273451

SELECT TOP 10 *
FROM olist_orders_dataset;

SELECT order_approved_at
	,order_delivered_carrier_date
	,order_delivered_customer_date
	,order_estimated_delivery_date
FROM olist_orders_dataset
WHERE order_delivered_carrier_date IS NULL
	OR order_delivered_customer_date IS NULL
	OR order_estimated_delivery_date IS NULL;

----------
ALTER TABLE olist_orders_dataset

ALTER COLUMN order_estimated_delivery_date DATETIME;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_purchase_timestamp DATETIME;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_approved_at DATETIME;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_delivered_carrier_date DATETIME;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_delivered_customer_date DATETIME;

ALTER TABLE olist_orders_dataset

ALTER COLUMN order_estimated_delivery_date DATETIME;

SELECT COUNT(*) AS Total_Rows
FROM olist_orders_dataset;

SELECT *
FROM olist_orders_dataset
WHERE order_id IS NULL;

SELECT *
FROM product_category_name_translation;

ALTER TABLE olist_products_dataset

ALTER COLUMN product_id VARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_id NVARCHAR(255);

ALTER TABLE olist_order_items_dataset

ALTER COLUMN product_id NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_id NVARCHAR(255);

---
-- Drop the foreign key constraint
ALTER TABLE olist_order_items_dataset

DROP CONSTRAINT FK__olist_ord__produ__2D27B809;

-- Drop the primary key constraint
ALTER TABLE olist_products_dataset

DROP CONSTRAINT PK__olist_pr__47027DF557A6D851;

--
ALTER TABLE olist_products_dataset

ALTER COLUMN product_id NVARCHAR(255) NOT NULL;-- Adjust size as needed

-- Recreate the primary key constraint
ALTER TABLE olist_products_dataset ADD CONSTRAINT PK__olist_pr__47027DF557A6D851 PRIMARY KEY (product_id);

ALTER TABLE olist_order_items_dataset

ALTER COLUMN product_id NVARCHAR(255);

-- Recreate the foreign key constraint
ALTER TABLE olist_order_items_dataset ADD CONSTRAINT FK__olist_ord__produ__2D27B809 FOREIGN KEY (product_id) REFERENCES olist_products_dataset (product_id);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_name_lenght BIGINT;

ALTER TABLE olist_products_dataset

ALTER COLUMN product_name_lenght NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_description_lenght NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_photos_qty NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_weight_g BIGINT;

ALTER TABLE olist_products_dataset

ALTER COLUMN product_length_cm BIGINT;

ALTER TABLE olist_products_dataset

ALTER COLUMN product_height_cm BIGINT;

ALTER TABLE olist_products_dataset

ALTER COLUMN product_width_cm BIGINT;

---
ALTER TABLE olist_products_dataset

ALTER COLUMN product_weight_g NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_length_cm NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_height_cm NVARCHAR(255);

ALTER TABLE olist_products_dataset

ALTER COLUMN product_width_cm NVARCHAR(255);

SELECT *
FROM olist_products_dataset;

SELECT *
FROM olist_products_dataset
WHERE product_id = '0011c512eb256aa0dbbb544d8dffcf6e'
WITH CTE AS (
		SELECT product_id
			,ROW_NUMBER() OVER (
				PARTITION BY product_id ORDER BY (
						SELECT NULL
						)
				) AS rn
		FROM olist_products_dataset
		)

DELETE
FROM CTE
WHERE rn > 1;

SELECT product_id
	,COUNT(*)
FROM olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT *
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('olist_products_dataset');

ALTER TABLE olist_products_dataset NOCHECK CONSTRAINT PK__olist_pr__47027DF557A6D851;

-- Perform your data insert
ALTER TABLE olist_products_dataset CHECK CONSTRAINT PK__olist_pr__47027DF557A6D851;

TRUNCATE TABLE olist_products_dataset;

-- Disable the foreign key constraint
ALTER TABLE olist_order_items_dataset NOCHECK CONSTRAINT FK__olist_ord__produ__2D27B809;

-- Truncate the table
TRUNCATE TABLE olist_products_dataset;

-- Delete the referencing rows
DELETE
FROM olist_order_items_dataset
WHERE product_id IN (
		SELECT product_id
		FROM olist_products_dataset
		);

-- Now, truncate the table
TRUNCATE TABLE olist_products_dataset;

DELETE
FROM olist_products_dataset;

SELECT *
FROM olist_sellers_dataset;

ALTER TABLE olist_order_items_dataset

ALTER COLUMN price NVARCHAR(255);

ALTER TABLE olist_order_items_dataset

ALTER COLUMN freight_value NVARCHAR(255);

DELETE
FROM olist_order_items_dataset;

SELECT *
FROM olist_order_items_dataset;

ALTER TABLE olist_order_items_dataset NOCHECK CONSTRAINT FK__olist_ord__order__2C3393D0;

ALTER TABLE olist_order_payments_dataset

ALTER COLUMN payment_value NVARCHAR(255);

DELETE
FROM olist_order_payments_dataset;

ALTER TABLE olist_order_items_dataset NOCHECK CONSTRAINT FK__olist_ord__order__30F848ED;

ALTER TABLE olist_order_payments_dataset NOCHECK CONSTRAINT FK__olist_ord__order__30F848ED;

SELECT *
FROM olist_order_payments_dataset

SELECT *
FROM olist_order_reviews_dataset;

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_message NVARCHAR(255);

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_message VARCHAR(MAX) COLLATE Modern_Spanish_CI_AS;

SELECT *
FROM olist_customers_dataset;

ALTER TABLE olist_geolocation_dataset

ALTER COLUMN geolocation_lat NVARCHAR(50);

ALTER TABLE olist_geolocation_dataset

ALTER COLUMN geolocation_lng NVARCHAR(50);

SELECT *
FROM olist_geolocation_dataset;

DELETE
FROM olist_orders_dataset;

SELECT *
FROM olist_orders_dataset;

SELECT *
FROM olist_products_dataset;

SELECT *
FROM olist_sellers_dataset;

SELECT *
FROM product_category_name_translation;

SELECT *
FROM olist_order_items_dataset;

SELECT *
FROM olist_order_payments_dataset;

SELECT *
FROM olist_order_reviews_dataset;

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_creation_date NVARCHAR(50);

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_answer_timestamp NVARCHAR(50);

SELECT *
FROM olist_order_reviews_dataset;

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_message NVARCHAR(MAX);

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_title NVARCHAR(MAX);

BULK INSERT olist_order_reviews_dataset
FROM 'C:\Users\Tuba\OneDrive\Belgeler\SQL Server Management Studio\datasets\olist_order_reviews_dataset.csv' WITH (
		FIELDTERMINATOR = ','
		,ROWTERMINATOR = '\r\n'
		,CODEPAGE = '65001'
		,DATAFILETYPE = 'char'
		,
		--TABLOCK,
		FIRSTROW = 2
		,MAXERRORS = 100
		);

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_score NVARCHAR(MAX);

ALTER TABLE olist_order_reviews_dataset NOCHECK CONSTRAINT your_foreign_key_constraint_name;

DELETE
FROM olist_order_reviews_dataset;

ALTER TABLE dbo.olist_order_reviews_dataset

DROP CONSTRAINT PK__olist_or__60883D908255C1B5;

SELECT *
FROM olist_order_reviews_dataset

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_title NVARCHAR(255) COLLATE Latin1_General_100_CI_AI_SC;

----
---- olist_order_reviews_dataset ALTER QUERIES----
-- Ensure review_id remains as PRIMARY KEY
ALTER TABLE olist_order_reviews_dataset ADD CONSTRAINT PK_olist_order_reviews PRIMARY KEY (review_id);

-- Ensure order_id is NOT NULL and maintains the FOREIGN KEY constraint
ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN order_id NVARCHAR(50) NOT NULL;

ALTER TABLE olist_order_reviews_dataset ADD CONSTRAINT FK_olist_order_reviews_orders FOREIGN KEY (order_id) REFERENCES olist_orders_dataset (order_id);

-- Ensure review_score is an integer (no changes needed)
ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_score INT;

-- Enable emoji support for review_comment_title
ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_title NVARCHAR(255) COLLATE Latin1_General_100_CI_AI_SC;

-- Enable emoji support for review_comment_message
ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_comment_message NVARCHAR(MAX) COLLATE Latin1_General_100_CI_AI_SC;

-- Ensure review_creation_date is a valid DATETIME column
ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_creation_date DATETIME;

-- Ensure review_answer_timestamp is a valid DATETIME column
ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_answer_timestamp DATETIME;

---For Primary Key constraint, detecting duplicates
SELECT review_id
	,COUNT(*)
FROM olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;

---deleting duplicates
WITH CTE
AS (
	SELECT review_id
		,ROW_NUMBER() OVER (
			PARTITION BY review_id ORDER BY (
					SELECT NULL
					)
			) AS row_num
	FROM olist_order_reviews_dataset
	)
DELETE
FROM olist_order_reviews_dataset
WHERE review_id IN (
		SELECT review_id
		FROM CTE
		WHERE row_num > 1
		);

SELECT COUNT(*)
FROM olist_order_reviews_dataset
WHERE review_id IS NULL;

SELECT review_creation_date
FROM olist_order_reviews_dataset
WHERE TRY_CONVERT(DATETIME, review_creation_date) IS NULL
	AND review_creation_date IS NOT NULL;

SELECT DISTINCT review_creation_date
FROM olist_order_reviews_dataset;

--datetime conversion
UPDATE olist_order_reviews_dataset
SET review_creation_date = CASE 
		WHEN TRY_CONVERT(DATETIME, review_creation_date, 103) IS NOT NULL
			THEN CONVERT(NVARCHAR(50), TRY_CONVERT(DATETIME, review_creation_date, 103), 120)
		ELSE NULL
		END;

UPDATE olist_order_reviews_dataset
SET review_answer_timestamp = CASE 
		WHEN TRY_CONVERT(DATETIME, review_answer_timestamp, 103) IS NOT NULL
			THEN CONVERT(NVARCHAR(50), TRY_CONVERT(DATETIME, review_answer_timestamp, 103), 120)
		ELSE NULL
		END;

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_creation_date DATETIME NULL;

ALTER TABLE olist_order_reviews_dataset

ALTER COLUMN review_answer_timestamp DATETIME NULL;

SELECT *
FROM olist_order_reviews_dataset;

ALTER TABLE olist_order_reviews_dataset NOCHECK CONSTRAINT PK_olist_order_reviews;

ALTER TABLE olist_order_reviews_dataset NOCHECK CONSTRAINT FK_olist_order_reviews_orders;

ALTER TABLE olist_order_reviews_dataset ADD CONSTRAINT PK_olist_order_reviews PRIMARY KEY (review_id)
	WITH NOCHECK;

ALTER TABLE olist_order_reviews_dataset NOCHECK CONSTRAINT ALL;

ALTER TABLE olist_order_reviews_dataset
	WITH NOCHECK ADD CONSTRAINT FK_olist_order_reviews_orders FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);

-- Drop the primary key constraint
ALTER TABLE olist_order_reviews_dataset

DROP CONSTRAINT PK_olist_order_reviews;

-- Drop the foreign key constraint
ALTER TABLE olist_order_reviews_dataset

DROP CONSTRAINT FK_olist_order_reviews_orders;

SELECT *
FROM olist_order_reviews_dataset;
