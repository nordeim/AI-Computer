---
name: webapp-testing-journey
description: Systematic web application testing methodology using OpenClaw browser tool. Use when testing web application user journeys, validating bug fixes, performing QA verification, or debugging frontend issues. Covers URL journey testing, accessibility tree analysis, DOM inspection, network request debugging, and comprehensive issue verification. Triggers on phrases like "test this application", "verify the fix", "check if it works", "test the user journey", "debug this issue".
---

# Webapp Testing Journey

Systematic methodology for testing web applications using OpenClaw's built-in browser tool. Built from real-world QA testing of AI Academy (2026-03-24).

## Core Philosophy

**Test assumptions, not claims.** Teams may claim fixes are deployed, but verification requires actual execution. Use browser automation to validate behavior, inspect DOM state, and capture network activity.

## Testing Workflow

```
1. PLAN: Define test cases with expected vs actual
2. EXECUTE: Navigate, interact, capture state
3. INSPECT: DOM, accessibility tree, console, network
4. VERIFY: Compare against expected behavior
5. REPORT: Document findings with evidence
```

## Browser Tool Commands

### Navigation

```bash
# Open URL
browser open <url>

# Navigate to new URL
browser navigate <url>

# Get current state
browser snapshot --refs aria

# Close browser
browser close
```

### Interaction

```bash
# Click element by ref (from snapshot)
browser act kind=click ref=e312

# Type text into input
browser act kind=type ref=e41 text="test@example.com"

# Press keyboard shortcut
browser act kind=press key="Control+k"

# Fill multiple fields
browser act kind=fill fields='[{"ref": "e41", "text": "email"}, {"ref": "e44", "text": "username"}]'

# Execute JavaScript
browser act kind=evaluate fn="() => document.title"
```

### Inspection

```bash
# Accessibility tree with refs (preferred)
browser snapshot --refs aria

# Console logs
browser console

# Screenshot
browser screenshot
```

## Methodology: URL Journey Testing

### Phase 1: Define Test Cases

Before testing, document:
- **Expected behavior**: What should happen
- **Previous state**: What was broken (if regression test)
- **Verification criteria**: How to confirm fix

Example test case matrix:
```
| Issue | Expected | Verification |
|-------|----------|--------------|
| Hero button click | Navigate to Sign In | URL changes, form visible |
| Registration submit | 201 Created | Console shows success |
| Command Palette | Search results render | List height > 0px |
```

### Phase 2: Execute Navigation

```bash
# 1. Open application
browser open http://localhost:5173/

# 2. Capture initial state
browser snapshot --refs aria

# 3. Identify interactive elements
# Look for [ref=eXXX] [cursor=pointer] in snapshot
```

### Phase 3: Interact and Observe

```bash
# Click target element
browser act kind=click ref=e312

# Capture result
browser snapshot --refs aria

# Check for expected changes
browser act kind=evaluate fn='() => window.location.href'
```

### Phase 4: Deep Inspection

When surface-level testing fails, inspect internals:

#### DOM Inspection
```bash
# Get specific element state
browser act kind=evaluate fn='() => {
  const listbox = document.querySelector("[role=\"listbox\"]");
  return {
    height: listbox?.style?.getPropertyValue("--cmdk-list-height"),
    hidden: listbox?.getAttribute("hidden"),
    childCount: listbox?.childElementCount
  };
}'
```

#### Accessibility Tree Analysis
```bash
# Snapshot shows semantic structure
browser snapshot --refs aria

# Look for:
# - [hidden] attributes on visible elements
# - Missing [cursor=pointer] on buttons
# - Empty listbox/group containers
# - Incorrect aria-* attributes
```

#### Console Debugging
```bash
# Check for errors
browser console

# Look for:
# - 400/500 status codes
# - Failed resource loads
# - API request/response logs
# - React warnings
```

#### Network Request Verification
```bash
# Direct API testing
curl -s -X POST http://localhost:8000/api/v1/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"testuser","password":"Test123!@","acceptTerms":"on"}'
```

### Phase 5: Evidence Collection

```bash
# Screenshot for visual evidence
browser screenshot

# Save to workspace
browser screenshot /home/pete/.openclaw/workspace/evidence.png
```

## Common Testing Patterns

### Button Functionality Test

```bash
# 1. Identify button in snapshot
# button "Enroll Now" [ref=e312] [cursor=pointer]

# 2. Click and observe
browser act kind=click ref=e312
browser snapshot --refs aria

# 3. Verify navigation
browser act kind=evaluate fn='() => window.location.href'
```

### Form Submission Test

```bash
# 1. Navigate to form
browser navigate http://localhost:5173/register

# 2. Fill fields
browser act kind=type ref=e41 text="test@example.com"
browser act kind=type ref=e44 text="testuser"
browser act kind=type ref=e48 text="TestPassword123!@"
browser act kind=click ref=e62  # checkbox

# 3. Submit and check console
browser act kind=click ref=e67
browser console

# Look for: [API Response] POST /auth/register/ - 201
```

### Search/Filter Test

