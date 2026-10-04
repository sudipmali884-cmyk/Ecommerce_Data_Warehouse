-- ============================================================
-- DIM_WAREHOUSES
-- ============================================================

WITH inventory AS (

    SELECT

        warehouse_id,
        warehouse_name,
        warehouse_city,
        warehouse_state

    FROM {{ ref('stg_inventory') }}

    WHERE warehouse_id IS NOT NULL

),

warehouses AS (

    SELECT

        warehouse_id,

        MAX(warehouse_name)
            AS warehouse_name,

        MAX(warehouse_city)
            AS warehouse_city,

        MAX(warehouse_state)
            AS warehouse_state

    FROM inventory

    GROUP BY warehouse_id

),

inventory_summary AS (

    SELECT

        warehouse_id,

        COUNT(
            DISTINCT product_id
        ) AS total_products,

        SUM(
            stock_quantity
        ) AS total_stock_quantity,

        SUM(
            reserved_quantity
        ) AS total_reserved_quantity,

        SUM(
            available_quantity
        ) AS total_available_quantity,

        SUM(
            stock_in_quantity
        ) AS total_stock_in_quantity,

        SUM(
            stock_out_quantity
        ) AS total_stock_out_quantity

    FROM {{ ref('stg_inventory') }}

    WHERE warehouse_id IS NOT NULL

    GROUP BY warehouse_id

)

SELECT

    -- ========================================================
    -- WAREHOUSE
    -- ========================================================

    w.warehouse_id,

    w.warehouse_name,

    w.warehouse_city,

    w.warehouse_state,


    -- ========================================================
    -- WAREHOUSE SUMMARY
    -- ========================================================

    COALESCE(

        s.total_products,

        0

    ) AS total_products,

    COALESCE(

        s.total_stock_quantity,

        0

    ) AS total_stock_quantity,

    COALESCE(

        s.total_reserved_quantity,

        0

    ) AS total_reserved_quantity,

    COALESCE(

        s.total_available_quantity,

        0

    ) AS total_available_quantity,

    COALESCE(

        s.total_stock_in_quantity,

        0

    ) AS total_stock_in_quantity,

    COALESCE(

        s.total_stock_out_quantity,

        0

    ) AS total_stock_out_quantity,


    -- ========================================================
    -- AVAILABLE STOCK PERCENTAGE
    -- ========================================================

    CASE

        WHEN s.total_stock_quantity IS NULL

        OR s.total_stock_quantity = 0

        THEN NULL

        ELSE ROUND(

            s.total_available_quantity
            /
            s.total_stock_quantity
            * 100,

            2

        )

    END AS available_stock_percentage,


    -- ========================================================
    -- RESERVED STOCK PERCENTAGE
    -- ========================================================

    CASE

        WHEN s.total_stock_quantity IS NULL

        OR s.total_stock_quantity = 0

        THEN NULL

        ELSE ROUND(

            s.total_reserved_quantity
            /
            s.total_stock_quantity
            * 100,

            2

        )

    END AS reserved_stock_percentage,


    -- ========================================================
    -- STOCK MOVEMENT
    -- ========================================================

    CASE

        WHEN s.total_stock_in_quantity >

             s.total_stock_out_quantity

        THEN 'Increasing'

        WHEN s.total_stock_in_quantity <

             s.total_stock_out_quantity

        THEN 'Decreasing'

        ELSE 'Stable'

    END AS stock_movement_status,


    -- ========================================================
    -- DATA QUALITY
    -- ========================================================

    CASE

        WHEN w.warehouse_id IS NULL

        THEN TRUE

        WHEN TRIM(w.warehouse_id) = ''

        THEN TRUE

        WHEN w.warehouse_name IS NULL

        THEN TRUE

        WHEN TRIM(w.warehouse_name) = ''

        THEN TRUE

        ELSE FALSE

    END AS warehouse_data_quality_issue

FROM warehouses w

LEFT JOIN inventory_summary s

    ON w.warehouse_id = s.warehouse_id