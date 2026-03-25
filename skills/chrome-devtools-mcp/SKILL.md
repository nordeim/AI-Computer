---
name: chrome-devtools-mcp
description: Full Chrome DevTools access via MCP — Lighthouse audits, performance traces, network inspection, a11y snapshots, JS evaluation, mobile emulation, and multi-page management. Use for web debugging, performance analysis, accessibility auditing, and browser automation beyond basic navigation/screenshots.
metadata:
  openclaw:
    emoji: "🔧"
    requires:
      bins:
        - chrome-devtools-mcp
        - mcporter
---

# chrome-devtools-mcp

Google-official MCP server providing full Chrome DevTools Protocol access to AI agents. 29 tools covering navigation, interaction, debugging, network inspection, performance tracing, Lighthouse audits, memory snapshots, and device emulation.

**Installed at:** `/usr/bin/chrome-devtools` (symlink to chrome-devtools-mcp)  
**Transport:** stdio via mcporter  
**Mode:** headless (configured for server use)

---

## Version Info

| Component | Version | Notes |
|-----------|---------|-------|
| chrome-devtools-mcp | 0.20.3 | CLI wrapper |
| Chrome (headless) | 147.0.7727.24 | Updated Mar 26 2026 |
| Transport | mcporter stdio | — |

---

## When to Use

| Scenario | Use chrome-devtools-mcp | Use built-in browser tool |
|----------|------------------------|---------------------------|
| Quick screenshot or snapshot | optional | ✅ preferred |
| Lighthouse audit (a11y/SEO/best-practices) | ✅ only option | — |
| Performance trace (LCP, CLS, INP) | ✅ only option | — |
| Network request inspection | ✅ only option | — |
| Console log access | ✅ only option | — |
| JavaScript evaluation on page | ✅ | ✅ |
| Mobile/responsive emulation | ✅ better | basic |
| Multi-page tab management | ✅ better | ✅ |
| Memory heap snapshots | ✅ only option | — |
| Form filling with a11y tree refs | ✅ better | ✅ |
| Quick navigation + screenshot | ✅ | ✅ preferred |

**Rule of thumb:** Use built-in browser tool for simple open/screenshot/snapshot. Use chrome-devtools-mcp when you need DevTools-grade debugging, auditing, or inspection.

---

## Quick Start

### Via mcporter (recommended for agent use)

```bash
# Navigate
mcporter call chrome-devtools.navigate_page url=https://example.com

# Take a11y tree snapshot (preferred over screenshots for interaction)
mcporter call chrome-devtools.take_snapshot

# Take screenshot
mcporter call chrome-devtools.take_screenshot filePath=/tmp/page.png

# Lighthouse audit
mcporter call chrome-devtools.lighthouse_audit

# Performance trace
mcporter call chrome-devtools.performance_start_trace
mcporter call chrome-devtools.performance_stop_trace
```

### Via CLI wrapper

```bash
chrome-devtools navigate_page --url https://example.com
chrome-devtools take_snapshot
chrome-devtools take_screenshot --filePath /tmp/page.png
chrome-devtools lighthouse_audit
```

---

## Tool Reference (29 Tools)

### Navigation (5 tools)

| Tool | Key Args | Description |
|------|----------|-------------|
| `navigate_page` | `url`, `type` (navigate/back/forward/reload), `ignoreCache`, `timeout` | Go to URL or navigate history |
| `new_page` | `url`, `background`, `isolatedContext` | Open new tab |
| `list_pages` | — | List all open tabs |
| `select_page` | `pageId`, `bringToFront` | Switch context to a tab |
| `close_page` | `pageId` | Close a tab (last tab cannot close) |

### Interaction (8 tools)

Always call `take_snapshot` first to get current UIDs. UIDs are ephemeral — they change on every snapshot.

| Tool | Key Args | Description |
|------|----------|-------------|
| `click` | `uid`, `dblClick`, `includeSnapshot` | Click element by UID |
| `hover` | `uid`, `includeSnapshot` | Hover over element |
| `drag` | `from_uid`, `to_uid`, `includeSnapshot` | Drag element onto another |
| `fill` | `uid`, `value`, `includeSnapshot` | Type into input / select option |
| `fill_form` | `elements` (JSON array), `includeSnapshot` | Fill multiple form fields at once |
| `type_text` | `text`, `submitKey` | Type into focused input |
| `press_key` | `key`, `includeSnapshot` | Press keyboard key/combo |
| `upload_file` | `uid`, `filePath`, `includeSnapshot` | Upload file via file input |

### Inspection & Debugging (5 tools)

