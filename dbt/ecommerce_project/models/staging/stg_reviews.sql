with reviews as(
    select * from {{ source('raw','reviews')}}
),

cleaned_data as (
    select

        CASE
            WHEN REGEXP_LIKE(
                NULLIF(TRIM(review_id), ''),
                '^REV[0-9]{9}$'
            )
            THEN NULLIF(TRIM(review_id), '')
            ELSE NULL
        END AS review_id,

        CASE
            WHEN REGEXP_LIKE(
                NULLIF(TRIM(order_id), ''),
                '^ORD[0-9]{8}$'
            )
            THEN NULLIF(TRIM(order_id), '')
            ELSE NULL
        END AS order_id,

        CASE
            WHEN REGEXP_LIKE(
                NULLIF(TRIM(customer_id), ''),
                '^CUST[0-9]{6}$'
            )
            THEN NULLIF(TRIM(customer_id), '')
            ELSE NULL
        END AS customer_id,

        CASE
            WHEN REGEXP_LIKE(
                NULLIF(TRIM(product_id), ''),
                '^PROD[0-9]{6}$'
            )
            THEN NULLIF(TRIM(product_id), '')
            ELSE NULL
        END AS product_id,
--        nullif(trim(review_id),'') as review_id,
--
--        -- ----------------------------------------------------
--        -- Order ID
--        -- ----------------------------------------------------
--
----        NULLIF(
----            TRIM(order_id),
----            ''
----        ) AS order_id,
----
----         case
----            when regexp_like(trim(phone_number),'^[6-9][0-9]{9}$')
----                then trim(phone_number)
----
----            else null
----        end as phone_number,
--        case
--            when regexp_like(nullif(trim(order_id),''), '^ORD[0-9]{8}$')
--                then nullif(trim(order_id),'')
--            else null
--        end as order_id,
--
--
--        -- ----------------------------------------------------
--        -- Customer ID
--        -- ----------------------------------------------------
----
----        NULLIF(
----            TRIM(customer_id),
----            ''
----        ) AS customer_id,
--
--
--        -- ----------------------------------------------------
--        -- Product ID
--        -- ----------------------------------------------------
--
--        NULLIF(
--            TRIM(product_id),
--            ''
--        ) AS product_id,

        case when rating between 1 and 5 then rating
        else null

        end as rating,

        nullif(initcap(trim(review_title)),'') as review_title,
        nullif(trim(review_text), '') as review_text,
--        case
--            review_date is null then null
--            review_date > current_date() then null
--            else review_date
--        end as review_date,
           CASE

            WHEN TRY_TO_DATE(review_date) IS NULL

                THEN NULL

            WHEN TRY_TO_DATE(review_date) > CURRENT_DATE()

                THEN NULL

            ELSE TRY_TO_DATE(review_date)

        END AS review_date,

        CASE

            WHEN LOWER(TRIM(verified_purchase::VARCHAR))
                IN ('true', '1', 'yes')

                THEN TRUE

            WHEN LOWER(TRIM(verified_purchase::VARCHAR))
                IN ('false', '0', 'no')

                THEN FALSE

            ELSE NULL

        END AS verified_purchase


    FROM reviews

),

deduplicated as(
    select * from cleaned_data
    qualify row_number() over(

    partition by review_id
    order by review_date desc
    )=1
)
select * from deduplicated

