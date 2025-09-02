#!/bin/bash
# Simple Cost Tracker - MINIMUM VIABLE COMPLEXITY
# Just logs API usage and costs - no over-engineering

LOG_FILE="$(dirname $0)/../logs/costs.log"
mkdir -p "$(dirname $LOG_FILE)"

# Simple cost tracking
log_cost() {
    local operation="$1"
    local estimated_cost="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') $operation $estimated_cost" >> "$LOG_FILE"
}

# Show today's total
show_total() {
    today=$(date '+%Y-%m-%d')
    if [ -f "$LOG_FILE" ]; then
        grep "$today" "$LOG_FILE" | awk '{sum += $4} END {print "Today: $" (sum ? sum : 0)}'
    else
        echo "Today: $0.00"
    fi
}

case "$1" in
    "log") log_cost "$2" "$3" ;;
    "total") show_total ;;
    *) echo "Usage: $0 {log operation cost|total}" ;;
esac