| Tool | Key Args | Description |
|------|----------|-------------|
| `evaluate_script` | `function` (JS function as string), `args` | Execute JS in page context, returns JSON |
| `list_console_messages` | `pageSize`, `pageIdx`, `types` | List console logs (error/warning/info/log) |
| `get_console_message` | `msgid` | Get specific console message |
| `list_network_requests` | `pageSize`, `pageIdx`, `resourceTypes` | List network requests with status/timing |
| `get_network_request` | `reqid` | Get full request/response headers and body |

### Performance (3 tools)

| Tool | Key Args | Description |
|------|----------|-------------|
| `performance_start_trace` | `reload`, `autoStop`, `filePath` | Start recording performance trace |
| `performance_stop_trace` | `filePath` | Stop trace and get analysis (LCP, CLS, INP, insights) |
| `performance_analyze_insight` | `insightSetId`, `insightName` | Deep-dive into specific insight |

### Audit (1 tool)

| Tool | Key Args | Description |
|------|----------|-------------|
| `lighthouse_audit` | `mode` (navigation), `device` (desktop/mobile), `outputDirPath` | Run Lighthouse: Accessibility, Best Practices, SEO scores + report files |

### Memory (1 tool)

| Tool | Key Args | Description |
|------|----------|-------------|
| `take_memory_snapshot` | `filePath` | Capture heap snapshot for memory leak debugging |

### Visual (3 tools)

| Tool | Key Args | Description |
|------|----------|-------------|
| `take_screenshot` | `format` (png/jpeg), `quality`, `fullPage`, `uid`, `filePath` | Screenshot viewport, full page, or specific element |
| `take_snapshot` | `verbose`, `filePath` | A11y tree snapshot with UIDs (preferred for interaction) |
| `wait_for` | `text` (array of strings), `timeout` | Wait for text to appear on page |

### Emulation (2 tools)

| Tool | Key Args | Description |
|------|----------|-------------|
| `emulate` | `viewport`, `networkConditions`, `cpuThrottlingRate`, `colorScheme`, `userAgent` | Emulate device/network/conditions |
| `resize_page` | `width`, `height` | Resize viewport |

### Dialog (1 tool)

| Tool | Key Args | Description |
|------|----------|-------------|
| `handle_dialog` | `action` (accept/dismiss), `promptText` | Handle browser dialogs (alert/confirm/prompt) |

---

## Usage Patterns

### Pattern 1: Lighthouse Audit + Performance Analysis

```bash
# 1. Navigate to target
mcporter call chrome-devtools.navigate_page url=https://www.example.com

# 2. Run Lighthouse audit
mcporter call chrome-devtools.lighthouse_audit

# 3. Start performance trace with page reload
mcporter call chrome-devtools.performance_start_trace reload=true

# 4. Stop trace and analyze
mcporter call chrome-devtools.performance_stop_trace

# 5. Deep-dive into specific insight
mcporter call chrome-devtools.performance_analyze_insight \
  --args '{"insightSetId": "NAVIGATION_0", "insightName": "LCPBreakdown"}'
```

**Example output:**
- Lighthouse: A11y 89, Best Practices 100, SEO 92
- Performance: LCP 258ms, CLS 0.00, TTFB 5ms
- Insights: LCPBreakdown, CLSCulprits, NetworkDependencyTree, ThirdParties, Cache

### Pattern 2: A11y Tree Snapshots for Interaction

```bash
# 1. Take snapshot to get UIDs
mcporter call chrome-devtools.take_snapshot
# Returns: uid=1_12 button "Explore SCP Fundamentals"

# 2. Click by UID
mcporter call chrome-devtools.click uid=1_12

# 3. Take new snapshot (UIDs change after DOM mutation)
mcporter call chrome-devtools.take_snapshot

# 4. Fill form by UID
mcporter call chrome-devtools.fill uid=1_45 value="user@example.com"
```

**UID format:** `{snapshotIndex}_{elementIndex}` (e.g., `1_12`, `1_207`)

**Key rule:** UIDs are valid only until the next DOM mutation. Always re-snapshot after navigation or interaction.

### Pattern 3: Network Request Inspection

```bash
# 1. List all requests
mcporter call chrome-devtools.list_network_requests
# Returns: reqid=29 GET https://example.com/assets/index.js [200]

# 2. Get detailed request info (headers, body, timing)
mcporter call chrome-devtools.get_network_request reqid=29

# 3. Filter by resource type
mcporter call chrome-devtools.list_network_requests --args '{"resourceTypes": ["xhr", "fetch"]}'
```

### Pattern 4: JavaScript Evaluation

