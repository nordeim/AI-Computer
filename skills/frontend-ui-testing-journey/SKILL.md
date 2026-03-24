---
name: frontend-ui-testing-journey
description: >
  Complete frontend UI testing, verification, troubleshooting, and resolution journey
  from the AI Academy project. Covers testing methodology, browser automation commands,
  common patterns, troubleshooting guides, and lessons learned from real-world testing.
triggers:
  - "test frontend"
  - "UI testing"
  - "browser testing"
  - "QA testing"
  - "E2E testing"
  - "visual testing"
  - "button testing"
  - "form testing"
  - "debug frontend"
  - "troubleshoot UI"
---

# Frontend UI Testing Journey

## Core Philosophy

> **"Test the user journey, not just the code."**

This skill documents the complete frontend UI testing methodology developed during the AI Academy project. It covers real-world testing scenarios, debugging techniques, and solutions to common frontend issues.

---

## Testing Workflow (5 Phases)

### Phase 1: Planning & Reconnaissance
**Goal:** Understand the testing scope and requirements.

1. **Define Test Cases**
   ```bash
   # Example: Testing login flow
   Test Case: User Login
   - Navigate to /login
   - Fill email field
   - Fill password field
   - Click "Sign in" button
   - Verify redirect to homepage
   ```

2. **Identify Critical Paths**
   - Authentication flow
   - Payment processing
   - Form submission
   - Navigation elements

3. **Gather Evidence Requirements**
   - Screenshot before/after
   - API response validation
   - DOM state verification

### Phase 2: Execution & Interaction
**Goal:** Execute test cases and interact with UI elements.

```bash
# Navigate to page
agent-browser open http://localhost:5173/login

# Wait for page load
agent-browser wait --load networkidle

# Fill form fields
agent-browser eval "(function() {
  const email = document.querySelector('input[type=\"email\"]');
  email.value = 'test@example.com';
  email.dispatchEvent(new Event('input', { bubbles: true }));
  return 'filled';
})()"

# Click button
agent-browser eval "(function() {
  const btn = Array.from(document.querySelectorAll('button'))
    .find(b => b.textContent.includes('Sign in'));
  if (btn) { btn.click(); return 'clicked'; }
  return 'not found';
})()"

# Capture evidence
agent-browser screenshot --annotate /tmp/test-result.png
```

### Phase 3: Inspection & Validation
**Goal:** Verify UI state and validate against expected behavior.

```bash
# Check DOM state
agent-browser eval "(function() {
  return {
    url: window.location.href,
    title: document.title,
    errors: document.querySelectorAll('.error').length,
    buttons: document.querySelectorAll('button').length
  };
})()"

# Check React state
agent-browser eval "(function() {
  const input = document.querySelector('input[placeholder*=\"Search\"]');
  return {
    value: input?.value,
    focused: document.activeElement === input
  };
})()"

# Check API responses
agent-browser eval "fetch('/api/v1/courses/').then(r => r.json()).then(d => d.success)"
```

### Phase 4: Verification & Testing
**Goal:** Verify fixes and test edge cases.

```bash
# Test button click
agent-browser eval "(function() {
  const btn = document.querySelector('button[aria-label=\"Search courses\"]');
  btn?.click();
  return 'clicked';
})()"

# Wait for state change
agent-browser wait --load networkidle

# Verify results
agent-browser eval "(function() {
  const listbox = document.querySelector('[role=\"listbox\"]');
  return {
    text: listbox?.textContent?.substring(0, 200),
    hidden: listbox?.hasAttribute('hidden'),
    itemCount: listbox?.children?.length
  };
})()"
```

### Phase 5: Reporting & Documentation
**Goal:** Document findings and capture evidence.

```bash
# Capture final screenshot
agent-browser screenshot --annotate /tmp/final-result.png

# Generate report
echo "## Test Report"
echo "Date: $(date)"
echo "URL: $(agent-browser eval 'window.location.href')"
echo "Tests Passed: $passed"
echo "Tests Failed: $failed"
```

