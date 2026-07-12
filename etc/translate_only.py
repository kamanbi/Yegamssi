"""번역만 수행 — DB 연결 없음. 완료 후 upload_all.py를 별도 실행."""
import csv, sys, os, time
from concurrent.futures import ThreadPoolExecutor, as_completed
from deep_translator import GoogleTranslator

sys.stdout.reconfigure(encoding="utf-8")

STYLES = os.path.join(os.path.dirname(os.path.abspath(__file__)), "fortune_styles")
REMAINING = [
    ("ja", "tsundere"),
    ("en", "cynical"), ("ja", "cynical"),
    ("en", "emotional"), ("ja", "emotional"),
    ("en", "historical"), ("ja", "historical"),
    ("en", "ai"), ("ja", "ai"),
]
BATCH = 100
DELAY = 0.2

def load_csv(path):
    with open(path, encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))

def save_csv(path, rows):
    with open(path, "w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["code","type","text","weight"])
        w.writeheader(); w.writerows(rows)

def translate_texts(texts, target):
    SEP = "\n@@@\n"
    try:
        out = GoogleTranslator(source="ko", target=target).translate(SEP.join(texts))
        parts = [p.strip() for p in out.split("@@@")]
        if len(parts) == len(texts):
            return parts
    except Exception:
        pass
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
    if os.path.exists(out_csv):
        print(f"  [{target}] 기존 파일 재사용")
        return
    texts = [r["text"] for r in ko_rows]
    translated = []
    for i in range(0, len(texts), BATCH):
        translated.extend(translate_texts(texts[i:i+BATCH], target))
        if i % 500 == 0:
            print(f"  [{target}] {min(i+BATCH,len(texts))}/{len(texts)}")
        time.sleep(DELAY)
    rows = [{"code":r["code"],"type":r["type"],"text":t,"weight":r["weight"]}
            for r,t in zip(ko_rows, translated)]
    save_csv(out_csv, rows)
    print(f"  [{target}] 저장 완료 ({len(rows)}행)")

def main():
    seen, order = set(), []
    for _, tone in REMAINING:
        if tone not in seen: seen.add(tone); order.append(tone)

    print(f"=== 번역 전용 시작: {order} ===\n")
    for tone in order:
        src = os.path.join(STYLES, f"fortune_ko_{tone}.csv")
        ko_rows = load_csv(src)
        langs = [lang for lang, t in REMAINING if t == tone]
        print(f"[{tone}] {langs} 병렬 번역")
        with ThreadPoolExecutor(max_workers=2) as ex:
            futs = {ex.submit(translate_lang, ko_rows, lang,
                    os.path.join(STYLES, f"fortune_{lang}_{tone}.csv")): lang
                    for lang in langs}
            for f in as_completed(futs):
                f.result()
        print(f"[{tone}] 완료\n")

    print("=== 모든 번역 완료 → upload_all.py 실행하세요 ===")

if __name__ == "__main__":
    main()
