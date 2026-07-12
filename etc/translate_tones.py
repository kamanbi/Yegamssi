from _secrets import require_env
import csv
import sys
import time
import os
import psycopg2
from deep_translator import GoogleTranslator

sys.stdout.reconfigure(encoding="utf-8")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
STYLES_DIR = os.path.join(BASE_DIR, "fortune_styles")

DB_URL = require_env("SUPABASE_DB_URL")

TONES = ["humor", "tsundere", "cynical", "emotional", "historical", "ai"]
TARGETS = ["en", "ja"]

BATCH_SIZE = 20
DELAY = 0.4


# ?�?� ?�틸 ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

def load_csv(path: str) -> list[dict]:
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def save_csv(path: str, rows: list[dict]) -> None:
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["code", "type", "text", "weight"])
        writer.writeheader()
        writer.writerows(rows)
    print(f"    ?�?? {os.path.basename(path)} ({len(rows)}??")


def translate_batch(texts: list[str], target: str) -> list[str]:
    SEP = "\n||||\n"
    joined = SEP.join(texts)
    translator = GoogleTranslator(source="ko", target=target)
    try:
        translated = translator.translate(joined)
        parts = translated.split("||||")
        if len(parts) != len(texts):
            # 분리 ?�패 ??개별 번역 ?�백
            parts = []
            for t in texts:
                try:
                    parts.append(translator.translate(t))
                    time.sleep(0.15)
                except Exception:
                    parts.append(t)
        return [p.strip() for p in parts]
    except Exception as e:
        print(f"      번역 ?�류: {e} ???�문 ?��?")
        return texts


def translate_all(ko_rows: list[dict], existing: dict, target: str) -> list[dict]:
    result = []
    pending_idx = []
    pending_texts = []

    for i, row in enumerate(ko_rows):
        key = (row["code"], row["type"])
        if key in existing:
            result.append({
                "code": row["code"], "type": row["type"],
                "text": existing[key], "weight": row["weight"],
            })
        else:
            result.append({
                "code": row["code"], "type": row["type"],
                "text": row["text"], "weight": row["weight"],
            })
            pending_idx.append(i)
            pending_texts.append(row["text"])

    total = len(pending_idx)
    done = 0
    for start in range(0, total, BATCH_SIZE):
        batch_idx = pending_idx[start:start + BATCH_SIZE]
        batch_texts = pending_texts[start:start + BATCH_SIZE]
        translated = translate_batch(batch_texts, target)
        for i, text in zip(batch_idx, translated):
            result[i]["text"] = text
        done += len(batch_idx)
        if done % 500 == 0 or done == total:
            print(f"      진행: {done}/{total}")
        time.sleep(DELAY)

    return result


# ?�?� Supabase ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

def ensure_table(cur, table: str) -> None:
    cur.execute(
        f'''CREATE TABLE IF NOT EXISTS "{table}" (
            id bigserial PRIMARY KEY,
            code text NOT NULL,
            type text NOT NULL,
            text text NOT NULL,
            weight integer NOT NULL DEFAULT 1
        )'''
    )
    cur.execute(f'CREATE INDEX IF NOT EXISTS "{table}_code_idx" ON "{table}" (code)')


def upload(rows: list[dict], table: str, conn) -> None:
    from psycopg2.extras import execute_values
    cur = conn.cursor()
    ensure_table(cur, table)
    # TRUNCATE ?�??DELETE ??timeout ??건너?� (?�규 ?�이블�? �??�태)
    try:
        cur.execute(f'TRUNCATE TABLE "{table}" RESTART IDENTITY')
        conn.commit()
    except Exception:
        conn.rollback()
    data = [(r["code"], r["type"], r["text"], int(r["weight"])) for r in rows]
    execute_values(
        cur,
        f'INSERT INTO "{table}" (code, type, text, weight) VALUES %s',
        data, page_size=500,
    )
    conn.commit()
    cur.close()
    print("Progress update")


# ?�?� 메인 ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�

def main() -> None:
    print("=== ??번역 ?�작 ===")
    print(f"?�???? {TONES}")
    print(f"?�어: {TARGETS}\n")

    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False

    for tone in TONES:
        src_path = os.path.join(STYLES_DIR, f"fortune_ko_{tone}.csv")
        if not os.path.exists(src_path):
            print(f"[{tone}] ?�스 ?�음 ??건너?�")
            continue

        print(f"\n[{tone}]")
        ko_rows = load_csv(src_path)
        print("Progress update")

        for target in TARGETS:
            out_path = os.path.join(STYLES_DIR, f"fortune_{target}_{tone}.csv")
            table_name = f"fortune_{target}_{tone}"

            # ?��? ?�료??CSV ?�으�??�번???�이 ?�로?�만
            if os.path.exists(out_path):
                existing_rows = load_csv(out_path)
                print(f"  [{target}] 기존 CSV ?�사??({len(existing_rows)}?? ???�로?�만")
                upload(existing_rows, table_name, conn)
                continue

            print(f"  [{target}] 번역 �?..")
            translated = translate_all(ko_rows, {}, target)
            save_csv(out_path, translated)
            upload(translated, table_name, conn)

    conn.close()
    print("\n=== ?�체 ?�료 ===")


if __name__ == "__main__":
    main()