---

## Browser Tool Commands

### Navigation Commands
```bash
# Open URL
agent-browser open http://localhost:5173/

# Navigate to path
agent-browser eval "window.location.href = '/courses'"

# Go back
agent-browser press "Alt+ArrowLeft"

# Wait for page load
agent-browser wait --load networkidle
```

### Interaction Commands
```bash
# Click element by text
agent-browser click "Sign In"

# Click element by selector
agent-browser eval "document.querySelector('button').click()"

# Type into input
agent-browser type "search query"

# Press keys
agent-browser press "Enter"
agent-browser press "Escape"
```

### Inspection Commands
```bash
# Get page snapshot
agent-browser snapshot -i

# Get element text
agent-browser eval "document.querySelector('h1').textContent"

# Check element visibility
agent-browser eval "document.querySelector('.modal').offsetHeight > 0"

# Count elements
agent-browser eval "document.querySelectorAll('button').length"
```

### Screenshot Commands
```bash
# Capture full page
agent-browser screenshot /tmp/page.png

# Capture with annotation
agent-browser screenshot --annotate /tmp/page.png

# Capture specific viewport
agent-browser set viewport 375 667
agent-browser screenshot /tmp/mobile.png
```

---

## Methodology: URL Journey Testing

### Step-by-Step Process

1. **Define Starting Point**
   ```bash
   agent-browser open http://localhost:5173/
   ```

2. **Identify Target Element**
   ```bash
   agent-browser eval "(function() {
     const elements = document.querySelectorAll('button, a');
     return Array.from(elements).map(e => ({
       tag: e.tagName,
       text: e.textContent?.trim(),
       href: e.getAttribute('href'),
       onClick: e.onclick?.toString()?.substring(0, 50)
     }));
   })()"
   ```

3. **Execute Action**
   ```bash
   agent-browser eval "(function() {
     const btn = Array.from(document.querySelectorAll('button'))
       .find(b => b.textContent.includes('Enroll Now'));
     if (btn) {
       btn.click();
       return 'clicked';
     }
     return 'not found';
   })()"
   ```

4. **Verify Result**
   ```bash
   agent-browser wait --load networkidle
   agent-browser eval "window.location.href"
   ```

5. **Capture Evidence**
   ```bash
   agent-browser screenshot --annotate /tmp/journey-step.png
   ```

---

## Common Testing Patterns

### Pattern 1: Button Click Testing
```bash
# Find and click button
agent-browser eval "(function() {
  const buttons = Array.from(document.querySelectorAll('button'));
  const target = buttons.find(b => 
    b.textContent.includes('Enroll Now') && 
    !b.disabled
  );
  if (target) {
    target.click();
    return { success: true, text: target.textContent };
  }
  return { success: false, available: buttons.map(b => b.textContent) };
})()"
```

### Pattern 2: Form Submission Testing
```bash
# Fill and submit form
agent-browser eval "(function() {
  const form = document.querySelector('form');
  const inputs = form.querySelectorAll('input');
  
  inputs.forEach(input => {
    if (input.type === 'email') input.value = 'test@example.com';
    if (input.type === 'password') input.value = 'TestPass123!';
    input.dispatchEvent(new Event('input', { bubbles: true }));
  });
  
  const submit = form.querySelector('button[type=\"submit\"]');
  if (submit) submit.click();
  
  return 'form submitted';
})()"
```

### Pattern 3: Search/Filter Testing
```bash
# Test search functionality
agent-browser eval "(function() {
  const input = document.querySelector('input[placeholder*=\"Search\"]');
  if (input) {
    input.focus();
    const setter = Object.getOwnPropertyDescriptor(
      window.HTMLInputElement.prototype, 'value'
    ).set;
    setter.call(input, 'ai');
    input.dispatchEvent(new Event('input', { bubbles: true }));
    return 'search executed';
  }
  return 'no input found';
})()"

# Wait for results
agent-browser wait --load networkidle

# Verify results
agent-browser eval "(function() {
  const items = document.querySelectorAll('[role=\"option\"]');
  return { count: items.length, visible: items.length > 0 };
})()"
```

