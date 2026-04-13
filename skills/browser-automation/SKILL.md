# Browser Automation Skill

Comprehensive guide to all browser automation capabilities on this system.

Covers:
- `agent-browser` v0.25.3 (standalone CLI)
- OpenClaw built-in `browser` tool
- chrome-devtools-mcp v0.21.0
- @playwright/mcp (MCP server)
- `playwright-cli` (standalone CLI)

---

## Quick Comparison

| Tool | Type | Chrome | Best For | Vision Needed |
|------|------|--------|----------|---------------|
| **agent-browser** | Standalone CLI | v147 (managed) | Scripting, quick checks, screenshots | ❌ No |
| **OpenClaw browser** | Built-in MCP | v144 (system) | Agent-native, persistent sessions | ❌ No |
| **chrome-devtools-mcp** | MCP server | v147 (headless) | Debugging, audits, performance traces | ❌ No |
| **@playwright/mcp** | MCP server | Chromium | Accessibility-first, token-efficient | ❌ No |
| **playwright-cli** | Standalone CLI | v147 (managed) | Token-efficient automation, testing | ❌ No |

---

## agent-browser v0.25.3

**Standalone CLI tool** with managed Chrome instance.

### Installation
```bash
npm install -g agent-browser
```

### Core Commands
```bash
# Navigate
agent-browser open <url>

# Snapshot with element refs
agent-browser snapshot -i           # Interactive mode with @e1, @e2 refs

# Screenshots
agent-browser screenshot [path]
agent-browser screenshot --full
agent-browser screenshot --annotate  # With labels

# Interact
agent-browser click @e2
agent-browser fill @e3 "text"
agent-browser press Enter

# Eval
agent-browser eval "document.title"
agent-browser get title / url / text @ref

# Session management
agent-browser close                 # Stop daemon
```

### Batch & Advanced Features (v0.25.3 validated)
```bash
# Batch execution
agent-browser batch < commands.json
agent-browser batch --bail "cmd1" "cmd2" "cmd3"  # Stop on first error

# Diff/comparison
agent-browser diff snapshot
agent-browser diff screenshot --baseline
agent-browser diff url <u1> <u2>

# Video recording
agent-browser record start <path> [url]
agent-browser record stop

# Auth vault
agent-browser auth save <name>
agent-browser auth login <name>
agent-browser auth list
agent-browser auth delete <name>

# WebSocket streaming
agent-browser stream enable --port 8080
agent-browser stream status
agent-browser stream disable

# Clipboard
agent-browser clipboard read
agent-browser clipboard write "text"
agent-browser clipboard paste
```

### Debug & Profiling (v0.25.3 NEW)
```bash
# Chrome DevTools profiler
agent-browser profiler start
agent-browser profiler stop /tmp/profile.json

# Chrome DevTools trace
agent-browser trace start
agent-browser trace stop /tmp/trace.json

# Console & errors
agent-browser console
agent-browser console --clear
agent-browser errors
agent-browser errors --clear

# Debug helpers
agent-browser highlight @e3
agent-browser inspect  # Open Chrome DevTools

# HAR capture (network)
agent-browser network har start
agent-browser network har stop /tmp/requests.har

# Storage
agent-browser storage local
agent-browser storage session
```

### AI & Dashboard (v0.25.3 NEW)
```bash
# AI natural language commands
agent-browser chat "open google.com and search for cats"
agent-browser chat  # Interactive REPL mode (requires AI_GATEWAY_API_KEY)

# Observability dashboard
agent-browser dashboard start           # Default port 4848
agent-browser dashboard start --port 8080
agent-browser dashboard stop

# Session management
agent-browser session
agent-browser session list
```

### Confirmation Workflow (v0.25.3 NEW)
```bash
# Action confirmation (for sensitive operations)
agent-browser --confirm-actions "navigation,form" open https://example.com

# Pending actions require explicit approval
agent-browser confirm <action-id>
agent-browser deny <action-id>
```

### Semantic Locators
```bash
agent-browser find role button click --name "Submit"
agent-browser find label "Email" fill "user@example.com"
agent-browser find text "Sign In" click
agent-browser find testid "submit" click
```

### Config File
**~/.agent-browser/config.json**
```json
{
  "args": "--no-sandbox"
}
```
*Required on Ubuntu for AppArmor compatibility*

---

## OpenClaw Built-in Browser Tool

**Native OpenClaw browser tool.** No external dependencies.

### Profiles
| Profile | Chrome | Use Case |
|---------|--------|----------|
| `openclaw` | v144 (managed) | Default - works out of the box |
| `user` | User's Chrome | Requires DevToolsActivePort setup |
| `chrome-relay` | Extension | User clicks toolbar to connect |

