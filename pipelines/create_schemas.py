import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
engine = create_engine(os.environ["DATABASE_URL"])
with engine.begin() as conn:
    for s in ["raw", "staging", "analytics", "ops"]:
        conn.execute(text(f"CREATE SCHEMA IF NOT EXISTS {s}"))
    rows = conn.execute(text(
        "SELECT schema_name FROM information_schema.schemata "
        "WHERE schema_name IN ('raw','staging','analytics','ops') ORDER BY 1"))
    print([r[0] for r in rows])
