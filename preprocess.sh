#!/bin/bash

# === INPUT ARGUMENTS ===
BASE="$1"
OUTPUT_DIR="${2:-.}"
BEL=$'\x07'
CURRENT_DATE=$(date '+%Y%m%d')
FINAL="${OUTPUT_DIR%/}/${BASE}_FINAL"
TMP_COMBINED="tmp_${BASE}_combined.txt"

# === VALIDATION ===
if [[ -z "$BASE" ]]; then
  echo "❌ Usage: $0 <base_filename> [output_directory]"
  echo "   Example: $0 HTPIB /data/output"
  exit 1
fi

[[ ! -d "$OUTPUT_DIR" ]] && echo "❌ Output directory not found: $OUTPUT_DIR" && exit 1

# === FIND COPY FILES SAFELY ===
COPY_FILES=()
for file in "${BASE}"_*; do
  [[ -f "$file" && "$file" != "$BASE" ]] && COPY_FILES+=("$file")
done

# === LOGIC DECISION ===
if [[ -f "$BASE" && ${#COPY_FILES[@]} -eq 0 ]]; then
  echo "ℹ️ Only $BASE exists. No action needed."
  exit 0
fi

if [[ ! -f "$BASE" && ${#COPY_FILES[@]} -eq 0 ]]; then
  echo "❌ No input files found matching '$BASE' or '${BASE}_*'"
  exit 1
fi

# === CLEANUP OLD OUTPUT ===
rm -f "$TMP_COMBINED" "$FINAL"

# === FILTER FUNCTION ===
filter_data() {
  local file=$1
  echo "   ➤ Filtering: $file"
  sed '/^H/d; /^T/d' "$file" >> "$TMP_COMBINED"
}

# === PROCESS FILES ===
echo "🔄 Processing files..."
[[ -f "$BASE" ]] && filter_data "$BASE"

for file in "${COPY_FILES[@]}"; do
  filter_data "$file"
done

# === COUNT & FINALIZE ===
record_count=$(wc -l < "$TMP_COMBINED")

{
  echo "H${BEL}${CURRENT_DATE}"
  cat "$TMP_COMBINED"
  echo "T${BEL}${record_count}"
} > "$FINAL"

rm -f "$TMP_COMBINED"
echo "✅ Output written to: $FINAL"
