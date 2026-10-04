with products as (
    select * from {{ source('raw','products')}}
),
cleaned_data as (
    select
        nullif(trim(product_id),'') as product_id,
        nullif(upper(trim(sku)),'') as sku,
        nullif(trim(product_name),'')  as product_name,
        case
            when trim(category)= '' then null
            else initcap(trim(category))

        end as category,
        case
            when trim(subcategory)= '' then null
            else initcap(trim(category))

        end as subcategory,

        nullif(initcap(trim(brand)), '') as brand,

        CASE
            WHEN cost_price < 0 THEN 0
            ELSE cost_price
        END AS cost_price,

        CASE
            WHEN selling_price < 0 THEN 0
            ELSE selling_price
        END AS selling_price,

        CASE
            WHEN discount_percentage < 0 THEN 0
                WHEN discount_percentage > 100 THEN 0
            ELSE discount_percentage
        END AS discount_percentage,

        CASE
            WHEN final_price < 0 THEN 0
            ELSE final_price
        END AS final_price,

        CASE
            WHEN rating < 0 OR rating > 5 THEN NULL
            ELSE rating
        END AS rating,

--        case
--            when try_to_decimal(cost_price, 18,2) < 0
--            THEN 0
--            ELSE TRY_TO_DECIMAL(cost_price,18,2)
--        end as cost_price,
--
--        case
--            when try_to_decimal(selling_price,18,2)<0
--                then 0
--            else try_to_decimal(selling_price,18,2)
--
--        end as selling_price,
--
--        case
--            when try_to_decimal(discount_percentage,5,2) < 0
--                then 0
--            when try_to_decimal(discount_percentage,5,2) > 100
--                then 0
--            else try_to_decimal(discount_percentage,5,2)
--        end as discount_percentage,
--
--
--        case
--            when try_to_decimal(final_price, 18, 2) < 0
--                then 0
--            else try_to_decimal(final_price,18,2)
--        end as final_price,
--
--        case
--            when try_to_decimal(rating, 3, 1) < 0
--                then null
--            when try_to_decimal(rating,3,1) > 5
--                then null
--            else try_to_decimal(rating,3,1)
--
--        end as rating,

        case
            when upper(trim(product_status)) in ('ACTIVE','INACTIVE','DISCONTINUED')
            then initcap(trim(product_status))

            else 'Unknown'

        end as product_status,

        CASE

            WHEN TRY_TO_DATE(created_at) IS NULL
                THEN NULL

            WHEN TRY_TO_DATE(created_at) > CURRENT_DATE()
                THEN NULL

            ELSE TRY_TO_DATE(created_at)

        END AS created_at


    FROM products

),

deduplicated as (
    select * from cleaned_data
    qualify row_number() over(
        partition by product_id
        order by created_at desc
    )=1
)

select * from deduplicated