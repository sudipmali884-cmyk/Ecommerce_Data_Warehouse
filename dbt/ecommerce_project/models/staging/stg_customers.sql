with customers as (
    select * from {{ source('raw','customers')}}
),
cleaned_data as(
    select
        -- primary key

        nullif(trim(customer_id) ,'')as customer_id,
--        CASE
--            WHEN REGEXP_LIKE(
--                NULLIF(TRIM(customer_id), ''),
--                '^CUST[0-9]{6}$'
--            )
--            THEN NULLIF(TRIM(customer_id), '')
--            ELSE 123456
--        END AS customer_id,
        nullif(INITCAP(TRIM(first_name)), '') as first_name,
        nullif(INITCAP(TRIM(last_name)), '') as last_name,

        case
            when upper(trim(gender)) in ('MALE','FEMALE')
                then initcap(trim(gender))
            else 'Other'
        end as gender,

        CASE

            WHEN TRY_TO_DATE(date_of_birth) IS NULL
                THEN NULL

            WHEN TRY_TO_DATE(date_of_birth) > CURRENT_DATE()
                THEN NULL

            ELSE TRY_TO_DATE(date_of_birth)

        END AS date_of_birth,

        case
            when regexp_like(trim(phone_number),'^[6-9][0-9]{9}$')
                then trim(phone_number)

            else null
        end as phone_number,

        case
            when regexp_like(trim(email),'^[a-z0-9.%+-]+@[a-z0-9.-]+\.[a-z]{2,}$')
                then lower(trim(email))

            else null
        end as email,

        nullif(trim(address),'') as address,
        case
            when trim(city)='' then null
            else initcap(trim(city))
        end as city,

        nullif(initcap(trim(state)),'') as state,

        nullif(initcap(trim(country)), '') as country,

        nullif(trim(postal_code),'') as postal_code,


        CASE

            WHEN TRY_TO_DATE(registration_date) IS NULL
                THEN NULL

            WHEN TRY_TO_DATE(registration_date) > CURRENT_DATE()
                THEN NULL

            ELSE TRY_TO_DATE(registration_date)

        END AS registration_date,

        case when upper(trim(customer_status)) in ('ACTIVE','INACTIVE')
        THEN INITCAP(TRIM(customer_status))
        else 'Unknown'

        end as customer_status,
        CASE

        WHEN UPPER(TRIM(customer_segment))
            IN (
                'BRONZE',
                'SILVER',
                'GOLD',
                'PLATINUM'
            )

            THEN INITCAP(TRIM(customer_segment))

        ELSE NULL

        END AS customer_segment,


        created_at,
        updated_at

    from customers

),

deduplicated as (
    select * from cleaned_data
    qualify row_number() over(
        partition by customer_id
        order by updated_at desc
    )=1
)

select * from deduplicated