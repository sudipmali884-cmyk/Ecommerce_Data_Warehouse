with orders as (
    select * from {{ source('raw','orders')}}
),

cleaned_data as (
select
    nullif(trim(order_id),'') as order_id,
    nullif(trim(customer_id),'') as customer_id,

        ----------------------------------------------------
        -- Order Date
        -- ----------------------------------------------------

    CASE

        WHEN TRY_TO_DATE(order_date) IS NULL
            THEN NULL

        WHEN TRY_TO_DATE(order_date) > CURRENT_DATE()
            THEN NULL

        ELSE TRY_TO_DATE(order_date)

    END AS order_date,

    -- ----------------------------------------------------
    -- Order Status
    -- ----------------------------------------------------

    CASE

        WHEN UPPER(TRIM(order_status))
            IN (
                'PENDING',
                'CONFIRMED',
                'SHIPPED',
                'DELIVERED',
                'CANCELLED',
                'RETURNED'
            )

            THEN INITCAP(TRIM(order_status))

        ELSE 'Unknown'

    END AS order_status,

    case
        when upper(trim(payment_status)) in (
        'PENDING','PAID','FAILED','REFUNDED'
        )

        then initcap(trim(payment_status))

        else 'Unknown'
    end as payment_status,

    -- ----------------------------------------------------
    -- Shipping Method
    -- ----------------------------------------------------

    CASE

        WHEN UPPER(TRIM(shipping_method))
            IN (
                'STANDARD',
                'EXPRESS',
                'SAME DAY',
                'ECONOMY'
            )

            THEN INITCAP(TRIM(shipping_method))

        ELSE 'Unknown'

    END AS shipping_method,

        -- ----------------------------------------------------
    -- Shipping Date
    -- ----------------------------------------------------

    CASE

        WHEN TRY_TO_DATE(shipping_date) IS NULL
            THEN NULL

        WHEN TRY_TO_DATE(shipping_date) > CURRENT_DATE()
            THEN NULL

        ELSE TRY_TO_DATE(shipping_date)

    END AS shipping_date,

    case
        when try_to_date(delivery_date) is null then null
        when try_to_date(delivery_date) < try_to_date(order_date) then null
        else try_to_date(delivery_date)
    end as delivery_date,

    case
        when shipping_charge < 0 then null
        else shipping_charge
    end as shipping_charge,

    case
        when tax_amount < 0 then null
        else tax_amount
    end as tax_amount,

    case
        when order_total < 0 then null
        else null
    end as order_total,

from orders


),
deduplicated as (

    select  * from cleaned_data
    qualify row_number()
    over(
        partition by order_id
        order by order_date desc)=1
)

select * from deduplicated