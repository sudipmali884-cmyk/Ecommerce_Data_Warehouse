-- ============================================================
-- DIM_PRODUCTS
-- ============================================================

WITH products AS (

    SELECT

        product_id,
        sku,
        product_name,
        category,
        subcategory,
        brand,
        cost_price,
        selling_price,
        discount_percentage,
        final_price,
        rating,
        product_status,
        created_at

    FROM {{ ref('stg_products') }}

),

product_sales AS (

    SELECT

        product_id,

        COUNT(DISTINCT order_id)
            AS total_orders,

        SUM(quantity)
            AS total_quantity_sold,

        SUM(line_total)
            AS total_sales_amount

    FROM {{ ref('int_order_items') }}

    WHERE product_id IS NOT NULL

    GROUP BY product_id

),

product_returns AS (

    SELECT

        product_id,

        COUNT(DISTINCT return_id)
            AS total_returns,

        SUM(return_quantity)
            AS total_return_quantity,

        SUM(refund_amount)
            AS total_refund_amount

    FROM {{ ref('int_returns') }}

    WHERE product_id IS NOT NULL

    GROUP BY product_id

)

SELECT

    -- ========================================================
    -- PRODUCT IDENTIFICATION
    -- ========================================================

    p.product_id,

    p.sku,

    p.product_name,

    -- ========================================================
    -- PRODUCT HIERARCHY
    -- ========================================================

    p.category,

    p.subcategory,

    p.brand,

    -- ========================================================
    -- PRICING
    -- ========================================================

    p.cost_price,

    p.selling_price,

    p.discount_percentage,

    p.final_price,

    -- ========================================================
    -- PRODUCT QUALITY
    -- ========================================================

    p.rating,

    p.product_status,

    p.created_at,

    -- ========================================================
    -- PROFIT PER UNIT
    -- ========================================================

    CASE

        WHEN p.selling_price IS NOT NULL

        AND p.cost_price IS NOT NULL

        THEN ROUND(

            p.selling_price
            - p.cost_price,

            2

        )

        ELSE NULL

    END AS profit_per_unit,

    -- ========================================================
    -- PROFIT MARGIN
    -- ========================================================

    CASE

        WHEN p.selling_price IS NULL

        OR p.selling_price = 0

        OR p.cost_price IS NULL

        THEN NULL

        ELSE ROUND(

            (
                p.selling_price
                - p.cost_price
            )

            / p.selling_price

            * 100,

            2

        )

    END AS profit_margin_percentage,

    -- ========================================================
    -- SALES INFORMATION
    -- ========================================================

    COALESCE(

        ps.total_orders,

        0

    ) AS total_orders,

    COALESCE(

        ps.total_quantity_sold,

        0

    ) AS total_quantity_sold,

    COALESCE(

        ps.total_sales_amount,

        0

    ) AS total_sales_amount,

    -- ========================================================
    -- RETURN INFORMATION
    -- ========================================================

    COALESCE(

        pr.total_returns,

        0

    ) AS total_returns,

    COALESCE(

        pr.total_return_quantity,

        0

    ) AS total_return_quantity,

    COALESCE(

        pr.total_refund_amount,

        0

    ) AS total_refund_amount,

    -- ========================================================
    -- RETURN RATE
    -- ========================================================

    CASE

        WHEN ps.total_quantity_sold IS NULL

        OR ps.total_quantity_sold = 0

        THEN 0

        ELSE ROUND(

            pr.total_return_quantity
            /
            ps.total_quantity_sold
            * 100,

            2

        )

    END AS return_rate_percentage,

    -- ========================================================
    -- PRODUCT DATA QUALITY
    -- ========================================================

    CASE

        WHEN p.product_id IS NULL

        THEN TRUE

        WHEN TRIM(p.product_id) = ''

        THEN TRUE

        WHEN p.product_name IS NULL

        THEN TRUE

        WHEN TRIM(p.product_name) = ''

        THEN TRUE

        WHEN p.cost_price IS NOT NULL

             AND p.cost_price < 0

        THEN TRUE

        WHEN p.selling_price IS NOT NULL

             AND p.selling_price < 0

        THEN TRUE

        WHEN p.rating IS NOT NULL

             AND (

                 p.rating < 0

                 OR

                 p.rating > 5

             )

        THEN TRUE

        ELSE FALSE

    END AS product_data_quality_issue

FROM products p

LEFT JOIN product_sales ps

    ON p.product_id = ps.product_id

LEFT JOIN product_returns pr

    ON p.product_id = pr.product_id