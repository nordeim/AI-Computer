# Mobile Navigation Debugging Taxonomy

Root-cause classification system for mobile navigation failures. Created during AI Academy QA testing (2026-03-19).

## Class A: DOM Presence Failure

**Symptom:** Navigation element not found in DOM.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  const nav = document.querySelector("nav");
  return {
    exists: !!nav,
    html: nav?.outerHTML?.slice(0, 200)
  };
}'
```

**Causes:**
- Conditional rendering based on viewport width
- SSR hydration mismatch
- JavaScript bundle not loaded
- Media query hiding element

**Solutions:**
- Check responsive breakpoint logic
- Verify hydration succeeds
- Ensure scripts load before interaction
- Use proper viewport meta tag

## Class B: CSS Visibility Failure

**Symptom:** Element in DOM but not visible.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  const el = document.querySelector("nav");
  const styles = getComputedStyle(el);
  return {
    display: styles.display,
    visibility: styles.visibility,
    opacity: styles.opacity,
    height: styles.height,
    width: styles.width
  };
}'
```

**Causes:**
- `display: none` applied
- `visibility: hidden` set
- `opacity: 0` with pointer events
- Height/width collapsed to 0

**Solutions:**
- Check CSS media queries
- Verify transition states
- Ensure parent container allows overflow
- Check for conflicting utility classes

## Class C: Clipping/Overflow Failure

**Symptom:** Element visible but partially hidden.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  const el = document.querySelector("nav");
  const rect = el.getBoundingClientRect();
  return {
    top: rect.top,
    left: rect.left,
    width: rect.width,
    height: rect.height,
    viewportWidth: window.innerWidth,
    viewportHeight: window.innerHeight,
    isClipped: rect.right > window.innerWidth || rect.bottom > window.innerHeight
  };
}'
```

**Causes:**
- Parent `overflow: hidden`
- Fixed positioning with incorrect coordinates
- Transform affecting stacking context
- Viewport units miscalculated

**Solutions:**
- Check parent overflow properties
- Verify z-index and stacking context
- Ensure transforms don't clip content
- Use proper viewport calculations

## Class D: Z-Index/Stacking Failure

**Symptom:** Element visible but covered by other elements.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  const el = document.querySelector("nav");
  const rect = el.getBoundingClientRect();
  const centerX = rect.left + rect.width / 2;
  const centerY = rect.top + rect.height / 2;
  const topEl = document.elementFromPoint(centerX, centerY);
  return {
    zIndex: getComputedStyle(el).zIndex,
    topElement: topEl?.tagName,
    topElementZIndex: topEl ? getComputedStyle(topEl).zIndex : null,
    isOnTop: topEl === el || el.contains(topEl)
  };
}'
```

**Causes:**
- Lower z-index than overlapping elements
- Missing `position` for z-index to take effect
- New stacking context from transform/opacity
- Modal/backdrop covering navigation

**Solutions:**
- Set explicit z-index values
- Ensure `position: relative/absolute/fixed`
- Check for stacking context creators
- Use z-index management system

## Class E: Breakpoint Mismatch

**Symptom:** Navigation works at some sizes but not others.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  return {
    viewportWidth: window.innerWidth,
    viewportHeight: window.innerHeight,
    devicePixelRatio: window.devicePixelRatio,
    mediaQueries: Array.from(document.styleSheets)
      .flatMap(sheet => {
        try {
          return Array.from(sheet.cssRules)
            .filter(r => r instanceof CSSMediaRule)
            .map(r => r.conditionText);
        } catch { return []; }
      })
  };
}'
```

**Causes:**
- Hardcoded breakpoints don't match design
- CSS and JS breakpoint mismatch
- Orientation change not handled
- Retina display scaling issues

**Solutions:**
- Use CSS custom properties for breakpoints
- Synchronize JS and CSS breakpoint detection
- Handle resize and orientation events
- Test on actual devices, not just emulation

## Class F: JavaScript Event Failure

**Symptom:** Navigation renders but clicks/taps do nothing.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  const nav = document.querySelector("nav");
  return {
    hasOnClick: !!nav.onclick,
    hasEventListener: nav?.getEventListeners?.()?.click?.length > 0,
    pointerEvents: getComputedStyle(nav).pointerEvents,
    hasClickListener: (() => {
      // Check if React/Vue/etc attached handlers
      const key = Object.keys(nav).find(k => k.startsWith("__react"));
      return !!key;
    })()
  };
}'
```

