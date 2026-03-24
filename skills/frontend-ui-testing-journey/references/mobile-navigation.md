# Mobile Navigation Testing Reference

## Overview

This document provides a comprehensive taxonomy of mobile navigation failures and testing patterns, developed during the AI Academy project's frontend testing journey.

---

## Classes of Mobile Navigation Failures (A-H)

### Class A: Touch Target Size Failures

**Symptom:** Buttons too small for reliable touch input.

**Diagnosis:**
```bash
# Check button dimensions
agent-browser eval "(function() {
  const buttons = document.querySelectorAll('button');
  return Array.from(buttons).map(b => ({
    text: b.textContent?.trim(),
    width: b.offsetWidth,
    height: b.offsetHeight,
    meetsMinimum: b.offsetWidth >= 44 && b.offsetHeight >= 44
  }));
})()"
```

**Anti-patterns to Avoid:**
```tsx
// ❌ Too small
<button className="p-1 text-xs">Click</button>

// ✅ Correct minimum size (44px)
<button className="p-3 text-sm min-h-[44px] min-w-[44px]">Click</button>
```

**Code Examples:**
```tsx
// Proper touch target
<button className="
  min-h-[44px] min-w-[44px]
  p-3
  text-sm
  touch-manipulation
  active:scale-95
">
  Click Me
</button>
```

---

### Class B: Overflow and Scroll Failures

**Symptom:** Content hidden or unreachable due to overflow issues.

**Diagnosis:**
```bash
# Check overflow properties
agent-browser eval "(function() {
  const container = document.querySelector('.mobile-container');
  return {
    overflow: getComputedStyle(container).overflow,
    scrollHeight: container.scrollHeight,
    clientHeight: container.clientHeight,
    hasScroll: container.scrollHeight > container.clientHeight
  };
})()"
```

**Anti-patterns to Avoid:**
```tsx
// ❌ Fixed height without scroll
<div className="h-screen">Content</div>

// ✅ Proper scroll container
<div className="h-screen overflow-y-auto">Content</div>
```

**Code Examples:**
```tsx
// Scrollable container
<div className="
  h-screen
  overflow-y-auto
  overscroll-contain
  -webkit-overflow-scrolling: touch
">
  {children}
</div>
```

---

### Class C: Hamburger Menu Failures

**Symptom:** Mobile menu doesn't open or close properly.

**Diagnosis:**
```bash
# Check menu state
agent-browser eval "(function() {
  const menu = document.querySelector('[role=\"navigation\"]');
  const trigger = document.querySelector('[aria-label=\"Menu\"]');
  return {
    menuVisible: menu?.offsetHeight > 0,
    triggerExists: !!trigger,
    ariaExpanded: trigger?.getAttribute('aria-expanded')
  };
})()"
```

**Anti-patterns to Avoid:**
```tsx
// ❌ No ARIA attributes
<button onClick={toggleMenu}>
  <MenuIcon />
</button>

// ✅ Proper ARIA support
<button 
  onClick={toggleMenu}
  aria-expanded={isOpen}
  aria-label="Toggle menu"
>
  <MenuIcon />
</button>
```

**Code Examples:**
```tsx
// Accessible mobile menu
<button
  onClick={() => setIsOpen(!isOpen)}
  aria-expanded={isOpen}
  aria-controls="mobile-menu"
  aria-label={isOpen ? "Close menu" : "Open menu"}
>
  {isOpen ? <XIcon /> : <MenuIcon />}
</button>

<nav
  id="mobile-menu"
  aria-hidden={!isOpen}
  className={cn(
    "fixed inset-0 z-50",
    isOpen ? "translate-x-0" : "translate-x-full"
  )}
>
  {/* Menu content */}
</nav>
```

---

### Class D: Viewport Meta Tag Failures

**Symptom:** Page doesn't scale properly on mobile devices.

**Diagnosis:**
```bash
# Check viewport meta tag
agent-browser eval "document.querySelector('meta[name=\"viewport\"]')?.content"
```

**Anti-patterns to Avoid:**
```html
<!-- ❌ User-scalable disabled -->
<meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no">

<!-- ✅ Accessible viewport -->
<meta name="viewport" content="width=device-width, initial-scale=1">
```

**Code Examples:**
```html
<!-- Proper viewport configuration -->
<meta 
  name="viewport" 
  content="width=device-width, initial-scale=1, viewport-fit=cover"
>
```

---

### Class E: Touch Event Handling Failures

**Symptom:** Touch events not firing or firing incorrectly.

**Diagnosis:**
```bash
# Check touch event listeners
agent-browser eval "(function() {
  const element = document.querySelector('.touch-target');
  return {
    hasTouchStart: !!element?.ontouchstart,
    hasTouchEnd: !!element?.ontouchend,
    hasClick: !!element?.onclick
  };
})()"
```

**Anti-patterns to Avoid:**
```tsx
// ❌ Only listening to click
<button onClick={handleClick}>Touch me</button>

// ✅ Handle both click and touch
<button 
  onClick={handleClick}
  onTouchEnd={handleTouchEnd}
  className="touch-manipulation"
>
  Touch me
</button>
```