```bash
# Return structured data from page
mcporter call chrome-devtools.evaluate_script \
  --args '{"function": "() => JSON.stringify({title: document.title, url: location.href, links: document.querySelectorAll(\"a\").length})"}'

# Modify page state
mcporter call chrome-devtools.evaluate_script \
  --args '{"function": "() => { document.body.style.backgroundColor = \"#000\"; return \"done\" }"}'
```

**Function format:** Must be a string containing a valid JS function. Arrow functions work: `() => ...`

**Return value:** Must be JSON-serializable. Wrap complex returns in `JSON.stringify()`.

### Pattern 5: Mobile/Responsive Testing

```bash
# Emulate iPhone 12
mcporter call chrome-devtools.emulate viewport="393x852x3,mobile,touch"

# Screenshot mobile view
mcporter call chrome-devtools.take_screenshot filePath=/tmp/mobile.png

# Emulate slow 3G + mid-range CPU
mcporter call chrome-devtools.emulate networkConditions="Slow3G" cpuThrottlingRate=4

# Reset emulation
mcporter call chrome-devtools.emulate viewport=""
```

**Viewport format:** `WxHxDPR[,mobile][,touch][,landscape]`

**Network conditions:** `offline`, `Slow3G`, `Fast3G`, `Slow4G`, `Fast4G`

### Pattern 6: Console Log Debugging

```bash
# List all console messages
mcporter call chrome-devtools.list_console_messages

# Filter errors only
mcporter call chrome-devtools.list_console_messages --args '{"types": ["error"]}'

# Get specific message by ID
mcporter call chrome-devtools.get_console_message msgid=<id_from_list>
```

### Pattern 7: Multi-Page Workflow

```bash
# Open background tab
mcporter call chrome-devtools.new_page url=https://docs.example.com background=true

# List all pages
mcporter call chrome-devtools.list_pages

# Switch to page 2
mcporter call chrome-devtools.select_page pageId=2

# Work in page 2 context...
mcporter call chrome-devtools.take_snapshot

# Close page 2
mcporter call chrome-devtools.close_page pageId=2
```

---

## Configuration

### Current mcporter config

```json
// ~/.mcporter/mcporter.json
{
  "servers": {
    "chrome-devtools": {
      "transport": "stdio",
      "command": "chrome-devtools-mcp",
      "args": ["--headless", "--no-usage-statistics", "--no-performance-crux"]
    }
  }
}
```

### Mode Options

| Flag | Purpose |
|------|---------|
| `--headless` | Run Chrome in headless mode (no GUI) — required for servers |
| `--no-usage-statistics` | Disable anonymous usage telemetry |
| `--no-performance-crux` | Disable CrUX field data fetching (faster audits) |
| `--browserUrl <url>` | Connect to existing Chrome instance instead of launching new one |
| `--slim` | Only 3 tools: navigate, snapshot, screenshot (minimal footprint) |
| `--isolated` | Run in isolated mode (separate profile) |

### Connecting to Existing Chrome

To use your logged-in Chrome session:

```bash
# 1. Launch Chrome with remote debugging
google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-devtools-profile

# 2. Update mcporter config to connect
mcporter config remove chrome-devtools
mcporter config add chrome-devtools --command chrome-devtools-mcp \
  --arg --browserUrl=http://127.0.0.1:9222 \
  --arg --no-usage-statistics --arg --no-performance-crux
```

---

## Practical Example: Auditing a Website

```bash
# Navigate
mcporter call chrome-devtools.navigate_page url=https://www.itrust.academy/
# → "Successfully navigated. Pages: 1: https://www.itrust.academy/ [selected]"

# Get page structure via a11y snapshot
mcporter call chrome-devtools.take_snapshot
# → Returns 208 elements with UIDs

# Lighthouse audit
mcporter call chrome-devtools.lighthouse_audit
# → Accessibility: 89, Best Practices: 100, SEO: 92

# Performance trace
mcporter call chrome-devtools.performance_start_trace
mcporter call chrome-devtools.performance_stop_trace
# → LCP: 258ms, TTFB: 5ms, CLS: 0.00

# Check network requests
mcporter call chrome-devtools.list_network_requests
# → 13 requests: HTML, JS bundle, Cloudflare beacon, Google Fonts

# JS evaluation
mcporter call chrome-devtools.evaluate_script \
  --args '{"function": "() => JSON.stringify({title: document.title, links: document.querySelectorAll(\"a\").length})"}'
# → {"title":"iTrust Academy | IT Training & Certification Across Asia","links":12}

# Mobile emulation
mcporter call chrome-devtools.emulate viewport="375x812x2,mobile,touch"
mcporter call chrome-devtools.take_screenshot filePath=/tmp/itrust-mobile.png
```

---

## Limitations & Gotchas

