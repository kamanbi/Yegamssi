import csv
import os
import sys
from collections import Counter
from pathlib import Path

import psycopg2
from psycopg2.extras import execute_values


sys.stdout.reconfigure(encoding="utf-8")

BASE_DIR = Path(__file__).resolve().parent
ROOT_DIR = BASE_DIR.parent
SOURCE_CSV = BASE_DIR / "fortune_styles" / "fortune_ko_base.csv"
TARGET_CSV = BASE_DIR / "fortune_vi.csv"
TABLE_NAME = "fortune_vi"
FIELDNAMES = ["code", "type", "text", "weight"]


def load_dotenv(path: Path) -> None:
    if not path.exists():
        return

    for line in path.read_text(encoding="utf-8").splitlines():
        stripped_line = line.strip()
        if not stripped_line or stripped_line.startswith("#") or "=" not in stripped_line:
            continue

        key, raw_value = stripped_line.split("=", 1)
        key = key.strip()
        if not key or key in os.environ:
            continue

        value = raw_value.strip().strip('"').strip("'")
        os.environ[key] = value


def require_database_url() -> str:
    load_dotenv(ROOT_DIR / ".env")
    database_url = os.environ.get("SUPABASE_DB_URL") or os.environ.get(
        "SUPABASE_DATABASE_URL"
    )
    if not database_url:
        raise RuntimeError(
            "Missing SUPABASE_DB_URL or SUPABASE_DATABASE_URL in environment/.env"
        )
    return database_url


def load_rows(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        raise FileNotFoundError(f"Missing CSV: {path}")

    with path.open(encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        if reader.fieldnames != FIELDNAMES:
            raise ValueError(f"{path.name}: invalid header {reader.fieldnames}")
        return list(reader)


def row_key(row: dict[str, str]) -> tuple[str, str]:
    return row["code"], row["type"]


def validate_target_rows(
    source_rows: list[dict[str, str]],
    target_rows: list[dict[str, str]],
) -> None:
    if len(target_rows) != len(source_rows):
        raise ValueError(
            f"{TARGET_CSV.name}: row count {len(target_rows)} != {len(source_rows)}"
        )

    source_key_counts = Counter(row_key(row) for row in source_rows)
    target_key_counts = Counter(row_key(row) for row in target_rows)
    if target_key_counts != source_key_counts:
        raise ValueError(f"{TARGET_CSV.name}: key structure does not match base CSV")

    for index, row in enumerate(target_rows, 2):
        if not row["text"].strip():
            raise ValueError(f"{TARGET_CSV.name}:{index}: empty text")
        if not row["weight"].isdigit() or int(row["weight"]) <= 0:
            raise ValueError(f"{TARGET_CSV.name}:{index}: invalid weight")


def create_table(cursor) -> None:
    cursor.execute(
        f"""
        DROP TABLE IF EXISTS "{TABLE_NAME}";
        CREATE TABLE "{TABLE_NAME}" (
            id bigint generated always as identity primary key,
            code text NOT NULL,
            type text NOT NULL,
            text text NOT NULL,
            weight smallint NOT NULL DEFAULT 1
        );
        CREATE INDEX idx_{TABLE_NAME} ON "{TABLE_NAME}" USING btree (code, type);
        ALTER TABLE "{TABLE_NAME}" ENABLE ROW LEVEL SECURITY;
        CREATE POLICY anon_read ON "{TABLE_NAME}" FOR SELECT TO anon USING (true);
        GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER
            ON "{TABLE_NAME}" TO anon, authenticated, service_role, postgres;
        """
    )


def upload_rows(database_url: str, rows: list[dict[str, str]]) -> int:
    values = [
        (row["code"], row["type"], row["text"], int(row["weight"]))
        for row in rows
    ]

    with psycopg2.connect(database_url, connect_timeout=20) as connection:
        with connection.cursor() as cursor:
            cursor.execute("SET statement_timeout = 0")
            create_table(cursor)
            execute_values(
                cursor,
                f'INSERT INTO "{TABLE_NAME}" (code, type, text, weight) VALUES %s',
                values,
                page_size=1000,
            )
            cursor.execute(
                f"""
                SELECT
                    count(*),
                    count(*) FILTER (WHERE btrim(text) = '')
                FROM "{TABLE_NAME}"
                """
            )
            uploaded_count, empty_text_count = cursor.fetchone()
            if empty_text_count:
                raise RuntimeError(f"{TABLE_NAME}: empty text rows uploaded")

            cursor.execute("NOTIFY pgrst, 'reload schema'")
            return uploaded_count


def main() -> None:
    source_rows = load_rows(SOURCE_CSV)
    target_rows = load_rows(TARGET_CSV)
    validate_target_rows(source_rows, target_rows)

    database_url = require_database_url()
    uploaded_count = upload_rows(database_url, target_rows)
    if uploaded_count != len(target_rows):
        raise RuntimeError(f"{TABLE_NAME}: uploaded {uploaded_count} != {len(target_rows)}")

    print(f"{TABLE_NAME}: uploaded rows={uploaded_count}")
    print("schema reload notified")


if __name__ == "__main__":
    main()
