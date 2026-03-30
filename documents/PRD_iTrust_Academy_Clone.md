# Product Requirements Document (PRD)
## iTrust Academy Website Clone

**Source:** `https://www.itrust.academy/`
**Date:** 2026-03-27
**Status:** Draft

---

## 1. Executive Summary

Clone the iTrust Academy single-page marketing site — a professional B2B IT training and certification platform serving Asia. The site is a parent company subsidiary of iTrustech Pte Ltd, offering vendor-certified training across SolarWinds, Securden, Quest, and Ivanti platforms. The design is clean, corporate, and trust-oriented with a burnt-orange brand color, card-based layout, and content-heavy sections focused on course details, upcoming schedules, and cross-selling professional services.

---

## 2. Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Framework** | React 18+ (SPA) | Single `#root` mount point, no SSR |
| **Bundler** | Vite | Single hashed bundle: `assets/index-T6ilB86q.js` |
| **Styling** | CSS-in-JS or Tailwind | Computed class patterns, no CSS variables at `:root` |
| **Routing** | Client-side (React Router or equivalent) | Single page — all nav buttons are `<button>` not `<a>` |
| **Fonts** | DM Sans (body), Space Mono (monospace/accents) | Self-hosted or inline |
| **Icons** | 36 inline SVGs | No icon library detected — custom SVG icons throughout |
| **Hosting** | Cloudflare | Cloudflare Insights beacon present |
| **Logo** | Inline base64 PNG | 300×115px, orange gradient shield + "iTrust Academy" text |

---

## 3. Design System & Tokens

### 3.1 Color Palette

```
/* === BRAND PRIMARY === */
--brand-orange:       #F27A1A    rgb(242, 122, 26)     ← Primary brand, CTAs
--brand-orange-light: rgba(242, 122, 26, 0.08)         ← Badge/light backgrounds
--brand-orange-border: rgba(242, 122, 26, 0.25)        ← Light borders

/* === VENDOR COLORS === */
--vendor-solarwinds:  #F27A1A    (orange — matches brand)
--vendor-securden:    #2BBCB3    (teal)
--vendor-quest:       #3B82F6    (blue)
--vendor-ivanti:      #7C3AED    (purple)

/* === SEMANTIC === */
--success:            #059669    rgb(5, 150, 105)      ← AVAILABLE badges
--success-bg:         #ECFDF5   rgb(236, 253, 245)     ← Badge backgrounds
--success-border:     #A7F3D0   rgb(167, 243, 208)     ← Badge borders

/* === SURFACES === */
--bg-white:           #FFFFFF
--bg-gray:            #F8F9FA   rgb(248, 249, 250)     ← Alternating sections
--border-default:     #E5E7EB   rgb(229, 231, 235)     ← Cards, dividers
--border-strong:      #374151   rgb(55, 65, 81)        ← Footer divider

/* === TEXT === */
--text-dark:          #111827   rgb(17, 24, 39)        ← Headings, primary
--text-secondary:     #6B7280   rgb(107, 114, 128)     ← Body secondary
--text-muted:         #9CA3AF   rgb(156, 163, 175)     ← Tertiary
--text-white:         #FFFFFF

/* === FOOTER === */
--footer-bg:          #1F2937   rgb(31, 41, 55)        ← Dark charcoal
--footer-text:        #D1D5DB   rgb(209, 213, 219)     ← Muted white
--footer-heading:     #FFFFFF
--footer-border:      #374151
```

### 3.2 Typography

| Token | Value | Usage |
|-------|-------|-------|
| `--font-body` | `'DM Sans', sans-serif` | All body text, headings, UI |
| `--font-mono` | `'Space Mono', monospace` | Labels, badges, accent text |

**Font weights observed:** 400 (regular), 500 (medium), 600 (semibold), 700 (bold)

### 3.3 Spacing & Layout

```
--card-padding:       28px
--section-gap:        80-120px (vertical between sections)
--card-radius:        14px      ← Primary card radius
--button-radius:      10px      ← CTA button radius
--badge-radius:       4px       ← Status badges
--max-width:          ~1200px   (centered content container)
--nav-height:         ~64px
```

### 3.4 Button System

| Type | Background | Color | Border | Radius | Font |
|------|-----------|-------|--------|--------|------|
| **Primary CTA** | `#F27A1A` | `#FFFFFF` | none | 10px | 14px/600 |
| **Secondary/Outline** | `#FFFFFF` | `#111827` | 1px `#E5E7EB` | 10px | 14px/600 |
| **Nav "Enroll Now"** | `#F27A1A` | `#FFFFFF` | none | 10px | 14px/600 |
| **Nav link buttons** | transparent | `#111827` | none | — | 14px/500 |

