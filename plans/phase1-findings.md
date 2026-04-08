# Phase 1: Feature Discovery Findings

**Started:** 2026-04-07 10:15 SGT
**Status:** IN PROGRESS

---

## 1. Agent-Browser v0.24.1 Analysis

### Version Status
| Source | Version | Status |
|--------|---------|--------|
| Installed CLI | v0.24.1 | ✅ Current |
| browser-automation skill | v0.24.0 | ⚠️ Minor update needed |
| chrome-devtools-mcp skill | Not referenced | — |

### Commands Discovered (Full Help Output)

**Core Commands (Navigation & Interaction):**
- `open <url>` - Navigate
- `click <sel>`, `dblclick <sel>` - Click elements
- `type <sel> <text>`, `fill <sel> <text>` - Text input
- `press <key>`, `keyboard type/inserttext` - Keyboard
- `hover <sel>`, `focus <sel>` - Focus management
- `check <sel>`, `uncheck <sel>`, `select <sel> <val>` - Form controls
- `drag <src> <dst>`, `upload <sel> <files>`, `download <sel> <path>` - Advanced interaction
- `scroll <dir> [px]`, `scrollintoview <sel>` - Scroll control
- `wait <sel|ms>` - Wait utility

**Screenshots & Visual:**
- `screenshot [path]` - Basic screenshot
- `pdf <path>` - Save as PDF
- `snapshot` - Accessibility tree with refs
- `eval <js>` - JavaScript execution

**Navigation:**
- `back`, `forward`, `reload`

**Get Info:**
- `agent-browser get <what> [selector]` - text, html, value, attr, title, url, count, box, styles, cdp-url

**Check State:**
- `agent-browser is <what> <selector>` - visible, enabled, checked

**Find Elements:**
- `agent-browser find <locator> <value> <action> [text]` - role, text, label, placeholder, alt, title, testid, first, last, nth

**Mouse:**
- `agent-browser mouse <action> [args]` - move, down, up, wheel

**Browser Settings:**
- `agent-browser set <setting> [value]` - viewport, device, geo, offline, headers, credentials, media

**Network:**
- `agent-browser network <action>` - route, unroute, requests, har
- `har start|stop [path]` - HAR file capture

**Storage:**
- `cookies [get|set|clear]` - Cookie management (full attributes support)
- `storage <local|session>` - Web storage

**Tabs:**
- `tab [new|list|close|<n>]` - Tab management

**Diff:**
- `diff snapshot` - Compare snapshots
- `diff screenshot --baseline` - Visual regression
- `diff url <u1> <u2>` - Compare pages

**Debug:**
- `trace start|stop [path]` - Chrome DevTools trace
- `profiler start|stop [path]` - Chrome profiler
- `record start <path> [url]` / `record stop` - Video recording (WebM)
- `console [--clear]`, `errors [--clear]` - Console/errors
- `highlight <sel>`, `inspect` - Debug helpers
- `clipboard <op> [text]` - read, write, copy, paste

**Streaming:**
- `stream enable [--port <n>]` - WebSocket streaming
- `stream disable`, `stream status`

**Batch:**
- `batch [--bail] ["cmd" ...]` - Sequential execution

**Auth Vault:**
- `auth save <name> [opts]` - Save auth profile
- `auth login <name>` - Login with saved creds
- `auth list`, `auth show <name>`, `auth delete <name>`

**Confirmation:**
- `confirm <id>`, `deny <id>` - Approve/deny pending actions

**Sessions:**
- `session`, `session list`

**Chat (AI):**
- `chat <message>` - Single-shot natural language
- `chat` - Interactive REPL

**Dashboard:**
- `dashboard [start]`, `dashboard start --port <n>`, `dashboard stop`

**Setup:**
- `install`, `install --with-deps`, `upgrade`, `dashboard start`, `profiles`

### Comparison: Documented vs Actual

| Feature | Skill Documents | Actual Status |
|---------|-----------------|---------------|
| Version | v0.24.0 | ✅ v0.24.1 (minor bump) |
| Basic commands | ✅ Covered | ✅ Verified |
| `diff` commands | ✅ Listed | ✅ Verified |
| `record` (video) | ✅ Listed | ✅ Verified |
| `auth` vault | ✅ Listed | ✅ Verified |
| `stream` | ✅ Listed | ✅ Verified |
| `clipboard` | ✅ Listed | ✅ Verified |
| `batch` | ✅ Listed | ✅ Verified |
| `network har` | ⚠️ Not detailed | ✅ Available |
| `profiler` | ❌ Not documented | ⚠️ **NEW - needs docs** |
| `trace` | ❌ Not documented | ⚠️ **NEW - needs docs** |
| `chat` (AI) | ❌ Not documented | ⚠️ **NEW - needs docs** |
| `dashboard` | ❌ Not documented | ⚠️ **NEW - needs docs** |
| `session` | ❌ Not documented | ⚠️ **NEW - needs docs** |
| `confirm/deny` | ❌ Not documented | ⚠️ **NEW - needs docs** |
| `cookies` full attributes | ⚠️ Basic only | ✅ Full support (--url, --domain, --path, --httpOnly, --secure, --sameSite, --expires) |

