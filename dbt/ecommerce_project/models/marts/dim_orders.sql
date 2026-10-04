-- ============================================================
-- DIM ORDERS
-- Grain: One row per order
-- ============================================================

WITH orders AS (

    SELECT

        order_id,
        customer_id,
        order_date,
        order_status,
        payment_status,
        shipping_method,
        shipping_date,
        delivery_date,
        shipping_charge,
        tax_amount,
        order_total

    FROM {{ ref('stg_orders') }}

    WHERE order_id IS NOT NULL

),

-- ============================================================
-- ORDER ITEM SUMMARY
-- IMPORTANT:
-- Aggregate order_items BEFORE joining with orders.
-- This prevents duplicate orders.
-- ============================================================

order_items AS (

    SELECT

        order_id,

        COUNT(*) AS total_order_lines,

        COUNT(
            DISTINCT product_id
        ) AS total_products,

        SUM(quantity) AS total_quantity,

        SUM(gross_amount) AS total_gross_amount,

        SUM(discount_amount) AS total_discount_amount,

        SUM(tax_amount) AS total_item_tax_amount,

        SUM(line_total) AS total_item_amount

    FROM {{ ref('stg_order_items') }}

    WHERE order_id IS NOT NULL

    GROUP BY order_id

),

-- ============================================================
-- CUSTOMER
-- ============================================================

customers AS (

    SELECT

        customer_id,

        first_name,

        last_name,

        gender,

        city,

        state,

        customer_status

    FROM {{ ref('stg_customers') }}

    WHERE customer_id IS NOT NULL

),

-- ============================================================
-- FINAL
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- ORDER KEY
        -- ----------------------------------------------------

        o.order_id,

        o.customer_id,

        o.order_date,


        -- ----------------------------------------------------
        -- CUSTOMER INFORMATION
        -- ----------------------------------------------------

        c.first_name AS customer_first_name,

        c.last_name AS customer_last_name,

        c.gender AS customer_gender,

        c.city AS customer_city,

        c.state AS customer_state,

        c.customer_status,


        -- ----------------------------------------------------
        -- ORDER STATUS
        -- ----------------------------------------------------

        o.order_status,

        o.payment_status,

        o.shipping_method,


        -- ----------------------------------------------------
        -- SHIPPING
        -- ----------------------------------------------------

        o.shipping_date,

        o.delivery_date,


        -- ----------------------------------------------------
        -- DELIVERY DAYS
        -- ----------------------------------------------------

        CASE

            WHEN o.shipping_date IS NOT NULL

             AND o.delivery_date IS NOT NULL

            THEN DATEDIFF(

                'day',

                o.shipping_date,

                o.delivery_date

            )

            ELSE NULL

        END AS delivery_days,


        -- ----------------------------------------------------
        -- ORDER PROCESSING DAYS
        -- ----------------------------------------------------

        CASE

            WHEN o.order_date IS NOT NULL

             AND o.shipping_date IS NOT NULL

            THEN DATEDIFF(

                'day',

                o.order_date,

                o.shipping_date

            )

            ELSE NULL

        END AS processing_days,


        -- ----------------------------------------------------
        -- ORDER AMOUNTS
        -- ----------------------------------------------------

        o.shipping_charge,

        o.tax_amount,

        o.order_total,


        -- ----------------------------------------------------
        -- ORDER ITEM METRICS
        -- ----------------------------------------------------

        COALESCE(

            oi.total_order_lines,

            0

        ) AS total_order_lines,

        COALESCE(

            oi.total_products,

            0

        ) AS total_products,

        COALESCE(

            oi.total_quantity,

            0

        ) AS total_quantity,

        COALESCE(

            oi.total_gross_amount,

            0

        ) AS total_gross_amount,

        COALESCE(

            oi.total_discount_amount,

            0

        ) AS total_discount_amount,

        COALESCE(

            oi.total_item_tax_amount,

            0

        ) AS total_item_tax_amount,

        COALESCE(

            oi.total_item_amount,

            0

        ) AS total_item_amount,


        -- ----------------------------------------------------
        -- DISCOUNT PERCENTAGE
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(

                oi.total_gross_amount,

                0

            ) = 0

            THEN 0

            ELSE ROUND(

                (

                    oi.total_discount_amount

                    /

                    oi.total_gross_amount

                ) * 100,

                2

            )

        END AS effective_discount_percentage,


        -- ----------------------------------------------------
        -- ORDER VALUE CATEGORY
        -- ----------------------------------------------------

        CASE

            WHEN o.order_total IS NULL

                THEN 'Unknown'

            WHEN o.order_total < 1000

                THEN 'Low Value'

            WHEN o.order_total < 5000

                THEN 'Medium Value'

            WHEN o.order_total < 20000

                THEN 'High Value'

            ELSE 'Premium Value'

        END AS order_value_category,


        -- ----------------------------------------------------
        -- DELIVERY STATUS
        -- ----------------------------------------------------

        CASE

            WHEN o.order_status = 'Delivered'

                THEN 'Delivered'

            WHEN o.order_status = 'Returned'

                THEN 'Returned'

            WHEN o.order_status = 'Cancelled'

                THEN 'Cancelled'

            WHEN o.delivery_date IS NOT NULL

                THEN 'Delivered'

            WHEN o.shipping_date IS NOT NULL

                THEN 'In Transit'

            WHEN o.order_status = 'Pending'

                THEN 'Pending'

            ELSE 'Processing'

        END AS delivery_status,


        -- ----------------------------------------------------
        -- CUSTOMER LOCATION
        -- ----------------------------------------------------

        CASE

            WHEN c.state IS NULL

                THEN 'Unknown'

            ELSE c.state

        END AS customer_region,


        -- ----------------------------------------------------
        -- DATA QUALITY FLAG
        -- ----------------------------------------------------

        CASE

            WHEN o.order_id IS NULL

                THEN TRUE

            WHEN o.customer_id IS NULL

                THEN TRUE

            WHEN o.order_date IS NULL

                THEN TRUE

            WHEN o.order_total < 0

                THEN TRUE

            ELSE FALSE

        END AS order_data_quality_issue


    FROM orders o

    LEFT JOIN customers c

        ON o.customer_id = c.customer_id

    LEFT JOIN order_items oi

        ON o.order_id = oi.order_id

)

SELECT *

FROM final