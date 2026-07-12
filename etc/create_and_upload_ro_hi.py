from _secrets import require_env
import psycopg2, csv, sys
sys.stdout.reconfigure(encoding='utf-8')

DB = require_env("SUPABASE_DB_URL")
TABLES = {
    'fortune_ro': 'etc/fortune_ro.csv',
    'fortune_hi': 'etc/fortune_hi.csv',
}

DDL = """
DROP TABLE IF EXISTS "{t}";
CREATE TABLE "{t}" (
    id bigint generated always as identity primary key,
    code text NOT NULL,
    type text NOT NULL,
    text text NOT NULL,
    weight smallint NOT NULL DEFAULT 1
);
CREATE INDEX idx_{t} ON "{t}" USING btree (code, type);
ALTER TABLE "{t}" ENABLE ROW LEVEL SECURITY;
CREATE POLICY anon_read ON "{t}" FOR SELECT TO anon USING (true);
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON "{t}" TO anon, authenticated, service_role, postgres;
"""

conn = psycopg2.connect(DB, connect_timeout=20)
conn.autocommit = False
cur = conn.cursor()

for table, path in TABLES.items():
    print(f'--- {table} ---')
    cur.execute("SET statement_timeout = 0")
    cur.execute(DDL.format(t=table))
    conn.commit()
    print(f'{table} created')

    cur.execute("SET statement_timeout = 0")
    with open(path, encoding='utf-8') as f:
        r = csv.reader(f)
        rows = list(r)[1:]  # skip header
    args = [(row[0], row[1], row[2], int(row[3])) for row in rows]
    psycopg2.extras = __import__('psycopg2.extras', fromlist=['extras'])
    from psycopg2.extras import execute_values
    execute_values(
        cur,
        f'INSERT INTO "{table}" (code, type, text, weight) VALUES %s',
        args,
        page_size=1000,
    )
    conn.commit()
    cur.execute(f'SELECT count(*) FROM "{table}"')
    print(f'{table} inserted rows:', cur.fetchone()[0])

cur.execute("NOTIFY pgrst, 'reload schema'")
conn.commit()
print('schema reload notified')

cur.close()
conn.close()
print('done')
