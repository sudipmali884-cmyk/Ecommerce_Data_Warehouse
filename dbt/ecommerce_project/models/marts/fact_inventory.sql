-- ============================================================
-- FACT INVENTORY
-- Grain: One row per inventory record
-- ============================================================

WITH inventory AS (

    SELECT

        inventory_id,

        product_id,

        warehouse_id,

        warehouse_name,

        warehouse_city,

        warehouse_state,

        stock_quantity,

        reserved_quantity,

        available_quantity,

        reorder_level,

        reorder_quantity,

        stock_status,

        stock_in_quantity,

        stock_out_quantity,

        last_restock_date

    FROM {{ ref('stg_inventory') }}

    WHERE inventory_id IS NOT NULL

),

-- ============================================================
-- PRODUCTS
-- ============================================================

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

    WHERE product_id IS NOT NULL

),

-- ============================================================
-- FINAL INVENTORY
-- ============================================================

final AS (

    SELECT

        -- ----------------------------------------------------
        -- INVENTORY
        -- ----------------------------------------------------

        i.inventory_id,

        i.product_id,

        i.warehouse_id,

        i.warehouse_name,

        i.warehouse_city,

        i.warehouse_state,


        -- ----------------------------------------------------
        -- PRODUCT
        -- ----------------------------------------------------

        p.product_name,

        p.category,

        p.subcategory,

        p.brand,

        p.product_status,

        p.cost_price,

        p.selling_price,


        -- ----------------------------------------------------
        -- STOCK
        -- ----------------------------------------------------

        COALESCE(
            i.stock_quantity,
            0
        ) AS stock_quantity,

        COALESCE(
            i.reserved_quantity,
            0
        ) AS reserved_quantity,

        COALESCE(
            i.available_quantity,
            0
        ) AS available_quantity,

        i.reorder_level,

        i.reorder_quantity,

        i.stock_status,

        i.stock_in_quantity,

        i.stock_out_quantity,

        i.last_restock_date,


        -- ----------------------------------------------------
        -- INVENTORY COST VALUE
        -- ----------------------------------------------------

        ROUND(

            COALESCE(i.stock_quantity, 0)
            *
            COALESCE(p.cost_price, 0),

            2

        ) AS inventory_cost_value,


        -- ----------------------------------------------------
        -- INVENTORY SELLING VALUE
        -- ----------------------------------------------------

        ROUND(

            COALESCE(i.stock_quantity, 0)
            *
            COALESCE(p.selling_price, 0),

            2

        ) AS inventory_selling_value,


        -- ----------------------------------------------------
        -- AVAILABLE STOCK VALUE
        -- ----------------------------------------------------

        ROUND(

            COALESCE(i.available_quantity, 0)
            *
            COALESCE(p.cost_price, 0),

            2

        ) AS available_stock_value,


        -- ----------------------------------------------------
        -- LOW STOCK
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(
                i.available_quantity,
                0
            ) <= COALESCE(
                i.reorder_level,
                0
            )

            THEN 1

            ELSE 0

        END AS low_stock_flag,


        -- ----------------------------------------------------
        -- OUT OF STOCK
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(
                i.available_quantity,
                0
            ) <= 0

            THEN 1

            ELSE 0

        END AS out_of_stock_flag,


        -- ----------------------------------------------------
        -- REORDER REQUIRED
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(
                i.available_quantity,
                0
            ) <= COALESCE(
                i.reorder_level,
                0
            )

            THEN 1

            ELSE 0

        END AS reorder_required_flag,


        -- ----------------------------------------------------
        -- NET STOCK MOVEMENT
        -- ----------------------------------------------------

        COALESCE(
            i.stock_in_quantity,
            0
        )
        -
        COALESCE(
            i.stock_out_quantity,
            0
        ) AS net_stock_movement,


        -- ----------------------------------------------------
        -- RESERVED %
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(
                i.stock_quantity,
                0
            ) > 0

            THEN ROUND(

                (
                    COALESCE(
                        i.reserved_quantity,
                        0
                    )
                    /
                    i.stock_quantity
                ) * 100,

                2

            )

            ELSE 0

        END AS reserved_stock_percentage,


        -- ----------------------------------------------------
        -- AVAILABLE %
        -- ----------------------------------------------------

        CASE

            WHEN COALESCE(
                i.stock_quantity,
                0
            ) > 0

            THEN ROUND(

                (
                    COALESCE(
                        i.available_quantity,
                        0
                    )
                    /
                    i.stock_quantity
                ) * 100,

                2

            )

            ELSE 0

        END AS available_stock_percentage,


        -- ----------------------------------------------------
        -- DATA QUALITY
        -- ----------------------------------------------------

        CASE

            WHEN i.inventory_id IS NULL
                THEN TRUE

            WHEN i.product_id IS NULL
                THEN TRUE

            WHEN i.warehouse_id IS NULL
                THEN TRUE

            WHEN i.stock_quantity < 0
                THEN TRUE

            WHEN i.reserved_quantity < 0
                THEN TRUE

            WHEN i.available_quantity < 0
                THEN TRUE

            WHEN i.reorder_level < 0
                THEN TRUE

            ELSE FALSE

        END AS data_quality_issue


    FROM inventory i

    LEFT JOIN products p

        ON i.product_id = p.product_id

)

SELECT *

FROM final