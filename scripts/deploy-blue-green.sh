#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ACTIVE_FILE="$ROOT_DIR/deployments/active-env.txt"
APP_DIR="$ROOT_DIR/app"

if [ ! -f "$ACTIVE_FILE" ]; then
  echo "active-env.txt was missing. Creating it with blue as the active environment."
  mkdir -p "$ROOT_DIR/deployments"
  printf "blue\n" > "$ACTIVE_FILE"
fi

ACTIVE_ENV="$(tr -d '[:space:]' < "$ACTIVE_FILE")"

case "$ACTIVE_ENV" in
  blue)
    TARGET_ENV="green"
    TARGET_PORT="3002"
    ;;
  green)
    TARGET_ENV="blue"
    TARGET_PORT="3001"
    ;;
  *)
    echo "Error: active-env.txt must contain blue or green."
    exit 1
    ;;
esac

TARGET_DIR="$ROOT_DIR/deployments/$TARGET_ENV"
PID_FILE="$TARGET_DIR/app.pid"
HEALTH_URL="http://localhost:$TARGET_PORT/health"

echo "Current active environment: $ACTIVE_ENV"
echo "Deployment target: $TARGET_ENV"
echo "Target port: $TARGET_PORT"

mkdir -p "$TARGET_DIR"

case "$TARGET_DIR" in
  "$ROOT_DIR"/deployments/blue|"$ROOT_DIR"/deployments/green)
    ;;
  *)
    echo "Error: unsafe deployment target path."
    exit 1
    ;;
esac

if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE")"
  if kill -0 "$OLD_PID" >/dev/null 2>&1; then
    echo "Stopping old $TARGET_ENV process with PID $OLD_PID..."
    kill "$OLD_PID" >/dev/null 2>&1 || true
    sleep 2
  fi
fi

echo "Copying app files to deployments/$TARGET_ENV..."
find "$TARGET_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp "$APP_DIR/app.js" "$TARGET_DIR/"
cp "$APP_DIR/server.js" "$TARGET_DIR/"
cp "$APP_DIR/package.json" "$TARGET_DIR/"
cp "$APP_DIR/package-lock.json" "$TARGET_DIR/"

echo "Installing production dependencies in deployments/$TARGET_ENV..."
(
  cd "$TARGET_DIR"
  npm install --omit=dev
)

echo "Starting $TARGET_ENV environment..."
(
  cd "$TARGET_DIR"
  PORT="$TARGET_PORT" nohup npm start > app.log 2>&1 &
  echo "$!" > "$PID_FILE"
)

echo "Running health check: $HEALTH_URL"
HEALTH_OK="false"

for _ in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsS "$HEALTH_URL" >/dev/null 2>&1; then
    HEALTH_OK="true"
    break
  fi
  sleep 1
done

if [ "$HEALTH_OK" != "true" ]; then
  echo "Health result: failed"
  echo "Deployment failed. Active environment remains: $ACTIVE_ENV"
  exit 1
fi

printf "%s\n" "$TARGET_ENV" > "$ACTIVE_FILE"

echo "Health result: passed"
echo "Active environment is now: $TARGET_ENV"
echo "Previous environment remains available for rollback: $ACTIVE_ENV"
echo "Deployment complete."
