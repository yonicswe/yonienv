#!/bin/bash
##############################################################################
# Configuration
##############################################################################
CACHE_DIR="$HOME/.diskhog_cache"
mkdir -p "$CACHE_DIR"
TARGET_DIR="${1:-$HOME}"
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: '$TARGET_DIR' is not a directory."
    exit 1
fi
CACHE_KEY=$(echo "$TARGET_DIR" | sed 's#[/ ]#_#g')
CACHE_FILE="$CACHE_DIR/${CACHE_KEY}.out"
CACHE_TIME="$CACHE_DIR/${CACHE_KEY}.time"
NOW=$(date +%s)
##############################################################################
# Show cached results if available
##############################################################################
if [[ -f "$CACHE_FILE" && -f "$CACHE_TIME" ]]; then
    LAST_RUN=$(<"$CACHE_TIME")
    AGE=$((NOW - LAST_RUN))
    echo
    echo "============================================================"
    echo "Previous results found for: $TARGET_DIR"
    echo "Cache age: ${AGE} seconds"
    echo "============================================================"
    echo
    cat "$CACHE_FILE"
    echo
    echo "Top 5 folders from previous results:"
    echo
    mapfile -t TOP_DIRS < <(
        awk '
            /^RESULTS$/ {results=1; next}
            results && $2 ~ /^\// {print $2}
        ' "$CACHE_FILE" | head -5
    )
    for i in "${!TOP_DIRS[@]}"; do
        printf "%d) %s\n" $((i + 1)) "${TOP_DIRS[$i]}"
    done
    echo
    echo "r) Re-scan $TARGET_DIR"
    echo "0) Exit"
    echo
    read -p "Choice: " CHOICE
    if [[ "$CHOICE" =~ ^[1-5]$ ]] &&
       (( CHOICE <= ${#TOP_DIRS[@]} ))
    then
        exec "$0" "${TOP_DIRS[$((CHOICE - 1))]}"
    fi
    if [[ "$CHOICE" != "r" && "$CHOICE" != "R" ]]; then
        exit 0
    fi
    echo
    echo "Running fresh scan..."
    echo
fi
##############################################################################
# New scan
##############################################################################
START_TIME=$(date +%s)
echo "Target directory: $TARGET_DIR"
echo
read -p "Search for (d)irectories or (f)iles? " MODE
if [[ "$MODE" =~ ^[Ff]$ ]]; then
    SCAN_TYPE="files"
    CMD_DESC="find \"$TARGET_DIR\" -type f -printf '%s %p\n'"
else
    SCAN_TYPE="directories"
    CMD_DESC="du -xsh \"$TARGET_DIR\"/* \"$TARGET_DIR\"/.??* 2>/dev/null"
fi
echo
echo "Running:"
echo "  $CMD_DESC"
echo
(
    while true; do
        NOW=$(date +%s)
        ELAPSED=$((NOW - START_TIME))
        printf "\rElapsed: %02d:%02d:%02d" \
            $((ELAPSED / 3600)) \
            $(((ELAPSED % 3600) / 60)) \
            $((ELAPSED % 60))
        sleep 1
    done
) &
TIMER_PID=$!
cleanup() {
    kill "$TIMER_PID" 2>/dev/null
    exit 1
}
trap cleanup INT TERM
##############################################################################
# File scan
##############################################################################
if [[ "$SCAN_TYPE" == "files" ]]; then
    RESULTS=$(
        find "$TARGET_DIR" -type f -printf '%s %p\n' 2>/dev/null |
        sort -nr |
        head -30
    )
    kill "$TIMER_PID" 2>/dev/null
    wait "$TIMER_PID" 2>/dev/null
    echo
    echo
    echo "Largest Files"
    echo "-------------"
    echo "$RESULTS"
    TOTAL=$(echo "$RESULTS" | awk '{sum+=$1} END {print sum+0}')
    echo
    echo "Total size of displayed files: $(numfmt --to=iec "$TOTAL")"
##############################################################################
# Directory scan
##############################################################################
else
    RESULTS=$(
        du -xsh "$TARGET_DIR"/* "$TARGET_DIR"/.??* 2>/dev/null |
        sort -hr |
        head -30
    )
    kill "$TIMER_PID" 2>/dev/null
    wait "$TIMER_PID" 2>/dev/null
    echo
    echo
    echo "Largest Directories"
    echo "-------------------"
    echo "$RESULTS"
    TOTAL=$(echo "$RESULTS" | awk '
    {
        size=$1
        unit=substr(size,length(size),1)
        if (unit=="K" || unit=="M" || unit=="G" || unit=="T" || unit=="P") {
            num=substr(size,1,length(size)-1)
            if (unit=="K") mult=1024
            else if (unit=="M") mult=1024^2
            else if (unit=="G") mult=1024^3
            else if (unit=="T") mult=1024^4
            else if (unit=="P") mult=1024^5
            sum += num * mult
        }
    }
    END {
        print int(sum)
    }')
    echo
    echo "Total size of displayed directories: $(numfmt --to=iec "$TOTAL")"
fi
##############################################################################
# Completion summary
##############################################################################
ELAPSED=$(( $(date +%s) - START_TIME ))
##############################################################################
# Save cache with metadata
##############################################################################
{
    echo "Directory: $TARGET_DIR"
    echo "Scan type: $SCAN_TYPE"
    echo "Generated: $(date)"
    echo "Elapsed: ${ELAPSED} seconds"
    if [[ -n "$TOTAL" ]]; then
        echo "Displayed total: $(numfmt --to=iec "$TOTAL" 2>/dev/null || echo "$TOTAL")"
    fi
    echo
    echo "RESULTS"
    echo
    echo "$RESULTS"
} > "$CACHE_FILE"
date +%s > "$CACHE_TIME"
##############################################################################
# Final message
##############################################################################
echo
echo "Completed in ${ELAPSED} seconds."
echo "Results saved to cache."
echo
echo "Tip: Running the script again on the same directory will show"
echo "the cached results immediately and allow drill-down into the"
echo "largest folders without re-scanning."
