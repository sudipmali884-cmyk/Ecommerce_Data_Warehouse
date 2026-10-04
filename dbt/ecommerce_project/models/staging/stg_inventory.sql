with inventory as(
    select * from {{ source('raw','inventory')}}
),
cleaned_data as(
    select
    case
        when regexp_like(nullif(trim(inventory_id),''),'^INV[0-9]{9}$')
        then nullif(trim(inventory_id), '') else null
        end as inventory_id,

        case
            when regexp_like(nullif(trim(product_id),''), '^PROD[0-9]{6}$') then
                nullif(trim(product_id), '')
                else null
        end as product_id,
        -- ====================================================
        -- Warehouse ID
        -- ====================================================

        nullif(
            upper(trim(warehouse_id)),
            ''
        ) as warehouse_id,


        -- ====================================================
        -- Warehouse Name
        -- ====================================================

        nullif(
            initcap(trim(warehouse_name)),
            ''
        ) as warehouse_name,


        -- ====================================================
        -- Warehouse City
        -- ====================================================

        nullif(
            initcap(trim(warehouse_city)),
            ''
        ) as warehouse_city,


        -- ====================================================
        -- Warehouse State
        -- ====================================================

        nullif(
            initcap(trim(warehouse_state)),
            ''
        ) as warehouse_state,

         -- ====================================================
        -- Stock Quantity
        -- ====================================================
--
--        case
--
--            when try_to_number(stock_quantity) is null
--                then null
--
--            when try_to_number(stock_quantity) < 0
--                then 0
--
--            else try_to_number(stock_quantity)
--
--        end as stock_quantity,


        case
            when stock_quantity is null then null
            when stock_quantity < 0 then 0
            else stock_quantity
        end as stock_quantity,

        case
            when reserved_quantity is null then null
            when reserved_quantity < 0 then 0
        else reserved_quantity
        end as reserved_quantity,

        case
            when available_quantity is null then null
            when available_quantity < 0 then 0
            else available_quantity
        end as available_quantity,

        case
            when reorder_level is null then null
            when reorder_level < 0 then null
            else reorder_level
        end as reorder_level,

        case
            when reorder_quantity is null then null
            when reorder_quantity < 0 then null
            else reorder_quantity
        end as reorder_quantity,

            case

            when upper(trim(stock_status)) in (

                'IN STOCK',
                'LOW STOCK',
                'OUT OF STOCK'

            )

            then initcap(trim(stock_status))

            else 'Unknown'

        end as stock_status,

        case
            when stock_in_quantity is null then null
            when stock_in_quantity < 0 then 0
            else stock_in_quantity
        end as stock_in_quantity,


        -- ====================================================
        -- Stock Out Quantity
--        boss when creating table the datatype is not number then ;use this format commented ]
        -- ====================================================

        case

            when try_to_number(stock_out_quantity) is null
                then null

            when try_to_number(stock_out_quantity) < 0
                then 0

            else try_to_number(stock_out_quantity)

        end as stock_out_quantity,

--        case
--            when stock_out_quantity is null then null
--            when stock_out_quantity < 0 then 0
--            else stock_out_quantity
--        end as stock_out_quantity,


        case
            when try_to_date (last_restock_date) is null
                then null
            when try_to_date(last_restock_date) < current_date() then null
            else try_to_date(last_restock_date)

        end as last_restock_date,

    from inventory





),

deduplicated as (
    select * from cleaned_data
    qualify row_number()
    over(
        partition by inventory_id
        order by last_restock_date desc
    )=1
)

select * from deduplicated