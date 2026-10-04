WITH returns AS (

    SELECT *

    FROM {{ ref('stg_returns') }}

),
orders as (
    select
        order_id,
        customer_id,
        order_date,
        order_status

        from {{ ref('stg_orders')}}
),
order_items as (
    select
        order_id,
        product_id,
        quantity,
        unit_price

    from {{ ref('stg_order_items')}}
),

products AS (

    SELECT

        product_id,

        product_name,

        category,

        subcategory,

        brand,

        cost_price,

        selling_price

    FROM {{ ref('stg_products') }}

)
SELECT

    r.return_id,

    r.order_id,

    r.customer_id,

    r.product_id,

    r.return_date,

    r.return_quantity,

    r.return_reason,

    r.return_condition,

    r.return_status,

    r.refund_amount,

    r.refund_method,

    r.refund_date,

    r.restock_flag,

    p.product_name,

    p.category,

    p.subcategory,

    p.brand,

    p.cost_price,

    p.selling_price,

    o.order_date,

    o.order_status,

    oi.quantity AS ordered_quantity,

    oi.unit_price AS ordered_unit_price,

    case
        when p.selling_price is not null
        then round(
            p.selling_price * r.return_quantity, 2
        )
        else null
    end as expected_refund_amount,

        -- ========================================================
    -- REFUND DIFFERENCE
    -- ========================================================

    CASE

        WHEN p.selling_price IS NOT NULL

        AND r.refund_amount IS NOT NULL

        THEN ROUND(

            r.refund_amount
            -
            (
                p.selling_price
                * r.return_quantity
            ),

            2

        )

        ELSE NULL

    END AS refund_amount_difference,

    -- ========================================================
    -- REFUND AMOUNT MATCH
    -- ========================================================

    CASE

        WHEN p.selling_price IS NULL

        THEN NULL

        WHEN r.refund_amount IS NULL

        THEN FALSE

        WHEN ABS(

            r.refund_amount
            -
            (
                p.selling_price
                * r.return_quantity
            )

        ) <= 1

        THEN TRUE

        ELSE FALSE

    END AS refund_amount_matches,


    -- ========================================================
    -- ORDER EXISTS
    -- ========================================================

    CASE

        WHEN o.order_id IS NOT NULL

        THEN TRUE

        ELSE FALSE

    END AS order_exists,


    -- ========================================================
    -- PRODUCT EXISTS
    -- ========================================================

    CASE

        WHEN p.product_id IS NOT NULL

        THEN TRUE

        ELSE FALSE

    END AS product_exists,


    -- ========================================================
    -- PRODUCT WAS ORDERED
    -- ========================================================

    CASE

        WHEN oi.order_id IS NOT NULL

        AND oi.product_id IS NOT NULL

        THEN TRUE

        ELSE FALSE

    END AS product_ordered,


    -- ========================================================
    -- CUSTOMER MATCH
    -- ========================================================

    CASE

        WHEN o.customer_id IS NULL

        THEN NULL

        WHEN r.customer_id = o.customer_id

        THEN TRUE

        ELSE FALSE

    END AS customer_id_matches_order,


    -- ========================================================
    -- RETURN DATE VALIDATION
    -- ========================================================

    CASE

        WHEN r.return_date IS NULL

        THEN FALSE

        WHEN o.order_date IS NULL

        THEN NULL

        WHEN r.return_date >= o.order_date

        THEN TRUE

        ELSE FALSE

    END AS valid_return_date,


    -- ========================================================
    -- RETURN QUANTITY VALIDATION
    -- ========================================================

    CASE

        WHEN r.return_quantity IS NULL

        THEN FALSE

        WHEN r.return_quantity <= 0

        THEN FALSE

        WHEN oi.quantity IS NULL

        THEN NULL

        WHEN r.return_quantity <= oi.quantity

        THEN TRUE

        ELSE FALSE

    END AS valid_return_quantity,


    -- ========================================================
    -- REFUND DATE VALIDATION
    -- ========================================================

    CASE

        WHEN r.refund_date IS NULL

        THEN NULL

        WHEN r.return_date IS NULL

        THEN NULL

        WHEN r.refund_date >= r.return_date

        THEN TRUE

        ELSE FALSE

    END AS valid_refund_date,


    -- ========================================================
    -- RESTOCK ELIGIBILITY
    -- ========================================================

    CASE

        WHEN r.return_condition IN (

            'New',

            'Opened'

        )

        AND r.restock_flag = TRUE

        THEN TRUE

        ELSE FALSE

    END AS eligible_for_restock,


    -- ========================================================
    -- RETURN COMPLETED FLAG
    -- ========================================================

    CASE

        WHEN r.return_status IN (

            'Completed',

            'Refunded'

        )

        THEN TRUE

        ELSE FALSE

    END AS return_completed,


    -- ========================================================
    -- RETURN DATA QUALITY FLAG
    -- ========================================================

    CASE

        WHEN r.order_id IS NULL

        THEN TRUE

        WHEN r.product_id IS NULL

        THEN TRUE

        WHEN o.order_id IS NULL

        THEN TRUE

        WHEN p.product_id IS NULL

        THEN TRUE

        WHEN r.return_quantity IS NULL

        THEN TRUE

        WHEN r.return_quantity <= 0

        THEN TRUE

        ELSE FALSE

    END AS return_data_quality_issue

FROM returns r

LEFT JOIN orders o

    ON r.order_id = o.order_id

LEFT JOIN order_items oi

    ON r.order_id = oi.order_id

    AND r.product_id = oi.product_id

LEFT JOIN products p

    ON r.product_id = p.product_id