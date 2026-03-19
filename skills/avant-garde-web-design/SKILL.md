---
name: avant-garde-web-design
description: Create distinctive, production-grade web interfaces that avoid generic "AI slop" aesthetics. Use when building UI components, pages, or applications requiring avant-garde design with intentional minimalism. Covers Tailwind CSS v4 CSS-first theming, Anti-Generic philosophy, WCAG AAA accessibility, mobile navigation patterns, and systematic design workflows. Includes strategic positioning frameworks, typography/color specifications, and implementation patterns for Next.js + Tailwind v4 + shadcn/ui stacks.
---

# Avant-Garde Web Design

> **Philosophy:** Intentionality is the only differentiator. Every element earns its place.
> **Stack:** Next.js 16+ • React 19+ • Tailwind CSS v4 (CSS-first) • shadcn/ui • Framer Motion

---

## When to Use This Skill

Use when:
- Building Next.js applications with Tailwind CSS v4 CSS-first architecture
- Creating distinctive, non-generic web interfaces
- Designing luxury, high-end, or memorable user experiences
- Implementing shadcn/ui components with custom styling
- Conducting code reviews for React/Next.js/TypeScript projects
- Debugging mobile navigation or visual layout issues
- Migrating from Tailwind v3 to v4

---

## Core Workflow: The 40-Minute Pre-Design Ritual

**Before writing any code, complete this ritual:**

### Phase 1: Strategic Positioning (15 min)

Read [`references/strategic-positioning.md`](references/strategic-positioning.md) and answer:

1. **Audience Psychographic Assessment**
   - Primary fear? → Institutional Clarity (risk) vs Dynamic Modernism (FOMO)
   - Decision style? → Rational (provide data) vs Emotional (create desire)
   - Trust source? → Institutions (signal legacy) vs Peers (signal community)
   - Category relationship? → New (build confidence) vs Experienced (signal superiority)

2. **Place on Strategic Positioning Matrix** — See [`references/strategic-positioning.md`](references/strategic-positioning.md) §2.1

### Phase 2: Design Direction (10 min)

Select aesthetic direction from [`references/design-directions.md`](references/design-directions.md):
- Brutally Minimal / Maximalist Chaos / Retro-Futuristic / Organic/Natural
- Luxury/Refined / Editorial/Magazine / Brutalist/Raw / Art Deco/Geometric

### Phase 3: Anti-Generic Litmus Test (10 min)

Answer for every major design decision:
- **Why?** — Tie to specific user need/psychology
- **Only?** — Challenge defaults, is this the only way?
- **Without?** — Would removal diminish the core experience?

### Phase 4: Technical Commitment (5 min)

From [`references/tech-commitments.md`](references/tech-commitments.md), pick top 3 commitments based on positioning.

---

## Tailwind CSS v4 (CSS-First Architecture)

**CRITICAL:** No `tailwind.config.js` — use CSS-only configuration.

### Required globals.css Structure

```css
@import "tailwindcss";

@theme {
  /* Colors - OKLCH color space */
  --color-primary: oklch(0.84 0.18 117.33);
  --color-text: #111827;
  --font-display: "Space Grotesk", sans-serif;
  --font-body: "Inter", sans-serif;
  --spacing-18: 4.5rem;
}
```

See [`references/tailwind-v4-migration.md`](references/tailwind-v4-migration.md) for:
- v3 → v4 utility mappings (`shadow-sm` → `shadow-xs`, `bg-gradient-*` → `bg-linear-*`)
- CSS variable syntax changes (`bg-[--color]` → `bg-(--color)`)
- Container queries, custom utilities, variant stacking

---

## Anti-Generic Design Principles

### Forbidden Patterns (The "Safe Harbor")

| Avoid | Why | Think Instead |
|-------|-----|---------------|
| Bento grids | Modern cliché | Why does this content NEED a grid? |
| Hero split (left/right) | Predictable | Massive typography or vertical narrative |
| Mesh/Aurora gradients | Lazy background | Radical color pairing |
| Glassmorphism (blue/white) | AI's "premium" | Solid, high-contrast flat |
| Deep Cyan / Fintech Blue | Safe harbor | Red, Black, or Neon Green |
| Inter/Roboto defaults | Without hierarchy | Distinctive type pairings |
| Purple-gradient-on-white | Cliché | Unexpected combinations |

### Universal Truths