### Quick Reference
```javascript
// Open page
browser open <url>                    // Default profile
browser open <url> profile="user"     // User's logged-in Chrome

// Snapshot
browser snapshot                      // Full tree
browser snapshot refs="aria"          // ARIA refs
browser snapshot compact=true

// Interact
browser act kind="click" ref="e5"
browser act kind="fill" ref="e3" text="hello"
browser act kind="press" key="Enter"
browser act kind="hover" ref="e7"

// Screenshot
browser screenshot path="/tmp/page.png"

// Close
browser close
```

### Profile="user" Setup
**Required manual step for Chrome 144:**
```bash
# 1. Launch Chrome
/usr/bin/google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile &

# 2. Create DevToolsActivePort
echo "9222" > ~/.config/google-chrome/DevToolsActivePort
echo "/devtools/browser/$(curl -s http://127.0.0.1:9222/json/version | grep -oP 'browser/\K[^"]+')" >> ~/.config/google-chrome/DevToolsActivePort
```

---

## chrome-devtools-mcp v0.21.0

**Google's official DevTools MCP server.** 29 tools for debugging.

### Installation
```bash
npm install -g chrome-devtools-mcp
mcporter config add chrome-devtools --command chrome-devtools-mcp --arg --headless
```

### Quick Start
```bash
# Navigate
mcporter call chrome-devtools.navigate_page url=https://example.com

# A11y snapshot (preferred over screenshots)
mcporter call chrome-devtools.take_snapshot

# Lighthouse audit
mcporter call chrome-devtools.lighthouse_audit

# Performance trace
mcporter call chrome-devtools.performance_start_trace
mcporter call chrome-devtools.performance_stop_trace
```

### Key Categories
| Category | Tools |
|----------|-------|
| Navigation | navigate_page, new_page, list_pages, select_page, close_page |
| Interaction | click, hover, drag, fill, type_text, press_key, upload_file |
| Inspection | evaluate_script, list_console_messages, list_network_requests |
| Performance | performance_start_trace, performance_stop_trace, analyze_insight |
| Audit | lighthouse_audit |
| Visual | take_screenshot, take_snapshot |
| Memory | take_memory_snapshot |
| Emulation | emulate, resize_page |

**UID Format:** `{snapshotIndex}_{elementIndex}` (e.g., `1_12`)
*Note: UIDs change on every DOM mutation - re-snapshot after interactions*

---

## @playwright/mcp (NEW)

**Microsoft's official Playwright MCP server.** Accessibility-first approach.

### Key Features
- 🌳 **Accessibility tree** - Uses semantic DOM structure, not pixels
- 🚫 **No vision models** - Structured data only, token-efficient
- 🎯 **Deterministic** - Clear element identification vs screenshot ambiguity
- ⚡ **Fast & lightweight** - No image processing overhead

### Requirements
- Node.js 18 or newer

### Installation
```bash
# MCP config
mcporter config add playwright --command npx --arg "@playwright/mcp@latest"
```

### Standard Config
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

### Quick Start
```bash
# Navigate and snapshot
mcporter call playwright.navigate url=https://example.com
mcporter call playwright.screenshot path=/tmp/pw.png

# Interact via accessibility tree
mcporter call playwright.click name="Submit"
mcporter call playwright.fill selector="#email" value="user@example.com"
```

### Supported Clients
- VSCode + Copilot
- Cursor
- Claude Code / Claude Desktop
- GitHub Copilot CLI
- Cline
- Gemini CLI
- Goose
- Kiro
- Opencode

---

## playwright-cli (NEW)

**Token-efficient CLI wrapper** for Playwright MCP.

### Key Features
- 🔄 **CLI interface** - Wrapper for `@playwright/mcp` providing a command-line interface
- 📦 **Token-efficient** - Accessibility tree approach, no vision models needed
- 🎯 **Same engine** - Uses the same underlying Playwright/MCP technology as @playwright/mcp

### Installation
```bash
# Install globally
npm install -g playwright-cli

# Or use via npx
npx playwright-cli <command>
```

### Core Commands
```bash
# Navigate to URL
playwright-cli open <url>

# Take screenshot
playwright-cli screenshot [path]

# Interactive mode (accessibility tree)
playwright-cli inspect <url>

# Run a script
playwright-cli run <script.ts>
```

### When to Use
- **Use `@playwright/mcp`** when you need MCP server integration (for agents, VSCode, etc.)
- **Use `playwright-cli`** when you want a simple CLI interface without MCP overhead
- Both use the same underlying Playwright engine and accessibility-first approach

