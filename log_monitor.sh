#!/usr/bin/env bash
# log_monitor.sh - simple log monitor which searches logs for keywords and writes alerts
# Usage: ./log_monitor.sh [keyword] [logfile] [--watch]

set -euo pipefail

KEYWORD="${1:-ERROR}"
LOGFILE="${2:-/var/log/syslog}"
WATCH_FLAG="${3:-}"

ALERT_DIR="${HOME}/log_alerts"
mkdir -p "$ALERT_DIR"
ALERT_FILE="${ALERT_DIR}/alerts_$(date +%Y%m%d_%H%M%S).log"

echo "Searching for keyword: '$KEYWORD' in $LOGFILE"
if [ "$WATCH_FLAG" = "--watch" ]; then
  echo "Starting live watch (press Ctrl+C to exit) and appending matches to ${ALERT_FILE}"
  tail -F "$LOGFILE" | while IFS= read -r line; do
    echo "$line" | grep -i --line-buffered "$KEYWORD" && echo "$(date +'%Y-%m-%d %H:%M:%S') $line" >> "$ALERT_FILE"
  done
else
  grep -i -- "$KEYWORD" "$LOGFILE" || true | tee -a "$ALERT_FILE"
  echo "Matches appended to ${ALERT_FILE}"
fi