# Product Requirements Document (PRD)
## AI Academy Website Clone

**Source:** `https://ai-academy.jesspete.shop/`
**Date:** 2026-03-27
**Status:** Draft

---

## 1. Executive Summary

Clone the AI Academy single-page marketing site — a polished, modern educational platform landing page for an AI engineering bootcamp. The site uses a clean, professional design with an indigo/cyan accent palette, modern typography, and a conversion-focused layout. It consists of a **Landing Page (Home)** and a **Courses Catalog** page, with interactive UI components (filter tabs, pricing cards, cohort schedules, newsletter signup).

---

## 2. Tech Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| **Framework** | React 18 + TypeScript | SPA with client-side routing |
| **Bundler** | Vite | Fast HMR dev experience |
| **Styling** | Tailwind CSS | Extensive custom design tokens via CSS variables |
| **Routing** | React Router (or equivalent) | Routes: `/`, `/courses` |
| **Fonts** | Google Fonts | Space Grotesk (display), Inter (body), JetBrains Mono (code) |
| **Icons** | Lucide (or inline SVG) | Consistent icon set throughout |
| **Hosting** | Cloudflare (detected) | Cloudflare Insights beacon present |

---

## 3. Design System & Tokens

### 3.1 Color Palette

```
--color-primary-50:  #eef2ff
--color-primary-100: #e0e7ff
--color-primary-200: #c7d2fe
--color-primary-300: #a5b4fc
--color-primary-400: #818cf8
--color-primary-500: #6366f1   ← Main brand (Indigo)
--color-primary-600: #4f46e5   ← Hover state
--color-primary-700: #4338ca
--color-primary-800: #3730a3
--color-primary-900: #312e81

--color-cyan-400:    #22d3ee   ← Secondary accent
--color-cyan-500:    #06b6d4
--color-amber-400:   #fbbf24   ← Star ratings / highlights
--color-amber-500:   #f59e0b
--color-emerald-500: #10b981   ← Success / enrollment

--color-background:  #fafaf9   (warm off-white)
--color-surface:     #ffffff
--color-surface-alt: #f8fafc   (cool gray tint)

--text-primary:      #0f172a   (slate-900)
--text-secondary:    #475569   (slate-600)
--text-tertiary:     #94a3b8   (slate-400)
--text-inverse:      #f8fafc

--color-border:      #e2e8f0
--color-border-strong: #cbd5e1
```

### 3.2 Typography

| Token | Value | Usage |
|-------|-------|-------|
| `--font-display` | `'Space Grotesk', system-ui, sans-serif` | Headings, hero, section titles |
| `--font-body` | `'Inter', -apple-system, BlinkMacSystemFont, sans-serif` | Body text, UI elements |
| `--font-mono` | `'JetBrains Mono', 'Fira Code', monospace` | Code snippets, badges |

**Scale:**
```
--text-xs:   0.75rem    (12px)
--text-sm:   0.875rem   (14px)
--text-base: 1rem       (16px)
--text-lg:   1.125rem   (18px)
--text-xl:   1.25rem    (20px)
--text-2xl:  1.5rem     (24px)
--text-3xl:  1.875rem   (30px)
--text-4xl:  2.25rem    (36px)
--text-5xl:  3rem       (48px)
--text-6xl:  3.75rem    (60px)
```

### 3.3 Spacing Scale

```
--space-1:  0.25rem   (4px)
--space-2:  0.5rem    (8px)
--space-3:  0.75rem   (12px)
--space-4:  1rem      (16px)
--space-6:  1.5rem    (24px)
--space-8:  2rem      (32px)
--space-12: 3rem      (48px)
--space-16: 4rem      (64px)
--space-20: 5rem      (80px)
--space-24: 6rem      (96px)
--space-32: 8rem      (128px)
```

### 3.4 Z-Index Scale

```
--z-base:     0
--z-dropdown: 200
--z-sticky:   300
--z-modal:    400
--z-popover:  500
--z-tooltip:  600
```

---

## 4. Site Structure & Routes

| Route | Page | Description |
|-------|------|-------------|
| `/` | Landing / Home | Full marketing landing page |
| `/courses` | Course Catalog | Filtered course grid with tabs |

---

## 5. Landing Page — Section-by-Section Spec

### 5.1 Header / Navbar (Sticky)

**Layout:** Full-width, sticky at top (`z-sticky: 300`), white background with subtle bottom border.

| Element | Details |
|---------|---------|
| Logo | Left-aligned. "AI" in indigo pill badge + "Academy" in dark text. Links to `/` |
| Nav links | `Courses` (link to `/courses`), `Learning Paths` (dropdown), `Enterprise` (dropdown), `Resources` (dropdown) |
| Right actions | Search icon button, "Sign In" text button, "Get Started" filled button (indigo) |
| Mobile | Hamburger menu icon replaces nav links |

