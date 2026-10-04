with orders as(
    select * from {{ ref('stg_orders')}}
),
customers as (
    select * from {{ ref('stg_customers')}}
--      customer_id,
--
--        first_name,
--
--        last_name,
--
--        gender,
--
--        city,
--
--        state,
--
--        customer_status
)
select
    o.order_id,

    o.customer_id,

    o.order_date,

    o.order_status,

    o.payment_status,

    o.shipping_method,

    o.shipping_date,

    o.delivery_date,

    o.shipping_charge,

    o.tax_amount,

    o.order_total,

    c.first_name,

    c.last_name,

    c.gender,

    c.city,

    c.state,

    c.customer_status,



    -- =====================================================
    -- BUSINESS LOGIC
    -- =====================================================

    CASE

        WHEN o.order_status = 'Delivered'

        THEN TRUE

        ELSE FALSE

    END AS is_delivered,


    CASE

        WHEN o.order_status = 'Cancelled'

        THEN TRUE

        ELSE FALSE

    END AS is_cancelled,


    CASE

        WHEN o.order_status = 'Returned'

        THEN TRUE

        ELSE FALSE

    END AS is_returned,


    CASE

        WHEN o.payment_status = 'Paid'

        THEN TRUE

        ELSE FALSE

    END AS is_paid,


    CASE

        WHEN o.delivery_date IS NOT NULL

        AND o.shipping_date IS NOT NULL

        THEN DATEDIFF(

            'day',

            o.shipping_date,

            o.delivery_date

        )

        ELSE NULL

    END AS delivery_days



from orders o
left join customers c
on o.customer_id = c.customer_id


