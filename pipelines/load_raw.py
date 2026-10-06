import os
from pathlib import Path
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text, inspect

load_dotenv()
engine = create_engine(os.environ["DATABASE_URL"])

for f in sorted(Path("data/raw").glob("*.parquet")):
    df = pd.read_parquet(f)
    df["loaded_at"] = pd.Timestamp.now(tz="UTC")
    exists = inspect(engine).has_table(f.stem, schema="raw")
    with engine.begin() as conn:
        if exists:
            conn.execute(text(f"TRUNCATE TABLE raw.{f.stem}"))
        df.to_sql(f.stem, conn, schema="raw", if_exists="append",
                  index=False, chunksize=5000)
        n = conn.execute(text(f"SELECT COUNT(*) FROM raw.{f.stem}")).scalar()
    print(f"{f.stem}: {len(df)} in file, {n} in database")

with engine.connect() as conn:
    size = conn.execute(text("SELECT pg_size_pretty(pg_database_size(current_database()))")).scalar()
print("database size:", size)
