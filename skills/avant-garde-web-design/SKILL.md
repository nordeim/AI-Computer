---
name: avant-garde-web-design
description: |
  Elite web design skill for producing distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Use when: (1) Building new web UI from scratch, (2) Creating luxury/premium brand experiences, (3) Designing landing pages, marketing sites, or product showcases, (4) Migrating from Tailwind v3 to v4, (5) Debugging mobile navigation issues, (6) Conducting UI code reviews, (7) User asks for "avant-garde", "distinctive", "non-generic", "luxury", or "premium" design. Triggers on: "create a beautiful website", "design a landing page", "build a luxury UI", "make it distinctive", "avoid generic design", "mobile nav not working", "tailwind v4 migration". Covers Tailwind CSS v4 CSS-first theming, Anti-Generic philosophy, WCAG AAA accessibility, mobile navigation patterns, strategic positioning frameworks, and implementation patterns for Next.js + Tailwind v4 + shadcn/ui stacks.
---

# Avant-Garde Web Design

> **Philosophy:** Intentionality is the only differentiator. Every element earns its place.
> **Stack:** Next.js 16+ • React 19+ • Tailwind CSS v4 (CSS-first) • shadcn/ui • Framer Motion

---

## Core Workflow: The 40-Minute Pre-Design Ritual

**Before writing code, complete this ritual:**

### Phase 1: Strategic Positioning (15 min)

Read [`references/strategic-positioning.md`](references/strategic-positioning.md) and answer:

1. **Audience Assessment**
   - Primary fear? → Institutional Clarity (risk) vs Dynamic Modernism (FOMO)
   - Decision style? → Rational (provide data) vs Emotional (create desire)
   - Trust source? → Institutions (signal legacy) vs Peers (signal community)

2. **Place on Strategic Positioning Matrix**

### Phase 2: Design Direction (10 min)

Select aesthetic direction from [`references/design-directions.md`](references/design-directions.md):
Brutally Minimal / Maximalist Chaos / Retro-Futuristic / Organic/Natural / Luxury/Refined / Editorial/Magazine / Brutalist/Raw / Art Deco/Geometric

### Phase 3: Anti-Generic Litmus Test (10 min)

Answer for every major decision:
- **Why?** — Tie to specific user need/psychology
- **Only?** — Challenge defaults, is this the only way?
- **Without?** — Would removal diminish the core experience?

### Phase 4: Technical Commitment (5 min)

From [`references/tech-commitments.md`](references/tech-commitments.md), pick top 3 commitments based on positioning.

---

## Tailwind CSS v4 (CSS-First Architecture)

**CRITICAL:** No `tailwind.config.js` — use CSS-only configuration.

```css
@import "tailwindcss";

@theme {
  --color-primary: oklch(0.84 0.18 117.33);
  --font-display: "Space Grotesk", sans-serif;
}
```

**References:**
- [`tailwind-v4-migration.md`](references/tailwind-v4-migration.md) — Setup, utility mappings, syntax changes
- [`tailwind-v4-pitfalls.md`](references/tailwind-v4-pitfalls.md) — Common pitfalls, performance, browser requirements

---

## Anti-Generic Design Principles

### Forbidden Patterns (The "Safe Harbor")

| Avoid | Why | Think Instead |
|-------|-----|---------------|
| Bento grids | Modern cliché | Why does this NEED a grid? |
| Hero split (left/right) | Predictable | Massive typography |
| Mesh/Aurora gradients | Lazy background | Radical color pairing |
| Glassmorphism (blue/white) | AI's "premium" | High-contrast flat |
| Inter/Roboto defaults | Without hierarchy | Distinctive type pairings |
| Purple-gradient-on-white | Cliché | Unexpected combinations |

### Universal Truths

1. **Intentionality is differentiation** — Document "why" for every decision
2. **Hierarchy is sacred duty** — Test by squinting; if it collapses, redesign
3. **Whitespace is voice** — Structural material, not empty space
4. **Accessibility is mastery** — Engineer for inclusion from the start

**Reference:** [`anti-generic-checklist.md`](references/anti-generic-checklist.md)

---

## Design Specifications

### Typography

