# 📊Olist E-commerce Dashboard

🔗 https://app.powerbi.com/reportEmbed?reportId=78122f6d-9d6e-4265-9ad6-0026c9aaadb8&autoAuth=true&ctid=8985f9b5-679c-4a39-8db6-854329895dac

## 💠Project Overview

The Olist E-commerce Dashboard aims to provide an in-depth analysis of e-commerce data using MS SQL Server for data management and Power BI for visualization. 
This project covers the end-to-end data pipeline from raw dataset exploration to business insights through interactive reports.

![image](https://github.com/user-attachments/assets/80d49f4b-30ff-4edc-9681-870f7362ccf0)

## 🎯Objectives

The primary objectives of this project include:

### 1. Database Creation & Querying:

* Store and manage e-commerce datasets efficiently in MS SQL Server.

* Write SQL queries and views to extract meaningful insights.

### 2. Advanced Data Analytics & Optimization:

* Perform data cleaning, indexing, and optimization to enhance query performance.

* Implement advanced SQL techniques such as aggregations, window functions, and subqueries.

### 3. Business Insights & Decision Support:

* Analyze key business metrics such as revenue trends, customer segmentation, logistics efficiency, and marketing performance.

### 4. Interactive Dashboard Development in Power BI:

* Design a clean, insightful dashboard using DAX calculations, relationships, and custom visualizations.

* Ensure real-time interactivity with Power BI’s drill-through and filter functionalities.

## 📑Dataset Overview

The project utilizes the Brazilian E-Commerce Public Dataset by Olist, sourced from Kaggle.

**Description:** This dataset contains information on e-commerce transactions, including orders, customers, products, sellers, and geolocation.

**Access:** https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data

**Data Schema:** 

![olist_data_schema](https://github.com/user-attachments/assets/122f5fad-51e3-483a-8bb8-e1463ccedef4)

### Key Datasets & Attributes

#### 1. Orders Dataset (olist_orders_dataset)

`order_id`, `customer_id`, `order_status`, `order_purchase_timestamp`, `order_delivered_customer_date`, `order_estimated_delivery_date`

#### 2. Products Dataset (olist_products_dataset)

`product_id`, `product_category_name`, `product_weight_g`, `product_length_cm`, `product_height_cm`, `product_width_cm`

#### 3. Sellers Dataset (olist_sellers_dataset)

`seller_id`, `seller_city`, `seller_state`

#### 4. Order Items Dataset (olist_order_items_dataset)

`order_id`, `product_id`, `seller_id`, `shipping_limit_date`, `price`, `freight_value`

#### 5. Order Payments Dataset (olist_order_payments_dataset)

`order_id`, `payment_type`, `payment_installments`, `payment_value`

#### 6. Order Reviews Dataset (olist_order_reviews_dataset)

`review_id`, `order_id`, `review_score`, `review_comment_message`, `review_creation_date`

#### 7. Customers Dataset (olist_customers_dataset)

`customer_id`, `customer_unique_id`, `customer_city`, `customer_state`

#### 8. Geolocation Dataset (olist_geolocation_dataset)

`geolocation_zip_code_prefix`, `geolocation_lat`, `geolocation_lng`, `geolocation_city`, `geolocation_state`

## 🗺️Roadmap & Implementation Phases

### Phase 1: Data Preparation

* Understand the dataset structure and relationships.

* Set up MS SQL Server and import data.

* Perform data cleaning and handle missing values.

### Phase 2: Foundational Queries

* Write basic queries for data exploration.

* Use JOINs to combine datasets.

* Apply filtering & sorting techniques.

### Phase 3: Advanced Analysis

* Implement aggregations & window functions.

* Use nested queries & subqueries.

* Create SQL Views for reusable data extracts.

### Phase 4: Data Integrity & Optimization

* Apply constraints & validation rules.

* Optimize performance using indexing.

* Automate processes with stored procedures & triggers.

### Phase 5: Business Insights

* **Revenue Analysis:** Identify revenue trends and high-performing products & customers.

* **Customer Segmentation:** Categorize customers based on behavior and purchase history.

* **Logistics Insights:** Assess delivery performance by region and optimize shipping strategies.

* **Marketing Insights:** Evaluate customer preferences and rearrange marketing strategies.

* **Predictions:** Predict monthly sales (Linear Growth Model), calculate YOY Growth and quarterly moving averages.

### Phase 6: Power BI Integration

* Export cleaned data from SQL Server.

* Establish relationships between datasets in Power BI.

* Develop an interactive dashboard with DAX measures & visualizations.

* Implement drill-through and filtering options for dynamic reporting.

### Phase 7: Documentation & Presentation

* Document all SQL queries and transformation steps.

* Create a presentation-ready report summarizing key insights.

* Present the final Power BI Dashboard.

## 📈Dashboard Features

**Revenue Breakdown:** Monthly and category-wise sales analysis.

**Customer Segmentation, Churn Status & CLV:** Behavior-based categorization, churn status and lifetime value.

**Order Fulfillment Analysis:** Delivery time performance by region and seller.

**Sales & Marketing Effectiveness:** Top cross-sales products, weekday & weekend preference.

## 🔧Technologies Used

**Database:** Microsoft SQL Server*

**Query Language:** SQL (T-SQL)*

**Visualization:** Microsoft Power BI*

**Scripting & Automation:** DAX, Stored Procedures, Triggers*

## ℹ️How to Use

* Open Power BI Report.

* Use filters & slicers to customize views.

* Click on help icons for information and directions.

* Utilize the interactive map for location-based insights.

## 💠Conclusion

This project offers a comprehensive approach to analyzing e-commerce transactions. 

By leveraging SQL Server for data management and Power BI for visualization, I gain valuable business insights that drive decision-making and strategy development.
