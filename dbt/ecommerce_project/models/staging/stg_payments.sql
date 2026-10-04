with payments as(
    select * from {{ source('raw','payments')}}
),
cleaned_data as(
    select
        nullif(trim(payment_id), '') as payment_id,
        nullif(trim(order_id),'') as order_id,

        nullif(trim(customer_id),'') as customer_id,

        case
            when try_to_date(payment_date) is null then null
            when try_to_date(payment_date) > current_date() then null
            else try_to_date(payment_date)
        end as payment_date,

        case
            when upper(trim(payment_method)) in (

                'CREDIT CARD',
                'DEBIT CARD',
                'NET BANKING',
                'WALLET',
                'CASH ON DELIVERY'

            )
            then initcap(trim(payment_method))
            when upper(trim(payment_method)) in ('UPI','EMI') then upper(trim('UPI','EMI'))
            else 'Unknown'
            end as payment_method,

             case

            when upper(trim(payment_gateway)) in (

                'RAZORPAY',
                'STRIPE',
                'PAYU',
                'CASHFREE',
                'PHONEPE',
                'PAYTM',
                'COD'

            )

            then upper(trim(payment_gateway))

            else 'Unknown'

        end as payment_gateway,

           -- ----------------------------------------------------
        -- Payment Status
        -- ----------------------------------------------------

        case

            when upper(trim(payment_status)) in (

                'PAID',
                'FAILED',
                'REFUNDED',
                'PENDING'

            )

            then initcap(trim(payment_status))

            else 'Unknown'

        end as payment_status,

        case
            when payment_amount < 0 then 0
            else payment_amount
        end as payment_amount,


        case
            when upper(trim(currency))='INR'
                then 'INR'
            else 'Unknown'
        end as currency,

        case
            when regexp_like(upper(trim(transaction_id)),'^TXN[0-9]{12}$')
            then upper(trim(transaction_id)) else null
        end as transaction_id

    from payments


),

deduplicated as (
    select * from cleaned_data
    qualify row_number()
    over ( partition by payment_id
    order by payment_date desc)=1

)

select * from deduplicated