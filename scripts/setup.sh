#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Preparing local environment..."

mkdir -p "$ROOT_DIR/logs"
echo "Ready: logs/ directory exists."

mkdir -p "$ROOT_DIR/deployments/blue" "$ROOT_DIR/deployments/green"
echo "Ready: deployments/blue and deployments/green directories exist."

if [ ! -f "$ROOT_DIR/deployments/active-env.txt" ]; then
  printf "blue\n" > "$ROOT_DIR/deployments/active-env.txt"
  echo "Ready: deployments/active-env.txt created with active environment set to blue."
else
  echo "Ready: deployments/active-env.txt already exists."
fi

echo "Installing app dependencies..."
(
  cd "$ROOT_DIR/app"
  npm install
)

echo "Success: environment preparation complete."
