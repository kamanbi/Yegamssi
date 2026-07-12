from _secrets import require_env
import csv, sys, os, time
import psycopg2
from psycopg2.extras import execute_values

sys.stdout.reconfigure(encoding="utf-8")

BASE_DIR  = os.path.dirname(os.path.abspath(__file__))
STYLES    = os.path.join(BASE_DIR, "fortune_styles")
DB = require_env("SUPABASE_DB_URL")

TASKS = [
    (os.path.join(BASE_DIR, "fortune_en.csv"),  "fortune_en"),
    (os.path.join(BASE_DIR, "fortune_ja.csv"),  "fortune_ja"),
    *[(os.path.join(STYLES, f"fortune_{lang}_{tone}.csv"), f"fortune_{lang}_{tone}")
      for lang in ("en", "ja")
      for tone in ("humor","tsundere","cynical","emotional","historical","ai")],
]

def load_csv(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def upload(path, table):
    if not os.path.exists(path):
        print(f"  [{table}] CSV ?�음 ??건너?�")
        return
    rows = load_csv(path)
    # ?�이블마?????�결 (statement_timeout=120s)
    conn = psycopg2.connect(DB, connect_timeout=30,
                            options="-c statement_timeout=120000")
    try:
        cur = conn.cursor()
        cur.execute(f'TRUNCATE TABLE "{table}" RESTART IDENTITY')
        data = [(r["code"], r["type"], r["text"], int(r["weight"])) for r in rows]
        execute_values(
            cur,
            f'INSERT INTO "{table}" (code,type,text,weight) VALUES %s',
            data, page_size=500
        )
        conn.commit()
        cur.close()
        print("Progress update")
    except Exception as e:
        conn.rollback()
        print(f"  [{table}] ?�패: {e}")
    finally:
        conn.close()

def main():
    print("=== psycopg2 ?�로???�작 ===")
    existing = [(p,t) for p,t in TASKS if os.path.exists(p)]
    missing  = [t for p,t in TASKS if not os.path.exists(p)]
    print(f"?�로?? {len(existing)}�?/ 미완 CSV: {missing}\n")

    for path, table in existing:
        upload(path, table)
        time.sleep(0.3)
    print("\n=== ?�료 ===")

if __name__ == "__main__":
    main()
