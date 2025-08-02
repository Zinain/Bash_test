#!/bin/bash

PROCESS_NAME="test"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/var/log/monitoring.log"
PID_FILE="$SCRIPT_DIR/test.pid"
MONITORING_URL="https://test.com/monitoring/test/api"
current_pid=$(pgrep -x "$PROCESS_NAME")

if [ -n "$current_pid" ]; then
  if [ -f "$PID_FILE" ]; then
    last_pid=$(cat "$PID_FILE")
    if [ "$last_pid" != "$current_pid" ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Process '$PROCESS_NAME' restarted (old PID: $last_pid, new PID: $current_pid)" >> "$LOG_FILE"
    fi
  fi
  echo "$current_pid" > "$PID_FILE"

  #Send http req
  status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$MONITORING_URL")
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Sent request to $MONITORING_URL, status: $status_code" >> "$LOG_FILE"

  if [[ "$status_code" != 2* ]]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Monitoring server unavailable or error (status: $status_code)" >> "$LOG_FILE"
  fi
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Process '$PROCESS_NAME' is not running" >> "$LOG_FILE"
fi
