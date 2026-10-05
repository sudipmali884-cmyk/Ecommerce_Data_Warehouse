-- 1.  Customers
copy into customers 
FROM @dcommerce_stage/customers.csv
file_format=(format_name='csv_format');


-- 2. Products
copy into products from @dcommerce_stage/products.csv file_format=(format_name='csv_format');

-- 3. Orders

copy into orders from @dcommerce_stage/orders.csv file_format=(format_name='csv_format');

-- 4. Payments

copy into payments from @dcommerce_stage/payments.csv file_format=(format_name='csv_format');

-- 5. order_items

copy into order_items from @dcommerce_stage/order_items file_format=(format_name='csv_format');

-- 6. Reviews

copy into reviews from @dcommerce_stage/reviews file_format=(format_name='csv_format');

-- 7. Returns

copy into returns from @dcommerce_stage/returns file_format=(format_name='csv_format');


