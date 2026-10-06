create schema if not exists analytics;

drop table if exists analytics.fact_order_items;
drop table if exists analytics.dim_date;
drop table if exists analytics.dim_user;
drop table if exists analytics.dim_product;
drop table if exists analytics.dim_distribution_center;

create table analytics.dim_date as
select
  cast(to_char(d, 'YYYYMMDD') as integer) as date_key,
  cast(d as date) as full_date,
  cast(extract(year from d) as integer) as year,
  cast(extract(quarter from d) as integer) as quarter,
  cast(extract(month from d) as integer) as month,
  to_char(d, 'Mon') as month_name,
  cast(extract(day from d) as integer) as day,
  cast(extract(isodow from d) as integer) as day_of_week,
  to_char(d, 'Dy') as day_name,
  (extract(isodow from d) >= 6) as is_weekend
from generate_series(
  (select cast(min(created_at) as date) from staging.stg_order_items),
  (select cast(max(created_at) as date) from staging.stg_order_items),
  interval '1 day'
) as d;

create table analytics.dim_user as
select user_id, age, gender, state, city, country, traffic_source,
       cast(created_at as date) as signup_date
from staging.stg_users;

create table analytics.dim_product as
select product_id, product_name, brand, category, department,
       cost, retail_price, distribution_center_id
from staging.stg_products;

create table analytics.dim_distribution_center as
select distribution_center_id, name, latitude, longitude
from staging.stg_distribution_centers;

create table analytics.fact_order_items as
select
  oi.order_item_id,
  oi.order_id,
  oi.user_id,
  oi.product_id,
  cast(to_char(oi.created_at, 'YYYYMMDD') as integer) as date_key,
  oi.status,
  oi.sale_price,
  p.cost,
  oi.sale_price - p.cost as margin,
  case when oi.shipped_at >= oi.created_at then cast(oi.shipped_at as date) - cast(oi.created_at as date) end as days_to_ship,
  case when oi.delivered_at >= oi.created_at then cast(oi.delivered_at as date) - cast(oi.created_at as date) end as days_to_deliver,
  (oi.shipped_at < oi.created_at) as ship_before_order,
  (oi.returned_at is not null) as is_returned
from staging.stg_order_items oi
left join staging.stg_products p on p.product_id = oi.product_id;

alter table analytics.dim_date add primary key (date_key);
alter table analytics.dim_user add primary key (user_id);
alter table analytics.dim_product add primary key (product_id);
alter table analytics.dim_distribution_center add primary key (distribution_center_id);
alter table analytics.fact_order_items add primary key (order_item_id);

create index idx_fact_user on analytics.fact_order_items (user_id);
create index idx_fact_product on analytics.fact_order_items (product_id);
create index idx_fact_date on analytics.fact_order_items (date_key);
create index idx_fact_order on analytics.fact_order_items (order_id);