**Causes:**
- Event handler not attached
- `pointer-events: none` on element or parent
- Event.preventDefault() blocking propagation
- React/Vue event system not initialized

**Solutions:**
- Verify event listeners in DevTools
- Check pointer-events CSS
- Ensure event propagation is correct
- Verify framework hydration

## Class G: Keyboard Accessibility Failure

**Symptom:** Navigation not accessible via keyboard.

**Diagnosis:**
```bash
browser act kind=evaluate fn='() => {
  const nav = document.querySelector("nav");
  const focusable = nav?.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  return {
    navTabIndex: nav?.getAttribute("tabindex"),
    hasAriaLabel: !!nav?.getAttribute("aria-label"),
    focusableCount: focusable?.length,
    firstFocusable: focusable?.[0]?.tagName,
    firstFocusableTabIndex: focusable?.[0]?.getAttribute("tabindex")
  };
}'
```

**Causes:**
- Missing `tabindex` on interactive elements
- `tabindex="-1"` preventing focus
- Negative tabindex on parent trapping focus
- Missing ARIA landmarks

**Solutions:**
- Use semantic HTML (`<nav>`, `<a>`, `<button>`)
- Add appropriate tabindex values
- Implement focus management
- Use ARIA landmarks and roles

## Class H: Click-Outside Race Condition

**Symptom:** Navigation closes immediately after opening.

**Diagnosis:**
```bash
# Simulate rapid interaction
browser act kind=evaluate fn='() => {
  const btn = document.querySelector("[aria-expanded]");
  btn?.click();
  return {
    expandedAfterClick: btn?.getAttribute("aria-expanded"),
    documentClickHandlers: window?.getEventListeners?.(document)?.click?.length
  };
}'

# Check timing
browser act kind=evaluate fn='() => {
  // Add timing probe
  const events = [];
  const orig = console.log;
  console.log = (...args) => {
    events.push({ time: performance.now(), args });
    orig(...args);
  };
  // Trigger interaction
  document.querySelector("button").click();
  return events;
}'
```

**Causes:**
- Click event propagates to document immediately
- Click-outside handler attached before animation completes
- Event timing during render cycle
- State update batching

**Solutions:**
- Use `setTimeout` to delay click-outside attachment
- Check event.target before closing
- Use `event.stopPropagation()` on toggle
- Implement proper state management

## Anti-Patterns to Avoid

### 1. Hiding Nav Without Trigger

**Problem:** Nav exists but no visible button to open it.

**Fix:** Always pair hidden nav with visible, accessible toggle.

### 2. Random Z-Index Values

**Problem:** `z-index: 9999` and similar arbitrary values.

**Fix:** Use z-index scale (10, 20, 30...) with documentation.

### 3. Non-Semantic Clickables

**Problem:** `<div onclick>` instead of `<button>`.

**Fix:** Use `<button>` for actions, `<a>` for navigation.

### 4. Missing Triggers at Breakpoints

**Problem:** Desktop nav hidden on mobile, no hamburger.

**Fix:** Test all breakpoints, ensure nav accessible at every size.

### 5. SSR Conditional Nav

**Problem:** Nav rendered differently on server vs client.

**Fix:** Use consistent rendering or proper hydration.

### 6. Click-Outside Race Conditions

**Problem:** Nav closes immediately after opening on mobile.

**Fix:** Delay click-outside handler attachment after open.