### 3.5 Vendor Card System

Each vendor card has:
- **Top border:** 3px solid in vendor color (SolarWinds=orange, others per vendor)
- **Other borders:** 1px `#E5E7EB`
- **Border-radius:** 14px
- **Padding:** 28px
- **Background:** `#FFFFFF`
- **Hover:** cursor pointer, potential subtle shadow
- **Expanded state:** Shows full description paragraph below vendor name

---

## 4. Site Structure

This is a **single-page application** with no sub-routes. All navigation buttons scroll to page sections (or are non-functional placeholders). The page flows as one continuous scroll.

| Nav Item | Target | Status |
|----------|--------|--------|
| Home | Scroll to top | Functional |
| Courses | Section anchor | Placeholder/scroll |
| Schedule | Section anchor | Placeholder/scroll |
| Blog | — | Placeholder |
| Contact | — | Placeholder |
| Enroll Now | — | Placeholder |

---

## 5. Page Sections — Detailed Spec

### 5.1 Navigation Bar

**Layout:** Full-width, sticky/fixed top. White background. Horizontal flex layout.

```
┌──────────────────────────────────────────────────────────┐
│ [Logo]   Home  Courses  Schedule  Blog  Contact  [Enroll │Now]  [☰] │
└──────────────────────────────────────────────────────────┘
```

| Element | Details |
|---------|---------|
| Logo | Base64 PNG — orange gradient shield with "iTrust Academy" text. 300×115 native, rendered ~140px wide |
| Nav links | 5 text buttons: Home, Courses, Schedule, Blog, Contact |
| CTA | "Enroll Now" — orange filled button, right-aligned |
| Mobile | Hamburger icon replaces nav links; logo + Enroll Now remain |

### 5.2 Hero Section

**Background:** White (`#FFFFFF`)

**Layout:** Single column, centered content. No hero image — pure text-focused.

```
┌────────────────────────────────────┐
│        NOW ENROLLING — Q2 2026     │  ← Orange pill badge
│                                    │
│    Advance Your IT Career.         │  ← h1, large, bold
│         Get Certified.             │
│                                    │
│  iTrust Academy delivers expert-   │  ← Subtitle paragraph
│  led, hands-on training across...  │
│                                    │
│  [Explore SCP Fundamentals →]      │  ← Primary CTA
│  [View All Courses]                │  ← Secondary outline
│                                    │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐     │
│  │  4  │ │ 5+ │ │Asia│ │SCP │     │  ← 4 stat badges
│  │Tech │ │Prog│ │Wide│ │Cert│     │
│  └────┘ └────┘ └────┘ └────┘     │
└────────────────────────────────────┘
```

**Components:**
- **Enrollment badge:** Pill shape, orange-tinted bg, uppercase text, letter-spacing
- **H1:** "Advance Your IT Career." (line 1) + "Get Certified." (line 2, bold)
- **Subtitle:** Full-width paragraph describing the academy
- **CTAs:** Two buttons side-by-side (primary orange + outline)
- **Stats row:** 4 compact stat blocks with number + label

### 5.3 Authorized Training Partner Section

**Background:** Light gray (`#F8F9FA`)

**Section header:**
- Label: "AUTHORIZED TRAINING PARTNER" (uppercase, small, orange-tinted)
- H2: "Training Across Leading IT Platforms"

**Vendor Cards Grid:** 2×2 on desktop, stacked on mobile.

Each card:
```
┌─────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ ← 3px top border (vendor color)
│                             │
│  SolarWinds                 │ ← Vendor name (vendor color, bold)
│  Enterprise observability,  │ ← Description (expandable)
│  network monitoring...      │
│                             │
└─────────────────────────────┘
```

| Vendor | Top Border Color | Name Color | Status |
|--------|-----------------|------------|--------|
| SolarWinds | `#F27A1A` (orange) | `#F27A1A` | Active |
| Securden | `#2BBCB3` (teal) | `#2BBCB3` | Active |
| Quest | `#3B82F6` (blue) | `#3B82F6` | Active |
| Ivanti | `#7C3AED` (purple) | `#7C3AED` | Active |

**Interaction:** Clicking a card toggles expansion to show the full description paragraph.

