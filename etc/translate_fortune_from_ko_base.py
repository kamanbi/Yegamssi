import csv
import json
import time
from dataclasses import dataclass
from pathlib import Path

from deep_translator import GoogleTranslator


BASE_DIR = Path(__file__).resolve().parent
SOURCE_CSV = BASE_DIR / "fortune_styles" / "fortune_ko_base.csv"
CACHE_PATH = BASE_DIR / "fortune_translation_cache_ko_base.json"
FIELDNAMES = ["code", "type", "text", "weight"]
BATCH_SIZE = 8
DELAY_SECONDS = 0.08
SEPARATOR = "\n<<<YEGAMSSI_TEXT_SEPARATOR>>>\n"


@dataclass(frozen=True)
class TranslationTarget:
    locale_key: str
    translator_target: str
    output_csv: Path


TARGETS = [
    TranslationTarget("en", "en", BASE_DIR / "fortune_en.csv"),
    TranslationTarget("ja", "ja", BASE_DIR / "fortune_ja.csv"),
    TranslationTarget("ro", "ro", BASE_DIR / "fortune_ro.csv"),
    TranslationTarget("hi", "hi", BASE_DIR / "fortune_hi.csv"),
    TranslationTarget("vi", "vi", BASE_DIR / "fortune_vi.csv"),
]


def load_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != FIELDNAMES:
            raise ValueError(f"{path.name}: invalid header {reader.fieldnames}")
        return list(reader)


def save_rows(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)


def load_cache() -> dict[str, dict[str, str]]:
    if not CACHE_PATH.exists():
        return {}
    return json.loads(CACHE_PATH.read_text(encoding="utf-8"))


def save_cache(cache: dict[str, dict[str, str]]) -> None:
    cache_text = json.dumps(cache, ensure_ascii=False, indent=2, sort_keys=True)
    temporary_path = CACHE_PATH.with_suffix(".json.tmp")
    last_error: Exception | None = None
    for attempt in range(1, 6):
        try:
            temporary_path.write_text(cache_text, encoding="utf-8")
            temporary_path.replace(CACHE_PATH)
            return
        except OSError as error:
            last_error = error
            time.sleep(0.4 * attempt)

    try:
        CACHE_PATH.write_text(cache_text, encoding="utf-8")
    except OSError as error:
        raise RuntimeError(f"failed to save translation cache: {CACHE_PATH}") from (
            last_error or error
        )


def unique_texts(rows: list[dict[str, str]]) -> list[str]:
    seen: set[str] = set()
    texts: list[str] = []
    for row in rows:
        text = row["text"]
        if text not in seen:
            seen.add(text)
            texts.append(text)
    return texts


def translate_batch(
    translator: GoogleTranslator,
    texts: list[str],
) -> list[str]:
    try:
        joined_text = SEPARATOR.join(texts)
        translated_text = translator.translate(joined_text)
        parts = [part.strip() for part in translated_text.split(SEPARATOR.strip())]
        if len(parts) == len(texts) and all(parts):
            return parts
    except Exception:
        time.sleep(DELAY_SECONDS * 5)

    translated_texts: list[str] = []
    for text in texts:
        translated_texts.append(translate_one(translator, text))
        time.sleep(DELAY_SECONDS)
    return translated_texts


def translate_one(translator: GoogleTranslator, text: str) -> str:
    last_error: Exception | None = None
    for attempt in range(1, 5):
        try:
            translated_text = translator.translate(text).strip()
            if translated_text:
                return translated_text
        except Exception as error:
            last_error = error
        time.sleep(DELAY_SECONDS * attempt * 8)
    raise RuntimeError(f"translation failed after retries: {text}") from last_error


def translate_unique_texts(
    source_texts: list[str],
    target: TranslationTarget,
    cache: dict[str, dict[str, str]],
) -> dict[str, str]:
    locale_cache = cache.setdefault(target.locale_key, {})
    missing_texts = [text for text in source_texts if text not in locale_cache]
    if not missing_texts:
        print(f"{target.locale_key}: cache complete")
        return locale_cache

    translator = GoogleTranslator(source="ko", target=target.translator_target)
    total = len(missing_texts)
    for start in range(0, total, BATCH_SIZE):
        batch = missing_texts[start : start + BATCH_SIZE]
        try:
            translated_texts = translate_batch(translator, batch)
            for source_text, translated_text in zip(batch, translated_texts):
                if not translated_text:
                    raise ValueError(f"{target.locale_key}: empty translation for {source_text}")
                locale_cache[source_text] = translated_text
        finally:
            save_cache(cache)

        done = min(start + BATCH_SIZE, total)
        if done % 40 == 0 or done == total:
            save_cache(cache)
            print(f"{target.locale_key}: translated {done}/{total} missing texts", flush=True)
        time.sleep(DELAY_SECONDS)

    save_cache(cache)
    return locale_cache


def build_target_rows(
    source_rows: list[dict[str, str]],
    translated_text_by_source: dict[str, str],
) -> list[dict[str, str]]:
    target_rows: list[dict[str, str]] = []
    for row in source_rows:
        translated_text = translated_text_by_source[row["text"]].strip()
        if not translated_text:
            raise ValueError(f"empty translated text for {row['code']} {row['type']}")
        target_rows.append(
            {
                "code": row["code"],
                "type": row["type"],
                "text": translated_text,
                "weight": row["weight"],
            }
        )
    return target_rows


def main() -> None:
    source_rows = load_rows(SOURCE_CSV)
    source_texts = unique_texts(source_rows)
    print(f"source rows={len(source_rows)} unique_texts={len(source_texts)}", flush=True)

    cache = load_cache()
    for target in TARGETS:
        print(f"{target.locale_key}: target={target.translator_target}", flush=True)
        translated_text_by_source = translate_unique_texts(source_texts, target, cache)
        target_rows = build_target_rows(source_rows, translated_text_by_source)
        save_rows(target.output_csv, target_rows)
        print(f"{target.locale_key}: saved {target.output_csv.name} rows={len(target_rows)}", flush=True)


if __name__ == "__main__":
    main()
