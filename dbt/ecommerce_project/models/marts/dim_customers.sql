with customers as (
    select * from {{ ref('stg_customers')}}
),
customer_orders as(
    select
        customer_id ,
        count(distinct order_id) as total_orders,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date

    from {{ ref('int_orders')}}

    where customer_id is not null

    group by customer_id
)

SELECT

    -- ========================================================
    -- CUSTOMER KEY
    -- ========================================================

    c.customer_id,

    -- ========================================================
    -- CUSTOMER INFORMATION
    -- ========================================================

    c.first_name,

    c.last_name,

    c.gender,

    c.date_of_birth,

    c.phone_number,

    c.email,

    -- ========================================================
    -- LOCATION
    -- ========================================================

    c.city,

    c.state,

    c.postal_code,

    -- ========================================================
    -- CUSTOMER DATES
    -- ========================================================

    c.registration_date,

    c.created_at,

    c.updated_at,

    -- ========================================================
    -- CUSTOMER STATUS
    -- ========================================================

    c.customer_status,

    c.customer_segment,

    CASE

        WHEN c.customer_status = 'Active'

        THEN TRUE

        ELSE FALSE

    END AS is_active,

    -- ========================================================
    -- ORDER ACTIVITY
    -- ========================================================

    COALESCE(

        co.total_orders,

        0

    ) AS total_orders,

    co.first_order_date,

    co.last_order_date,

    -- ========================================================
    -- CUSTOMER ACTIVITY
    -- ========================================================

    CASE

        WHEN co.total_orders > 0

        THEN TRUE

        ELSE FALSE

    END AS has_order_history,

    -- ========================================================
    -- DATA QUALITY FLAG
    -- ========================================================

    CASE

        WHEN c.customer_id IS NULL

        THEN TRUE

        WHEN TRIM(c.customer_id) = ''

        THEN TRUE

        ELSE FALSE

    END AS customer_data_quality_issue

FROM customers c

LEFT JOIN customer_orders co

    ON c.customer_id = co.customer_id
