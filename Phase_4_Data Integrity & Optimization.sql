--Phase 4: Data Integrity & Optimization

--1. Constraints & Validation

--Add constraints for valid data entry (e.g., positive quantities, non-negative prices).

-- Ensure product quantity is always positive
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT chk_positive_quantity CHECK (order_item_id > 0);

-- Ensure price and freight value are non-negative
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT chk_non_negative_price CHECK (price >= 0);

ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT chk_non_negative_freight CHECK (freight_value >= 0);

--Use DEFAULT values for columns to avoid NULL issues:
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT df_default_price DEFAULT 0 FOR price;

--2. Indexing

--Add indexes to frequently joined or filtered columns (e.g., order_id, customer_id).

-- Index on order_id (frequently used in joins)
CREATE INDEX idx_order_id ON olist_order_items_dataset(order_id);

-- Index on customer_id (used in joins & filtering)
CREATE INDEX idx_customer_id ON olist_orders_dataset(customer_id);

-- Composite index for faster order retrieval
CREATE INDEX idx_order_seller ON olist_order_items_dataset(order_id, seller_id);

--3. Stored Procedures

--Stored procedures automate repetitive queries for performance & reusability.

--Fetching Customer Order History
CREATE PROCEDURE GetCustomerOrderHistory
    @customer_id VARCHAR(50)
AS
BEGIN
    SELECT O.order_id, O.order_purchase_timestamp, 
           I.product_id, I.price, I.freight_value
    FROM olist_orders_dataset O
    JOIN olist_order_items_dataset I ON O.order_id = I.order_id
    WHERE O.customer_id = @customer_id
    ORDER BY O.order_purchase_timestamp DESC;
END;

--Calculating Seller Performance
CREATE PROCEDURE GetSellerPerformance
    @seller_id VARCHAR(50)
AS
BEGIN
    SELECT I.seller_id, COUNT(DISTINCT I.order_id) AS TotalOrders,
           AVG(R.review_score) AS AvgReviewScore, SUM(I.price) AS TotalRevenue
    FROM olist_order_items_dataset I
    JOIN olist_order_reviews_dataset R ON I.order_id = R.order_id
    WHERE I.seller_id = @seller_id
    GROUP BY I.seller_id;
END;

--Add error handling using TRY...CATCH for robustness:
BEGIN TRY
    EXEC GetSellerPerformance 'seller_id_example';
END TRY
BEGIN CATCH
    PRINT ERROR_MESSAGE();
END CATCH;

--Example
EXEC GetSellerPerformance '0015a82c2db000af6aaaf3ae2ecb0532';

 SELECT I.seller_id, COUNT(DISTINCT I.order_id) AS TotalOrders,
           AVG(R.review_score) AS AvgReviewScore, SUM(I.price) AS TotalRevenue
    FROM olist_order_items_dataset I
    JOIN olist_order_reviews_dataset R ON I.order_id = R.order_id
    WHERE I.seller_id = '0015a82c2db000af6aaaf3ae2ecb0532'
    GROUP BY I.seller_id;

--4. Triggers

--Implement triggers for actions.

--Since the dataset doesn’t track stock directly, we will log order events.

--Logging Ordered Products in a Separate Table
CREATE TABLE product_sales_log (
    product_id VARCHAR(50) PRIMARY KEY,
    total_sold INT DEFAULT 0,
    last_order DATETIME DEFAULT GETDATE()
);


-- Create Trigger for Logging Product Sales
CREATE TRIGGER trg_LogProductSales
ON olist_order_items_dataset
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Update total_sold if the product already exists
    UPDATE product_sales_log
    SET total_sold = total_sold + I.order_item_id,
        last_order = GETDATE()
    FROM product_sales_log P
    JOIN inserted I ON P.product_id = I.product_id;

    -- Insert new products if they don’t exist in the log
    INSERT INTO product_sales_log (product_id, total_sold, last_order)
    SELECT I.product_id, SUM(I.order_item_id), GETDATE()
    FROM inserted I
    WHERE NOT EXISTS (
        SELECT 1 FROM product_sales_log P WHERE P.product_id = I.product_id
    )
    GROUP BY I.product_id;
END;
