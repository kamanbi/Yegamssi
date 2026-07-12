from _secrets import require_env
import csv
import json
import sys
import time
import os
import urllib.request
import urllib.error

sys.stdout.reconfigure(encoding="utf-8")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STYLES_DIR = os.path.join(BASE_DIR, "fortune_styles")

SUPABASE_URL = require_env("SUPABASE_URL")
SERVICE_KEY = require_env("SUPABASE_SERVICE_ROLE_KEY")
HEADERS = {
    "apikey": SERVICE_KEY,
    "Authorization": f"Bearer {SERVICE_KEY}",
    "Content-Type": "application/json",
    "Prefer": "resolution=merge-duplicates",
}
CHUNK = 400  # REST API 1???�입 ?�수


def load_csv(path: str) -> list[dict]:
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def delete_all(table: str) -> None:
    """?�이�??�체 ??�� (id >= 0 조건)"""
    url = f"{SUPABASE_URL}/rest/v1/{table}?id=gte.0"
    req = urllib.request.Request(url, method="DELETE", headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=30):
            pass
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"  DELETE ?�류 {e.code}: {body[:200]}")


def insert_chunk(table: str, rows: list[dict]) -> bool:
    url = f"{SUPABASE_URL}/rest/v1/{table}"
    payload = json.dumps([
        {"code": r["code"], "type": r["type"], "text": r["text"], "weight": int(r["weight"])}
        for r in rows
    ]).encode("utf-8")
    req = urllib.request.Request(url, data=payload, method="POST", headers=HEADERS)
    try:
        with urllib.request.urlopen(req, timeout=30):
            return True
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"  INSERT ?�류 {e.code}: {body[:300]}")
        return False


def upload(csv_path: str, table: str) -> None:
    if not os.path.exists(csv_path):
        print(f"  [{table}] CSV ?�음 ??건너?�: {csv_path}")
        return

    rows = load_csv(csv_path)
    print(f"  [{table}] {len(rows)}???�로??�?..")

    delete_all(table)
    time.sleep(0.5)

    ok = 0
    for i in range(0, len(rows), CHUNK):
        chunk = rows[i:i + CHUNK]
        if insert_chunk(table, chunk):
            ok += len(chunk)
        else:
            print(f"    �?�� {i}~{i+len(chunk)} ?�패")
        time.sleep(0.3)

    print("Progress update")


def main() -> None:
    tasks = [
        # 기본
        (os.path.join(BASE_DIR, "fortune_en.csv"), "fortune_en"),
        (os.path.join(BASE_DIR, "fortune_ja.csv"), "fortune_ja"),
        *[
            (os.path.join(STYLES_DIR, f"fortune_{lang}_{tone}.csv"), f"fortune_{lang}_{tone}")
            for lang in ["en", "ja"]
            for tone in ["humor", "tsundere", "cynical", "emotional", "historical", "ai"]
        ],
    ]

    # ?��? CSV ?�는 것만 ?�터
    existing = [(p, t) for p, t in tasks if os.path.exists(p)]
    missing  = [(p, t) for p, t in tasks if not os.path.exists(p)]

    print(f"=== Supabase ?�로??({len(existing)}�??�이�? ===\n")
    if missing:
        print(f"CSV ?�음 (번역 ?�요): {[t for _,t in missing]}\n")

    for csv_path, table in existing:
        upload(csv_path, table)

    print("\n=== ?�로???�료 ===")


if __name__ == "__main__":
    main()
