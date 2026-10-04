with payments as(
    select * from {{ ref('stg_payments')}}
),
orders as (
        SELECT

        order_id,
        customer_id,
        order_date,

        order_status,
        payment_status,

        order_total

    FROM {{ ref('stg_orders') }}
)

SELECT

    p.payment_id,

    p.order_id,

    p.customer_id,

    p.payment_date,

    p.payment_method,

    p.payment_gateway,

    p.payment_status,

    p.payment_amount,

    p.currency,

    p.transaction_id,

    o.order_date,

    o.order_status,

    o.payment_status as order_payment_status,

    o.order_total,


    case
        when o.order_total is not null
        then round(p.payment_amount - o.order_total,2)
        else null
    end as payment_amount_difference,

    -- payment amount match flag

    case
        when o.order_total is null
            then false
        when abs(p.payment_amount - order_total) <=1
        then true
        else false

    end as payment_amount_matches,

    -- payment success flag

    case
        when p.payment_status ='Refunded'
        then true
        else false
    end as is_refunded,

    case
        when p.payment_status='Failed'
        then true
        else false
    end as id_failed_payment,

    case
        when p.payment_status ='Pending'
        then true
        else false

    end as is_pending_payment,

    case
        when o.order_id is null
        then false
        else true

    end as order_exists,


    case
        when o.customer_id is null
            then null
        when o.customer_id = p.customer_id
            then true
        else false
    end as customer_id_matches_order,


     -- =====================================================
    -- PAYMENT DATE VALIDATION
    -- ========================================================

    CASE

        WHEN p.payment_date IS NULL

        THEN FALSE

        WHEN o.order_date IS NULL

        THEN NULL

        WHEN p.payment_date >= o.order_date

        THEN TRUE

        ELSE FALSE

    END AS valid_payment_date,


    -- ========================================================
    -- PAYMENT DATA QUALITY FLAG
    -- ========================================================

    CASE

        WHEN p.order_id IS NULL

        THEN TRUE

        WHEN o.order_id IS NULL

        THEN TRUE

        WHEN p.payment_status IS NULL

        THEN TRUE

        WHEN p.payment_amount IS NULL

        THEN TRUE

        ELSE FALSE

    END AS payment_data_quality_issue

from payments p
left join orders o
on p.order_id = o.order_id