### 5.4 "Training That Gets Results" (Why Choose Us)

**Background:** White (`#FFFFFF`)

**Section header:**
- Label: "WHY CHOOSE US"
- H2: "Training That Gets Results"

**Features Grid:** 3×2 on desktop (6 items), 2×3 on tablet, 1×6 on mobile.

Each feature card:
```
┌──────────────────────────────┐
│  🎓                          │ ← Emoji icon
│  Vendor-Certified Instructors│ ← Title (bold)
│  SolarWinds courses led by.. │ ← Description
└──────────────────────────────┘
```

**Features:**
1. 🎓 **Vendor-Certified Instructors** — SolarWinds courses led by SolarWinds Certified Instructors
2. 🖥️ **Hands-On Lab Environments** — Every course includes dedicated lab environments
3. 📋 **Certification-Aligned Curriculum** — Courses align to SCP exam domains
4. 🌏 **Regional Expertise** — Training in English, Mandarin, and Bahasa Melayu
5. ✅ **Certification Support** — SCP exam vouchers (2 attempts) included
6. 📞 **Post-Training Support** — Study materials, practice resources, instructor Q&A

### 5.5 Featured Course: SCP Observability Fundamentals

**Background:** White (`#FFFFFF`), full-width section.

**Layout:** Two-column on desktop. Left = course modules. Right = sidebar with exam domains + inclusions.

```
┌────────────────────────────────────────────────────────────┐
│ FEATURED COURSE · SOLARWINDS                               │
│ SCP Observability Self-Hosted Fundamentals                 │ ← h2
│                                                            │
│ This intensive 3-day program prepares IT professionals...  │ ← Description
│                                                            │
│ ┌─────────────────────────┐  ┌───────────────────────────┐ │
│ │ MODULE 1                │  │ SCP EXAM DOMAINS          │ │
│ │ Platform Architecture   │  │ ┌───────────────────────┐ │ │
│ │ & Node Management       │  │ │ Architecture    10% D1│ │ │
│ │ SCP Exam: 1.1 + 1.2    │  │ │ Node Mgmt       12% D1│ │ │
│ │ ─────────────────────── │  │ │ Customization   25% D2│ │ │
│ │ • SolarWinds Platform.. │  │ │ Alerts          20% D3│ │ │
│ │ • Network Sonar Wizard  │  │ │ Reports         20% D3│ │ │
│ │ • Node management...    │  │ │ Troubleshooting 13% D3│ │ │
│ │ +3 more topics          │  │ └───────────────────────┘ │ │
│ ├─────────────────────────┤  │                           │ │
│ │ MODULE 2                │  │ WHAT'S INCLUDED           │ │
│ │ Customization & User    │  │ ✓ 3 days training by SCI │ │
│ │ Experience              │  │ ✓ Official curriculum    │ │
│ │ ...                     │  │ ✓ Hands-on lab access    │ │
│ ├─────────────────────────┤  │ ✓ Study guide & 250 Q's  │ │
│ │ MODULE 3                │  │ ✓ SCP voucher (2 tries)  │ │
│ │ Alerts, Reports &       │  │ ✓ Certificate of compl.  │ │
│ │ Troubleshooting Tools   │  │                           │ │
│ │ ...                     │  │ [View Full Course Details→]│ │
│ └─────────────────────────┘  └───────────────────────────┘ │
└────────────────────────────────────────────────────────────┘
```

**Left Column — Course Modules:**
- 3 expandable module cards, each with:
  - Module number (large, bold)
  - Module title + SCP exam domain reference
  - Bullet list of topics with checkmark icons
  - "+N more topics" toggle

**Right Column — Sidebar (stacked):**

*Exam Domains Table:*
- Header: "SCP EXAM DOMAINS"
- 6-row table: Domain Name | Weight % | Day
- Row borders: 1px `#F0F0F0`
- Compact, data-dense layout

*What's Included List:*
- Header: "WHAT'S INCLUDED"
- 6 items with green checkmark icons:
  - 3 days of training by a SolarWinds Certified Instructor
  - Official SolarWinds Academy curriculum
  - Hands-on lab environment access
  - HCO Fundamentals Study Guide & 250 practice questions
  - SCP exam voucher (2 attempts included)
  - Certificate of completion

*CTA:* "View Full Course Details →" (orange button)

### 5.6 Upcoming Training Dates

**Background:** Light gray (`#F8F9FA`)

