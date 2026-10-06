create schema if not exists ops;

create table if not exists ops.dq_results (
  run_at timestamptz not null,
  check_name text not null,
  table_name text not null,
  failed_rows bigint not null,
  status text generated always as (case when failed_rows = 0 then 'PASS' else 'FAIL' end) stored
);

insert into ops.dq_results (run_at, check_name, table_name, failed_rows)
select now(), check_name, table_name, failed_rows from (

  select 'duplicate_pk' as check_name, 'fact_order_items' as table_name,
    (select count(*) - count(distinct order_item_id) from analytics.fact_order_items) as failed_rows
  union all
  select 'null_keys', 'fact_order_items',
    (select count(*) from analytics.fact_order_items
     where user_id is null or product_id is null or date_key is null or order_id is null)
  union all
  select 'orphan_user', 'fact_order_items',
    (select count(*) from analytics.fact_order_items f
     left join analytics.dim_user d on d.user_id = f.user_id where  d.user_id is null)
  union all
  select 'orphan_product', 'fact_order_items',
    (select count(*) from analytics.fact_order_items f
     left join analytics.dim_product d on d.product_id = f.product_id where d.product_id is null)
  union all
  select 'orphan_date', 'fact_order_items',
    (select count(*) from analytics.fact_order_items f
     left join analytics.dim_date d on d.date_key = f.date_key where d.date_key is null)
  union all
  select 'non_positive_sale_price', 'fact_order_items',
    (select count(*) from analytics.fact_order_items where sale_price is null or sale_price <= 0)
  union all
  select 'negative_days_to_ship', 'fact_order_items',
    (select count(*) from analytics.fact_order_items where days_to_ship < 0)
  union all
  select 'deliver_before_ship', 'fact_order_items',
    (select count(*) from analytics.fact_order_items where days_to_deliver < days_to_ship)
  union all
  select 'duplicate_pk', 'dim_user',
    (select count(*) - count(distinct user_id) from analytics.dim_user)
  union all
  select 'age_out_of_range', 'dim_user',
    (select count(*) from analytics.dim_user where age is null or age < 0 or age > 120)
  union all
  select 'null_cost_or_price', 'dim_product',
    (select count(*) from analytics.dim_product where cost is null or retail_price is null)
  union all
  select 'price_below_cost', 'dim_product',
    (select count(*) from analytics.dim_product where retail_price < cost)

) checks;