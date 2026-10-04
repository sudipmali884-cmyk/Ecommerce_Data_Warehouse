-- ============================================================
-- FACT PAYMENTS
-- Grain: One row per payment
-- ============================================================

WITH payments AS (

    SELECT

        payment_id,

        order_id,

        customer_id,

        payment_date,

        payment_method,

        payment_gateway,

        payment_status,

        payment_amount,

        currency,

        transaction_id

    FROM {{ ref('stg_payments') }}

    WHERE payment_id IS NOT NULL

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

        order_total

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
-- FINAL PAYMENT FACT
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- PAYMENT KEYS
        -- ----------------------------------------------------

        p.payment_id,

        p.order_id,

        p.customer_id,


        -- ----------------------------------------------------
        -- DATE
        -- ----------------------------------------------------

        p.payment_date,

        CAST(

            p.payment_date AS DATE

        ) AS payment_date_key,


        -- ----------------------------------------------------
        -- PAYMENT INFORMATION
        -- ----------------------------------------------------

        p.payment_method,

        p.payment_gateway,

        p.payment_status,

        p.currency,

        p.transaction_id,


        -- ----------------------------------------------------
        -- ORDER INFORMATION
        -- ----------------------------------------------------

        o.order_date,

        o.order_status,

        o.order_total,


        -- ----------------------------------------------------
        -- CUSTOMER INFORMATION
        -- ----------------------------------------------------

        c.customer_status,

        c.city AS customer_city,

        c.state AS customer_state,


        -- ----------------------------------------------------
        -- PAYMENT AMOUNT
        -- ----------------------------------------------------

        COALESCE(

            p.payment_amount,

            0

        ) AS payment_amount,


        -- ----------------------------------------------------
        -- PAYMENT SUCCESS FLAG
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_status = 'Paid'

            THEN 1

            ELSE 0

        END AS successful_payment_flag,


        -- ----------------------------------------------------
        -- FAILED PAYMENT FLAG
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_status = 'Failed'

            THEN 1

            ELSE 0

        END AS failed_payment_flag,


        -- ----------------------------------------------------
        -- REFUND FLAG
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_status = 'Refunded'

            THEN 1

            ELSE 0

        END AS refunded_payment_flag,


        -- ----------------------------------------------------
        -- PENDING PAYMENT FLAG
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_status = 'Pending'

            THEN 1

            ELSE 0

        END AS pending_payment_flag,


        -- ----------------------------------------------------
        -- PAYMENT SUCCESS AMOUNT
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_status = 'Paid'

            THEN COALESCE(

                p.payment_amount,

                0

            )

            ELSE 0

        END AS successful_payment_amount,


        -- ----------------------------------------------------
        -- REFUND AMOUNT
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_status = 'Refunded'

            THEN COALESCE(

                p.payment_amount,

                0

            )

            ELSE 0

        END AS refund_amount,


        -- ----------------------------------------------------
        -- PAYMENT VS ORDER AMOUNT
        -- ----------------------------------------------------

        CASE

            WHEN o.order_total IS NULL

            THEN NULL

            ELSE ROUND(

                p.payment_amount
                -
                o.order_total,

                2

            )

        END AS payment_order_amount_difference,


        -- ----------------------------------------------------
        -- PAYMENT DATE DIFFERENCE
        -- ----------------------------------------------------

        CASE

            WHEN o.order_date IS NOT NULL

             AND p.payment_date IS NOT NULL

            THEN DATEDIFF(

                'day',

                o.order_date,

                p.payment_date

            )

            ELSE NULL

        END AS payment_delay_days,


        -- ----------------------------------------------------
        -- PAYMENT METHOD CATEGORY
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_method =

                'Cash on Delivery'

            THEN 'COD'

            WHEN p.payment_method IN (

                'UPI',

                'Credit Card',

                'Debit Card',

                'Net Banking'

            )

            THEN 'Online'

            WHEN p.payment_method IN (

                'Wallet',

                'EMI'

            )

            THEN 'Alternative'

            ELSE 'Other'

        END AS payment_type,


        -- ----------------------------------------------------
        -- HIGH VALUE PAYMENT
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_amount >= 50000

            THEN 1

            ELSE 0

        END AS high_value_payment_flag,


        -- ----------------------------------------------------
        -- DATA QUALITY FLAG
        -- ----------------------------------------------------

        CASE

            WHEN p.payment_id IS NULL

                THEN TRUE

            WHEN p.order_id IS NULL

                THEN TRUE

            WHEN p.customer_id IS NULL

                THEN TRUE

            WHEN p.payment_amount < 0

                THEN TRUE

            WHEN p.payment_status IS NULL

                THEN TRUE

            ELSE FALSE

        END AS data_quality_issue


    FROM payments p

    LEFT JOIN orders o

        ON p.order_id = o.order_id

    LEFT JOIN customers c

        ON p.customer_id = c.customer_id

)

SELECT *

FROM final