with returns as(
select * from {{source('raw','returns')}}
),

cleaned_data as (
    select
        nullif(trim(return_id),'')as return_id,
        nullif(trim(order_id),'') as order_id,
            -- ----------------------------------------------------
        -- Customer ID
        -- ----------------------------------------------------

        nullif(
            upper(trim(customer_id)),
            ''
        ) as customer_id,


        -- ----------------------------------------------------
        -- Product ID
        -- ----------------------------------------------------

        nullif(
            upper(trim(product_id)),
            ''
        ) as product_id,

            -- ----------------------------------------------------
        -- Return Date
        -- ----------------------------------------------------

        case

            when try_to_date(return_date) is null
                then null

            when try_to_date(return_date) > current_date()
                then null

            else try_to_date(return_date)

        end as return_date,

             -- ----------------------------------------------------
        -- Return Quantity
        -- ----------------------------------------------------

        case

            when try_to_number(return_quantity) is null
                then null

            when try_to_number(return_quantity) <= 0
                then null

            else try_to_number(return_quantity)

        end as return_quantity,

         -- ----------------------------------------------------
        -- Return Reason
        -- ----------------------------------------------------

        case

            when trim(return_reason) = ''
                then null

            when upper(trim(return_reason)) in (

                'DAMAGED PRODUCT',
                'WRONG PRODUCT',
                'PRODUCT NOT AS DESCRIBED',
                'SIZE ISSUE',
                'COLOR ISSUE',
                'QUALITY ISSUE',
                'LATE DELIVERY',
                'CHANGED MIND',
                'DEFECTIVE PRODUCT',
                'DUPLICATE ORDER',
                'OTHER'

            )

            then initcap(trim(return_reason))

            else 'Unknown'

        end as return_reason,


        -- ----------------------------------------------------
        -- Return Condition
        -- ----------------------------------------------------

        case

            when upper(trim(return_condition)) in (

                'NEW',
                'OPENED',
                'USED',
                'DAMAGED'

            )

            then initcap(trim(return_condition))

            else 'Unknown'

        end as return_condition,
         -- ----------------------------------------------------
        -- Return Status
        -- ----------------------------------------------------

        case

            when upper(trim(return_status)) in (

                'REQUESTED',
                'APPROVED',
                'REJECTED',
                'PICKED UP',
                'RECEIVED',
                'COMPLETED',
                'REFUNDED'

            )

            then initcap(trim(return_status))

            else 'Unknown'

        end as return_status,


        case
            when refund_amount is null then null
            when refund_amount < 0 then 0
            else refund_amount
        end as refund_amount,


         case

            when upper(trim(refund_method)) in (

                'ORIGINAL PAYMENT METHOD',
                'BANK TRANSFER',
                'UPI',
                'WALLET',
                'STORE CREDIT'

            )

            then initcap(trim(refund_method))

            else 'Unknown'

        end as refund_method,

        case
            when refund_date is null then null
            when refund_date < current_date() then null
            else refund_date
        end as refund_date,

             -- ----------------------------------------------------

        case

            when upper(trim(restock_flag::varchar)) in (
                'TRUE',
                '1',
                'YES'
            )

                then true

            when upper(trim(restock_flag::varchar)) in (
                'FALSE',
                '0',
                'NO'
            )

                then false

            else null

        end as restock_flag

    from returns
),

deduplicated as (
    select * from cleaned_data
    qualify row_number() over(
        partition by return_id
        order by return_date desc
    )=1
)

select * from deduplicated