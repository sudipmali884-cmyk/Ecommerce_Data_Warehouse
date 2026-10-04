-- ============================================================
-- FACT RETURNS
-- Grain: One row per return
-- ============================================================

WITH returns AS (

    SELECT

        return_id,
        order_id,
        customer_id,
        product_id,
        return_date,
        return_quantity,
        return_reason,
        return_condition,
        return_status,
        refund_amount,
        refund_method,
        refund_date,
        restock_flag

    FROM {{ ref('stg_returns') }}

    WHERE return_id IS NOT NULL

),

-- ============================================================
-- ORDERS
-- ============================================================

orders AS (

    SELECT

        order_id,
        customer_id,
        order_date,
        order_status

    FROM {{ ref('stg_orders') }}

    WHERE order_id IS NOT NULL

),

-- ============================================================
-- CUSTOMERS
-- ============================================================

customers AS (

    SELECT

        customer_id,
        customer_status,
        city,
        state

    FROM {{ ref('stg_customers') }}

    WHERE customer_id IS NOT NULL

),

-- ============================================================
-- PRODUCTS
-- ============================================================

products AS (

    SELECT

        product_id,
        product_name,
        category,
        subcategory,
        brand,
        selling_price

    FROM {{ ref('stg_products') }}

    WHERE product_id IS NOT NULL

),

-- ============================================================
-- FINAL
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- RETURN KEYS
        -- ----------------------------------------------------

        r.return_id,

        r.order_id,

        r.customer_id,

        r.product_id,


        -- ----------------------------------------------------
        -- RETURN DATE
        -- ----------------------------------------------------

        r.return_date,

        CAST(
            r.return_date AS DATE
        ) AS return_date_key,


        -- ----------------------------------------------------
        -- RETURN INFORMATION
        -- ----------------------------------------------------

        r.return_quantity,

        r.return_reason,

        r.return_condition,

        r.return_status,

        r.refund_method,

        r.refund_date,

        r.restock_flag,


        -- ----------------------------------------------------
        -- REFUND
        -- ----------------------------------------------------

        COALESCE(
            r.refund_amount,
            0
        ) AS refund_amount,


        -- ----------------------------------------------------
        -- ORDER INFORMATION
        -- ----------------------------------------------------

        o.order_date,

        o.order_status,


        -- ----------------------------------------------------
        -- CUSTOMER INFORMATION
        -- ----------------------------------------------------

        c.customer_status,

        c.city AS customer_city,

        c.state AS customer_state,


        -- ----------------------------------------------------
        -- PRODUCT INFORMATION
        -- ----------------------------------------------------

        p.product_name,

        p.category,

        p.subcategory,

        p.brand,

        p.selling_price,


        -- ----------------------------------------------------
        -- RETURN STATUS FLAGS
        -- ----------------------------------------------------

        CASE

            WHEN r.return_status = 'Completed'

            THEN 1

            ELSE 0

        END AS completed_return_flag,


        CASE

            WHEN r.return_status = 'Approved'

            THEN 1

            ELSE 0

        END AS approved_return_flag,


        CASE

            WHEN r.return_status = 'Rejected'

            THEN 1

            ELSE 0

        END AS rejected_return_flag,


        CASE

            WHEN r.return_status = 'Refunded'

            THEN 1

            ELSE 0

        END AS refunded_return_flag,


        -- ----------------------------------------------------
        -- RESTOCK FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.restock_flag = TRUE

            THEN 1

            ELSE 0

        END AS restocked_flag,


        -- ----------------------------------------------------
        -- RETURN DELAY
        -- ----------------------------------------------------

        CASE

            WHEN o.order_date IS NOT NULL
             AND r.return_date IS NOT NULL

            THEN DATEDIFF(

                'day',

                o.order_date,

                r.return_date

            )

            ELSE NULL

        END AS return_delay_days,


        -- ----------------------------------------------------
        -- RETURN VALUE
        -- ----------------------------------------------------

        CASE

            WHEN p.selling_price IS NOT NULL
             AND r.return_quantity IS NOT NULL

            THEN ROUND(

                ABS(p.selling_price)
                *
                ABS(r.return_quantity),

                2

            )

            ELSE 0

        END AS returned_product_value,


        -- ----------------------------------------------------
        -- REFUND COMPLETED FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.refund_date IS NOT NULL

             AND r.refund_amount > 0

            THEN 1

            ELSE 0

        END AS refund_completed_flag,


        -- ----------------------------------------------------
        -- DATA QUALITY FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.return_id IS NULL

                THEN TRUE

            WHEN r.order_id IS NULL

                THEN TRUE

            WHEN r.customer_id IS NULL

                THEN TRUE

            WHEN r.product_id IS NULL

                THEN TRUE

            WHEN r.return_quantity IS NULL

                THEN TRUE

            WHEN r.return_quantity <= 0

                THEN TRUE

            WHEN r.refund_amount < 0

                THEN TRUE

            ELSE FALSE

        END AS data_quality_issue


    FROM returns r

    LEFT JOIN orders o

        ON r.order_id = o.order_id

    LEFT JOIN customers c

        ON r.customer_id = c.customer_id

    LEFT JOIN products p

        ON r.product_id = p.product_id

)

SELECT *

FROM final