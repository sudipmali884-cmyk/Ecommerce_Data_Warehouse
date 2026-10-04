{{ config (materialized='view')}}
select
customer_id,
TRIM(first_name) as first_name,
TRIM(last_name) as last_name,
--  COALESCE(email, 'unknown@example.com') AS email,-- replacing the null to value
--
coalesce (email,'unknow@example.com') as email,
gender, date_of_birth, phone, city, state, country, customer_segment,
registration_date, is_active
from {{ source('raw','customers')}}
where customer_id is not null

-- 1 create one sources.yml file in staging
-- 2  type there
-- 3. dbt debug in termninal
--4. this will give some error because postgres profile.yml are present remove it from c:users?SUDIP.dbt/profile.yml
-- 5. dbt debug then
-- 6. dbt run --select stg_customers
-- 7 . then go to snowflake and select * from stf_customers limit 10;
-- 8. test the model in stg_customers.yml
