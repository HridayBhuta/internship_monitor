#!/bin/bash
set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$BASE_DIR"

echo "=== Job Tracker Started ==="

rm -rf jobs/yesterday
mkdir -p jobs
mv jobs/today jobs/yesterday 2>/dev/null || true
mkdir -p jobs/today

./fetch.sh
./build_logs.sh

echo "=== Job Tracker Finished ==="