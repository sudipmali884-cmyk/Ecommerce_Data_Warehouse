-- step 1 - create WAREHOUSE
create warehouse projects_wh
with 
warehouse_size='XSMALL'
AUTO_SUSPEND=60
AUTO_RESUME=TRUE;


-- step 2 - create database 

create database dcommerce_db;
use database dcommerce_db;
select  current_database(); -- DCOMMERCE_DB

-- step 3 - create schemas 

CREATE SCHEMA RAW;

CREATE SCHEMA STAGING;

CREATE SCHEMA ANALYTICS;

use schema raw; 
