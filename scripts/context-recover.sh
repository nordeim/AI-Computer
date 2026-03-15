#!/bin/bash
#
# context-recover.sh — Unified Context Recovery
# Combines context-anchor speed with QMD semantic depth
#
# Usage:
#   context-recover.sh              # Standard recovery (anchor only, <100ms)
#   context-recover.sh --semantic   # Deep recovery (anchor + QMD, ~5s)
#   context-recover.sh --quick      # Fast mode (anchor only, skip QMD)
#

set -e

WORKSPACE="${WORKSPACE:-$HOME/.openclaw/workspace}"
QUICK_MODE=false
SEMANTIC_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)    QUICK_MODE=true; shift ;;
        --semantic) SEMANTIC_MODE=true; shift ;;
        --help)     echo "Usage: context-recover.sh [--quick|--semantic]"; exit 0 ;;
        *)          shift ;;
    esac
done

echo "═══════════════════════════════════════════════════════════"
echo " CONTEXT RECOVERY — Unified Memory Architecture"
echo "═══════════════════════════════════════════════════════════"
echo ""

# TIER 1: Fast bootstrap via context-anchor (always runs)
echo "⚡ TIER 1: Fast anchor recovery..."
if [ -f "$WORKSPACE/skills/context-anchor/scripts/anchor.sh" ]; then
    "$WORKSPACE/skills/context-anchor/scripts/anchor.sh" \
        ${QUICK_MODE:+--quick} \
        ${SEMANTIC_MODE:+--semantic} 2>/dev/null || echo "Anchor completed with warnings"
else
    echo "⚠️  anchor.sh not found — skipping"
fi

# TIER 2: Semantic expansion via QMD (optional)
if [ "$QUICK_MODE" = false ] && [ "$SEMANTIC_MODE" = true ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════"
    echo "🧠 TIER 2: QMD semantic expansion..."
    echo "═══════════════════════════════════════════════════════════"
    echo ""
    
    if command -v qmd >/dev/null 2>&1; then
        echo "Querying daily collection for recent context..."
        qmd query "current task blocker decision" -c daily --limit 3 2>/dev/null | head -20 || echo "QMD query completed"
    else
        echo "⚠️  QMD not available — skipping semantic expansion"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ Context recovery complete"
echo "═══════════════════════════════════════════════════════════"
