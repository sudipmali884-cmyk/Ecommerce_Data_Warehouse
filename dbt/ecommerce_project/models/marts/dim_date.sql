-- ============================================================
-- DIM_DATE
-- ============================================================

WITH date_spine AS (

    SELECT

        DATEADD(
            DAY,
            SEQ4(),
            '2020-01-01'::DATE
        ) AS date_day

    FROM TABLE(
        GENERATOR(
            ROWCOUNT => 3653
        )
    )

)

SELECT

    -- ========================================================
    -- DATE KEY
    -- ========================================================

    TO_NUMBER(
        TO_CHAR(
            date_day,
            'YYYYMMDD'
        )
    ) AS date_key,

    -- ========================================================
    -- DATE
    -- ========================================================

    date_day AS full_date,

    -- ========================================================
    -- YEAR
    -- ========================================================

    YEAR(date_day) AS year,

    -- ========================================================
    -- QUARTER
    -- ========================================================

    QUARTER(date_day) AS quarter,

    'Q'
    || QUARTER(date_day) AS quarter_name,

    -- ========================================================
    -- MONTH
    -- ========================================================

    MONTH(date_day) AS month_number,

    TO_CHAR(
        date_day,
        'MMMM'
    ) AS month_name,

    TO_CHAR(
        date_day,
        'MON'
    ) AS month_short_name,

    -- ========================================================
    -- YEAR MONTH
    -- ========================================================

    TO_CHAR(
        date_day,
        'YYYY-MM'
    ) AS year_month,

    -- ========================================================
    -- WEEK
    -- ========================================================

    WEEKOFYEAR(date_day) AS week_number,

    -- ========================================================
    -- DAY
    -- ========================================================

    DAY(date_day) AS day_of_month,

    DAYOFWEEK(date_day) AS day_of_week,

    TO_CHAR(
        date_day,
        'DAY'
    ) AS day_name,

    TO_CHAR(
        date_day,
        'DY'
    ) AS day_short_name,

    -- ========================================================
    -- WEEKEND FLAG
    -- ========================================================

    CASE

        WHEN DAYOFWEEK(date_day) IN (1, 7)

        THEN TRUE

        ELSE FALSE

    END AS is_weekend,

    -- ========================================================
    -- MONTH END FLAG
    -- ========================================================

    CASE

        WHEN date_day = LAST_DAY(date_day)

        THEN TRUE

        ELSE FALSE

    END AS is_month_end,

    -- ========================================================
    -- QUARTER END FLAG
    -- ========================================================

    CASE

        WHEN date_day = LAST_DAY(
            date_day,
            'QUARTER'
        )

        THEN TRUE

        ELSE FALSE

    END AS is_quarter_end,

    -- ========================================================
    -- YEAR END FLAG
    -- ========================================================

    CASE

        WHEN date_day = LAST_DAY(
            date_day,
            'YEAR'
        )

        THEN TRUE

        ELSE FALSE

    END AS is_year_end

FROM date_spine