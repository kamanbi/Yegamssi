from _secrets import require_env
import csv
import sys
import time
import os
import psycopg2
from deep_translator import GoogleTranslator

sys.stdout.reconfigure(encoding="utf-8")

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
KO_CSV = os.path.join(BASE_DIR, "ko.csv")
EN_CSV = os.path.join(BASE_DIR, "en.csv")
OUT_EN = os.path.join(BASE_DIR, "fortune_en.csv")
OUT_JA = os.path.join(BASE_DIR, "fortune_ja.csv")

DB_URL = require_env("SUPABASE_DB_URL")
BATCH_SIZE = 20   # ??번에 번역??????DELAY = 0.4       # 배치 �??�레??(�?


def load_csv(path: str) -> list[dict]:
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def save_csv(path: str, rows: list[dict]) -> None:
    if not rows:
        return
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=["code", "type", "text", "weight"])
        writer.writeheader()
        writer.writerows(rows)
    print(f"  ?�?? {path} ({len(rows)}??")


def translate_batch(texts: list[str], target: str) -> list[str]:
    """?�러 ?�스?��? 구분?�로 ?�쳐 ??번에 번역 ???�분�?"""
    SEP = "\n||||\n"
    joined = SEP.join(texts)
    translator = GoogleTranslator(source="ko", target=target)
    try:
        translated = translator.translate(joined)
        parts = translated.split("||||")
        # 분리 ?��? ?�르�?개별 번역?�로 ?�백
        if len(parts) != len(texts):
            parts = []
            for t in texts:
                try:
                    parts.append(translator.translate(t))
                    time.sleep(0.1)
                except Exception:
                    parts.append(t)
        return [p.strip() for p in parts]
    except Exception as e:
        print(f"    번역 ?�류: {e} ???�문 ?��?")
        return texts


def translate_rows(
    ko_rows: list[dict],
    existing_map: dict[str, str],  # (code, type) ??text
    target: str,
) -> list[dict]:
    """ko_rows�?target ?�어�?번역. existing_map???�으�??�사??"""
    result: list[dict] = []
    pending_idx: list[int] = []
    pending_texts: list[str] = []

    for i, row in enumerate(ko_rows):
        key = (row["code"], row["type"])
        if key in existing_map:
            result.append({"code": row["code"], "type": row["type"],
                           "text": existing_map[key], "weight": row["weight"]})
        else:
            result.append({"code": row["code"], "type": row["type"],
                           "text": row["text"], "weight": row["weight"]})  # placeholder
            pending_idx.append(i)
            pending_texts.append(row["text"])

    total = len(pending_idx)
    print(f"  번역 ?�요: {total}??/ ?�체 {len(ko_rows)}??({target})")

    done = 0
    for start in range(0, total, BATCH_SIZE):
        batch_idx = pending_idx[start:start + BATCH_SIZE]
        batch_texts = pending_texts[start:start + BATCH_SIZE]
        translated = translate_batch(batch_texts, target)
        for i, text in zip(batch_idx, translated):
            result[i]["text"] = text
        done += len(batch_idx)
        if done % 200 == 0 or done == total:
            print(f"    진행: {done}/{total}")
        time.sleep(DELAY)

    return result


def upload_to_supabase(rows: list[dict], table_name: str) -> None:
    """Supabase PostgreSQL???�이�??�체 교체 ???�입."""
    print(f"\nSupabase ?�로?? {table_name} ({len(rows)}??")
    conn = psycopg2.connect(DB_URL)
    conn.autocommit = False
    cur = conn.cursor()
    try:
        cur.execute(f'TRUNCATE TABLE "{table_name}"')
        insert_sql = f'INSERT INTO "{table_name}" (code, type, text, weight) VALUES (%s, %s, %s, %s)'
        chunk_size = 500
        for i in range(0, len(rows), chunk_size):
            chunk = rows[i:i + chunk_size]
            cur.executemany(insert_sql, [(r["code"], r["type"], r["text"], int(r["weight"])) for r in chunk])
            print(f"  ?�입: {min(i + chunk_size, len(rows))}/{len(rows)}")
        conn.commit()
        print(f"  ?�료: {table_name}")
    except Exception as e:
        conn.rollback()
        print(f"  ?�로???�패: {e}")
        raise
    finally:
        cur.close()
        conn.close()


def main() -> None:
    print("=== ?�세 번역 ?�작 ===")

    ko_rows = load_csv(KO_CSV)
    print("Progress update")

    # 기존 en.csv ??(code, type) �?    existing_en: dict[str, str] = {}
    if os.path.exists(EN_CSV):
        for row in load_csv(EN_CSV):
            existing_en[(row["code"], row["type"])] = row["text"]
        print(f"기존 en.csv ?�사?? {len(existing_en)}??��")

    # ?�?� ?�어 번역 ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
    print("\n[1/2] ?�어 번역")
    en_rows = translate_rows(ko_rows, existing_en, "en")
    save_csv(OUT_EN, en_rows)

    # ?�?� ?�본??번역 ?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
    print("\n[2/2] ?�본??번역")
    ja_rows = translate_rows(ko_rows, {}, "ja")
    save_csv(OUT_JA, ja_rows)

    # ?�?� Supabase ?�로???�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�?�
    print("\n=== Supabase ?�로??===")
    upload_to_supabase(en_rows, "fortune_en")
    upload_to_supabase(ja_rows, "fortune_ja")

    print("\n=== ?�료 ===")
    print("Progress update")
    print("Progress update")


if __name__ == "__main__":
    main()