### New Features Since v0.24.0 (Need Documentation)

1. **`profiler start|stop [path]`** - Chrome DevTools profiler recording
2. **`trace start|stop [path]`** - Chrome DevTools trace recording
3. **`chat <message>`** - AI-powered natural language commands
4. **`dashboard [start]`** - Observability dashboard server (port 4848)
5. **`session` / `session list`** - Session management
6. **`confirm/deny <id>`** - Action confirmation workflow
7. **Cookies full attributes** - Now supports --url, --domain, --path, --httpOnly, --secure, --sameSite, --expires

---

## 2. Chrome-DevTools-MCP v0.21.0 Analysis

### Version Status
| Source | Version | Status |
|--------|---------|--------|
| Installed (via mcporter) | v0.21.0 | ✅ Current |
| chrome-devtools-mcp skill | v0.20.3 | ⚠️ **OUTDATED - needs update** |
| browser-automation skill | v0.21.0 | ✅ Correct |

### Tools Discovered (29 tools via mcporter)

**Navigation (5):**
1. `navigate_page` - type, url, ignoreCache, handleBeforeUnload, initScript, timeout
2. `new_page` - url, background, isolatedContext, timeout
3. `list_pages`
4. `select_page` - pageId, bringToFront
5. `close_page` - pageId

**Interaction (8):**
6. `click` - uid, dblClick, includeSnapshot
7. `hover` - uid, includeSnapshot
8. `drag` - from_uid, to_uid, includeSnapshot
9. `fill` - uid, value, includeSnapshot
10. `fill_form` - elements, includeSnapshot
11. `type_text` - text, submitKey
12. `press_key` - key, includeSnapshot
13. `upload_file` - uid, filePath, includeSnapshot

**Inspection (5):**
14. `evaluate_script` - function, args
15. `list_console_messages` - pageSize, pageIdx, types, includePreservedMessages
16. `get_console_message` - msgid
17. `list_network_requests` - pageSize, pageIdx, resourceTypes, includePreservedRequests
18. `get_network_request` - reqid, requestFilePath, responseFilePath

**Performance (3):**
19. `performance_start_trace` - reload, autoStop, filePath
20. `performance_stop_trace` - filePath
21. `performance_analyze_insight` - insightSetId, insightName

**Audit (1):**
22. `lighthouse_audit` - mode, device, outputDirPath

**Memory (1):**
23. `take_memory_snapshot` - filePath

**Visual (3):**
24. `take_screenshot` - format, quality, uid, fullPage, filePath
25. `take_snapshot` - verbose, filePath
26. `wait_for` - text, timeout

**Emulation (2):**
27. `emulate` - networkConditions, cpuThrottlingRate, geolocation, userAgent, colorScheme, viewport
28. `resize_page` - width, height

**Dialog (1):**
29. `handle_dialog` - action, promptText

### Comparison: Documented vs Actual

| Feature | Skill Documents (v0.20.3) | Actual (v0.21.0) |
|---------|---------------------------|------------------|
| Tool count | 29 | 29 ✅ Same |
| All tool names | ✅ Match | ✅ Verified |
| Chrome version | 147.0.7727.24 | Need to verify |
| Version number | v0.20.3 | ⚠️ **Update to v0.21.0** |

**Note:** The tool list appears identical between v0.20.3 and v0.21.0. The version bump may be internal fixes or minor improvements not affecting the tool interface.

---

## 3. Cross-Skill Consistency Check

| Skill | agent-browser version | chrome-devtools version | Chrome version |
|-------|----------------------|------------------------|----------------|
| browser-automation | v0.24.0 ⚠️ | v0.21.0 ✅ | v147 |
| chrome-devtools-mcp | — | v0.20.3 ⚠️ | v147 |
| frontend-ui-testing-journey | TBD | TBD | TBD |
| webapp-testing-journey | TBD | TBD | TBD |

---

## 4. Key Findings Summary

### Agent-Browser Updates Needed:
1. Version: v0.24.0 → v0.24.1
2. Add: `profiler` command documentation
3. Add: `trace` command documentation
4. Add: `chat` AI command documentation
5. Add: `dashboard` observability feature
6. Add: `session` management
7. Add: `confirm/deny` action workflow
8. Expand: `cookies` full attribute support

### Chrome-DevTools-MCP Updates Needed:
1. Version: v0.20.3 → v0.21.0 (chrome-devtools-mcp/SKILL.md)
2. Verify: Chrome version still 147.0.7727.24

### Both Skills:
1. Consistency: Ensure version numbers match across all 5 skills

---

## 5. Next Steps (Phase 2)

- [ ] Live test agent-browser commands (especially new ones)
- [ ] Live test chrome-devtools-mcp tools
- [ ] Verify Chrome version via `chrome --version`
- [ ] Test integration between tools
