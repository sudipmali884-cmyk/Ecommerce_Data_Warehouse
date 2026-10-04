-- ============================================================
-- FACT ORDER ITEMS
-- Grain: One row per order item
-- ============================================================

WITH order_items AS (

    SELECT

        order_item_id,

        order_id,

        product_id,

        quantity,

        unit_price,

        discount_percentage,

        gross_amount,

        discount_amount,

        tax_amount,

        line_total

    FROM {{ ref('stg_order_items') }}

    WHERE order_item_id IS NOT NULL

),

-- ============================================================
-- ORDERS
-- ============================================================

orders AS (

    SELECT

        order_id,

        customer_id,

        order_date,

        order_status,

        payment_status,

        shipping_method

    FROM {{ ref('stg_orders') }}

    WHERE order_id IS NOT NULL

),

-- ============================================================
-- PRODUCTS
-- ============================================================

products AS (

    SELECT

        product_id,

        sku,

        product_name,

        category,

        subcategory,

        brand,

        cost_price,

        selling_price,

        final_price,

        product_status

    FROM {{ ref('stg_products') }}

    WHERE product_id IS NOT NULL

),

-- ============================================================
-- FINAL
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- KEYS
        -- ----------------------------------------------------

        oi.order_item_id,

        oi.order_id,

        oi.product_id,

        o.customer_id,


        -- ----------------------------------------------------
        -- DATE
        -- ----------------------------------------------------

        o.order_date,

        CAST(

            o.order_date AS DATE

        ) AS order_date_key,


        -- ----------------------------------------------------
        -- PRODUCT INFORMATION
        -- ----------------------------------------------------

        p.sku,

        p.product_name,

        p.category,

        p.subcategory,

        p.brand,


        -- ----------------------------------------------------
        -- ORDER INFORMATION
        -- ----------------------------------------------------

        o.order_status,

        o.payment_status,

        o.shipping_method,


        -- ----------------------------------------------------
        -- QUANTITY
        -- ----------------------------------------------------

        oi.quantity,


        -- ----------------------------------------------------
        -- PRICE
        -- ----------------------------------------------------

        oi.unit_price,

        p.cost_price,

        p.selling_price,

        p.final_price,


        -- ----------------------------------------------------
        -- DISCOUNT
        -- ----------------------------------------------------

        oi.discount_percentage,

        oi.gross_amount,

        oi.discount_amount,


        -- ----------------------------------------------------
        -- TAX
        -- ----------------------------------------------------

        oi.tax_amount,


        -- ----------------------------------------------------
        -- FINAL LINE VALUE
        -- ----------------------------------------------------

        oi.line_total,


        -- ----------------------------------------------------
        -- CALCULATED COST
        -- ----------------------------------------------------

        CASE

            WHEN p.cost_price IS NULL

            THEN NULL

            ELSE ROUND(

                p.cost_price
                * oi.quantity,

                2

            )

        END AS total_cost,


        -- ----------------------------------------------------
        -- GROSS PROFIT
        -- ----------------------------------------------------

        CASE

            WHEN p.cost_price IS NULL

            THEN NULL

            ELSE ROUND(

                oi.line_total

                -

                (

                    p.cost_price
                    * oi.quantity

                ),

                2

            )

        END AS gross_profit,


        -- ----------------------------------------------------
        -- PROFIT MARGIN
        -- ----------------------------------------------------

        CASE

            WHEN oi.line_total IS NULL

            OR oi.line_total = 0

            OR p.cost_price IS NULL

            THEN NULL

            ELSE ROUND(

                (

                    oi.line_total

                    -

                    (

                        p.cost_price
                        * oi.quantity

                    )

                )

                /

                oi.line_total

                * 100,

                2

            )

        END AS profit_margin_percentage,


        -- ----------------------------------------------------
        -- DISCOUNT VALUE
        -- ----------------------------------------------------

        CASE

            WHEN oi.gross_amount IS NULL

            OR oi.gross_amount = 0

            THEN 0

            ELSE ROUND(

                oi.discount_amount

                /

                oi.gross_amount

                * 100,

                2

            )

        END AS effective_discount_percentage,


        -- ----------------------------------------------------
        -- SALES FLAG
        -- ----------------------------------------------------

        CASE

            WHEN o.order_status = 'Cancelled'

            THEN 0

            WHEN o.order_status = 'Returned'

            THEN 0

            ELSE 1

        END AS valid_sales_flag,


        -- ----------------------------------------------------
        -- DELIVERED FLAG
        -- ----------------------------------------------------

        CASE

            WHEN o.order_status = 'Delivered'

            THEN 1

            ELSE 0

        END AS delivered_flag,


        -- ----------------------------------------------------
        -- RETURN FLAG
        -- ----------------------------------------------------

        CASE

            WHEN o.order_status = 'Returned'

            THEN 1

            ELSE 0

        END AS returned_flag,


        -- ----------------------------------------------------
        -- DATA QUALITY FLAG
        -- ----------------------------------------------------

        CASE

            WHEN oi.order_id IS NULL

                THEN TRUE

            WHEN oi.product_id IS NULL

                THEN TRUE

            WHEN o.order_id IS NULL

                THEN TRUE

            WHEN p.product_id IS NULL

                THEN TRUE

            WHEN oi.quantity <= 0

                THEN TRUE

            WHEN oi.unit_price < 0

                THEN TRUE

            WHEN oi.line_total < 0

                THEN TRUE

            ELSE FALSE

        END AS data_quality_issue


    FROM order_items oi

    LEFT JOIN orders o

        ON oi.order_id = o.order_id

    LEFT JOIN products p

        ON oi.product_id = p.product_id

)

SELECT *

FROM final