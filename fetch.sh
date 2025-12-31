#!/bin/bash
mkdir -p jobs/today

while IFS='|' read -r NAME URL; do
    echo "Fetching $NAME"

    curl -s "$URL" |
    tr '[:upper:]' '[:lower:]' |
    grep -E "engineer|developer|analyst|software|intern|research|scientist" |
    grep -Ev "phd|postdoc" |
    sed 's/<[^>]*>//g' |
    sort -u > "jobs/today/$NAME"

done < urls.txt