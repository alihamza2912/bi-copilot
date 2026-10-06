from pathlib import Path
from google.cloud import bigquery

PROJECT = "arcane-trilogy-460317-r1"
DATASET = "bigquery-public-data.thelook_ecommerce"
TABLES = ["distribution_centers", "users", "products", "inventory_items",
          "orders", "order_items", "events"]

client = bigquery.Client(project=PROJECT)
out = Path("data/raw")
out.mkdir(parents=True, exist_ok=True)

for t in TABLES:
    sql = f"SELECT * FROM `{DATASET}.{t}`"
    if t == "events":
        sql += " ORDER BY created_at DESC LIMIT 200000"
    df = client.query(sql).to_dataframe()
    df.to_parquet(out / f"{t}.parquet", index=False)
    print(f"{t}: {len(df)} rows")
