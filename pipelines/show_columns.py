import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
e = create_engine(os.environ["DATABASE_URL"])
q = """SELECT table_name, string_agg(column_name || ' (' || data_type || ')', ', ' ORDER BY ordinal_position)
       FROM information_schema.columns
       WHERE table_schema = 'raw'
       GROUP BY table_name ORDER BY table_name"""
with e.connect() as conn:
    for name, cols in conn.execute(text(q)):
        print(f"\n{name}:\n  {cols}")
