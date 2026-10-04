# E-Commerce Data Warehouse & Analytics

An end-to-end E-Commerce Data Warehouse and Analytics project built using
Python, Snowflake, dbt, SQL, and Power BI.

## 🚀 Project Architecture

Python
   ↓
CSV Files
   ↓
Snowflake RAW
   ↓
dbt STAGING
   ↓
dbt INTERMEDIATE
   ↓
dbt MARTS
   ↓
Power BI

## 🛠️ Technologies Used

- Python
- Pandas
- SQL
- Snowflake
- dbt
- Power BI
- DAX
- Git
- GitHub

## 📊 Data Warehouse

The project contains data related to:

- Customers
- Products
- Orders
- Order Items
- Payments
- Reviews
- Returns
- Inventory

## 🏗️ dbt Data Models

### Dimensions

- dim_customers
- dim_products
- dim_orders
- dim_date

### Facts

- fact_orders
- fact_order_items
- fact_payments
- fact_reviews
- fact_returns
- fact_inventory

## 🔄 Data Transformation

The data follows a layered architecture:

### RAW

Raw CSV data is loaded into Snowflake without major transformations.

### STAGING

Data cleaning and standardization are performed.

### INTERMEDIATE

Business logic and intermediate transformations are applied.

### MARTS

Dimensional models and fact tables are created for analytics.

## 📈 Power BI Dashboard

The Power BI dashboard contains:

1. Executive Overview
2. Customer Analysis
3. Product & Sales Analysis
4. Order & Payment Analysis
5. Returns Analysis
6. Inventory Analysis




### Key KPIs

- Total Revenue
- Total Orders
- Total Customers
- Total Products
- Average Order Value
- Payment Success Rate
- Return Rate
- Refund Amount
- Available Stock
- Reorder Required Products

## 🧹 Data Quality

The project includes realistic data-quality scenarios such as:

- Duplicate records
- NULL values
- Blank values
- Invalid values
- Incorrect formatting
- Duplicate customer records
- Data validation

dbt models and tests are used to improve data quality and reliability.

## 🎯 Key Learning Outcomes

Through this project, I practiced:

- ETL/ELT pipeline development
- Data warehouse architecture
- Snowflake data loading
- SQL transformations
- dbt modeling
- Dimensional modeling
- Data quality testing
- Power BI dashboard development
- DAX
- Git and GitHub

## 👨‍💻 Author

Sudip Mali

GitHub: https://github.com/sudipmali884-cmyk