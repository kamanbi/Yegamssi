#!/usr/bin/env bash
# Generate SQL INSERT for new tiers

OUT="ko_insert.sql"

echo "-- fortune_ko: A / B1 / C1 / D tier inserts (3840 rows)" > "$OUT"
echo "-- Run in Supabase SQL editor or via psql" >> "$OUT"
echo "" >> "$OUT"
echo "INSERT INTO fortune_ko (code, type, text, weight) VALUES" >> "$OUT"

# Read ko_new_tiers.csv and generate SQL values
first=1
while IFS=',' read -r code type text weight; do
  # Escape single quotes in text
  escaped="${text//\'/\'\'}"
  if [ $first -eq 1 ]; then
    printf "  ('%s','%s','%s',%s)" "$code" "$type" "$escaped" "$weight" >> "$OUT"
    first=0
  else
    printf ",\n  ('%s','%s','%s',%s)" "$code" "$type" "$escaped" "$weight" >> "$OUT"
  fi
done < ko_new_tiers.csv

echo "" >> "$OUT"
echo "ON CONFLICT (code, type) DO UPDATE SET text = EXCLUDED.text, weight = EXCLUDED.weight;" >> "$OUT"

wc -l "$OUT"
head -5 "$OUT"
echo "..."
tail -4 "$OUT"
