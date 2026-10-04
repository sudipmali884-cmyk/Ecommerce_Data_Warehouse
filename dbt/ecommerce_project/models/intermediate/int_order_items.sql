with order_items as(
    select * from {{ ref('stg_order_items')}}
),

orders as (
   SELECT

        order_id,
        customer_id,
        order_date,
        order_status

    FROM {{ ref('stg_orders') }}
),
products as (
    select
        product_id,
        product_name,
        category,
        subcategory,
        brand,
        cost_price,
        selling_price,
    from {{ ref('stg_products')}}
)
select
    oi.order_item_id,

    oi.order_id,

    oi.product_id,

    oi.quantity,

    oi.unit_price,

    oi.discount_percentage,

    oi.gross_amount,

    oi.discount_amount,

    oi.tax_amount,

    oi.line_total,


    -- ========================================================
    -- ORDER INFORMATION
    -- ========================================================

    o.customer_id,

    o.order_date,

    o.order_status,


    -- ========================================================
    -- PRODUCT INFORMATION
    -- ========================================================

    p.product_name,

    p.category,

    p.subcategory,

    p.brand,

    p.cost_price,

    p.selling_price,


    -- ========================================================
    -- BUSINESS CALCULATIONS
    -- ========================================================

    CASE

        WHEN p.cost_price IS NOT NULL

        THEN p.cost_price * oi.quantity

        ELSE NULL

    END AS total_cost,


    CASE

        WHEN p.cost_price IS NOT NULL

        THEN oi.line_total
             - (p.cost_price * oi.quantity)

        ELSE NULL

    END AS profit_amount,


    CASE

        WHEN oi.line_total > 0

        AND p.cost_price IS NOT NULL

        THEN (

            (
                oi.line_total
                - (p.cost_price * oi.quantity)
            )

            / oi.line_total

        ) * 100

        ELSE NULL

    END AS profit_margin_percentage,


    -- ========================================================
    -- BUSINESS FLAGS
    -- ========================================================

    CASE

        WHEN oi.quantity <= 0

        THEN TRUE

        ELSE FALSE

    END AS invalid_quantity_flag,


    CASE

        WHEN oi.product_id IS NULL

        THEN TRUE

        WHEN p.product_id IS NULL

        THEN TRUE

        ELSE FALSE

    END AS invalid_product_flag,


    CASE

        WHEN oi.order_id IS NULL

        THEN TRUE

        WHEN o.order_id IS NULL

        THEN TRUE

        ELSE FALSE

    END AS invalid_order_flag

FROM order_items oi

LEFT JOIN orders o

    ON oi.order_id = o.order_id

LEFT JOIN products p

    ON oi.product_id = p.product_id