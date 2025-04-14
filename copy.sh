#!/bin/bash

# === CONFIGURABLE PARAMETERS ===
WATCH_PATH="$1"         # Directory to watch
WATCH_FILE="$2"         # File to monitor (e.g. abc)
INTERVAL_SEC=60         # Polling interval in seconds
IDLE_THRESHOLD_SEC=600  # Threshold for idle time in seconds (10 minutes)
LOG_FILE="monitor_log_$(date '+%Y%m%d_%H%M%S').log"

# === FUNCTIONS ===

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $*" | tee -a "$LOG_FILE"
}

# === ARGUMENT VALIDATION ===

if [[ -z "$WATCH_PATH" || -z "$WATCH_FILE" ]]; then
    echo "❌ Usage: $0 <directory_path> <file_name>"
    echo "   Example: $0 /data/input abc"
    exit 1
fi

FULL_PATH="${WATCH_PATH%/}/$WATCH_FILE"
COPY_FILE="${FULL_PATH}_copy"

log "🟢 Starting file monitor on: $FULL_PATH"
log "🔁 Checking every ${INTERVAL_SEC}s. Copy if idle for ${IDLE_THRESHOLD_SEC}s"

# === MONITOR LOOP ===
while true; do
    if [[ -f "$FULL_PATH" ]]; then
        last_mod_epoch=$(stat -c %Y "$FULL_PATH" 2>/dev/null)
        now_epoch=$(date +%s)
        idle_secs=$(( now_epoch - last_mod_epoch ))

        if (( idle_secs >= IDLE_THRESHOLD_SEC )); then
            log "⏰ File '$WATCH_FILE' idle for ${idle_secs}s. Copying to $COPY_FILE..."

            if [[ ! -f "$COPY_FILE" ]]; then
                cp "$FULL_PATH" "$COPY_FILE" && log "✅ Copied to new file."
            else
                cat "$FULL_PATH" >> "$COPY_FILE" && log "🔄 Appended to existing copy."
            fi

            # Wait until file is modified again before reprocessing
            while [[ -f "$FULL_PATH" ]]; do
                new_mod_epoch=$(stat -c %Y "$FULL_PATH" 2>/dev/null)
                if [[ "$new_mod_epoch" -ne "$last_mod_epoch" ]]; then
                    log "✏️ File modified again. Will re-check idle time."
                    break
                fi
                sleep "$INTERVAL_SEC"
            done
        else
            log "🟡 File '$WATCH_FILE' exists, idle for ${idle_secs}s (less than threshold)."
        fi
    else
        log "🔍 File '$WATCH_FILE' not found in path: $WATCH_PATH"
    fi

    sleep "$INTERVAL_SEC"
done
