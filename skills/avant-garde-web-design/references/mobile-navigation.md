# Mobile Navigation Patterns

## Definition of "Nav Disappears"

Navigation is "disappeared" when ANY of these are true:
- No visible navigation affordance (links, menu button, drawer)
- Nav exists but not visible (hidden by CSS)
- Nav visible but not interactive (covered by layer/z-index)
- Nav interactive but not reachable by keyboard

---

## Non-Negotiable Guardrails

### 1. Viewport Meta is Mandatory
```html
<meta name="viewport" content="width=device-width, initial-scale=1">
```

### 2. Never Destroy Without Substitution
**Forbidden:** Mobile media query sets `display: none` with no replacement.

**Required:** Add mobile trigger + overlay/drawer OR keep inline nav visible.

### 3. Symmetrical Breakpoint Strategy
```tsx
// Desktop nav: visible at md and above
<nav className="hidden md:flex items-center gap-8">...</nav>

// Mobile trigger: hidden at md and above
<button className="md:hidden" aria-label="Open menu">Menu</button>
```

### 4. Semantic Controls
- Use real `<button type="button">` for toggles
- Include: `aria-controls`, `aria-expanded`, `aria-label`
- Avoid checkbox/label hacks when accessibility matters

### 5. Overlay Positioning
- Must be `position: fixed`
- Not inside container with `overflow: hidden`
- Support `overflow-y: auto` for small-height devices

### 6. Z-Index Scale
```css
:root {
  --z-base: 0;
  --z-dropdown: 200;
  --z-sticky: 300;
  --z-modal: 400;
  --z-popover: 500;
  --z-tooltip: 600;
}
```

---

## Root-Cause Taxonomy

| Class | Symptom | Fix |
|-------|---------|-----|
| **A** | No visible nav on mobile | Add mobile trigger + overlay |
| **B** | Hidden by opacity/visibility | Verify state toggling logic |
| **C** | Clipped by overflow | Use `position: fixed` overlay |
| **D** | Behind another layer | Check z-index scale |
| **E** | Breakpoint mismatch | Verify viewport meta |
| **F** | JavaScript failure | Guard selectors, check console |
| **G** | Keyboard inaccessible | Use real `<button>` elements |
| **H** | Click-outside race condition | Exclude trigger from handler |

---

## React + shadcn/ui Implementation

### MobileNav Component
```tsx
"use client";

import * as React from "react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/Sheet";
import { Button } from "@/components/ui/Button";

const NAV_ITEMS = [
  { href: "/", label: "Home" },
  { href: "/about", label: "About" },
] as const;

export function MobileNav() {
  const [open, setOpen] = React.useState(false);
  const pathname = usePathname();

  React.useEffect(() => {
    setOpen(false); // Close on route change
  }, [pathname]);

  return (
    <Sheet open={open} onOpenChange={setOpen}>
      <SheetTrigger asChild>
        <Button variant="ghost" size="icon" className="md:hidden">
          <MenuIcon />
        </Button>
      </SheetTrigger>
      <SheetContent side="right" className="w-[300px]">
        <nav className="flex flex-col gap-4">
          {NAV_ITEMS.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setOpen(false)}
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </SheetContent>
    </Sheet>
  );
}
```

### DesktopNav Component
```tsx
export function DesktopNav() {
  return (
    <nav className="hidden md:flex items-center gap-8">
      {NAV_ITEMS.map((item) => (
        <Link key={item.href} href={item.href}>
          {item.label}
        </Link>
      ))}
    </nav>
  );
}
```

---

## Anti-Patterns (Avoid!)

### ❌ Anti-Pattern 1: Hide Nav Without Menu Trigger
```css
@media (max-width: 768px) {
  .nav-links { display: none; } /* Creates dead-end */
}
```

### ❌ Anti-Pattern 2: Random Z-Index
```css
.nav { z-index: 999999; } /* Hides architectural problems */
```

### ❌ Anti-Pattern 3: Non-Semantic Clickables
```tsx
<div onClick={toggleMenu}>Menu</div> /* Invisible to keyboard */
```

### ❌ Anti-Pattern 4: Missing Trigger at Correct Breakpoint
```tsx
<nav className="hidden md:flex">...</nav>
<button className="hidden md:inline-flex">Menu</button>
/* Nothing visible on mobile! */
```

### ❌ Anti-Pattern 5: SSR Conditional Nav
```tsx
const isMobile = window.innerWidth < 768; // Breaks on SSR
return isMobile ? <MobileNav/> : <DesktopNav/>;
```

### ❌ Anti-Pattern 6: Click-Outside Race Condition
```tsx
useEffect(() => {
  const handleClick = (e: MouseEvent) => {
    if (!menuRef.current?.contains(e.target as Node)) {
      setIsOpen(false); // Closes when toggle clicked!
    }
  };
  document.addEventListener('click', handleClick);
}, []);
```

**Fix:** Check both menu AND trigger:
```tsx
const handleClickOutside = (e: MouseEvent) => {
  const target = e.target as HTMLElement;
  if (menu && !menu.contains(target) && !trigger?.contains(target)) {
    setIsOpen(false);
  }
};
```

---

## Verification Checklist

### Keyboard Accessibility
- [ ] Tab reaches menu button
- [ ] Enter/Space opens menu
- [ ] Focus moves into menu
- [ ] Arrow keys navigate items
- [ ] Escape closes menu
- [ ] Focus returns to trigger after close
- [ ] Visible focus ring on all interactive elements

### Behavior
- [ ] Menu opens/closes reliably
- [ ] Clicking link closes menu
- [ ] Resizing to desktop closes menu
- [ ] No background scroll bleed when open
- [ ] Route change closes mobile menu
- [ ] Animations respect reduced motion

### Styling
- [ ] Trigger visible on mobile (`md:hidden`)
- [ ] Desktop links hidden on mobile (`hidden md:flex`)
- [ ] No purge issues (classes in production)
- [ ] Menu not clipped: top items visible
- [ ] Menu not behind header/hero layers