**Code Examples:**
```tsx
// Proper touch handling
<button
  onClick={handleClick}
  onTouchEnd={(e) => {
    e.preventDefault();
    handleClick();
  }}
  className="
    touch-manipulation
    select-none
    active:scale-95
    transition-transform
  "
>
  Touch Me
</button>
```

---

### Class F: Responsive Breakpoint Failures

**Symptom:** Layout breaks at certain viewport widths.

**Diagnosis:**
```bash
# Test different viewports
agent-browser set viewport 320 568  # iPhone SE
agent-browser set viewport 375 667  # iPhone 8
agent-browser set viewport 414 896  # iPhone 11
agent-browser set viewport 768 1024 # iPad
```

**Anti-patterns to Avoid:**
```tsx
// ❌ Fixed widths
<div className="w-[500px]">Content</div>

// ✅ Responsive widths
<div className="w-full max-w-[500px] px-4">Content</div>
```

**Code Examples:**
```tsx
// Responsive grid
<div className="
  grid
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  gap-4
  px-4
">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

---

### Class G: Font Scaling Failures

**Symptom:** Text too small or too large on mobile.

**Diagnosis:**
```bash
# Check font sizes
agent-browser eval "(function() {
  const elements = document.querySelectorAll('p, h1, h2, h3');
  return Array.from(elements).map(e => ({
    tag: e.tagName,
    fontSize: getComputedStyle(e).fontSize,
    lineHeight: getComputedStyle(e).lineHeight
  }));
})()"
```

**Anti-patterns to Avoid:**
```tsx
// ❌ Fixed pixel sizes
<p className="text-[12px]">Small text</p>

// ✅ Responsive text
<p className="text-sm sm:text-base">Responsive text</p>
```

**Code Examples:**
```tsx
// Responsive typography
<h1 className="
  text-2xl
  sm:text-3xl
  lg:text-4xl
  font-bold
  leading-tight
">
  Heading
</h1>

<p className="
  text-sm
  sm:text-base
  leading-relaxed
">
  Body text
</p>
```

---

### Class H: Gesture Conflict Failures

**Symptom:** Swipe gestures interfere with scrolling.

**Diagnosis:**
```bash
# Check touch-action property
agent-browser eval "getComputedStyle(document.body).touchAction"
```

**Anti-patterns to Avoid:**
```tsx
// ❌ Touch-action none on scrollable container
<div className="touch-none overflow-y-auto">Content</div>

// ✅ Proper touch-action
<div className="touch-pan-y overflow-y-auto">Content</div>
```

**Code Examples:**
```tsx
// Proper gesture handling
<div
  className="
    touch-pan-y
    overscroll-contain
    overflow-y-auto
  "
  onTouchStart={handleTouchStart}
  onTouchMove={handleTouchMove}
  onTouchEnd={handleTouchEnd}
>
  {children}
</div>
```

---

## Mobile Testing Commands

### Viewport Testing
```bash
# Set mobile viewport
agent-browser set viewport 375 667

# Capture mobile screenshot
agent-browser screenshot /tmp/mobile.png

# Reset to desktop
agent-browser set viewport 1280 720
```

### Touch Simulation
```bash
# Simulate tap
agent-browser eval "document.querySelector('button').click()"

# Simulate long press
agent-browser eval "(function() {
  const el = document.querySelector('.long-press-target');
  el.dispatchEvent(new TouchEvent('touchstart', { bubbles: true }));
  setTimeout(() => {
    el.dispatchEvent(new TouchEvent('touchend', { bubbles: true }));
  }, 500);
  return 'simulated';
})()"
```

### Responsive Testing
```bash
# Test multiple viewports
for width in 320 375 414 768 1024 1280; do
  agent-browser set viewport $width 800
  agent-browser screenshot /tmp/viewport-${width}.png
done
```

---

## Best Practices

### 1. Always Test on Real Viewports
```bash
# Common mobile viewports
agent-browser set viewport 320 568  # iPhone SE
agent-browser set viewport 375 667  # iPhone 8
agent-browser set viewport 390 844  # iPhone 12/13
agent-browser set viewport 414 896  # iPhone 11
```

### 2. Verify Touch Targets
- Minimum 44x44px for buttons
- 8px spacing between targets
- Visual feedback on touch

### 3. Test Landscape Orientation
```bash
# Landscape mobile
agent-browser set viewport 667 375
```

### 4. Verify Accessibility
- Screen reader compatibility
- Keyboard navigation
- Color contrast

---

## Quick Reference

### Common Mobile Viewports
| Device | Width | Height |
|--------|-------|--------|
| iPhone SE | 320 | 568 |
| iPhone 8 | 375 | 667 |
| iPhone 12/13 | 390 | 844 |
| iPhone 11 | 414 | 896 |
| iPad | 768 | 1024 |
| iPad Pro | 1024 | 1366 |

### Touch Target Guidelines
| Element | Minimum Size | Recommended |
|---------|--------------|-------------|
| Button | 44x44px | 48x48px |
| Link | 44x44px | 48x48px |
| Icon | 24x24px | 32x32px |
| Input | 44px height | 48px height |

---

**Reference Version:** 1.0.0  
**Last Updated:** March 24, 2026  
**Source:** AI Academy Project  
**Status:** Production Ready ✅
