#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_FILE="$ROOT_DIR/deployments/active-env.txt"

if [ ! -f "$ACTIVE_FILE" ]; then
  echo "Error: deployments/active-env.txt does not exist."
  echo "Run bash scripts/setup.sh first."
  exit 1
fi

ACTIVE_ENV="$(tr -d '[:space:]' < "$ACTIVE_FILE")"

case "$ACTIVE_ENV" in
  blue)
    ROLLBACK_ENV="green"
    ROLLBACK_PORT="3002"
    ;;
  green)
    ROLLBACK_ENV="blue"
    ROLLBACK_PORT="3001"
    ;;
  *)
    echo "Error: active-env.txt must contain blue or green."
    exit 1
    ;;
esac

ROLLBACK_DIR="$ROOT_DIR/deployments/$ROLLBACK_ENV"
PID_FILE="$ROLLBACK_DIR/app.pid"
HEALTH_URL="http://localhost:$ROLLBACK_PORT/health"

echo "Current active environment: $ACTIVE_ENV"
echo "Rollback target: $ROLLBACK_ENV"
echo "Rollback target port: $ROLLBACK_PORT"

if [ ! -f "$PID_FILE" ]; then
  echo "Rollback status: failed"
  echo "Reason: deployments/$ROLLBACK_ENV/app.pid was not found."
  exit 1
fi

ROLLBACK_PID="$(cat "$PID_FILE")"
echo "Found rollback PID file: deployments/$ROLLBACK_ENV/app.pid"
echo "Saved rollback PID: $ROLLBACK_PID"

echo "Checking rollback environment health: $HEALTH_URL"

if ! curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
  echo "Rollback status: failed"
  echo "Reason: health check failed for $ROLLBACK_ENV."
  echo "Active environment remains: $ACTIVE_ENV"
  exit 1
fi

printf "%s\n" "$ROLLBACK_ENV" > "$ACTIVE_FILE"

echo "Rollback status: successful"
echo "Active environment is now: $ROLLBACK_ENV"