### Pattern 4: Modal/Dialog Testing
```bash
# Open modal
agent-browser eval "document.querySelector('[aria-label=\"Open dialog\"]').click()"

# Verify modal is visible
agent-browser eval "(function() {
  const modal = document.querySelector('[role=\"dialog\"]');
  return {
    visible: modal && modal.offsetHeight > 0,
    hasCloseButton: !!modal?.querySelector('button[aria-label=\"Close\"]')
  };
})()"

# Close modal
agent-browser press "Escape"
```

---

## Troubleshooting Guide

### Issue 1: Element Not Found

**Symptom:** `Element not found. Verify the selector is correct.`

**Diagnosis:**
```bash
# Check if element exists
agent-browser eval "document.querySelector('button[aria-label=\"Search\"]')"

# List all buttons
agent-browser eval "Array.from(document.querySelectorAll('button')).map(b => b.textContent)"
```

**Solutions:**
1. Wait for element to render
2. Use different selector
3. Check if element is in shadow DOM
4. Verify element is not hidden

```bash
# Wait for element
agent-browser wait --load networkidle

# Try different selector
agent-browser eval "document.querySelector('[data-testid=\"search-button\"]')"
```

### Issue 2: React State Not Updating

**Symptom:** Input value changes but React state remains null.

**Diagnosis:**
```bash
# Check input value
agent-browser eval "document.querySelector('input').value"

# Check if handlers are attached
agent-browser eval "typeof document.querySelector('input').oninput"
```

**Solutions:**
1. Use native value setter
2. Dispatch multiple events
3. Remove conflicting handlers

```bash
# Use native setter
agent-browser eval "(function() {
  const input = document.querySelector('input');
  const setter = Object.getOwnPropertyDescriptor(
    window.HTMLInputElement.prototype, 'value'
  ).set;
  setter.call(input, 'new value');
  input.dispatchEvent(new Event('input', { bubbles: true }));
  return 'set';
})()"
```

### Issue 3: Hidden Elements

**Symptom:** Element exists in DOM but not visible.

**Diagnosis:**
```bash
# Check hidden attribute
agent-browser eval "document.querySelector('[role=\"listbox\"]').hasAttribute('hidden')"

# Check computed style
agent-browser eval "getComputedStyle(document.querySelector('.element')).display"
```

**Solutions:**
1. Remove hidden attribute
2. Set display to block
3. Check parent visibility

```bash
# Remove hidden
agent-browser eval "document.querySelector('[hidden]').removeAttribute('hidden')"
```

### Issue 4: Button Not Responding

**Symptom:** Button click has no effect.

**Diagnosis:**
```bash
# Check onClick handler
agent-browser eval "(function() {
  const btn = document.querySelector('button');
  return {
    hasOnclick: typeof btn.onclick === 'function',
    onclickStr: btn.onclick?.toString()?.substring(0, 100),
    disabled: btn.disabled
  };
})()"
```

**Solutions:**
1. Check if button is disabled
2. Verify onClick handler is attached
3. Check for event propagation issues

### Issue 5: Form Validation Errors

**Symptom:** Form submission fails with validation error.

**Diagnosis:**
```bash
# Check form state
agent-browser eval "(function() {
  const form = document.querySelector('form');
  const inputs = form.querySelectorAll('input');
  return Array.from(inputs).map(i => ({
    name: i.name,
    value: i.value,
    type: i.type,
    valid: i.validity.valid
  }));
})()"
```

**Solutions:**
1. Fill all required fields
2. Check field types match expected format
3. Verify checkbox values (string vs boolean)

---

## Lessons Learned

### Lesson 1: Test the User Journey, Not Just Code
**Insight:** Components may have onClick handlers in code but fail at runtime due to context issues.

**Example from AI Academy:**
- "Enroll Now" buttons had handlers but didn't work
- Root cause: Missing React Router context
- Solution: Verify runtime behavior, not just code

