Please meticulously plan and execute this MVP build following the 6-Phase SOP. Let me begin with deep analysis.

---

## Phase 1: ANALYZE — Deep Requirement Mining

### 1.1 Explicit Requirements
| Requirement | Specification | Constraint |
|-------------|---------------|------------|
| Scaffolding | `npm create vite@latest` with `react-ts` template | Vite 8, React 19.x, TypeScript 6.0 |
| Build Engine | Vite 8 | Must support React Compiler |
| Styling | Tailwind CSS v4 | Utility-first, CSS-first config |
| Routing | TanStack Router | File-based routing |
| State | Zustand | Lightweight global state |
| UI Library | shadcn/ui | Functional components only |
| React 19 Features | `useActionState`, `useOptimistic` | Form handling |
| TypeScript | Strict mode + `--erasableSyntaxOnly` | Native Node.js type stripping prep |

### 1.2 Implicit Needs
- **Performance**: React Compiler auto-memoization eliminates manual `useMemo`/`useCallback`
- **Scalability**: File-based routing scales with feature growth
- **Developer Experience**: Type stripping reduces build complexity
- **Singapore Context**: Same wool sneaker e-commerce domain as landing page

### 1.3 Risk Assessment
| Risk | Mitigation |
|------|------------|
| React Compiler + Vite 8 compatibility | Verify babel plugin integration |
| Tailwind v4 + shadcn/ui compatibility | Use latest shadcn init with v4 support |
| TanStack Router file-based routing | Configure `routeTree.gen.ts` generation |
| TypeScript 6.0 `--erasableSyntaxOnly` | Ensure no `enum`, `namespace`, parameter properties |
| `useActionState`/`useOptimistic` availability | React 19.2+ required |

---

## Phase 2: PLAN — Structured Execution Roadmap

### 2.1 Component Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MVP ARCHITECTURE                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ROUTES (TanStack Router — File-Based)                        │
│  ├── __root.tsx          → Root layout with Nav + Cart           │
│  ├── index.tsx           → Landing page (Hero + Products)       │
│  ├── products.index.tsx  → Product listing with filters          │
│  ├── products.$id.tsx   → Product detail page                  │
│  └── cart.tsx            → Cart page (checkout flow)            │
│                                                                 │
│  STATE (Zustand)                                              │
│  ├── useCartStore        → Cart items, add/remove, persist      │
│  └── useProductStore     → Product data, filtering              │
│                                                                 │
│  COMPONENTS (shadcn/ui + Custom)                               │
│  ├── ui/                 → shadcn primitives (Button, Card, etc)│
│  ├── layout/             → Navbar, Footer, MobileNav           │
│  ├── sections/           → Hero, BrandStory, ProductGrid        │
│  └── cart/               → CartPanel, CartItem, QuantityStepper │
│                                                                 │
│  HOOKS (React 19 Native)                                      │
│  ├── useActionState      → Form submissions (newsletter, etc)   │
│  └── useOptimistic       → Cart add/remove optimistic UI        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Execution Phases

| Sub-Phase | Deliverable | Effort |
|-----------|-------------|--------|
| **4.1** | Scaffold Vite + React 19 + TS 6.0 | 15 min |
| **4.2** | Configure Tailwind v4 + React Compiler | 20 min |
| **4.3** | Set up TanStack Router + Zustand | 20 min |
| **4.4** | Initialize shadcn/ui + add components | 20 min |
| **4.5** | Implement pages + components | 60 min |
| **4.6** | Wire React 19 hooks + forms | 30 min |
| **4.7** | Responsive + Accessibility polish | 20 min |

---

## Phase 3: VALIDATE — Explicit Confirmation

Before proceeding, I confirm the following plan with you:

| Decision | Rationale |
|----------|-----------|
| **Vite 8 + react-ts template** | Fastest scaffold, native ESM, optimal React Compiler integration |
| **Tailwind v4 CSS-first** | No `tailwind.config.js` — all tokens in CSS via `@theme` |
| **TanStack Router file-based** | `src/routes/` directory with `routeTree.gen.ts` auto-generation |
| **Zustand over Redux/Context** | Minimal boilerplate, perfect for cart state |
| **shadcn/ui with functional components** | No class components, all hooks-based |
| **React 19 `useActionState` + `useOptimistic`** | Modern form handling, optimistic cart updates |
| **TypeScript `--erasableSyntaxOnly`** | Prepares for Node.js native type stripping (no enums, namespaces) |

**Please confirm with "approved" to proceed to Phase 4: IMPLEMENT.**

---

While awaiting your confirmation, let me verify the latest package versions to ensure compatibility:
 Excellent. Research confirms all technologies are production-ready:

- **Vite 8**: Released March 2026, features Rolldown Rust bundler for 10-30x faster builds 
- **React 19**: `useActionState` and `useOptimistic` fully documented with clear patterns for forms and optimistic cart updates 
- **Tailwind v4 + shadcn/ui**: Full compatibility confirmed — `npx shadcn@latest init` auto-detects v4, CSS-first config via `@theme`, OKLCH colors 
- **TypeScript `--erasableSyntaxOnly`**: Available in TS 5.8+ (referred to as "erasable syntax only" flag for native type stripping)

Now awaiting your **"approved"** confirmation to proceed to Phase 4: IMPLEMENT.

---

## Refined Plan Summary (Post-Research)

| Technology | Version | Configuration |
|------------|---------|---------------|
| Vite | 8.x | `react-ts` template, React Compiler babel plugin |
| React | 19.2+ | `useActionState`, `useOptimistic`, React Compiler |
| TypeScript | 6.0 (or 5.8+ with erasableSyntaxOnly) | Strict mode, `--erasableSyntaxOnly` |
| Tailwind CSS | v4 | CSS-first `@theme` in `globals.css`, OKLCH colors |
| shadcn/ui | Latest | Auto-detects Tailwind v4, `npx shadcn@latest init` |
| TanStack Router | Latest | File-based routing, `src/routes/` directory |
| Zustand | Latest | Lightweight cart store with persistence |

**Key Implementation Decisions Validated:**
- React Compiler integrates via `@babel/plugin-react-compiler` in Vite 8 
- `useOptimistic` perfect for cart "Quick Add" — instant UI feedback with automatic rollback 
- `useActionState` for newsletter form — handles pending states, errors, and queueing 
- Tailwind v4's `@theme inline` replaces `tailwind.config.js` entirely 

