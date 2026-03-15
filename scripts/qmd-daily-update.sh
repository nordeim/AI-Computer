#!/bin/bash
# QMD Daily Index Update
# Run via cron at 3:30am PST (after daily ingestion)

set -e

LOG_FILE="/tmp/qmd-update-$(date +%Y%m%d).log"
TELEGRAM_TOPIC="1126"  # cron-updates

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting QMD daily update..."

# Change to workspace
cd /home/pete/.openclaw/workspace

# source the python venv environment
source /opt/venv/bin/activate && pip list | grep -E 'sentence|transform|torch'

# Re-index all collections (incremental)
qmd update 2>&1 | tee -a "$LOG_FILE"

# Regenerate embeddings for new/changed files
qmd embed 2>&1 | tee -a "$LOG_FILE"

# Cleanup old cache files
qmd cleanup 2>&1 | tee -a "$LOG_FILE"

log "QMD daily update complete"
log "Status: $(qmd status 2>&1 | head -5)"
