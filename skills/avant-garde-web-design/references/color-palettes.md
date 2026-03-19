# Color Palettes & Typography Systems

## Validated Color Palettes

### Warm Authority (Institutional Clarity)
Single accent for trust-building, B2B focus.

```css
:root {
  --color-primary: #F27A1A;        /* Warm orange */
  --color-primary-subtle: rgba(242, 122, 26, 0.08);
  --color-bg-primary: #FFFFFF;
  --color-bg-secondary: #F8F9FA;
  --color-text-primary: #111827;   /* Near-black */
  --color-text-secondary: #6B7280; /* Gray */
  --color-status-green: #059669;
}

/* Vendor accents (optional) */
--color-accent-1: #2BBCB4;  /* Teal - SolarWinds */
--color-accent-2: #3B82F6;  /* Blue - Securden */
--color-accent-3: #7C3AED;  /* Violet - Quest */
```

**Use when:** B2B services, enterprise, regulated industries, long sales cycles.

---

### Tech Ambition (Dynamic Modernism)
Multi-accent for energy, B2C focus.

```css
:root {
  --color-primary: #4F46E5;        /* Indigo */
  --color-primary-subtle: rgba(79, 70, 229, 0.08);
  --color-primary-light: #E0E7FF;
  --color-bg-primary: #FAFAF9;     /* Warm off-white */
  --color-bg-card: #F8FAFC;        /* Cool off-white */
  --color-bg-dark: #1E293B;        /* Slate-800 */
  --color-text-primary: #15172A;   /* Slate-900 */
  --color-text-secondary: #475569; /* Slate-600 */

  /* Accent palette */
  --color-accent-cyan: #06B6D4;
  --color-accent-emerald: #10B981;
  --color-accent-amber: #F59E0B;
  --color-accent-violet: #7C3AED;
  --color-urgency: #EF4444;        /* Red for scarcity */
}
```

**Use when:** B2C, tech-forward audiences, competitive markets, conversion funnels.

---

## Typography Systems

### Institutional Clarity (Single Family)
Cohesive, fast-loading, unified.

```css
:root {
  --font-family: 'DM Sans', system-ui, sans-serif;
  --font-mono: 'Space Mono', monospace; /* Labels/stats only */
}

h1 { font-size: 76.8px; font-weight: 700; line-height: 1.06; letter-spacing: -0.03em; }
h2 { font-size: 40px; font-weight: 700; line-height: 1.2; letter-spacing: -0.02em; }
h3 { font-size: 24px; font-weight: 600; line-height: 1.3; }
body { font-size: 16px; font-weight: 400; line-height: 1.6; }
```

**Key Insight:** Single font family creates instant cohesion. Mono reserved for technical elements only.

---

### Dynamic Modernism (Two-Family)
Personality + readability.

```css
:root {
  --font-display: 'Space Grotesk', sans-serif;
  --font-body: 'Inter', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}

h1 { font-family: var(--font-display); font-size: 60px; font-weight: 700; line-height: 1.0; letter-spacing: -0.04em; }
h2 { font-family: var(--font-display); font-size: 36px; font-weight: 700; line-height: 1.2; }
h3 { font-family: var(--font-display); font-size: 24px; font-weight: 600; line-height: 1.3; }
body { font-family: var(--font-body); font-size: 16px; font-weight: 400; line-height: 1.6; }
.labels { font-family: var(--font-mono); font-size: 13px; }
```

**Key Insight:** Two-font pairing balances personality with readability. More character than single-family approach.

---

## Typography Pairings (Ready to Use)

| Pairing | Use Case | Fonts |
|---------|----------|-------|
| **Single family** | Corporate, fast-loading | DM Sans only |
| **Display + body** | Modern tech, personality | Space Grotesk + Inter |
| **With mono labels** | Technical/data-heavy | Either + JetBrains Mono |

---

## 60-30-10 Rule

```
60% → Primary/Background (calm, neutral base)
30% → Secondary (supporting areas)
10% → Accent (CTAs, highlights, attention)
```

---

## Color Psychology

| If You Need... | Consider Hues | Avoid |
|----------------|---------------|-------|
| Trust, calm | Blue family | Aggressive reds |
| Growth, nature | Green family | Industrial grays |
| Energy, urgency | Orange, red | Passive blues |
| Luxury, creativity | Deep Teal, Gold, Emerald | Cheap-feeling brights |
| Clean, minimal | Neutrals | Overwhelming color |

---

## Layout Specifications

### Shared Standards
| Pattern | Value |
|---------|-------|
| Max content width | 1140px |
| Navigation height | 68px |
| Card border radius | 12-16px |
| Card padding | 24-32px |
| Section padding | 4-8rem vertical |

### Border/Shadow Defaults
```css
.card {
  border-radius: 14px;
  padding: 28px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

/* Dark mode */
.dark .card {
  background: rgba(30, 41, 59, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
}
```
