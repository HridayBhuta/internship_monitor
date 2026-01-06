#!/bin/bash
mkdir -p jobs/today

HAS_JS_ENGINE=$(command -v shot-scraper &> /dev/null && echo 1 || echo 0)

while IFS='|' read -r NAME URL; do
    [[ -z "$URL" ]] && continue
    echo "Fetching $NAME (JS-rendered)..."
    
    if [[ "$HAS_JS_ENGINE" == "1" ]]; then
        RAW_HTML=$(shot-scraper html "$URL" --wait 5000)
    else
        RAW_HTML=$(curl -s -L "$URL")
    fi
    
    echo "$RAW_HTML" | \
        perl -0777 -pe 's/<script[^>]*>.*?<\/script>//gis' | \
        perl -0777 -pe 's/<style[^>]*>.*?<\/style>//gis' | \
        sed 's/<[^>]*>//g' | \
        tr -s '[:space:]' ' ' | \
        tr ',' '\n' | tr ';' '\n' | \
        sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | \
        tr '[:upper:]' '[:lower:]' | \
        grep -iE "engineer|developer|analyst|software|intern|research|devops|scientist" | \
        grep -Ev 'cookie|privacy|policy|terms|copyright|©|login|sign.?up' | \
        grep -E '.{15,}' | \
        sort -u > "jobs/today/$NAME"

done < urls.txt