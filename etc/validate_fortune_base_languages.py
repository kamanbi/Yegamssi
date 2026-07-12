import csv
import re
from collections import Counter
from dataclasses import dataclass
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent
BASE_CSV = BASE_DIR / "fortune_styles" / "fortune_ko_base.csv"
FIELDNAMES = ["code", "type", "text", "weight"]
ALLOWED_TIERS = {"A", "B", "B1", "C", "C1", "D"}
CODE_PATTERN = re.compile(
    r"^(overall|money|love|work|health|decision)_([A-Z][0-9]?)(?:_|$)"
)


@dataclass(frozen=True)
class FortuneCsvTarget:
    label: str
    path: Path


TARGETS = [
    FortuneCsvTarget("ko_base", BASE_CSV),
    FortuneCsvTarget("ko_cynical", BASE_DIR / "fortune_styles" / "fortune_ko_cynical.csv"),
    FortuneCsvTarget("ko_humor", BASE_DIR / "fortune_styles" / "fortune_ko_humor.csv"),
    FortuneCsvTarget("ko_tsundere", BASE_DIR / "fortune_styles" / "fortune_ko_tsundere.csv"),
    FortuneCsvTarget("ko_emotional", BASE_DIR / "fortune_styles" / "fortune_ko_emotional.csv"),
    FortuneCsvTarget("ko_historical", BASE_DIR / "fortune_styles" / "fortune_ko_historical.csv"),
    FortuneCsvTarget("ko_ai", BASE_DIR / "fortune_styles" / "fortune_ko_ai.csv"),
    FortuneCsvTarget("en", BASE_DIR / "fortune_en.csv"),
    FortuneCsvTarget("ja", BASE_DIR / "fortune_ja.csv"),
    FortuneCsvTarget("ro", BASE_DIR / "fortune_ro.csv"),
    FortuneCsvTarget("hi", BASE_DIR / "fortune_hi.csv"),
    FortuneCsvTarget("zh", BASE_DIR / "fortune_zh.csv"),
    FortuneCsvTarget("es", BASE_DIR / "fortune_es.csv"),
    FortuneCsvTarget("pt", BASE_DIR / "fortune_pt.csv"),
    FortuneCsvTarget("de", BASE_DIR / "fortune_de.csv"),
    FortuneCsvTarget("fr", BASE_DIR / "fortune_fr.csv"),
    FortuneCsvTarget("vi", BASE_DIR / "fortune_vi.csv"),
]


def load_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise FileNotFoundError(f"Missing fortune CSV: {path}")

    with path.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != FIELDNAMES:
            raise ValueError(f"{path.name}: invalid header {reader.fieldnames}")
        return list(reader)


def row_key(row: dict[str, str]) -> tuple[str, str]:
    return row["code"], row["type"]


def runtime_tier(code: str) -> str:
    match = CODE_PATTERN.match(code)
    if not match:
        raise ValueError(f"Invalid fortune code: {code}")
    return match.group(2)


def validate_target(
    target: FortuneCsvTarget,
    base_rows: list[dict[str, str]],
    base_key_counts: Counter[tuple[str, str]],
) -> None:
    target_rows = load_rows(target.path)
    if len(target_rows) != len(base_rows):
        raise ValueError(
            f"{target.label}: row count {len(target_rows)} != {len(base_rows)}"
        )

    target_key_counts = Counter(row_key(row) for row in target_rows)
    if target_key_counts != base_key_counts:
        missing_keys = sorted(
            key for key in base_key_counts if target_key_counts[key] != base_key_counts[key]
        )
        extra_keys = sorted(
            key for key in target_key_counts if target_key_counts[key] != base_key_counts[key]
        )
        raise ValueError(
            f"{target.label}: key count mismatch "
            f"missing_or_short={missing_keys[:5]} extra_or_long={extra_keys[:5]}"
        )

    tier_counts = Counter()
    for index, row in enumerate(target_rows, 2):
        if not row["text"].strip():
            raise ValueError(f"{target.label}:{index}: empty text")
        if not row["weight"].isdigit() or int(row["weight"]) <= 0:
            raise ValueError(f"{target.label}:{index}: invalid weight {row['weight']}")

        tier = runtime_tier(row["code"])
        if tier not in ALLOWED_TIERS:
            raise ValueError(f"{target.label}:{index}: unreachable tier {tier}")
        tier_counts[tier] += 1

    print(f"ok: {target.label} rows={len(target_rows)} tiers={dict(tier_counts)}")


def main() -> None:
    base_rows = load_rows(BASE_CSV)
    base_key_counts = Counter(row_key(row) for row in base_rows)
    for target in TARGETS:
        validate_target(target, base_rows, base_key_counts)


if __name__ == "__main__":
    main()
