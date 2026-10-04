-- ============================================================
-- FACT REVIEWS
-- Grain: One row per review
-- ============================================================

WITH reviews AS (

    SELECT

        review_id,

        order_id,

        customer_id,

        product_id,

        rating,

        review_title,

        review_text,

        review_date,

        verified_purchase

    FROM {{ ref('stg_reviews') }}

    WHERE review_id IS NOT NULL

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

        brand

    FROM {{ ref('stg_products') }}

    WHERE product_id IS NOT NULL

),

-- ============================================================
-- FINAL REVIEW FACT
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- REVIEW KEYS
        -- ----------------------------------------------------

        r.review_id,

        r.order_id,

        r.customer_id,

        r.product_id,


        -- ----------------------------------------------------
        -- REVIEW DATE
        -- ----------------------------------------------------

        r.review_date,

        CAST(

            r.review_date AS DATE

        ) AS review_date_key,


        -- ----------------------------------------------------
        -- REVIEW INFORMATION
        -- ----------------------------------------------------

        r.rating,

        r.review_title,

        r.review_text,

        r.verified_purchase,


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


        -- ----------------------------------------------------
        -- RATING CATEGORY
        -- ----------------------------------------------------

        CASE

            WHEN r.rating = 5

                THEN 'Excellent'

            WHEN r.rating = 4

                THEN 'Good'

            WHEN r.rating = 3

                THEN 'Average'

            WHEN r.rating = 2

                THEN 'Poor'

            WHEN r.rating = 1

                THEN 'Very Poor'

            ELSE 'Unknown'

        END AS rating_category,


        -- ----------------------------------------------------
        -- POSITIVE REVIEW FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.rating >= 4

                THEN 1

            ELSE 0

        END AS positive_review_flag,


        -- ----------------------------------------------------
        -- NEGATIVE REVIEW FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.rating <= 2

                THEN 1

            ELSE 0

        END AS negative_review_flag,


        -- ----------------------------------------------------
        -- NEUTRAL REVIEW FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.rating = 3

                THEN 1

            ELSE 0

        END AS neutral_review_flag,


        -- ----------------------------------------------------
        -- VERIFIED REVIEW FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.verified_purchase = TRUE

                THEN 1

            ELSE 0

        END AS verified_review_flag,


        -- ----------------------------------------------------
        -- REVIEW DELAY
        --
        -- Number of days between purchase and review
        -- ----------------------------------------------------

        CASE

            WHEN o.order_date IS NOT NULL

             AND r.review_date IS NOT NULL

            THEN DATEDIFF(

                'day',

                o.order_date,

                r.review_date

            )

            ELSE NULL

        END AS review_delay_days,


        -- ----------------------------------------------------
        -- REVIEW LENGTH
        -- ----------------------------------------------------

        CASE

            WHEN r.review_text IS NOT NULL

            THEN LENGTH(

                TRIM(r.review_text)

            )

            ELSE 0

        END AS review_text_length,


        -- ----------------------------------------------------
        -- REVIEW TITLE PRESENT
        -- ----------------------------------------------------

        CASE

            WHEN NULLIF(

                TRIM(r.review_title),

                ''

            ) IS NOT NULL

            THEN 1

            ELSE 0

        END AS has_review_title,


        -- ----------------------------------------------------
        -- DATA QUALITY FLAG
        -- ----------------------------------------------------

        CASE

            WHEN r.review_id IS NULL

                THEN TRUE

            WHEN r.order_id IS NULL

                THEN TRUE

            WHEN r.customer_id IS NULL

                THEN TRUE

            WHEN r.product_id IS NULL

                THEN TRUE

            WHEN r.rating IS NULL

                THEN TRUE

            WHEN r.rating NOT BETWEEN 1 AND 5

                THEN TRUE

            ELSE FALSE

        END AS data_quality_issue


    FROM reviews r


    LEFT JOIN orders o

        ON r.order_id = o.order_id


    LEFT JOIN customers c

        ON r.customer_id = c.customer_id


    LEFT JOIN products p

        ON r.product_id = p.product_id

)

SELECT *

FROM final