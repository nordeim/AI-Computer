# Patterns Catalog

Validated patterns extracted from comparative analysis of iTrust Academy and AI Academy.

---

## Patterns to Steal

### Credibility & Trust

| Pattern | Source | Implementation |
|---------|--------|----------------|
| **Exam domain transparency table** | iTrust | Percentage + day mapping. Builds credibility through specificity. |
| **Vendor authorization badges** | iTrust | "Authorized Training Partner" logos. Institutional trust signals. |
| **FAANG logo trust bar** | AI Academy | Company logos grayscale → color on hover. Subtle, professional. |
| **Quantified outcomes** | AI Academy | "94% completion", "92% placement", "45% salary increase". |

### Visual Hierarchy

| Pattern | Source | Implementation |
|---------|--------|----------------|
| **Stats in hero** | Both | 4 metrics: large numbers + small labels |
| **Dark section for premium** | AI Academy | Visual rhythm break for pricing/featured content |
| **Status pills** | Both | "AVAILABLE" (green), "FILLING FAST" (amber), "OPEN" (blue) |
| **Card top-border coding** | Both | 3px colored top border for category differentiation |

### Conversion Psychology

| Pattern | Source | Implementation |
|---------|--------|----------------|
| **Strikethrough + urgency** | AI Academy | Original price + discounted + "Only 8 spots" |
| **Month/day date badges** | AI Academy | Calendar-style visual treatment |
| **Early bird deadlines** | AI Academy | Specific dates create authentic urgency |
| **Multiple CTA placements** | iTrust | Strategic CTAs throughout scroll |

### Typography & Content

| Pattern | Source | Implementation |
|---------|--------|----------------|
| **Single font discipline** | iTrust | DM Sans throughout. Mono for stats only. |
| **Two-font system** | AI Academy | Space Grotesk headlines + Inter body |
| **Monospace for statistics** | Both | JetBrains Mono/Space Mono for numbers |
| **Ghost buttons with arrows** | iTrust | Subtle secondary navigation |

---

## Component Implementation Examples

### Status Badges
```html
<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium
  bg-green-100 text-green-800">AVAILABLE</span>

<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium
  bg-amber-100 text-amber-800">FILLING FAST</span>

<span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium
  bg-blue-100 text-blue-800">OPEN</span>
```

### Trust Bar
```html
<div class="flex items-center justify-center gap-8 py-8">
  <img src="google.svg" 
    class="h-8 opacity-50 grayscale hover:opacity-100 hover:grayscale-0 transition-all" />
  <img src="microsoft.svg" 
    class="h-8 opacity-50 grayscale hover:opacity-100 hover:grayscale-0 transition-all" />
</div>
```

### Stats in Hero
```html
<div class="grid grid-cols-2 md:grid-cols-4 gap-8">
  <div>
    <div class="text-4xl font-bold font-mono">94%</div>
    <div class="text-sm text-muted-foreground">Completion Rate</div>
  </div>
</div>
```

### Dark Section
```html
<section class="bg-slate-900 text-white py-16">
  <!-- Premium content, pricing, featured course -->
</section>
```

---

## Anti-Patterns Each Avoids

| iTrust Avoids | AI Academy Avoids |
|---------------|-------------------|
| Stock photography clichés | Corporate sterility |
| Over-animation | Single-color monotony |
| Vague promises | Generic stock illustrations |
| Pricing without context | Information overload in hero |

---

## Anti-Patterns to Avoid

| Anti-Pattern | Why It Fails | Alternative |
|--------------|--------------|-------------|
| Emoji icons in enterprise | Undermines credibility | Lucide/Heroicons |
| Generic stock photos | Zero distinctiveness | Custom/abstract |
| Purple-gradient-on-white | "AI slop" signal | Unexpected combinations |
| Predictable card grids | No memorability | Asymmetric layouts |
| Inter/Roboto without hierarchy | Safe = forgettable | Distinctive display font |
| Hidden pricing on B2C | Creates friction | Transparent or "Request Quote" |
| Dark mode without verification | Accessibility failure | Explicit contrast testing |

---

## Conversion Optimization

### Urgency Without Manipulation

| Bad | Good |
|-----|------|
| "BUY NOW OR MISS OUT!" | "Only 8 spots remaining" |
| Countdown timer that loops | Specific cohort start date |
| Fake scarcity | Real enrollment numbers |

### Trust Architecture

| B2B (iTrust) | B2C (AI Academy) |
|--------------|------------------|
| Vendor partnerships | FAANG logos |
| Certifications | Outcome percentages |
| Regional specificity | Community size |
| Professional services | Student testimonials |

---

## Layout Specifications

| Element | Both Sites | Rationale |
|---------|------------|-----------|
| Max content width | 1140px | Optimal line length |
| Navigation height | 68px fixed | Standard, accessible |
| Card border-radius | 12-14px | Modern, approachable |
| Card padding | 24-32px | Generous spacing |
| Section padding | 4-8rem vertical | Breathing room |

---

**See Also:** [`color-palettes.md`](color-palettes.md) for palette specifications.