**Section header:**
- Label: "UPCOMING TRAINING"
- H2: "Next Public Course Dates"
- Subtitle: "Browse our full schedule or register your interest for an upcoming session."

**Schedule Cards:** List layout, each card is a row.

```
┌──────────────────────────────────────────────────────────┐
│ SolarWinds                                               │
│ SolarWinds Observability Self-Hosted Fundamentals        │
│                                                          │
│ 📅 14 Apr–16 Apr    📍 Singapore    [AVAILABLE]          │
└──────────────────────────────────────────────────────────┘
```

Each card:
- Left-accent border: 4px solid `#F27A1A` (orange)
- Border-radius: 14px
- Background: `#FFFFFF`
- Content:
  - Vendor name (small, vendor color)
  - Course title (bold)
  - Meta row: Date (calendar icon) | Location (pin icon) | Status badge
- **Status badge "AVAILABLE":** `#059669` text, `#ECFDF5` bg, `#A7F3D0` border, 4px radius
- **Hover:** cursor pointer, subtle elevation

**CTA:** "View Full Schedule →" (orange button, centered below cards)

### 5.7 "Beyond Training" — iTrustech Professional Services

**Background:** White (`#FFFFFF`)

**Section header:**
- Label: "iTRUSTECH PROFESSIONAL SERVICES"
- H2: "Beyond Training — We're Here to Help"
- Subtitle: "iTrust Academy is the training arm of iTrustech. For hands-on help beyond certification, our professional services team has you covered."

**Services Grid:** List/cards linking to `https://www.itrustech.com`

Each service card:
```
┌─────────────────────────────────────┐
│  Professional Services              │ ← Title (bold)
│  Deployment, configuration, and     │ ← Description
│  platform optimization.             │
│                                     │
│  itrustech.com →                    │ ← External link
└─────────────────────────────────────┘
```

**5 Services:**
1. Professional Services — Deployment, configuration, and platform optimization
2. Migration & Upgrades — Planning, execution, and post-migration validation
3. Health Assessments — Environment health checks with actionable recommendations
4. Optimization — Alert tuning, reporting, and polling optimization
5. Software Licensing — Licensing guidance, renewals, and procurement

**Bottom note:** "iTrust Academy = Training & Certification | iTrustech = Professional Services, Licensing & More → www.itrustech.com"

### 5.8 Footer

**Background:** Dark charcoal (`#1F2937`)

**Layout:** 5-column grid on desktop, stacked on mobile.

```
┌──────────────────────────────────────────────────────────────────┐
│ SolarWinds         Other Vendors    Resources    Company   Need │
│ ─────────────      ──────────────   ─────────    ───────   More │
│ SCP Fundamentals   Securden PAM     Blog         About     ...  │
│ SAM & Log Analyz.  Quest (Soon)     Schedule     Contact        │
│ Database Fund.     Ivanti (Soon)    SCP Exam ↗                   │
│ Service Desk                                                     │
├──────────────────────────────────────────────────────────────────┤
│ [Logo]  © 2026 iTrust Academy by iTrustech Pte Ltd              │
│         Headquarters in Singapore · Offices in HK & Malaysia     │
└──────────────────────────────────────────────────────────────────┘
```

**Column 1 — SolarWinds Courses:**
- SCP Fundamentals
- SAM & Log Analyzer
- Database Fund. & Adv.
- Service Desk & Leadership

**Column 2 — Other Vendors:**
- Securden PAM
- Quest (Coming Soon)
- Ivanti (Coming Soon)

**Column 3 — Resources:**
- Blog
- Schedule
- SCP Exam Info (external link → solarwinds.com)

**Column 4 — Company:**
- About iTrustech (external link → itrustech.com)
- Contact Us

**Column 5 — Need More Than Training?:**
- Professional Services (→ itrustech.com)
- Migration & Upgrades (→ itrustech.com)
- Health Assessments (→ itrustech.com)
- Software Licensing (→ itrustech.com)

**Bottom Bar:**
- Logo (small)
- "© 2026 iTrust Academy by iTrustech Pte Ltd"
- "Headquarters in Singapore · Offices in Hong Kong & Malaysia · Training across Asia"

---

## 6. Interactive Behaviors

