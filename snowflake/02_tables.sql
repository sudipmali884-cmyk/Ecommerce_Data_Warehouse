
-- customers

create table customers(
customer_id number,
first_name STRING,
last_name STRING,
gender STRING,
date_of_birth DATE,
email STRING,
phone STRING,
address STRING,
city STRING,
state STRING,
country STRING,
zip_code STRING,
registration_date DATE,
customer_segment STRING,
is_active BOOLEAN
);

-- products tables
CREATE OR REPLACE TABLE products (
product_id NUMBER,
product_name STRING,
brand STRING,
category STRING,
sub_category STRING,
cost_price NUMBER(10,2),
selling_price NUMBER(10,2),
profit NUMBER(10,2),
supplier STRING,
stock_status STRING,
rating NUMBER(2,1),
weight_kg NUMBER(8,2),
colour STRING,
size STRING,
warranty_months NUMBER,
launch_date DATE,
is_active BOOLEAN
);

-- orders

CREATE OR REPLACE TABLE orders (

order_id NUMBER,

customer_id NUMBER,

order_date TIMESTAMP,

shipping_date DATE,

delivery_date DATE,

order_status STRING,

shipping_address STRING,

shipping_city STRING,

shipping_state STRING,

shipping_country STRING,

discount_amount NUMBER(10,2),

total_amount NUMBER(12,2)

);

-- 4 order items

CREATE OR REPLACE TABLE order_items (

order_item_id NUMBER,

order_id NUMBER,

product_id NUMBER,

quantity NUMBER,

unit_price NUMBER(10,2),

discount NUMBER(10,2),

tax_amount NUMBER(10,2),

total_price NUMBER(12,2)

);

-- 5 Payments

CREATE OR REPLACE TABLE payments (

payment_id NUMBER,

order_id NUMBER,

payment_date TIMESTAMP,

payment_method STRING,

payment_gateway STRING,

payment_status STRING,

transaction_id STRING,

bank_name STRING,

amount NUMBER(12,2),

currency STRING,

created_at TIMESTAMP

);

-- 6 reviews

CREATE OR REPLACE TABLE reviews (

review_id NUMBER,

customer_id NUMBER,

product_id NUMBER,

rating NUMBER,

review_title STRING,

review_text STRING,

verified_purchase BOOLEAN,

helpful_votes NUMBER,

review_date DATE

);

-- 7 returns

CREATE OR REPLACE TABLE returns (

return_id NUMBER,

order_id NUMBER,

product_id NUMBER,

return_reason STRING,

refund_amount NUMBER(12,2),

return_request_date DATE,

return_status STRING,

refund_date DATE,

refund_method STRING

);

show tables;