1. **Stateless UIDs:** Element UIDs from `take_snapshot` are invalidated by any DOM mutation. Always re-snapshot after clicks, navigation, or form fills.

2. **evaluate_script format:** The `function` parameter must be a **string** containing the function definition.
   ```bash
   # ✅ Correct
   mcporter call chrome-devtools.evaluate_script \
     --args '{"function": "() => document.title"}'
   
   # ❌ Wrong (inline arg parsing fails)
   mcporter call chrome-devtools.evaluate_script 'function() { return document.title }'
   ```

3. **Performance traces are per-navigation:** Each `performance_start_trace`/`stop_trace` pair captures one navigation. Use the `insightSetId` (e.g., `NAVIGATION_0`) to drill into specific insights.

4. **Lighthouse is slow:** Expect 5-15 seconds per audit. `--no-performance-crux` skips CrUX field data to speed things up.

5. **Single browser instance:** All pages share one Chrome instance. Emulation settings (viewport, network throttling) apply globally until reset.

6. **Headless limitations:** Some sites detect headless Chrome and serve different content. Use `--browserUrl` to connect to a real Chrome instance if needed.

7. **Memory snapshots are large:** `take_memory_snapshot` generates multi-MB heap dump files. Use `filePath` to control location.

8. **Chrome version:** v147 headless active. Some sites may behave differently than headed Chrome.

---

## vs. Built-in OpenClaw Browser Tool

| Feature | chrome-devtools-mcp | OpenClaw browser tool |
|---------|--------------------|-----------------------|
| Navigation | ✅ | ✅ |
| Screenshots | ✅ | ✅ |
| A11y snapshots | ✅ (detailed, with UIDs) | ✅ (ARIA refs) |
| Click/type/fill | ✅ (by UID) | ✅ (by ARIA ref) |
| Lighthouse audit | ✅ | ❌ |
| Performance traces | ✅ | ❌ |
| Network inspection | ✅ | ❌ |
| Console access | ✅ | ❌ |
| JS evaluation | ✅ | ✅ |
| Mobile emulation | ✅ (full device profiles) | basic |
| Multi-profile | ❌ (single instance) | ✅ (openclaw/user/relay) |
| Authenticated sites | via `--browserUrl` | via `profile="user"` |
| Speed | Slower (stdio spawn) | Faster (persistent session) |

**Recommendation:** Use OpenClaw browser tool for routine automation (open, snapshot, click, screenshot). Use chrome-devtools-mcp when you need DevTools capabilities (auditing, debugging, performance analysis).

---

## Installation (Reference)

```bash
# Already installed. Reinstall if needed:
npm install -g chrome-devtools-mcp

# Verify
chrome-devtools --version
which chrome-devtools
# → /usr/bin/chrome-devtools

# mcporter config (already configured)
mcporter config add chrome-devtools --command chrome-devtools-mcp \
  --arg --headless --arg --no-usage-statistics --arg --no-performance-crux
```

---

## Key Files

| Path | Purpose |
|------|---------|
| `/usr/bin/chrome-devtools` | CLI wrapper symlink |
| `~/.mcporter/mcporter.json` | mcporter server config |
| `/tmp/chrome-devtools-mcp-*/` | Lighthouse report output directory |

---

## Verification Report (2026-03-26)

### Chrome Upgraded

| Component | Before | After |
|-----------|--------|-------|
| chrome-devtools-mcp | 0.20.3 | 0.20.3 (unchanged) |
| Chrome headless | 146.x | **147.0.7727.24** |

### All 29 Tools Verified

| Category | Tools | Status |
|----------|-------|--------|
| Navigation | navigate_page, new_page, list_pages, select_page, close_page | ✅ |
| Interaction | click, hover, drag, fill, fill_form, type_text, press_key, upload_file | ✅ |
| Inspection | evaluate_script, list_console_messages, get_console_message, list_network_requests, get_network_request | ✅ |
| Performance | performance_start_trace, performance_stop_trace, performance_analyze_insight | ✅ |
| Audit | lighthouse_audit | ✅ |
| Memory | take_memory_snapshot | ✅ |
| Visual | take_screenshot, take_snapshot, wait_for | ✅ |
| Emulation | emulate, resize_page | ✅ |
| Dialog | handle_dialog | ✅ |

### Test Results (example.com)

- Lighthouse: A11y 96, Best Practices 96, SEO 80
- Performance: LCP 124ms, TTFB 20ms, CLS 0.00
- Network: 1 request captured (GET example.com [200])

---

*Skill created: 2026-03-16 | Last validated: 2026-03-26 | chrome-devtools-mcp v0.20.3 with Chrome 147.0.7727.24 headless*