```bash
# 1. Open search interface
browser act kind=press key="Control+k"

# 2. Type search query
browser act kind=type ref=e14 text="ai"

# 3. Check results rendered
browser act kind=evaluate fn='() => {
  const listbox = document.querySelector("[role=\"listbox\"]");
  return {
    hasItems: listbox?.querySelectorAll("[cmdk-item]")?.length > 0,
    height: listbox?.style?.getPropertyValue("--cmdk-list-height")
  };
}'
```

## Troubleshooting Guide

### Issue: Element Not Found

**Symptoms:** `TimeoutError: locator.click: Timeout 8000ms exceeded`

**Causes:**
- Element not in viewport
- Element hidden by CSS
- Element not yet rendered (timing)

**Solutions:**
```bash
# Use evaluate to click directly
browser act kind=evaluate fn='() => {
  const btn = document.querySelector("button");
  if (btn?.textContent?.includes("Enroll Now")) {
    btn.click();
    return "clicked";
  }
  return "not found";
}'

# Wait for element
browser act kind=evaluate fn='() => {
  return new Promise(resolve => {
    const check = () => {
      const el = document.querySelector("button");
      if (el) resolve("found");
      else setTimeout(check, 100);
    };
    check();
  });
}'
```

### Issue: React State Not Updating

**Symptoms:** Input has value but component state is null

**Diagnosis:**
```bash
# Check if React state matches DOM
browser act kind=evaluate fn='() => {
  const input = document.querySelector("input");
  return {
    domValue: input?.value,
    hasOnInput: !!input?.oninput,
    hasOnChange: !!input?.onchange
  };
}'
```

**Solutions:**
- Check for conflicting handlers (cmdk library issue)
- Verify `shouldFilter` prop configuration
- Look for duplicate handler bindings

### Issue: API 400 Bad Request

**Symptoms:** Form submission fails with validation error

**Diagnosis:**
```bash
# Test API directly
curl -s -X POST http://localhost:8000/api/v1/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","username":"test","password":"Test123!@","acceptTerms":"on"}'

# Check response for missing fields
# {"errors": {"first_name": ["This field is required."]}}
```

**Solutions:**
- Compare frontend fields with API requirements
- Check for hidden required fields
- Verify field name mapping (frontend vs backend)

### Issue: Hidden Elements in Accessibility Tree

**Symptoms:** Element shows `[hidden]` but should be visible

**Diagnosis:**
```bash
# Check hidden attribute source
browser act kind=evaluate fn='() => {
  const el = document.querySelector("[role=\"listbox\"]");
  return {
    hiddenAttr: el?.getAttribute("hidden"),
    computedDisplay: getComputedStyle(el)?.display,
    computedVisibility: getComputedStyle(el)?.visibility
  };
}'
```

## Lessons Learned

### 1. Team Claims Need Verification

**Case:** Team reported "Homepage Enroll Now button fixed" but earlier testing showed noop handlers.

**Lesson:** Always execute actual clicks and verify navigation. Don't trust status reports without evidence.

### 2. Root Cause May Differ from Symptom

**Case:** Registration failed with generic error, suspected checkbox validation, actual cause was missing `first_name`/`last_name` fields.

**Lesson:** Use `curl` to test API directly. Console logs show actual API errors, not frontend interpretation.

### 3. Accessibility Tree Reveals State

**Case:** Command Palette showed `hidden=""` and `height: 0px` when broken, `hidden: null` and `height: 124px` when working.

**Lesson:** Accessibility tree snapshots provide definitive evidence of component state.

### 4. Console Logs Are Gold

**Case:** Console showed `[API Response] POST /auth/register/ - 201` confirming registration success.

**Lesson:** Always check console during form submissions. Network requests logged with status codes.

### 5. Direct API Testing Isolated Frontend from Backend

**Case:** `curl` requests proved checkbox fix worked before UI testing.

**Lesson:** Test backend independently to isolate frontend issues from backend issues.

## Blockers Encountered

### Solved: Checkbox Validation

**Problem:** Checkbox sends `"on"` string, backend expected boolean.

**Solution:** Team updated Zod schema to accept `z.union([z.boolean(), z.string()])`.

**Verification:** Both `"on"` and `true` now accepted via curl.

### Solved: Missing Required Fields

**Problem:** Registration form missing `first_name`/`last_name`, API returned 400.

**Solution:** Backend made fields optional or auto-populated.

**Verification:** Registration now succeeds with just email/username/password.

### Solved: Command Palette Not Rendering

**Problem:** `query` state null, list height 0px, no items rendered.

**Solution:** Team added `shouldFilter={false}` to disable cmdk's built-in filtering.

**Verification:** List height 124px, items visible in accessibility tree.

## Recommended Next Steps

1. **Automate repetitive tests** — Create Playwright/Cypress scripts for regression testing
2. **Document API schemas** — Maintain OpenAPI specs for frontend/backend contract
3. **Add visual regression** — Screenshot comparison for UI changes
4. **Implement test logging** — Capture test runs for historical comparison
5. **Create test data fixtures** — Consistent test accounts and data

## Resources

### References

- **mobile-navigation.md** — Mobile navigation debugging taxonomy (Classes A-H)
- **browser-automation/SKILL.md** — Full browser automation guide
- **chrome-devtools-mcp/SKILL.md** — DevTools-grade debugging with MCP