See **`skills/playwright-cli/SKILL.md`** for full documentation.

---

## When to Use Which

### Scenario Quick Reference

| Scenario | Recommended Tool | Why |
|----------|------------------|-----|
| Quick CLI screenshot | agent-browser | Simple, no API overhead |
| Agent-native automation | OpenClaw browser | Persistent session, no exec |
| Performance audit | chrome-devtools-mcp | Lighthouse + traces |
| Accessibility testing | @playwright/mcp | A11y tree native |
| Debugging network issues | chrome-devtools-mcp | Full request inspection |
| Mobile/responsive testing | All three | All support emulation |
| Video recording | agent-browser | Built-in WebM capture |
| Self-healing tests | @playwright/mcp | Semantic locators |
| Visual diff/regression | agent-browser | `diff` command built-in |
| Multi-page workflows | Any MCP server | Better tab management |

### Decision Tree

```
Need visual debugging/audits? → chrome-devtools-mcp
Need pure accessibility approach? → @playwright/mcp  
Need CLI scripting? → agent-browser
Need agent-native (no exec)? → OpenClaw browser
```

---

## Common Patterns

### Pattern 1: Screenshot Comparison
```bash
# agent-browser approach
agent-browser open https://v1.example.com
agent-browser screenshot --full /tmp/baseline.png
agent-browser open https://v2.example.com
agent-browser diff screenshot --baseline /tmp/baseline.png
```

### Pattern 2: Performance Audit
```bash
# chrome-devtools-mcp approach
mcporter call chrome-devtools.navigate_page url=https://example.com
mcporter call chrome-devtools.performance_start_trace
# ... interact with page ...
mcporter call chrome-devtools.performance_stop_trace
mcporter call chrome-devtools.analyze_insight
```

### Pattern 3: Debug & Profiling (agent-browser v0.25.3)
```bash
# Profile page interactions
agent-browser open https://example.com
agent-browser profiler start
agent-browser fill @e1 "search term"
agent-browser click @e2
agent-browser profiler stop /tmp/profile.json

# Capture network traffic
agent-browser network har start
agent-browser click @e3
agent-browser network har stop /tmp/network.har

# Debug JS errors
agent-browser errors
agent-browser console
```

---

## Gotchas & Pitfalls

### agent-browser
- **Daemon persists** - `close` only stops browser, daemon keeps running
- **Refs change** - Snapshot refs invalidate after DOM changes
- **No sandbox** - Required on Ubuntu AppArmor, not security issue for local use
- **Profile path** - Default Chrome stored in `~/.agent-browser/browsers/`

### OpenClaw browser
- **Port conflict** - Default 18800 may conflict if another Chrome CDP running
- **Profile=user** - Requires manual `DevToolsActivePort` setup
- **No chrome://** - Cannot navigate to internal Chrome URLs

### General
- **Race conditions** - Add waits between actions if page is slow
- **Dynamic content** - Re-snapshot after AJAX loads
- **Mobile emulation** - Some CSS may differ from real device

---

## Diagnostic Commands

```bash
# Check if agent-browser daemon is running
pgrep -f "agent-browser" || echo "daemon not running"

# Check Chrome processes
ps aux | grep chrome | grep -v grep

# Check listening ports
ss -tlnp | grep chrome

# Check CDP endpoint
curl -s http://127.0.0.1:18800/json/version  # OpenClaw Chrome
curl -s http://127.0.0.1:9222/json/version   # User Chrome (if running)

# Check DevToolsActivePort
cat ~/.config/google-chrome/DevToolsActivePort

# Restart agent-browser daemon
agent-browser close
agent-browser open https://example.com
```

---

## E2E Testing Pattern (Hybrid API + UI)

For automated testing, don't rely on browser auth. Use the hybrid pattern:

```python
# 1. Authenticate via API (not browser)
tokens = await api_login()

# 2. Create test data via API
headers = {"Authorization": f"Bearer {tokens['access']}"}
await api_post("/invoices/", data, headers)

# 3. Use browser only for visual verification
agent-browser open http://localhost:3000/dashboard
agent-browser screenshot /tmp/dashboard.png
```

**Why:** HttpOnly cookies and JWT tokens in JS memory break browser automation. API auth is reliable.

---

## Skill Metadata

- **Created:** 2026-03-14
- **Last updated:** 2026-04-12
- **agent-browser:** v0.25.3 / Chrome 147
- **OpenClaw browser:** Chrome 144 / port 18800
- **chrome-devtools-mcp:** v0.21.0 / Chrome 147 headless
- **System:** Ubuntu (KDE neon), AppArmor active