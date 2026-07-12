from _secrets import require_env
import csv, sys, os, time
import psycopg2
from psycopg2.extras import execute_values

sys.stdout.reconfigure(encoding="utf-8")

STYLES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fortune_styles")
DB = require_env("SUPABASE_DB_URL")

TONES = ["tsundere", "cynical", "emotional", "historical", "ai"]
LANGS = ["en", "ja"]

def load(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def upload(path, table):
    rows = load(path)
    conn = psycopg2.connect(DB, connect_timeout=30, options="-c statement_timeout=120000")
    cur = conn.cursor()
    data = [(r["code"], r["type"], r["text"], int(r["weight"])) for r in rows]
    execute_values(cur, f'INSERT INTO "{table}" (code,type,text,weight) VALUES %s',
                   data, page_size=500)
    conn.commit()
    cur.close(); conn.close()
    print("Progress update")

def main():
    done = set()
    print("=== 감시 ?�작 (60초마??체크) ===")
    while True:
        for tone in TONES:
            for lang in LANGS:
                key = f"{lang}_{tone}"
                if key in done:
                    continue
                path = os.path.join(STYLES, f"fortune_{lang}_{tone}.csv")
                if os.path.exists(path):
                    print("Progress update")
                    try:
                        upload(path, f"fortune_{lang}_{tone}")
                        done.add(key)
                    except Exception as e:
                        print(f"  ?�류: {e}")

        remaining = [(f"{l}_{t}") for t in TONES for l in LANGS
                     if f"{l}_{t}" not in done]
        if not remaining:
            print("\n=== 모든 ???�로???�료 ===")
            break
        print(f"?��?�? {remaining}")
        time.sleep(60)

if __name__ == "__main__":
    main()