| Component | Behavior |
|-----------|----------|
| **Vendor cards** | Click to expand/collapse description text. Toggle with animation. |
| **Course module cards** | Expand/collapse to show "+N more topics" |
| **Nav buttons** | Smooth scroll to corresponding section (or non-functional placeholder) |
| **Mobile hamburger** | Slide-in or overlay menu with all nav links |
| **CTA buttons** | Hover: subtle opacity/darken shift. Press: scale down slightly. |
| **Schedule cards** | Hover: slight elevation + border highlight |
| **External links** | Open in new tab (itrustech.com, solarwinds.com) |
| **"Enroll Now"** | Placeholder — could link to a form or be non-functional |

---

## 7. Responsive Design

### Breakpoints

| Breakpoint | Width | Layout Changes |
|-----------|-------|----------------|
| Mobile | < 768px | Single column, hamburger nav, stacked cards |
| Tablet | 768–1023px | 2-column vendor grid, condensed layout |
| Desktop | ≥ 1024px | Full layout, 2-column vendor grid, side-by-side course details |

### Mobile-Specific Changes
- **Nav:** Hamburger menu (top-right), logo left, "Enroll Now" button visible
- **Hero:** Stats badges wrap to 2×2 grid
- **Vendor cards:** Stack vertically
- **Features:** Stack to single column
- **Course section:** Modules and sidebar stack vertically
- **Schedule cards:** Full width
- **Services:** Stack vertically
- **Footer:** Single column, accordion-style or stacked sections

---

## 8. Asset Requirements

| Asset | Format | Details |
|-------|--------|---------|
| **Logo** | SVG (preferred) or PNG | Orange gradient shield with "iTrust Academy" wordmark. Current: 300×115 base64 PNG |
| **Vendor icons** | Inline SVG | Optional logos for SolarWinds, Securden, Quest, Ivanti |
| **Feature emoji** | Unicode emoji | 🎓 🖥️ 📋 🌏 ✅ 📞 (no image assets needed) |
| **Checkmark icon** | Inline SVG | Green checkmark for "What's Included" list |
| **Arrow icons** | Inline SVG | Right arrows for "→" on CTAs and links |
| **Calendar icon** | Inline SVG | Used in schedule date display |
| **Location pin icon** | Inline SVG | Used in schedule location display |
| **External link icon** | Inline SVG | Small arrow/box icon for outbound links |
| **Hamburger icon** | Inline SVG | Mobile nav toggle |
| **Chevron/down icon** | Inline SVG | For expandable sections (vendor cards, modules) |

---

## 9. Content Inventory

### 9.1 Copy Text

**Hero:**
> NOW ENROLLING — Q2 2026
> Advance Your IT Career. Get Certified.
> iTrust Academy delivers expert-led, hands-on training across SolarWinds, Securden, Quest, and Ivanti — equipping IT professionals across Asia with the skills and certifications employers demand.

**Stats:** 4 Technology Vendors | 5+ Training Programs | Asia-Wide Coverage | SCP Certification Prep

**Section — Authorized Training Partner:**
> Training Across Leading IT Platforms

**Vendor descriptions:**
- **SolarWinds:** Enterprise observability, network monitoring, database performance, and ITSM. SolarWinds Certified Instructors delivering official SolarWinds Academy curriculum. SCP exam vouchers included.
- **Securden:** Unified Privileged Access Management for credential security, session monitoring, and compliance. Training by Securden Authorized Trainers.
- **Quest:** IT management, Active Directory security, migration, and data protection. Authorized training for Quest product deployment.
- **Ivanti:** Endpoint management, ITSM, and security for the modern digital workplace. Authorized Ivanti platform training.

**Section — Why Choose Us:**
> Training That Gets Results

**Section — Featured Course:**
> FEATURED COURSE · SOLARWINDS
> SCP Observability Self-Hosted Fundamentals
> This intensive 3-day program prepares IT professionals for the SolarWinds Certified Professional (SCP) Hybrid Cloud Observability Fundamentals examination.

**Section — Upcoming Training:**
> Next Public Course Dates
> Browse our full schedule or register your interest for an upcoming session.

**Schedule entries:**
1. SolarWinds Observability Self-Hosted Fundamentals — 14 Apr–16 Apr — Singapore — AVAILABLE
2. SolarWinds Observability Self-Hosted Fundamentals — 21 Apr–23 Apr — Online (Zoom) — AVAILABLE
3. Securden Unified PAM — Administration Training — 28 Apr–29 Apr — Singapore — AVAILABLE

**Section — Professional Services:**
> Beyond Training — We're Here to Help
> iTrust Academy is the training arm of iTrustech. For hands-on help beyond certification, our professional services team has you covered.

