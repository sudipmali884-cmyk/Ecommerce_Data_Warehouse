with orders as (
    select * from {{ ref('stg_orders')}}
    where order_id is not null
),
order_items as(

    select
        order_id,

        COUNT(*) AS total_order_lines,

        COUNT(
            DISTINCT product_id
        ) AS total_products,

        SUM(quantity) AS total_quantity,

        SUM(gross_amount) AS gross_amount,

        SUM(discount_amount) AS discount_amount,

        SUM(tax_amount) AS item_tax_amount,

        SUM(line_total) AS item_total

    FROM {{ ref('stg_order_items') }}

    WHERE order_id IS NOT NULL

    GROUP BY order_id

),

-- ============================================================
-- FINAL FACT
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- KEYS
        -- ----------------------------------------------------

        o.order_id,

        o.customer_id,


        -- ----------------------------------------------------
        -- DATE
        -- ----------------------------------------------------

        o.order_date,

        CAST(
            o.order_date AS DATE
        ) AS order_date_key,


        -- ----------------------------------------------------
        -- ORDER ATTRIBUTES
        -- ----------------------------------------------------

        o.order_status,

        o.payment_status,

        o.shipping_method,


        -- ----------------------------------------------------
        -- SHIPPING DATES
        -- ----------------------------------------------------

        o.shipping_date,

        o.delivery_date,


        -- ----------------------------------------------------
        -- QUANTITY METRICS
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


        -- ----------------------------------------------------
        -- SALES AMOUNTS
        -- ----------------------------------------------------

        COALESCE(

            oi.gross_amount,

            0

        ) AS gross_amount,

        COALESCE(

            oi.discount_amount,

            0

        ) AS discount_amount,

        COALESCE(

            oi.item_tax_amount,

            0

        ) AS item_tax_amount,

        COALESCE(

            oi.item_total,

            0

        ) AS item_total,


        -- ----------------------------------------------------
        -- ORDER LEVEL AMOUNTS
        -- ----------------------------------------------------

        COALESCE(

            o.shipping_charge,

            0

        ) AS shipping_charge,

        COALESCE(

            o.tax_amount,

            0

        ) AS order_tax_amount,

        COALESCE(

            o.order_total,

            0

        ) AS order_total,


        -- ----------------------------------------------------
        -- NET SALES
        -- ----------------------------------------------------

        CASE

            WHEN o.order_status IN (

                'Cancelled',

                'Returned'

            )

            THEN 0

            ELSE COALESCE(

                o.order_total,

                0

            )

        END AS net_sales,


        -- ----------------------------------------------------
        -- DISCOUNT %
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(

                oi.gross_amount,

                0

            ) = 0

            THEN 0

            ELSE ROUND(

                (

                    oi.discount_amount

                    /

                    oi.gross_amount

                ) * 100,

                2

            )

        END AS discount_percentage,


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
        -- ORDER FLAGS
        -- ----------------------------------------------------

        CASE

            WHEN o.order_status = 'Delivered'

            THEN 1

            ELSE 0

        END AS delivered_order_flag,


        CASE

            WHEN o.order_status = 'Cancelled'

            THEN 1

            ELSE 0

        END AS cancelled_order_flag,


        CASE

            WHEN o.order_status = 'Returned'

            THEN 1

            ELSE 0

        END AS returned_order_flag,


        CASE

            WHEN o.payment_status = 'Paid'

            THEN 1

            ELSE 0

        END AS paid_order_flag,


        -- ----------------------------------------------------
        -- DATA QUALITY FLAG
        -- ----------------------------------------------------

        CASE

            WHEN o.customer_id IS NULL

                THEN TRUE

            WHEN o.order_date IS NULL

                THEN TRUE

            WHEN o.order_total < 0

                THEN TRUE

            ELSE FALSE

        END AS data_quality_issue


    FROM orders o

    LEFT JOIN order_items oi

        ON o.order_id = oi.order_id

)

SELECT *

FROM final