1. **Intentionality is differentiation** — Document "why" for every decision
2. **Hierarchy is sacred duty** — Test by squinting; if it collapses, redesign
3. **Whitespace is voice** — Structural material, not empty space
4. **Accessibility is mastery** — Engineer for inclusion from the start

See [`references/anti-generic-checklist.md`](references/anti-generic-checklist.md) for complete checklist.

---

## Validated Design Specifications

### Typography Systems

| Approach | Fonts | Use Case |
|----------|-------|----------|
| **Institutional (Single Family)** | DM Sans only | Corporate, fast-loading, cohesive |
| **Expressive (Two-Family)** | Space Grotesk + Inter | Modern tech, personality + readability |
| **With Mono Labels** | Either + JetBrains Mono | Technical/data-heavy |

H1 Scale: 60-77px, line-height 1.0-1.06, letter-spacing -0.03em to -0.04em

### Color Palettes

See [`references/color-palettes.md`](references/color-palettes.md) for:
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

### Root-Cause Taxonomy

| Class | Symptom | Fix |
|-------|---------|-----|
| **A** | No visible nav on mobile | Add mobile trigger + overlay |
| **B** | Hidden by opacity/visibility | Verify state toggling |
| **C** | Clipped by overflow | Use `position: fixed` |
| **D** | Behind another layer | Check z-index scale |
| **E** | Breakpoint mismatch | Verify viewport meta |
| **F** | JavaScript failure | Guard selectors, check console |
| **G** | Keyboard inaccessible | Use real `<button>` elements |
| **H** | Click-outside race | Exclude trigger from handler |

See [`references/mobile-navigation.md`](references/mobile-navigation.md) for complete patterns.

---

## Component Patterns (Library Discipline)

**CRITICAL:** If shadcn/Radix/MUI detected, USE IT. Don't rebuild.

| Component | Library Primitive | Styling |
|-----------|------------------|---------|
| Buttons | Shadcn `Button` | CVA variants |
| Cards | Shadcn `Card` | Custom top borders |
| Navigation | Shadcn `NavigationMenu` | Backdrop blur |
| Modals | Shadcn `Dialog` | Theme-aligned |
| Forms | Radix primitives | Validation with Zod |

### useReducedMotion Hook (Required)

```tsx
const prefersReducedMotion = useReducedMotion();
<motion.div
  initial={prefersReducedMotion ? {} : { opacity: 0 }}
  animate={{ opacity: 1 }}
/>
```

---

## Verification Gates

### Pre-Commit Checklist

```bash
npx tsc --noEmit      # Type check
npm run lint          # Lint
npm test              # Tests
npm run build         # Build
npm audit             # Security
```

### Design Quality Gate

- [ ] Distinctive aesthetic direction (not generic)
- [ ] Intentional whitespace usage
- [ ] Typography hierarchy is clear
- [ ] Animations respect `prefers-reduced-motion`
- [ ] Color contrast meets WCAG AAA (preferred) or AA
- [ ] Micro-interactions 150-300ms

---

## Reference Files

| File | When to Read |
|------|--------------|
| [`references/strategic-positioning.md`](references/strategic-positioning.md) | Always — Strategic framework |
| [`references/tailwind-v4-migration.md`](references/tailwind-v4-migration.md) | v3→v4 migration or v4 specifics |
| [`references/anti-generic-checklist.md`](references/anti-generic-checklist.md) | Design review |
| [`references/color-palettes.md`](references/color-palettes.md) | Color decisions |
| [`references/mobile-navigation.md`](references/mobile-navigation.md) | Navigation issues |
| [`references/design-directions.md`](references/design-directions.md) | Aesthetic direction selection |
| [`references/tech-commitments.md`](references/tech-commitments.md) | Technical requirements |

---

## Related Skills

| Skill | When to Use |
|-------|-------------|
| [aesthetic](../aesthetic/SKILL.md) | Inspiration capture, design iteration |
| [code-review](../code-review/SKILL.md) | Review protocols, feedback handling |
| [nextjs-react-expert](../nextjs-react-expert/SKILL.md) | Performance optimization |
| [ui-styling](../ui-styling/SKILL.md) | shadcn/ui implementation |
| [web-design-guidelines](../web-design-guidelines/SKILL.md) | Accessibility audit |

---

> **Remember:** Technical excellence requires both rigorous implementation and distinctive design. Every line of code and every pixel should demonstrate intentionality and craftsmanship.
