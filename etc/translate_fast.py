from _secrets import require_env
import csv, sys, os, time
import psycopg2
from psycopg2.extras import execute_values
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

sys.stdout.reconfigure(encoding="utf-8")

STYLES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fortune_styles")
DB = require_env("SUPABASE_DB_URL")

# ??좎럥利??????좎럩???좎럡????좎룞?? 野껉퍓彛?
REMAINING = [
    ("ja", "tsundere"),
    ("en", "cynical"), ("ja", "cynical"),
    ("en", "emotional"), ("ja", "emotional"),
    ("en", "historical"), ("ja", "historical"),
    ("en", "ai"), ("ja", "ai"),
]

BATCH = 100
DELAY = 0.25


def load_csv(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def save_csv(path, rows):
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["code","type","text","weight"])
        w.writeheader(); w.writerows(rows)

def translate_texts(texts, target):
    SEP = "\n@@@\n"
    joined = SEP.join(texts)
    try:
        out = GoogleTranslator(source="ko", target=target).translate(joined)
        parts = out.split("@@@")
        parts = [p.strip() for p in parts]
        if len(parts) == len(texts):
            return parts
    except Exception:
        pass
    # ??좎럥媛? 揶쏆뮆??甕곕뜆肉?
    results = []
    t = GoogleTranslator(source="ko", target=target)
    for text in texts:
        try:
            results.append(t.translate(text))
            time.sleep(0.05)
        except Exception:
            results.append(text)
    return results

def translate_lang(ko_rows, target, out_csv):
    """Translate one language and write a CSV file."""
    if os.path.exists(out_csv):
        print("Progress update")
        return load_csv(out_csv)

    texts = [r["text"] for r in ko_rows]
    translated_texts = []
    total = len(texts)
    for i in range(0, total, BATCH):
        batch = texts[i:i+BATCH]
        translated_texts.extend(translate_texts(batch, target))
        if (i // BATCH) % 5 == 0:
            pct = min(i+BATCH, total)
            print(f"  [{target}] {pct}/{total}")
        time.sleep(DELAY)

    rows = [{"code": r["code"], "type": r["type"],
             "text": t, "weight": r["weight"]}
            for r, t in zip(ko_rows, translated_texts)]
    save_csv(out_csv, rows)
    print(f"  [{target}] CSV ??????좎럥利?({len(rows)}??")
    return rows

def upload(rows, table):
    conn = psycopg2.connect(DB, connect_timeout=30,
                            options="-c statement_timeout=30000")
    cur = conn.cursor()
    sql = f'INSERT INTO "{table}" (code,type,text,weight) VALUES (%s,%s,%s,%s)'
    CHUNK = 100
    for i in range(0, len(rows), CHUNK):
        batch = rows[i:i+CHUNK]
        cur.executemany(sql, [(r["code"],r["type"],r["text"],int(r["weight"])) for r in batch])
        conn.commit()
        time.sleep(0.05)
    cur.close(); conn.close()
    print("Progress update")

def process_tone(tone):
    src = os.path.join(STYLES, f"fortune_ko_{tone}.csv")
    ko_rows = load_csv(src)
    print(f"\n[{tone}] ??좎럩??({len(ko_rows)}??")

    langs_to_do = [lang for lang, t in REMAINING if t == tone]

    with ThreadPoolExecutor(max_workers=2) as ex:
        futures = {}
        for lang in langs_to_do:
            out = os.path.join(STYLES, f"fortune_{lang}_{tone}.csv")
            futures[ex.submit(translate_lang, ko_rows, lang, out)] = lang

        results = {}
        for f in as_completed(futures):
            lang = futures[f]
            results[lang] = f.result()

    for lang, rows in results.items():
        upload(rows, f"fortune_{lang}_{tone}")

def main():
    # ??좎룞?? ?⑥쥙? ???곕뗄??(??좎럩苑???좎룞??)
    seen, tones_order = set(), []
    for _, tone in REMAINING:
        if tone not in seen:
            seen.add(tone); tones_order.append(tone)

    print(f"=== ??쥓??甕곕뜆肉???좎럩??===")
    print(f"?????? {tones_order}")
    print(f"獄쏄퀣????좎럡由? {BATCH}, 筌왖?? {DELAY}s\n")

    for tone in tones_order:
        process_tone(tone)

    print("\n=== ??좎럩猿???좎럥利?===")

if __name__ == "__main__":
    main()
