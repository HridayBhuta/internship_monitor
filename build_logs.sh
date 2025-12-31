#!/bin/bash
mkdir -p logs
: > logs/changes.log

for FILE in jobs/today/*; do
    NAME=$(basename "$FILE")

    if [[ -f jobs/yesterday/$NAME ]]; then
        {
            echo "===== NEW JOBS ($NAME) ====="
            comm -13 jobs/yesterday/$NAME jobs/today/$NAME

            echo
            echo "===== REMOVED JOBS ($NAME) ====="
            comm -23 jobs/yesterday/$NAME jobs/today/$NAME
            echo
        } >> logs/changes.log
    else
        {
            echo "===== FIRST RUN ($NAME) ====="
            cat "$FILE"
            echo
        } >> logs/changes.log
    fi
done