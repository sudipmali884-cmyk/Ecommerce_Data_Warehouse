with order_items as (
    select * from {{ source('raw','order_items')}}
),

cleaned_data as (
    select
        nullif(trim(order_item_id), '') as order_item_id,
        nullif(trim(order_id),'') as order_id,
        nullif(trim(product_id),'') as product_id,

        case
            when try_to_number(quantity) is null then null
            when try_to_number(quantity) <= 0 then null
            else try_to_number(quantity)
        end as quantity,

        case
            when unit_price < 0 then null
            else unit_price
        end as unit_price,

        case
            when discount_percentage < 0 then null
            when discount_percentage > 100 then null
            else discount_percentage
        end as discount_percentage,

        case
            when gross_amount < 0 then null
            when gross_amount > 1605105 then null
            else gross_amount
        end as gross_amount,

        case
            when discount_amount < 0 then null

            else discount_amount
        end as discount_amount,

        case
            when tax_amount < 0 then null
            else tax_amount
        end as tax_amount,
        case
            when line_total < 0 then null
            else line_total
        end as line_total,

    from order_items

),

deduplicated as (
    select * from cleaned_data
    qualify row_number() over(
    partition by order_item_id
    order by order_item_id
    )=1
)

select * from deduplicated