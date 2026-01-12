#!/bin/bash
mkdir -p jobs/today

# Check for shot-scraper
HAS_JS_ENGINE=$(command -v shot-scraper &> /dev/null && echo 1 || echo 0)

if [[ "$HAS_JS_ENGINE" == "0" ]]; then
    echo "CRITICAL: shot-scraper not found. Please run: pip install shot-scraper"
    exit 1
fi

while IFS='|' read -r NAME URL; do
    [[ -z "$URL" || "$NAME" =~ ^# ]] && continue
    echo "Fetching $NAME..."
    
    RAW_TEXT=""
    
    if [[ "$HAS_JS_ENGINE" == "1" ]]; then
        # FIX: The 'javascript' command doesn't have a --wait flag.
        # We must use a Promise inside the JS to wait.
        # This JS waits 10 seconds (10000ms) then returns the body text.
        JS_COMMAND="new Promise(done => setTimeout(() => done(document.body.innerText), 10000));"
        
        # We use --browser-arg to force a large window since --width isn't supported here
        echo "  -> Attempting JS scrape (10s wait)..."
        JSON_OUTPUT=$(shot-scraper javascript "$URL" "$JS_COMMAND" --browser-arg "--window-size=1920,1080" 2>/dev/null)
        
        # Decode JSON output
        RAW_TEXT=$(echo "$JSON_OUTPUT" | python3 -c "import sys, json; print(json.load(sys.stdin))" 2>/dev/null)
    fi

    echo "  -> Scraped ${#RAW_TEXT} characters of text."

    # Fallback to curl if JS failed or returned empty
    if [[ ${#RAW_TEXT} -lt 100 ]]; then
         echo "  -> JS returned minimal text. Falling back to curl..."
         RAW_HTML=$(curl -s -L -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64)" "$URL")
         # Convert HTML to basic text
         RAW_TEXT=$(echo "$RAW_HTML" | sed 's/<[^>]*>/ /g')
    fi

    # 2. FILTER & SAVE
    echo "$RAW_TEXT" | \
        sed 's/[[:blank:]]\+/ /g' | \
        sed 's/^[ \t]*//;s/[ \t]*$//' | \
        sed '/^$/d' | \
        # Keywords
        grep -iE "engineer|developer|analyst|software|intern|research|devops|scientist|system|specialist|QA|quality|principal|lead|manager|architect" | \
        # Exclusions
        grep -iEv 'phd|postdoc|director|vp|legal|finance|hr business|recruiter' | \
        grep -iEv 'privacy policy|cookie|rights reserved|copyright|loading' | \
        grep -E '.{10,}' | \
        sort -u > "jobs/today/$NAME"

    COUNT=$(wc -l < "jobs/today/$NAME")
    echo "  -> FINAL: Found $COUNT roles for $NAME"

done < urls.txt