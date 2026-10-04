WITH inventory AS (

    SELECT *

    FROM {{ ref('stg_inventory') }}

),

products AS (

    SELECT

        product_id,

        product_name,

        category,

        subcategory,

        brand,

        cost_price,

        selling_price,
        product_status

    FROM {{ ref('stg_products') }}

)

SELECT

    i.inventory_id,

    i.product_id,

    i.warehouse_id,

    i.warehouse_name,

    i.warehouse_city,

    i.warehouse_state,

    i.stock_quantity,

    i.reserved_quantity,

    i.available_quantity,

    i.reorder_level,

    i.reorder_quantity,

    i.stock_status,

    i.stock_in_quantity,

    i.stock_out_quantity,

    i.last_restock_date,

    p.product_name,

    p.category,

    p.subcategory,

    p.brand,

    p.cost_price,

    p.selling_price,

    p.product_status,

    -- ========================================================
    -- PRODUCT EXISTS VALIDATION
    -- ========================================================

    CASE

        WHEN p.product_id IS NOT NULL

        THEN TRUE

        ELSE FALSE

    END AS product_exists,


    -- ========================================================
    -- AVAILABLE STOCK CALCULATION
    --
    -- Stock Quantity - Reserved Quantity
    -- ========================================================

    CASE

        WHEN i.stock_quantity IS NOT NULL

        AND i.reserved_quantity IS NOT NULL

        THEN

            i.stock_quantity
            - i.reserved_quantity

        ELSE NULL

    END AS calculated_available_quantity,


    -- ========================================================
    -- AVAILABLE QUANTITY MATCH
    -- ========================================================

    CASE

        WHEN i.available_quantity IS NULL

        THEN FALSE

        WHEN i.stock_quantity IS NULL

        OR i.reserved_quantity IS NULL

        THEN NULL

        WHEN i.available_quantity =

            i.stock_quantity
            - i.reserved_quantity

        THEN TRUE

        ELSE FALSE

    END AS available_quantity_matches,


    -- ========================================================
    -- REORDER REQUIRED
    -- ========================================================

    CASE

        WHEN i.available_quantity IS NULL

        OR i.reorder_level IS NULL

        THEN NULL

        WHEN i.available_quantity <= i.reorder_level

        THEN TRUE

        ELSE FALSE

    END AS reorder_required,


    -- ========================================================
    -- STOCK LEVEL
    -- ========================================================

    CASE

        WHEN i.available_quantity IS NULL

        OR i.reorder_level IS NULL

        THEN 'Unknown'

        WHEN i.available_quantity <= 0

        THEN 'Out of Stock'

        WHEN i.available_quantity <= i.reorder_level

        THEN 'Low Stock'

        ELSE 'Healthy Stock'

    END AS calculated_stock_status,


    -- ========================================================
    -- INVENTORY COST VALUE
    -- ========================================================

    CASE

        WHEN p.cost_price IS NOT NULL

        AND i.stock_quantity IS NOT NULL

        THEN ROUND(

            p.cost_price
            * i.stock_quantity,

            2

        )

        ELSE NULL

    END AS inventory_cost_value,


    -- ========================================================
    -- AVAILABLE INVENTORY COST VALUE
    -- ========================================================

    CASE

        WHEN p.cost_price IS NOT NULL

        AND i.available_quantity IS NOT NULL

        THEN ROUND(

            p.cost_price
            * i.available_quantity,

            2

        )

        ELSE NULL

    END AS available_inventory_cost_value,


    -- ========================================================
    -- INVENTORY SELLING VALUE
    -- ========================================================

    CASE

        WHEN p.selling_price IS NOT NULL

        AND i.stock_quantity IS NOT NULL

        THEN ROUND(

            p.selling_price
            * i.stock_quantity,

            2

        )

        ELSE NULL

    END AS inventory_selling_value,


    -- ========================================================
    -- POTENTIAL INVENTORY PROFIT
    -- ========================================================

    CASE

        WHEN p.selling_price IS NOT NULL

        AND p.cost_price IS NOT NULL

        AND i.stock_quantity IS NOT NULL

        THEN ROUND(

            (
                p.selling_price
                - p.cost_price
            )
            * i.stock_quantity,

            2

        )

        ELSE NULL

    END AS potential_inventory_profit,


    -- ========================================================
    -- STOCK MOVEMENT
    -- ========================================================

    CASE

        WHEN i.stock_in_quantity IS NULL

        OR i.stock_out_quantity IS NULL

        THEN NULL

        ELSE

            i.stock_in_quantity
            - i.stock_out_quantity

    END AS net_stock_movement,


    -- ========================================================
    -- STOCK MOVEMENT STATUS
    -- ========================================================

    CASE

        WHEN i.stock_in_quantity IS NULL

        OR i.stock_out_quantity IS NULL

        THEN 'Unknown'

        WHEN i.stock_in_quantity >

             i.stock_out_quantity

        THEN 'Increasing'

        WHEN i.stock_in_quantity <

             i.stock_out_quantity

        THEN 'Decreasing'

        ELSE 'Stable'

    END AS stock_movement_status,


    -- ========================================================
    -- RESERVED STOCK PERCENTAGE
    -- ========================================================

    CASE

        WHEN i.stock_quantity IS NULL

        OR i.stock_quantity = 0

        THEN NULL

        WHEN i.reserved_quantity IS NULL

        THEN NULL

        ELSE ROUND(

            (
                i.reserved_quantity
                / i.stock_quantity
            ) * 100,

            2

        )

    END AS reserved_stock_percentage,


    -- ========================================================
    -- INVENTORY DATA QUALITY FLAG
    -- ========================================================

    CASE

        WHEN i.product_id IS NULL

        THEN TRUE

        WHEN p.product_id IS NULL

        THEN TRUE

        WHEN i.stock_quantity IS NULL

        THEN TRUE

        WHEN i.stock_quantity < 0

        THEN TRUE

        WHEN i.reserved_quantity IS NOT NULL

             AND i.reserved_quantity < 0

        THEN TRUE

        WHEN i.available_quantity IS NOT NULL

             AND i.available_quantity < 0

        THEN TRUE

        WHEN i.reorder_level IS NOT NULL

             AND i.reorder_level < 0

        THEN TRUE

        ELSE FALSE

    END AS inventory_data_quality_issue

FROM inventory i

LEFT JOIN products p

    ON i.product_id = p.product_id