### 5.2 Hero Section

**Background:** Subtle grid pattern overlay on off-white. Radial gradient glow behind the illustration.

**Left Column (60%):**
- **Badge:** Pill-shaped, indigo tinted background → "Now Enrolling: April Cohorts"
- **Heading:** `h1` — "Master AI Engineering" (line 1, normal weight) + "in 12 Weeks" (line 2, bold/gradient)
- **Subtext:** Descriptive paragraph about live instruction, 50K+ engineers
- **CTAs:** Two buttons side by side:
  - "Explore Programs" — filled indigo, right arrow icon
  - "Watch Demo" — outlined, play icon
- **Stats Row:** Three stat blocks with icons:
  - 🔥 94% — Completion Rate
  - 📈 89% — Placement Rate
  - 💰 42% — Avg. Salary Increase

**Right Column (40%):**
- Hero illustration: AI-themed graphic (purple/indigo gradient, circuit patterns, silhouette)
- Floating badge 1: "Live Classes" + "Interactive sessions" (top-left overlay)
- Floating badge 2: "Certified" + "Industry recognized" (top-right overlay)
- Code snippet overlay: `import OpenAI from "openai"` with syntax highlighting (bottom)

### 5.3 Social Proof / Trust Bar

- Text: "Trusted by engineers at leading tech companies"
- Logo row: Google, Microsoft, Amazon, Meta, OpenAI, Anthropic (gray/monochrome)

### 5.4 Learning Paths Section

**Section header:** Label "Learning Paths" → H2 "Choose Your Specialization" → subtitle

**Card Grid:** 3 columns on desktop, stacked on mobile. Each card:
- Thumbnail illustration (gradient, topic-themed)
- Title (e.g., "AI Engineering", "Data Science", "Machine Learning")
- Course count badge ("1 courses", "0 courses")
- "Explore →" link

### 5.5 "Everything You Need to Succeed" (Features Grid)

**Section header:** Label "Why Choose Us" → H2 "Everything You Need to Succeed"

**Feature Grid:** 3×2 on desktop, 2×3 on tablet, 1×6 on mobile
- Icon (circular, tinted background)
- Title (e.g., "Live Instruction", "Hands-on Projects")
- Description paragraph

**Features:**
1. 🎥 Live Instruction — "Learn directly from industry experts in real-time sessions"
2. 🛠️ Hands-on Projects — "Build portfolio-worthy AI systems with guided projects"
3. 💼 Career Support — "Get personalized coaching and job placement assistance"
4. 🏆 Industry Certification — "Earn recognized credentials valued by top employers"
5. 👥 Community Access — "Join a network of 12,000+ AI professionals"
6. 📦 Lifetime Materials — "Access course updates and resources indefinitely"

### 5.6 Featured Course Section

**Section header:** Label "Featured Program" → H2 "Our Most Popular Course"

**Layout:** Two-column card (image left, details right)

**Left — Image Card:**
- Course illustration (dark gradient, AI/ML themed)
- Badge: "intermediate" (pill, overlay)
- Stats bar: 8 weeks Duration | 12 Modules | 0 Students

**Right — Details:**
- H3 "AI Engineering Bootcamp"
- Description paragraph
- Star rating: 5 filled stars + "4.8" + "(127 reviews)"
- Skills tags: `Python`, `PyTorch`, `LangChain`, `Vector DBs`, `MLOps`
- Included checklist (green checkmarks):
  - Live instruction + recordings
  - Hands-on lab environments
  - Certification exam voucher
  - 1-year community access
  - Career support & job referrals
  - Lifetime content updates
- Price: "$2,499" (large, bold)
- CTA: "Enroll Now →" (indigo filled button)

### 5.7 Upcoming Cohorts Section

**Section header:** Label "Upcoming Cohorts" → H2 "Start Your Journey Soon" → subtitle

**Cohort Cards:** Each card includes:
- Left date block: Month (e.g., "Apr") + Day (e.g., "19") large
- Middle details: Course name + "OPEN" badge (green) | Date, Timezone (EST), Format (online) with icons
- Right: Price + "Enroll Now" button

### 5.8 Enterprise Section

**Layout:** Two-column. Left = text content, Right = stats cards.

**Left Column:**
- Label "Enterprise Solutions"
- H2 "Train Your Team at Scale"
- Description paragraph
- Feature list with check icons:
  - Custom curriculum tailored to your tech stack
  - Flexible scheduling for global teams
  - Dedicated account manager
  - Volume discounts for 10+ enrollments
  - Progress tracking and reporting
- Two CTAs: "Talk to Sales →" (filled), "Download Brochure" (outlined)

**Right Column:**
- 3 stat cards (2×2 grid, one spans): 200+ Enterprise Clients, 50K+ Engineers Trained, 94% Completion Rate
- Bottom CTA card: "Ready to transform your team? / Get a custom quote in 24 hours"