| Approach | Fonts | Use Case |
|----------|-------|----------|
| **Institutional** | DM Sans only | Corporate, cohesive |
| **Expressive** | Space Grotesk + Inter | Modern tech, personality |
| **With Mono** | Either + JetBrains Mono | Technical/data-heavy |

H1 Scale: 60-77px, line-height 1.0-1.06

### Color Palettes

**Reference:** [`color-palettes.md`](references/color-palettes.md)
- **Warm Authority:** `#F27A1A` primary, white background, single accent
- **Tech Ambition:** `#4F46E5` primary, multi-accent (cyan, emerald, amber, violet)

---

## Mobile Navigation Patterns

### Non-Negotiable Guardrails

1. **Viewport meta required:** `<meta name="viewport" content="width=device-width, initial-scale=1">`
2. **Never destroy nav without substitution** — Add mobile trigger + overlay
3. **Symmetrical breakpoints:** Desktop `hidden md:flex`, Mobile `md:hidden`
4. **Semantic controls:** Use `<button>`, not `<div onClick>`
5. **Overlay positioning:** `position: fixed`, `overflow-y: auto`

### Root-Cause Taxonomy (Classes A-H)

| Class | Symptom | Fix |
|-------|---------|-----|
| **A** | No visible nav | Add mobile trigger + overlay |
| **B** | Hidden by opacity | Verify state toggling |
| **C** | Clipped by overflow | Use `position: fixed` |
| **D** | Behind another layer | Check z-index scale |
| **E** | Breakpoint mismatch | Verify viewport meta |
| **F** | JavaScript failure | Guard selectors, check console |
| **G** | Keyboard inaccessible | Use real `<button>` elements |
| **H** | Click-outside race | Exclude trigger from handler |

**References:**
- [`mobile-navigation.md`](references/mobile-navigation.md) — Implementation patterns
- [`mobile-nav-debugging.md`](references/mobile-nav-debugging.md) — Debugging workflow

---

## Component Patterns (Library Discipline)

**CRITICAL:** If shadcn/Radix/MUI detected, USE IT. Don't rebuild.

| Component | Library Primitive |
|-----------|------------------|
| Buttons | Shadcn `Button` + CVA variants |
| Cards | Shadcn `Card` + custom top borders |
| Navigation | Shadcn `NavigationMenu` + backdrop blur |
| Modals | Shadcn `Dialog` + theme-aligned |

### useReducedMotion Hook (Required)

```tsx
const prefersReducedMotion = useReducedMotion();
<motion.div initial={prefersReducedMotion ? {} : { opacity: 0 }} />
```

---

## Verification Gates

### Pre-Commit Checklist

```bash
npx tsc --noEmit && npm run lint && npm test && npm run build && npm audit
```

### Design Quality Gate

- [ ] Distinctive aesthetic direction (not generic)
- [ ] Intentional whitespace usage
- [ ] Typography hierarchy is clear
- [ ] Animations respect `prefers-reduced-motion`
- [ ] Color contrast meets WCAG AAA (preferred) or AA

---

## Reference Files

| File | When to Read |
|------|--------------|
| [`strategic-positioning.md`](references/strategic-positioning.md) | Always — Strategic framework |
| [`tailwind-v4-migration.md`](references/tailwind-v4-migration.md) | v3→v4 migration or v4 setup |
| [`tailwind-v4-pitfalls.md`](references/tailwind-v4-pitfalls.md) | Debugging v4 issues |
| [`anti-generic-checklist.md`](references/anti-generic-checklist.md) | Design review |
| [`color-palettes.md`](references/color-palettes.md) | Color decisions |
| [`design-directions.md`](references/design-directions.md) | Aesthetic direction selection |
| [`mobile-navigation.md`](references/mobile-navigation.md) | Nav implementation |
| [`mobile-nav-debugging.md`](references/mobile-nav-debugging.md) | Nav debugging |
| [`patterns-catalog.md`](references/patterns-catalog.md) | UI patterns to steal |
| [`tech-commitments.md`](references/tech-commitments.md) | Technical requirements |

---

## Related Skills

`aesthetic` (inspiration) • `code-review` (reviews) • `nextjs-react-expert` (performance) • `ui-styling` (shadcn) • `web-design-guidelines` (a11y)

---

> Technical excellence requires both rigorous implementation and distinctive design.
