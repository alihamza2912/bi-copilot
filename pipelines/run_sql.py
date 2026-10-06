import os, sys
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
engine = create_engine(os.environ["DATABASE_URL"])
sql = open(sys.argv[1]).read()
with engine.begin() as conn:
    for stmt in [s.strip() for s in sql.split(";") if s.strip()]:
        conn.execute(text(stmt))
    print("ran", sys.argv[1])
    for v in ["stg_users", "stg_products", "stg_orders", "stg_order_items",
              "stg_events", "stg_distribution_centers"]:
        n = conn.execute(text(f"SELECT COUNT(*) FROM staging.{v}")).scalar()
        print(v, n)
