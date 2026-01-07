#!/bin/bash
mkdir -p jobs/today

HAS_JS_ENGINE=$(command -v shot-scraper &> /dev/null && echo 1 || echo 0)

if [[ "$HAS_JS_ENGINE" == "0" ]]; then
    echo "WARNING: shot-scraper not found."
fi

while IFS='|' read -r NAME URL; do
    [[ -z "$URL" || "$NAME" =~ ^# ]] && continue
    echo "Fetching $NAME..."
    
    if [[ "$HAS_JS_ENGINE" == "1" ]]; then
        RAW_HTML=$(shot-scraper html "$URL" --wait 5000 2>/dev/null)
    else
        RAW_HTML=$(curl -s -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$URL")
    fi
    
    echo "$RAW_HTML" | \
        sed -n '/<body/,/<\/body>/p' | \
        perl -0777 -pe 's/<script[^>]*>.*?<\/script>//gis' | \
        perl -0777 -pe 's/<style[^>]*>.*?<\/style>//gis' | \
        sed -E 's/<\/(div|p|li|tr|br|h[1-6])>/\n/gi' | \
        sed 's/<[^>]*>//g' | \
        sed 's/&nbsp;/ /g' | \
        sed 's/[[:blank:]]\+/ /g' | \
        sed 's/^[ \t]*//;s/[ \t]*$//' | \
        sed '/^$/d' | \

        grep -iE "engineer|developer|analyst|software|intern|research|devops|scientist" | \
        grep -iEv 'phd|postdoc|senior scientist|principal scientist' | \
        grep -iEv '^cookie policy$|^privacy policy$|^terms of service$|copyright ©|all rights reserved' | \
        
        grep -E '.{10,}' | \
        sort -u > "jobs/today/$NAME"

    if [[ ! -s "jobs/today/$NAME" ]]; then
        echo "  -> Warning: No jobs found for $NAME."
    else
        echo "  -> Found $(wc -l < "jobs/today/$NAME") potential roles"
    fi

done < urls.txt