CREATE OR REPLACE VIEW staging.stg_users AS
SELECT DISTINCT ON (id)
       id AS user_id, age, gender, TRIM(state) AS state, TRIM(city) AS city,
       TRIM(country) AS country, traffic_source, created_at
FROM raw.users ORDER BY id;

CREATE OR REPLACE VIEW staging.stg_products AS
SELECT DISTINCT ON (id)
       id AS product_id, TRIM(name) AS product_name, TRIM(brand) AS brand,
       TRIM(category) AS category, TRIM(department) AS department,
       cost, retail_price, distribution_center_id
FROM raw.products ORDER BY id;

CREATE OR REPLACE VIEW staging.stg_orders AS
SELECT DISTINCT ON (order_id)
       order_id, user_id, status, created_at, shipped_at, delivered_at,
       returned_at, num_of_item
FROM raw.orders ORDER BY order_id;

CREATE OR REPLACE VIEW staging.stg_order_items AS
SELECT DISTINCT ON (id)
       id AS order_item_id, order_id, user_id, product_id, status,
       created_at, shipped_at, delivered_at, returned_at, sale_price
FROM raw.order_items ORDER BY id;

CREATE OR REPLACE VIEW staging.stg_events AS
SELECT DISTINCT ON (id)
       id AS event_id, user_id, session_id, created_at, traffic_source,
       event_type, uri, browser, state, city
FROM raw.events ORDER BY id;

CREATE OR REPLACE VIEW staging.stg_distribution_centers AS
SELECT id AS distribution_center_id, TRIM(name) AS name, latitude, longitude
FROM raw.distribution_centers;
