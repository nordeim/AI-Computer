# agent-browser v0.25.1 New Features - Skills Update

**Date:** 2026-04-08
**Status:** ✅ COMPLETE

---

## New Features Documented

### Added to browser-automation/SKILL.md

Three new sections with complete documentation:

1. **Debug & Profiling (v0.25.1 NEW)** - Lines 91-118
   - `profiler start|stop` - Chrome DevTools CPU profiler
   - `trace start|stop` - Chrome DevTools trace
   - `console` / `errors` - Console and error viewing
   - `highlight` / `inspect` - Debug helpers
   - `har start|stop` - HTTP Archive capture
   - `storage local|session` - Web storage inspection

2. **AI & Dashboard (v0.25.1 NEW)** - Lines 120-134
   - `chat` - Natural language commands (requires AI_GATEWAY_API_KEY)
   - `dashboard start|stop` - Observability server (port 4848)
   - `session` / `session list` - Session management

3. **Confirmation Workflow (v0.25.1 NEW)** - Lines 136-142
   - `--confirm-actions` - Require approval for sensitive operations
   - `confirm` / `deny` - Approve or reject pending actions

### Added to webapp-testing-journey/SKILL.md

1. **Tool Selection Matrix** - 6 new rows (Lines 47-52)
   - Profiler traces, Network HAR, Console/errors, Visual highlights

2. **agent-browser CLI section** - Updated all NEW markers to v0.25.1
   - Annotated Screenshots
   - Video Recording
   - Visual Diff
   - Auth Testing
   - Debug & Profiling (NEW)
   - Network HAR Capture (NEW)
   - AI Natural Language (NEW)

### Added to frontend-ui-testing-journey/SKILL.md

1. **Tool Selection Matrix** - 4 new rows (Lines 47-50)
   - Profiler traces, Network HAR, Console/errors, Visual highlights

---

## Features NOT Yet Documented (Future Work)

These features exist in v0.25.1 but are specialized:

- iOS Simulator support (`-p ios`, `--device`)
- Lightpanda engine (`--engine lightpanda`)
- Action policy JSON (`--action-policy`)
- Domain restrictions (`--allowed-domains`)
- Batch execution with `--bail`
- Cookies with full attributes

These can be added when use cases arise.

---

## Verification Summary

| Skill | Sections Added | Features Added | Status |
|-------|---------------|----------------|--------|
| browser-automation | 3 | 15+ commands | ✅ |
| webapp-testing-journey | 2 | 10+ commands | ✅ |
| frontend-ui-testing-journey | 1 | 4 matrix rows | ✅ |

---

*Updated: 2026-04-08 06:50 SGT*
