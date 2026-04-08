# Browser Automation Skills Review & Validation Plan

**Created:** 2026-04-06
**Updated:** 2026-04-07
**Scope:** 5 skills under `/home/pete/.openclaw/workspace/skills/`

---

## Executive Summary

User upgraded `agent-browser` and `chrome-devtools-mcp` to latest versions. Need to discover new features, test them, and update 5 skills to be comprehensive and accurate.

**Current State:**
| Tool | Current Version | Skill Ref | Status |
|------|-----------------|-----------|--------|
| agent-browser | v0.24.1 | v0.24.0 mentioned | ✅ Minor bump |
| chrome-devtools-mcp | v0.21.0 | v0.20.3 documented | ⚠️ Outdated in skill |
| Chrome | v147.0.7727.24 | v147 noted | ✅ Current |

---

## Phase 1: Feature Discovery (Est. 30 min)

### 1.1 Agent-Browser v0.24.1 Feature Discovery
**Goal:** Identify new features since v0.24.0

**Actions:**
- [ ] Check `agent-browser --help` for new commands (already done - saw full output)
- [ ] Diff help output against documented commands in SKILL.md
- [ ] Check for undocumented features (try `--experimental` flags, new subcommands)
- [ ] Review changelogs if available

**Expected New Features to Verify:**
- `agent-browser auth` vault commands (save/login/list/show/delete)
- `agent-browser clipboard` operations (read/write/copy/paste)
- `agent-browser stream` WebSocket streaming
- `agent-browser batch` JSON batch execution
- `agent-browser profiler` Chrome DevTools profiler
- `agent-browser network har` HAR file capture
- `agent-browser cookies` with full cookie attributes
- `agent-browser tab` tab management
- `agent-browser diff` visual regression

### 1.2 Chrome-DevTools-MCP v0.21.0 Feature Discovery
**Goal:** Identify new tools/capabilities since v0.20.3

**Actions:**
- [ ] List all available tools via mcporter
- [ ] Compare against 29 tools documented in SKILL.md
- [ ] Note any new emulation, inspection, or performance tools

**Known Tools to Verify (29 documented):**
| Category | Tools |
|----------|-------|
| Navigation | navigate_page, new_page, list_pages, select_page, close_page (5) |
| Interaction | click, hover, drag, fill, fill_form, type_text, press_key, upload_file (8) |
| Inspection | evaluate_script, list_console_messages, get_console_message, list_network_requests, get_network_request (5) |
| Performance | performance_start_trace, performance_stop_trace, performance_analyze_insight (3) |
| Audit | lighthouse_audit (1) |
| Memory | take_memory_snapshot (1) |
| Visual | take_screenshot, take_snapshot, wait_for (3) |
| Emulation | emulate, resize_page (2) |
| Dialog | handle_dialog (1) |

---

## Phase 2: Live Testing & Validation (Est. 60 min)

### 2.1 Test Environment Setup
**Goal:** Ensure all tools work in current environment

**Actions:**
- [ ] Verify agent-browser connects to Chrome v147
- [ ] Verify chrome-devtools-mcp launches via mcporter
- [ ] Verify OpenClaw built-in browser works
- [ ] Create test target (simple HTML page or use example.com)

### 2.2 Agent-Browser Feature Testing
**Goal:** Validate all documented features work

**Test Cases:**
| Feature | Test Command | Expected Result |
|---------|--------------|-----------------|
| Basic navigation | `agent-browser open https://example.com` | Page loads |
| Snapshot with refs | `agent-browser snapshot -i` | Shows @e1, @e2 refs |
| Click interaction | `agent-browser click @e1` | Element clicked |
| Screenshot | `agent-browser screenshot /tmp/test.png` | PNG created |
| Annotated screenshot | `agent-browser screenshot --annotate /tmp/test.png` | PNG with labels |
| Video recording | `agent-browser record start /tmp/test.webm && sleep 2 && agent-browser record stop` | WebM created |
| Visual diff | `agent-browser diff snapshot` | Comparison output |
| Network HAR | `agent-browser network har start /tmp/test.har && agent-browser network har stop` | HAR file created |
| Auth vault | `agent-browser auth save test --url https://example.com` | Saved successfully |
| Batch execution | `echo '[["open", "https://example.com"], ["screenshot", "/tmp/batch.png"]]' \| agent-browser batch` | Executes |
| JS eval | `agent-browser eval "document.title"` | Returns title |
| Mobile emulation | `agent-browser set device "iPhone 12"` | Viewport set |