### 5.9 Footer

**Layout:** 4-column grid

**Column 1 — Brand:**
- "AI" pill + "Academy" logo
- Tagline paragraph
- Newsletter: "SUBSCRIBE TO OUR NEWSLETTER" + email input + send button

**Column 2 — COURSES:**
- AI Engineering, Data Science, Cloud Computing, Cybersecurity, DevOps & SRE

**Column 3 — COMPANY:**
- About Us, Careers, Blog, Press, Partners

**Column 4 — RESOURCES:**
- Documentation, Community, Help Center, Webinars, Podcast

**Bottom bar:**
- © 2026 AI Academy. All rights reserved.
- Legal links: Privacy Policy, Terms of Service, Cookie Policy, Accessibility
- Social icons: Twitter, LinkedIn, GitHub, YouTube

---

## 6. Courses Page — Section-by-Section Spec

### 6.1 Hero Banner

- Dark gradient background (indigo/purple)
- H1: "Explore Our Courses"
- Subtitle: "Industry-leading programs designed to take you from fundamentals to production-grade AI systems"
- Stats row (icon + label): Live Classes, Hands-on Labs, Expert Instructors, Certification

### 6.2 Filter Bar

- Pill/tab buttons: `All Courses`, `AI Engineering`, `Data Science`, `Cloud Computing`, `Cybersecurity`, `DevOps & SRE`
- Active tab: indigo filled. Inactive: outlined/ghost.

### 6.3 Course Grid

- 3 columns desktop, responsive down to 1 column mobile
- Each course card:
  - Thumbnail illustration (dark, gradient, topic-themed)
  - Difficulty badge (bottom-left overlay): `beginner` / `intermediate` / `advanced`
  - Title (H3)
  - Description (truncated 2 lines)
  - Meta row: Duration | Modules | Students (with icons)
  - Price + "Enroll Now" button

### 6.4 State: Empty Category

- Centered message: "No courses found"
- Subtitle: "Courses for [Category] are coming soon. Stay tuned!"
- Illustration/icon

---

## 7. Interactive Components & Behaviors

| Component | Behavior |
|-----------|----------|
| **Navbar dropdowns** | Hover/click to reveal dropdown menus for Learning Paths, Enterprise, Resources |
| **Mobile menu** | Hamburger → slide-in or overlay menu with all nav links |
| **Search** | Click search icon → modal or inline search input |
| **Course filter tabs** | Click tab → filter course grid with animation/transition |
| **CTA buttons** | Hover: subtle scale + shadow lift. Click: ripple or press effect |
| **Cohort cards** | Hover: slight elevation + border highlight |
| **Newsletter input** | Validation on empty submit. Success toast on valid email |
| **Stats counters** | (Optional) Animate count-up on scroll into view |

---

## 8. Responsive Breakpoints

| Breakpoint | Width | Layout Changes |
|-----------|-------|----------------|
| Mobile | < 640px | Single column, hamburger nav, stacked cards |
| Tablet | 640–1023px | 2-column grids, condensed nav |
| Desktop | 1024–1439px | Full layout, 3-column grids |
| Wide | ≥ 1440px | Max-width container (~1280px), centered |

---

## 9. Asset Requirements

| Asset | Description |
|-------|-------------|
| **Hero illustration** | Abstract AI/ML graphic with purple-indigo gradient, circuit motifs, silhouette figure. SVG preferred. |
| **Course thumbnails** | 6 unique dark-gradient illustrations for each course topic. ~800×450px. |
| **Feature icons** | 6 circular icons (live class, projects, career, cert, community, materials). Lucide or custom SVG. |
| **Company logos** | Google, Microsoft, Amazon, Meta, OpenAI, Anthropic — monochrome SVG. |
| **Stat icons** | Small icons for completion rate, placement, salary increase. |
| **Star icons** | Filled + empty star for ratings. |
| **Social icons** | Twitter/X, LinkedIn, GitHub, YouTube — footer use. |
| **Checkmark icon** | Green checkmark for included features list. |
| **Arrow icons** | Right arrows for CTAs, chevrons for dropdowns. |

---

## 10. Content Inventory

### 10.1 Copy Text

**Hero:**
> Now Enrolling: April Cohorts
> Master AI Engineering in 12 Weeks
> Build production-grade AI systems with live instruction from industry experts. Join 50,000+ engineers who accelerated their careers.

**Stats:** 94% Completion Rate | 89% Placement Rate | 42% Avg. Salary Increase

**Trust bar:** Trusted by engineers at leading tech companies

**Learning Paths:** Choose Your Specialization — Industry-aligned curricula designed by practitioners from top tech companies

**Features:** Everything You Need to Succeed — A complete learning experience designed for working professionals