---

## 10. Non-Functional Requirements

- **No backend required** — static marketing page, all content hardcoded
- **No authentication** — "Enroll Now" buttons are non-functional (UI only)
- **External links** — itrustech.com and solarwinds.com links open in new tabs
- **SEO:** Semantic HTML, proper heading hierarchy (h1 → h2), meta tags, Open Graph
- **Accessibility:** WCAG 2.1 AA — keyboard nav, focus states, color contrast ≥ 4.5:1
- **Performance:** Lighthouse ≥ 90, FCP < 1.5s, LCP < 2.5s
- **Cross-browser:** Chrome, Firefox, Safari, Edge (latest 2 versions)
- **Single page:** No routing needed — smooth scroll navigation only

---

## 11. Recommended Project Structure

```
itrust-academy/
├── public/
│   ├── favicon.ico
│   └── logo.svg (or logo.png)
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Navbar.tsx
│   │   │   ├── MobileMenu.tsx
│   │   │   └── Footer.tsx
│   │   ├── sections/
│   │   │   ├── Hero.tsx
│   │   │   ├── VendorPlatforms.tsx
│   │   │   ├── WhyChooseUs.tsx
│   │   │   ├── FeaturedCourse.tsx
│   │   │   ├── UpcomingSchedule.tsx
│   │   │   └── ProfessionalServices.tsx
│   │   ├── cards/
│   │   │   ├── VendorCard.tsx
│   │   │   ├── FeatureCard.tsx
│   │   │   ├── ScheduleCard.tsx
│   │   │   ├── ServiceCard.tsx
│   │   │   └── CourseModule.tsx
│   │   └── ui/
│   │       ├── Button.tsx
│   │       ├── Badge.tsx
│   │       ├── SectionHeader.tsx
│   │       └── StatBadge.tsx
│   ├── data/
│   │   ├── vendors.ts
│   │   ├── courses.ts
│   │   ├── features.ts
│   │   ├── schedule.ts
│   │   └── services.ts
│   ├── styles/
│   │   └── globals.css
│   ├── icons/
│   │   └── (inline SVG components)
│   ├── App.tsx
│   └── main.tsx
├── index.html
├── tailwind.config.ts (or styled-components config)
├── vite.config.ts
├── tsconfig.json
├── package.json
└── README.md
```

---

## 12. Development Phases

### Phase 1: Scaffold & Foundation
- Initialize Vite + React + TypeScript
- Set up CSS/styling solution with design tokens
- Build Navbar (desktop + mobile hamburger)
- Build Footer (5-column grid)

### Phase 2: Core Sections (top → bottom)
1. Hero section (badge, heading, CTAs, stat badges)
2. Vendor Platforms (2×2 expandable cards)
3. Why Choose Us (3×2 feature grid)

### Phase 3: Featured Course Section
1. Course header + description
2. Module cards (expandable with topic lists)
3. Exam domains table
4. "What's Included" checklist
5. CTA button

### Phase 4: Schedule & Services
1. Upcoming training schedule cards
2. Professional services section
3. Cross-linking to itrustech.com

### Phase 5: Polish & QA
- Responsive testing (mobile, tablet, desktop)
- Hover/transition animations
- Accessibility audit (keyboard, contrast, screen reader)
- Performance optimization
- Cross-browser testing

---

## 13. Acceptance Criteria

- [ ] Single-page layout matches reference site within 95% visual fidelity
- [ ] All 7 major sections render correctly in order
- [ ] Vendor cards expand/collapse with smooth animation
- [ ] Course module cards expand to show additional topics
- [ ] Fully responsive at mobile (< 768px), tablet (768–1023px), desktop (≥ 1024px)
- [ ] Mobile hamburger menu functional with all nav items
- [ ] External links (itrustech.com, solarwinds.com) open in new tab
- [ ] "AVAILABLE" badges display with correct green styling
- [ ] Footer 5-column layout with correct link groupings
- [ ] Orange brand color (#F27A1A) used consistently for CTAs, accents, SolarWinds
- [ ] Vendor colors correctly applied (SolarWinds=orange, Securden=teal, Quest=blue, Ivanti=purple)
- [ ] Lighthouse: Performance ≥ 90, Accessibility ≥ 95
- [ ] Semantic HTML with proper heading hierarchy (single h1, multiple h2)
- [ ] Keyboard-navigable with visible focus states
- [ ] No console errors or warnings

---

*End of PRD*
