import os
from pathlib import Path
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
engine = create_engine(os.environ["DATABASE_URL"])

for f in sorted(Path("data/raw").glob("*.parquet")):
    df = pd.read_parquet(f)
    df["loaded_at"] = pd.Timestamp.now(tz="UTC")
    df.to_sql(f.stem, engine, schema="raw", if_exists="replace",
              index=False, chunksize=5000)
    with engine.connect() as conn:
        n = conn.execute(text(f"SELECT COUNT(*) FROM raw.{f.stem}")).scalar()
    print(f"{f.stem}: {len(df)} in file, {n} in database")

with engine.connect() as conn:
    size = conn.execute(text("SELECT pg_size_pretty(pg_database_size(current_database()))")).scalar()
print("database size:", size)
