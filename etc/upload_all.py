from _secrets import require_env
import csv, sys, os, time
import psycopg2

sys.stdout.reconfigure(encoding="utf-8")

BASE   = os.path.dirname(os.path.abspath(__file__))
STYLES = os.path.join(BASE, "fortune_styles")
DB = require_env("SUPABASE_DB_URL")

TASKS = [
    # fortune_ja_tsundere ?�료 ??    (os.path.join(STYLES, "fortune_en_cynical.csv"),   "fortune_en_cynical"),
    (os.path.join(STYLES, "fortune_ja_cynical.csv"),   "fortune_ja_cynical"),
    (os.path.join(STYLES, "fortune_en_emotional.csv"), "fortune_en_emotional"),
    (os.path.join(STYLES, "fortune_ja_emotional.csv"), "fortune_ja_emotional"),
    (os.path.join(STYLES, "fortune_en_historical.csv"),"fortune_en_historical"),
    (os.path.join(STYLES, "fortune_ja_historical.csv"),"fortune_ja_historical"),
    (os.path.join(STYLES, "fortune_en_ai.csv"),        "fortune_en_ai"),
    (os.path.join(STYLES, "fortune_ja_ai.csv"),        "fortune_ja_ai"),
]

# en_tsundere 중복(17928?? ?�리???�함
CLEANUP = [("fortune_en_tsundere", os.path.join(STYLES, "fortune_en_tsundere.csv"))]

def load(p):
    with open(p, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def upload_table(rows, table):
    conn = psycopg2.connect(DB, connect_timeout=30)
    conn.autocommit = False
    cur = conn.cursor()
    sql = f'INSERT INTO "{table}" (code,type,text,weight) VALUES (%s,%s,%s,%s)'
    CHUNK = 200
    for i in range(0, len(rows), CHUNK):
        cur.execute("SET LOCAL statement_timeout = '0'")
        batch = rows[i:i+CHUNK]
        cur.executemany(sql, [(r["code"],r["type"],r["text"],int(r["weight"])) for r in batch])
        conn.commit()
        time.sleep(0.1)
    cur.close(); conn.close()
    print("Progress update")

def cleanup_table(table, path):
    """Operational helper."""
    rows = load(path)
    conn = psycopg2.connect(DB, connect_timeout=30)
    conn.autocommit = False
    cur = conn.cursor()
    cur.execute("SET LOCAL statement_timeout = '0'")
    cur.execute(f'DELETE FROM "{table}"')
    conn.commit()
    sql = f'INSERT INTO "{table}" (code,type,text,weight) VALUES (%s,%s,%s,%s)'
    CHUNK = 200
    for i in range(0, len(rows), CHUNK):
        cur.execute("SET LOCAL statement_timeout = '0'")
        cur.executemany(sql, [(r["code"],r["type"],r["text"],int(r["weight"])) for r in rows[i:i+CHUNK]])
        conn.commit()
        time.sleep(0.1)
    cur.close(); conn.close()
    print("Progress update")

def main():
    # 1. 중복 ?�리
    print("=== 중복 ?�리 ===")
    for table, path in CLEANUP:
        cleanup_table(table, path)

    # 2. 미완 ?�이�??�로??    print("\n=== ?�로??===")
    missing = [(p,t) for p,t in TASKS if not os.path.exists(p)]
    if missing:
        print(f"CSV ?�음 (번역 ?��?: {[t for _,t in missing]}")

    for path, table in TASKS:
        if not os.path.exists(path):
            print(f"  {table}: CSV ?�음 ??건너?�")
            continue
        upload_table(load(path), table)

    print("\n=== ?�료 ===")

if __name__ == "__main__":
    main()
