#!/bin/sh

# === INPUT ARGUMENTS ===
BASE="$1"
SEARCH_DIR="${2:-.}"
BEL="$(printf '\007')"  # BEL delimiter
CURRENT_DATE=$(date '+%Y%m%d')
FINAL="${BASE}_FINAL"
TMP_COMBINED="tmp_${BASE}_combined.txt"
TMP_FILE_LIST="tmp_${BASE}_file_list.txt"

# === VALIDATION ===
if [ -z "$BASE" ]; then
  echo "❌ Usage: $0 <base_filename> [search_directory]"
  echo "   Example: $0 HTPIB /data/input"
  exit 1
fi

if [ ! -d "$SEARCH_DIR" ]; then
  echo "❌ Directory does not exist: $SEARCH_DIR"
  exit 1
fi

# === FIND MATCHING FILES ===
TIMESTAMPED_FILES=""
find "$SEARCH_DIR" -maxdepth 1 -type f -name "${BASE}_*" -print | while IFS= read -r file; do
  # Strip path prefix and ignore the base file itself
  file_name=$(basename "$file")
  [ "$file_name" = "$BASE" ] && continue
  TIMESTAMPED_FILES="${TIMESTAMPED_FILES}${SEARCH_DIR%/}/$file_name"$'\n'
done > "$TMP_FILE_LIST"

# === CHECK CONDITIONS ===
FILE_COUNT=$(wc -l < "$TMP_FILE_LIST" 2>/dev/null)

if [ -f "${SEARCH_DIR%/}/$BASE" ] && [ "$FILE_COUNT" -eq 0 ]; then
  echo "ℹ️ Only $BASE exists in $SEARCH_DIR. No timestamped files. Exiting."
  exit 0
fi

if [ ! -f "${SEARCH_DIR%/}/$BASE" ] && [ "$FILE_COUNT" -eq 0 ]; then
  echo "❌ No matching files found in $SEARCH_DIR for '$BASE' or '${BASE}_*'"
  rm -f "$TMP_FILE_LIST"
  exit 1
fi

# === CLEANUP PREVIOUS OUTPUT ===
rm -f "$TMP_COMBINED" "$FINAL"

# === FILTER FUNCTION ===
filter_data() {
  file="$1"
  echo "   ➤ Filtering: $file"
  sed '/^H/d; /^T/d' "$file" >> "$TMP_COMBINED"
}

# === PROCESS FILES ===
echo "🔄 Processing files..."
[ -f "${SEARCH_DIR%/}/$BASE" ] && filter_data "${SEARCH_DIR%/}/$BASE"

while IFS= read -r file; do
  [ -f "$file" ] && filter_data "$file"
done < "$TMP_FILE_LIST"

record_count=$(wc -l < "$TMP_COMBINED")

# === WRITE FINAL FILE ===
{
  printf "H%s%s\n" "$BEL" "$CURRENT_DATE"
  cat "$TMP_COMBINED"
  printf "T%s%d\n" "$BEL" "$record_count"
} > "$FINAL"

# === CLEANUP ===
rm -f "$TMP_COMBINED" "$TMP_FILE_LIST"

echo "✅ Output written to: $FINAL"
