import csv
import time
from dataclasses import dataclass
from pathlib import Path

from deep_translator import GoogleTranslator


BASE_DIR = Path(__file__).resolve().parent
SOURCE_CSV = BASE_DIR / "fortune_en.csv"


@dataclass(frozen=True)
class TranslationTarget:
    locale_key: str
    translator_target: str
    output_csv: Path


TARGETS = [
    TranslationTarget("ro", "ro", BASE_DIR / "fortune_ro.csv"),
    TranslationTarget("hi", "hi", BASE_DIR / "fortune_hi.csv"),
]

BATCH_SIZE = 12
DELAY_SECONDS = 0.25
SEPARATOR = "\n<<<YEGAMSSI_ROW_SEPARATOR>>>\n"
FIELDNAMES = ["code", "type", "text", "weight"]


def load_rows(path: Path) -> list[dict[str, str]]:
    with path.open(encoding="utf-8-sig", newline="") as file:
        return list(csv.DictReader(file))


def save_rows(path: Path, rows: list[dict[str, str]]) -> None:
    with path.open("w", encoding="utf-8-sig", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=FIELDNAMES)
        writer.writeheader()
        writer.writerows(rows)


def translate_batch(
    translator: GoogleTranslator,
    texts: list[str],
) -> list[str]:
    joined_text = SEPARATOR.join(texts)
    translated_text = translator.translate(joined_text)
    parts = [part.strip() for part in translated_text.split(SEPARATOR.strip())]
    if len(parts) == len(texts):
        return parts

    translated_rows: list[str] = []
    for text in texts:
        translated_rows.append(translator.translate(text).strip())
        time.sleep(DELAY_SECONDS)
    return translated_rows


def translate_rows(
    source_rows: list[dict[str, str]],
    target: TranslationTarget,
) -> list[dict[str, str]]:
    translator = GoogleTranslator(source="en", target=target.translator_target)
    translated_rows: list[dict[str, str]] = []
    total = len(source_rows)

    for start in range(0, total, BATCH_SIZE):
        batch = source_rows[start : start + BATCH_SIZE]
        texts = [row["text"] for row in batch]
        translated_texts = translate_batch(translator, texts)

        for row, translated_text in zip(batch, translated_texts):
            translated_rows.append(
                {
                    "code": row["code"],
                    "type": row["type"],
                    "text": translated_text,
                    "weight": row["weight"],
                }
            )

        done = min(start + BATCH_SIZE, total)
        if done % 240 == 0 or done == total:
            print(f"{target.locale_key}: {done}/{total}")
        time.sleep(DELAY_SECONDS)

    return translated_rows


def main() -> None:
    if not SOURCE_CSV.exists():
        raise FileNotFoundError(f"Missing source CSV: {SOURCE_CSV}")

    source_rows = load_rows(SOURCE_CSV)
    print(f"source: {SOURCE_CSV.name} rows={len(source_rows)}")

    for target in TARGETS:
        if target.output_csv.exists():
            existing_rows = load_rows(target.output_csv)
            if len(existing_rows) == len(source_rows):
                print(f"{target.locale_key}: existing complete, skip")
                continue

        print(f"{target.locale_key}: translate -> {target.output_csv.name}")
        translated_rows = translate_rows(source_rows, target)
        save_rows(target.output_csv, translated_rows)
        print(f"{target.locale_key}: saved rows={len(translated_rows)}")


if __name__ == "__main__":
    main()
