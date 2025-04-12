#!/bin/bash

# Ensure exactly 1 argument passed
if [[ $# -ne 1 ]]; then
  echo "❌ Usage: $0 <base_filename>"
  echo "   Example: $0 HTPIB"
  exit 1
fi

BASE="$1"
INPUT1="${BASE}"
INPUT2="${BASE}_COPY"
FINAL="${BASE}_FINAL"
TMP_COMBINED="tmp_${BASE}_combined.txt"
BEL=$'\x07'
CURRENT_DATE=$(date '+%Y%m%d')

echo "=== Starting processing for: $BASE ==="

# Check if at least one input file exists
if [[ ! -f "$INPUT1" && ! -f "$INPUT2" ]]; then
  echo "❌ Neither $INPUT1 nor $INPUT2 exists. Cannot proceed."
  exit 1
fi

# Clean up from previous runs
rm -f "$TMP_COMBINED" "$FINAL"

# Function to filter out lines starting with H or T using sed
filter_data() {
  local file=$1
  if [[ -f "$file" ]]; then
    echo "   ➤ Filtering file: $file"
    sed '/^H/d; /^T/d' "$file" >> "$TMP_COMBINED"
  else
    echo "   ⚠️  File not found: $file (skipping)"
  fi
}

# Filter available input files
filter_data "$INPUT1"
filter_data "$INPUT2"

# Count valid data lines
record_count=$(wc -l < "$TMP_COMBINED")
echo "📊 Record count after filtering: $record_count"

# Write final output file
{
  echo "H${BEL}${CURRENT_DATE}"
  cat "$TMP_COMBINED"
  echo "T${BEL}${record_count}"
} > "$FINAL"

echo "✅ Final file generated: $FINAL"

# Cleanup temp file
rm -f "$TMP_COMBINED"

echo "=== Processing complete for: $BASE ==="
