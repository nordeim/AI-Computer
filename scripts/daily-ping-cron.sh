#!/bin/bash
# Daily Ping Cron Job - Traditional Shell Script
# Uses existing infrastructure at /home/project/openclaw/

set -e

LOG_DIR="/home/project/openclaw/logs"
LOG_FILE="$LOG_DIR/daily-ping-$(date +%Y-%m-%d).log"
MESSAGE_FILE="/home/project/openclaw/daily-message.txt"

# Telegram config
TELEGRAM_TARGET="1087368827"

echo "[$(date)] Daily ping starting..."

# Fetch Bitcoin data
BTC_API_URL="https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true"
BTC_DATA=$(curl -s --max-time 30 "$BTC_API_URL" 2>/dev/null || echo '{"bitcoin":{"usd":0,"usd_24h_change":0}}')

BTC_PRICE=$(echo "$BTC_DATA" | grep -o '"usd":[0-9]*' | head -1 | cut -d: -f2)
BTC_CHANGE=$(echo "$BTC_DATA" | grep -o '"usd_24h_change":[-0-9.]*' | head -1 | cut -d: -f2)

# Round price
BTC_PRICE=$(printf "%.0f" "$BTC_PRICE" 2>/dev/null || echo "0")

# Fetch GitHub TRENDING repos (top 10, created recently with high stars)
GH_API_URL="https://api.github.com/search/repositories?q=created:>2024-01-01&sort=stars&order=desc&per_page=10"
GH_DATA=$(curl -s --max-time 30 "$GH_API_URL" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    repos = data.get('items', [])
    for i, repo in enumerate(repos[:10], 1):
        name = repo.get('name', 'Unknown')
        desc = repo.get('description', 'No description')[:50]
        stars = repo.get('stargazers_count', 0)
        # Format stars as K
        if stars >= 1000:
            stars_str = f'{stars/1000:.1f}K'
        else:
            stars_str = str(stars)
        print(f'{i}. {name} — {desc} ({stars_str} ⭐)')
except Exception as e:
    print('1. Error fetching repos')
")

# Log data
echo "[$DATE] Bitcoin: $BTC_PRICE, Change: $BTC_CHANGE%" >> "$LOG_FILE"
echo "[$DATE] GitHub Trending:" >> "$LOG_FILE"
echo "$GH_DATA" >> "$LOG_FILE"

# Fetch stock prices using yfinance via Python
STOCK_DATA=$(cd /home/project/openclaw && /opt/venv/bin/python3 << 'PYTHON_SCRIPT'
import yfinance as yf
import json

stocks = ['NVDA', 'MSFT', 'GOOGL', 'INTC', 'META', 'AMD']
results = {}

for symbol in stocks:
    try:
        ticker = yf.Ticker(symbol)
        info = ticker.info
        current = info.get('currentPrice') or info.get('regularMarketPrice', 0)
        prev = info.get('previousClose', current)
        
        if current and prev:
            change_pct = ((current - prev) / prev) * 100
            change = current - prev
        else:
            change_pct = 0
            change = 0
        
        results[symbol] = {
            'price': round(current, 2),
            'change': round(change, 2),
            'change_pct': round(change_pct, 2)
        }
    except Exception as e:
        results[symbol] = {
            'price': 0,
            'change': 0,
            'change_pct': 0,
            'error': str(e)
        }

print(json.dumps(results))
PYTHON_SCRIPT
)

echo "[$DATE] Stocks: $STOCK_DATA" >> "$LOG_FILE"

# Format the message
DATE=$(date +"%A, %B %d, %Y")

# Determine Bitcoin trend emoji
BTC_TREND="📈"
if (( $(echo "$BTC_CHANGE < 0" | bc -l 2>/dev/null || echo "0") )); then
    BTC_TREND="📉"
fi

# Format stock lines
STOCK_LINES=""
for symbol in NVDA MSFT GOOGL INTC META AMD; do
    PRICE=$(echo "$STOCK_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$symbol',{}).get('price',0))")
    CHANGE=$(echo "$STOCK_DATA" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('$symbol',{}).get('change_pct',0))")
    
    if (( $(echo "$CHANGE >= 0" | bc -l 2>/dev/null || echo "1") )); then
        TREND="📈"
    else
        TREND="📉"
    fi
    
    STOCK_LINES+="• $symbol $PRICE ($TREND $(printf "%.2f" "$CHANGE")%)"
    STOCK_LINES+=$'\n'
done

# Create formatted message
cat > "$MESSAGE_FILE" << EOF
📅 $DATE

📈 Crypto
• Bitcoin: \$$BTC_PRICE ($BTC_TREND $(printf "%.2f" "$BTC_CHANGE")%)

💹 Tech Stocks
$STOCK_LINES
⭐ Top 10 GitHub Trending Repos
$(echo "$GH_DATA")

Have a productive day! 🤝
EOF

echo "Message generated: $MESSAGE_FILE"

# Send via Telegram using message tool
# This requires the message tool to be available in the environment
if command -v message >/dev/null 2>&1; then
    message send --target "$TELEGRAM_TARGET" --channel telegram --text "$(cat $MESSAGE_FILE)"
    echo "Sent via message tool"
else
    echo "Message tool not available, message saved to $MESSAGE_FILE"
fi

echo "[$DATE] Daily ping completed successfully" >> "$LOG_FILE"