### Lesson 2: Use Native DOM Methods for Testing
**Insight:** React synthetic events don't always work with browser automation.

**Example from AI Academy:**
- `input.value = 'ai'` didn't update React state
- Solution: Use `Object.getOwnPropertyDescriptor` to set value

### Lesson 3: Disable Library Filtering When Using Custom Logic
**Insight:** Third-party libraries may apply their own filtering that conflicts with custom logic.

**Example from AI Academy:**
- cmdk library filtering was hiding search results
- Solution: Added `shouldFilter={false}` to disable built-in filtering

### Lesson 4: Check for Missing Test Infrastructure
**Insight:** Tests may fail to run if test directories lack proper structure.

**Example from AI Academy:**
- Soft delete tests weren't discovered by test runner
- Solution: Created `__init__.py` in test directory

### Lesson 5: Verify Backend Integration Separately
**Insight:** Frontend issues may be caused by backend changes.

**Example from AI Academy:**
- Registration failed due to missing backend fields
- Solution: Test API directly with curl before debugging frontend

---

## Blockers Encountered (All Solved)

### Blocker 1: Blank Screenshots
**Issue:** All screenshots showed blank white pages.  
**Root Cause:** `kimi-plugin-inspect-react` plugin incompatible with React 19.  
**Solution:** Removed plugin from `vite.config.ts`.  
**Evidence:** React mounts successfully after fix.

### Blocker 2: Buttons Not Responding
**Issue:** "Enroll Now" buttons had no effect when clicked.  
**Root Cause:** Missing onClick handlers and wrong anchor tags.  
**Solution:** Added proper onClick handlers with `useNavigate`.  
**Evidence:** Buttons now navigate to correct routes.

### Blocker 3: Command Palette Not Showing Results
**Issue:** Search returned results but they weren't visible.  
**Root Cause:** cmdk library filtering + onInput handler conflict.  
**Solution:** Removed onInput handler, added `shouldFilter={false}`.  
**Evidence:** Results now visible with 124px list height.

### Blocker 4: Registration Form Validation Error
**Issue:** "Invalid input: expected boolean, received string".  
**Root Cause:** Checkbox sends "on" string instead of boolean.  
**Solution:** Updated Zod schema to accept both string and boolean.  
**Evidence:** Registration succeeds with 201 Created.

### Blocker 5: Empty Course Catalog
**Issue:** Courses page showed "No courses found".  
**Root Cause:** API returns array directly, frontend expected nested results.  
**Solution:** Changed `data.results` to `Array.isArray(data.data)`.  
**Evidence:** 3 courses now display correctly.

---

## Recommended Next Steps

### Immediate
1. **Visual Regression Testing** - Add screenshot comparison
2. **Cross-Browser Testing** - Test on Firefox, Safari
3. **Accessibility Audit** - WCAG compliance verification

### Short-term
4. **Performance Testing** - Lighthouse integration
5. **Load Testing** - Concurrent user simulation
6. **Mobile Testing** - Responsive design verification

### Long-term
7. **CI/CD Integration** - Automated test runs
8. **Test Coverage** - Increase to 95%+
9. **Documentation** - Video tutorials

---

## Quick Reference

### Essential Commands
```bash
# Start servers
./start_servers.sh

# Run E2E tests
npm run test tests/e2e/smoke.spec.ts

# Capture screenshots
agent-browser open http://localhost:5173/
agent-browser screenshot --annotate /tmp/page.png

# Check API health
curl http://localhost:8000/api/v1/courses/
```

### Common Patterns
```bash
# Find button by text
document.querySelector('button').textContent

# Click button
Array.from(document.querySelectorAll('button'))
  .find(b => b.textContent.includes('Text')).click()

# Check React state
Object.getOwnPropertyDescriptor(
  window.HTMLInputElement.prototype, 'value'
).set.call(input, value)
```

---

**Skill Version:** 1.0.0  
**Last Updated:** March 24, 2026  
**Source:** AI Academy Project  
**Status:** Production Ready ✅
