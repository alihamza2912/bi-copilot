import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()
e = create_engine(os.environ["DATABASE_URL"])
q = """SELECT relname, pg_size_pretty(pg_total_relation_size(c.oid))
       FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
       WHERE n.nspname = 'raw' AND c.relkind = 'r'
       ORDER BY pg_total_relation_size(c.oid) DESC"""
with e.connect() as conn:
    for r in conn.execute(text(q)):
        print(r[0], r[1])