### 2.3 Chrome-DevTools-MCP Feature Testing
**Goal:** Validate all 29 tools work

**Test Cases:**
| Tool | Test | Expected Result |
|------|------|-----------------|
| navigate_page | Navigate to example.com | Success |
| take_snapshot | Get accessibility tree | List of elements with UIDs |
| click | Click element by UID | Element clicked, new snapshot needed |
| fill | Fill form field | Value entered |
| lighthouse_audit | Run audit | A11y/Best Practices/SEO scores |
| performance_start/stop_trace | Run trace | Performance metrics |
| list_network_requests | List XHR | Network activity |
| emulate | Mobile viewport | Emulated device |

### 2.4 OpenClaw Built-in Browser Testing
**Goal:** Validate built-in tool works

**Test Cases:**
- [ ] `browser open https://example.com`
- [ ] `browser snapshot --profile openclaw`
- [ ] `browser act kind=click ref=e1`
- [ ] `browser screenshot path=/tmp/test.png`

---

## Phase 3: Skill File Analysis (Est. 30 min)

### 3.1 Review Each Skill Against Findings

**Skills to Review:**
1. `browser-automation/SKILL.md` (7684 bytes, dated Apr 4)
2. `chrome-devtools-mcp/SKILL.md` (17129 bytes, dated Mar 26)
3. `frontend-ui-testing-journey/SKILL.md` (24232 bytes, dated Apr 4)
4. `webapp-testing-journey/SKILL.md` (20470 bytes, dated Apr 4)
5. `e2e-testing-lessons/SKILL.md` (6334 bytes, dated Mar 14)

### 3.2 Identify Required Updates

**For each skill, check:**
- [ ] Version numbers match installed versions
- [ ] All commands in examples work (syntax validation)
- [ ] New features are documented
- [ ] Removed features are deleted
- [ ] Examples use correct syntax
- [ ] No duplicate/redundant content across skills

### 3.3 Cross-Skill Alignment

**Check for consistency across:**
- Tool descriptions (browser-automation vs chrome-devtools-mcp)
- Example patterns (frontend-ui-testing vs webapp-testing-journey)
- Version references
- Command syntax (agent-browser vs OpenClaw browser)

---

## Phase 4: Skill Updates (Est. 90 min)

### 4.1 browser-automation/SKILL.md Updates
**Priority:** High (primary reference)

**Updates needed:**
- [ ] Update version: v0.24.0 → v0.24.1
- [ ] Verify all commands work with v0.24.1
- [ ] Add auth vault section with examples
- [ ] Add clipboard operations section
- [ ] Add batch execution examples
- [ ] Test and document profiler command
- [ ] Update Chrome reference: v147 (already correct)

### 4.2 chrome-devtools-mcp/SKILL.md Updates
**Priority:** High (version is wrong)

**Updates needed:**
- [ ] Update version: v0.20.3 → v0.21.0
- [ ] Verify all 29 tools still exist (no removed tools)
- [ ] Check for any new tools added in v0.21.0
- [ ] Document HEADLESS_MODE capabilities (noted in skill)
- [ ] Verify lighthouse patterns work
- [ ] Update performance trace patterns

### 4.3 frontend-ui-testing-journey/SKILL.md Updates
**Priority:** Medium (comprehensive patterns)

**Updates needed:**
- [ ] Verify all 3 tools (OpenClaw, agent-browser, chrome-devtools-mcp) are current
- [ ] Update version references throughout document
- [ ] Check mobile navigation reference (links to mobile-navigation.md)
- [ ] Ensure GitHub workflow examples are still valid

### 4.4 webapp-testing-journey/SKILL.md Updates
**Priority:** Medium (methodology guide)

**Updates needed:**
- [ ] Update version references in "When to use which tool" section
- [ ] Verify all quick-reference commands work
- [ ] Update "Available Tools" comparison table
- [ ] Check agent-browser workflow examples

### 4.5 e2e-testing-lessons/SKILL.md Updates
**Priority:** Low (seems current,