**Featured Course:**
> AI Engineering Bootcamp
> A comprehensive bootcamp covering transformer architectures, LLM deployment, and RAG systems.
> Skills: Python, PyTorch, LangChain, Vector DBs, MLOps
> Price: $2,499

**Enterprise:** Train Your Team at Scale — Upskill your engineering team with customized training programs designed around your technology stack and business goals.

**Footer tagline:** Empowering engineers with production-grade skills through live instruction and hands-on learning.

---

## 11. Performance & Quality Requirements

| Metric | Target |
|--------|--------|
| Lighthouse Performance | ≥ 90 |
| First Contentful Paint | < 1.5s |
| Largest Contentful Paint | < 2.5s |
| Cumulative Layout Shift | < 0.1 |
| Accessibility | ≥ 95 |
| SEO | ≥ 90 |

---

## 12. Non-Functional Requirements

- **No backend required** — static marketing site, all content hardcoded or from local JSON
- **No authentication** — Sign In / Get Started buttons are non-functional (UI only)
- **No real payments** — "Enroll Now" buttons can link to a placeholder or do nothing
- **SEO:** Semantic HTML, proper heading hierarchy, meta tags, Open Graph tags
- **Accessibility:** WCAG 2.1 AA — keyboard nav, focus states, alt text, color contrast
- **Analytics:** Placeholder for Cloudflare/Web Vitals (optional)
- **Cross-browser:** Chrome, Firefox, Safari, Edge (latest 2 versions)

---

## 13. Project Structure (Recommended)

```
ai-academy/
├── public/
│   ├── favicon.ico
│   └── assets/
│       ├── illustrations/   # Hero, course thumbnails
│       ├── icons/           # Feature icons, social icons
│       └── logos/           # Company logos
├── src/
│   ├── components/
│   │   ├── layout/
│   │   │   ├── Navbar.tsx
│   │   │   └── Footer.tsx
│   │   ├── home/
│   │   │   ├── Hero.tsx
│   │   │   ├── TrustBar.tsx
│   │   │   ├── LearningPaths.tsx
│   │   │   ├── Features.tsx
│   │   │   ├── FeaturedCourse.tsx
│   │   │   ├── UpcomingCohorts.tsx
│   │   │   └── Enterprise.tsx
│   │   ├── courses/
│   │   │   ├── CourseHero.tsx
│   │   │   ├── FilterBar.tsx
│   │   │   ├── CourseGrid.tsx
│   │   │   └── CourseCard.tsx
│   │   └── ui/
│   │       ├── Button.tsx
│   │       ├── Badge.tsx
│   │       ├── Card.tsx
│   │       └── Input.tsx
│   ├── data/
│   │   ├── courses.ts
│   │   ├── learningPaths.ts
│   │   └── cohorts.ts
│   ├── styles/
│   │   └── tokens.css       # CSS custom properties
│   ├── pages/
│   │   ├── Home.tsx
│   │   └── Courses.tsx
│   ├── App.tsx
│   ├── main.tsx
│   └── router.tsx
├── index.html
├── tailwind.config.ts
├── vite.config.ts
├── tsconfig.json
├── package.json
└── README.md
```

---

## 14. Development Phases

### Phase 1: Scaffold & Design System
- Initialize Vite + React + TypeScript + Tailwind
- Define all CSS custom properties (tokens)
- Set up routing
- Build reusable UI primitives (Button, Badge, Card, Input)

### Phase 2: Layout Components
- Navbar (desktop + mobile with hamburger)
- Footer (4-column grid + newsletter)

### Phase 3: Home Page Sections (top → bottom)
1. Hero section (with floating badges + code snippet)
2. Trust bar / social proof
3. Learning Paths (3-card grid)
4. Features grid (3×2)
5. Featured Course (2-column card)
6. Upcoming Cohorts (schedule cards)
7. Enterprise section (2-column + stats)

### Phase 4: Courses Page
1. Hero banner
2. Filter bar (tabs)
3. Course grid with cards
4. Empty state handling

### Phase 5: Polish & QA
- Animations (scroll reveals, hover effects, counter animations)
- Responsive testing across breakpoints
- Accessibility audit
- Performance optimization
- Cross-browser testing

---

## 15. Acceptance Criteria

- [ ] Landing page visually matches the reference site within 95% fidelity
- [ ] Courses page with functional filter tabs
- [ ] Fully responsive at mobile, tablet, and desktop
- [ ] All navigation links and dropdowns functional
- [ ] Newsletter email input with validation
- [ ] Smooth hover/transition effects on interactive elements
- [ ] Lighthouse scores meet targets (Perf ≥ 90, A11y ≥ 95)
- [ ] No console errors or warnings
- [ ] Semantic HTML with proper heading hierarchy
- [ ] Keyboard-navigable with visible focus states

---

*End of PRD*
