#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_FILE="$ROOT_DIR/deployments/active-env.txt"
LOG_DIR="$ROOT_DIR/logs"
LOG_FILE="$LOG_DIR/health.log"

mkdir -p "$LOG_DIR"

echo "Health check monitoring started."
echo "Logs are stored at: $LOG_FILE"
echo "Press Ctrl+C to stop."

trap 'echo "Health check monitoring stopped."; exit 0' INT TERM

while true; do
  TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"

  if [ ! -f "$ACTIVE_FILE" ]; then
    ENVIRONMENT="missing"
    HTTP_STATUS="000"
    RESULT="failed: active-env.txt not found"
  else
    ENVIRONMENT="$(tr -d '[:space:]' < "$ACTIVE_FILE")"

    case "$ENVIRONMENT" in
      blue)
        PORT="3001"
        ;;
      green)
        PORT="3002"
        ;;
      *)
        PORT=""
        ;;
    esac

    if [ -z "$PORT" ]; then
      HTTP_STATUS="000"
      RESULT="failed: invalid active environment"
    else
      HEALTH_URL="http://localhost:$PORT/health"
      HTTP_STATUS="$(curl -s -o /dev/null -w '%{http_code}' "$HEALTH_URL")" || HTTP_STATUS="000"

      if [ "$HTTP_STATUS" = "200" ]; then
        RESULT="success"
      else
        RESULT="failed"
      fi
    fi
  fi

  printf "%s | env=%s | status=%s | result=%s\n" "$TIMESTAMP" "$ENVIRONMENT" "$HTTP_STATUS" "$RESULT" | tee -a "$LOG_FILE"
  sleep 10 &
  wait $!
done
