with reviews as(
    select * from {{ ref('stg_reviews')}}
),

orders as(
    select
        order_id,
        customer_id,
        order_date,
        order_status

        from {{ ref('stg_orders')}}
),

order_items as (
    select distinct
    order_id,
    product_id
    from {{ ref('stg_order_items')}}
),


products as (
    select
    product_id,

    product_name,

    category,

    subcategory,

    brand,
    selling_price

    FROM {{ ref('stg_products') }}
)
select
    r.review_id,
    r.order_id,
    r.customer_id,
    r.product_id,
    r.rating,
    r.review_title,
    r.review_text,
    r.review_date,
    r.verified_purchase,
    o.order_date,
    o.order_status,
    p.product_name,
    p.category,
    p.subcategory,
    p.brand,
    p.selling_price,

    case
        when oi.order_id is not null
        and oi.product_id is not null
        then true
        else false
    end as product_purchased_in_order,

    case
        when o.order_id is not null
        then true
        else false
    end as order_exists,

    case
        when p.product_id is not null
        then true
        else false
    end as product_exists,

    case
        when o.customer_id is null then null

        when r.customer_id =o.customer_id
        then true
        else false
    end as customer_id_matches_order,

    CASE

        WHEN r.review_date IS NULL

        THEN FALSE

        WHEN o.order_date IS NULL

        THEN NULL

        WHEN r.review_date >= o.order_date

        THEN TRUE

        ELSE FALSE

    END AS valid_review_date,


    CASE

        WHEN r.rating >= 4

        THEN 'Positive'

        WHEN r.rating = 3

        THEN 'Neutral'

        WHEN r.rating <= 2

        THEN 'Negative'

        ELSE 'Unknown'

    END AS rating_category,

    -- REVIEW DATA QUALITY
    -- ========================================================

    CASE

        WHEN r.order_id IS NULL

        THEN TRUE

        WHEN r.product_id IS NULL

        THEN TRUE

        WHEN r.customer_id IS NULL

        THEN TRUE

        WHEN p.product_id IS NULL

        THEN TRUE

        WHEN o.order_id IS NULL

        THEN TRUE

        ELSE FALSE

    END AS review_data_quality_issue

from reviews r
left join orders o
on r.order_id = o.order_id
left join order_items oi
on r.order_id = oi. order_id

and r.product_id = oi.product_id

left join products p
on r.product_id = p.product_id
