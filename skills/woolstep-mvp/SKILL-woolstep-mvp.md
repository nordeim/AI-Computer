# React 19 + TypeScript 6 + Vite 8 MVP — Production-Ready Web App Skill

Use when building a new MVP or production web application using modern React, TypeScript strict mode, Vite 8 (Rolldown), Tailwind CSS v4, and file-based routing. Covers the complete lifecycle from `npm init` to shipping tested, type-safe, production-grade code.

---

## Skill Stack

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| Framework | React | ^19.2 | Concurrent features, useActionState, useOptimistic |
| Language | TypeScript | ^6.0 | Strict, erasableSyntaxOnly, no `any` |
| Build Tool | Vite | ^8.0 | Rolldown engine, HMR, production bundling |
| Styling | Tailwind CSS | ^4.2 | CSS-first `@theme inline`, no config file |
| Router | TanStack Router | ^1.169 | File-based, type-safe |
| State | Zustand | ^5.0 | Lightweight, persist middleware |
| UI Primitives | shadcn/ui | Latest | Accessible component base |
| Icons | Lucide React | ^1.14 | SVG icon set |
| Testing | Vitest | ^4.1 | Unit + behavioral testing (jsdom) |
| Testing | Testing Library | ^16.3 | React component testing |

---

## 1. Bootstrap New Project

### Step 1: Scaffold
```bash
npm create vite@latest my-app -- --template react-ts
cd my-app
```

### Step 2: Install core dependencies
```bash
npm install react@latest react-dom@latest zustand @tanstack/react-router@dev
```

### Step 3: Install dev dependencies (--legacy-peer-deps for Vite 8 compatibility)
```bash
npm install --legacy-peer-deps -D \
  typescript@latest vite@latest @vitejs/plugin-react@latest \
  tailwindcss@latest @tailwindcss/vite vitest @testing-library/react \
  @testing-library/jest-dom jsdom @types/react@latest @types/react-dom@latest
```

### Step 4: Verify
```bash
npx tsc --version      # >= 6.0
npm run build          # Should succeed
```

---

## 2. TypeScript Configuration (Non-Negotiable)

### `tsconfig.json`
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "useDefineForClassFields": true,
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "erasableSyntaxOnly": true,
    "verbatimModuleSyntax": true,
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@hooks/*": ["./src/hooks/*"],
      "@lib/*": ["./src/lib/*"],
      "@routes/*": ["./src/routes/*"],
      "@stores/*": ["./src/stores/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

### CRITICAL RULES

| Rule | Rationale |
|---|---|
| No `any` | Use `unknown` or proper types. `strict: true` enforces. |
| No `enum` | `erasableSyntaxOnly` rejects. Use union types. |
| No `namespace` | Same rejection. Use ES modules. |
| No `baseUrl` | Deprecated in TS 6.0. Use `"./"` prefix in `paths`. |
| No unused vars | `noUnusedLocals`, `noUnusedParameters`. Build will fail. |
| Explicit types | Use `import type` for type-only imports. |

---

## 3. Tailwind CSS v4 Configuration

### `src/globals.css` — CSS-First, No `tailwind.config.js`

```css
@import "tailwindcss";

@theme inline {
  /* Colors */
  --color-warm-white: #FAF8F5;
  --color-oat: #EDE8DF;
  --color-foggy-gray: #D5CFC4;
  --color-stone: #9A9185;
  --color-taupe: #7A7268;
  --color-warm-charcoal: #3D3832;
  --color-terracotta: #C4A882;

  /* Typography */
  --font-display: 'Playfair Display', Georgia, serif;
  --font-body: 'DM Sans', system-ui, sans-serif;

  /* Spacing Scale (use semantic names, not px values) */
  --spacing-1: 4px;
  --spacing-2: 8px;
  --spacing-3: 16px;
  --spacing-4: 24px;
  /* ... */

  /* Z-Index Tokens */
  --z-base: 0;
  --z-raised: 10;
  --z-sticky: 100;
  --z-overlay: 200;
  --z-cart: 300;
  --z-modal: 400;
  --z-toast: 500;

  /* Custom Animations */
  --animate-fade-in-up: fade-in-up 800ms ease-out forwards;

  @keyframes fade-in-up {
    from { opacity: 0; transform: translateY(30px); }
    to   { opacity: 1;   transform: translateY(0); }
  }
}

@layer base {
  html { scroll-behavior: smooth; }
  body {
    font-family: var(--font-body);
    color: var(--color-text-primary);
    background-color: var(--color-warm-white);
  }
  :focus-visible {
    outline: 2px solid var(--color-terracotta);
    outline-offset: 2px;
  }
}

@layer utilities {
  .container-custom {
    width: 100%;
    max-width: 1280px;
    margin: 0 auto;
    padding: 0 24px;
  }
}

/* Reduced Motion */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Tailwind v4 Rules
- No `tailwind.config.js` — all in `globals.css`
- No arbitrary values like `bg-[#FAF8F5]` — extend `@theme` instead
- Mobile-first: `sm:`, `md:`, `lg:`
- Custom `@keyframes` inside `@theme inline`
- Complex classes in `@layer utilities`

---

## 4. Negative Value Gotcha (Tailwind v4)

```css
/* WRONG: Tailwind v4 silently ignores this */
className="absolute bottom--24 left--24"
/* Element gets NO positioning. Result: sits at default position. */

/* CORRECT: Single hyphen prefix for negative values */
className="absolute -bottom-24 -left-24"
```

Rule: Tailwind v4 does NOT parse `bottom--24` as negative. Double hyphen is a literal token, not negation. Always use single hyphen prefix (`-bottom-24`).

---

## 5. Vite 8 Configuration

### `vite.config.ts` — Function-form `manualChunks` (Rolldown Required)

```typescript
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  plugins: [
    TanStackRouterVite({ target: 'react' }),
    tailwindcss(),
    react()
  ],
  resolve: {
    alias: {
      '@': '/src',
      '@components': '/src/components',
      '@hooks': '/src/hooks',
      '@lib': '/src/lib',
      '@routes': '/src/routes',
      '@stores': '/src/stores'
    }
  },
  // ⚠️ CRITICAL: Vite 8 / Rolldown requires FUNCTION FORM
  build: {
    manualChunks: (id: string) => {
      if (id.includes('react')) return 'react-vendor'
      if (id.includes('tanstack')) return 'router-vendor'
      if (id.includes('lucide')) return 'lucide'
    }
  }
})
```

### Vite 8 Key Gotchas
- `manualChunks` must be a **FUNCTION**, not an object
- `--legacy-peer-deps` required for dependency installation
- `@babel/plugin-react-compiler` post-stable — optional for now

---

## 6. TanStack Router — File-Based Routing

### Route File Convention
```
src/routes/
├── __root.tsx         # Root layout (Navbar, Footer, CartOverlay)
├── index.tsx          # / (Home)
├── about.tsx          # /about
├── products.index.tsx # /products
├── products.$id.tsx   # /products/:id
└── cart.tsx           # /cart
```

### After EVERY route change, run:
```bash
npx tsr generate
```

### Root Layout Pattern
```tsx
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { Navbar } from '@components/layout/Navbar'
import { Footer } from '@components/layout/Footer'
import { CartOverlay } from '@components/cart/CartOverlay'
import { CartDrawer } from '@components/cart/CartDrawer'

export const Route = createRootRoute({ component: RootComponent })

function RootComponent() {
  return (
    <>
      <Navbar />
      <main className="min-h-screen pt-[72px]">
        <Outlet />
      </main>
      <Footer />
      <CartOverlay />
      <CartDrawer />          {/* Z-index: --z-cart (300) */}
    </>
  )
}
```

### Navigation
```tsx
// ✅ CORRECT
<Link to="/products/$id" params={{ id: product.id }}>

// ❌ WRONG (string interpolation for route params)
<Link to={`/products/${product.id}`}>
```

---

## 7. Zustand State Management

### Pattern: Flat Stores, Selector Subscriptions, Persist Middleware

```typescript
import { create } from 'zustand'
import { persist } from 'zustand/middleware'
import type { CartItem } from '../types'

interface CartState {
  items: CartItem[]
  isOpen: boolean           // UI state (NOT persisted)
  openCart: () => void
  closeCart: () => void
}

export const useCartStore = create<CartState>()(
  persist(
    (set, get) => ({
      items: [],
      isOpen: false,
      openCart: () => set({ isOpen: true }),
      closeCart: () => set({ isOpen: false })
    }),
    {
      name: 'my-app-cart',
      // CRITICAL: Only persist data, NEVER UI state
      partialize: (state) => ({ items: state.items })
    }
  )
)
```

### Zustand Rules (Critical)

| Rule | Example |
|---|---|
| ✅ Selector in JSX | `const isOpen = useCartStore(s => s.isOpen)` |
| ❌ `.getState()` in JSX | `useCartStore.getState().isOpen` (stale, no re-renders) |
| ✅ Persist data only | `partialize: (s) => ({ items: s.items })` |
| ❌ Persist UI state | Never persist `isOpen`, `isLoading`, etc. |

### Store-to-Store Calls (Internal OK)
```typescript
// OK inside store logic (not JSX)
addItem: (item) => {
  set({ items: [...get().items, item] })
  useToastStore.getState().addToast('Added!', 'success')  // ✅ Store-to-store
}
```

---

## 8. React 19 — Modern Hook Patterns

### `useActionState` for Forms
```tsx
import { useActionState } from 'react'

const [state, formAction, isPending] = useActionState(
  async (_prev, formData: FormData) => {
    const email = formData.get('email') as string
    if (!email?.includes('@')) {
      return { message: 'Invalid email', type: 'error' as const }
    }
    await new Promise(r => setTimeout(r, 1000))  // Simulate API call
    return { message: 'Subscribed!', type: 'success' as const }
  },
  { message: '', type: 'idle' as const }
)

// Use action prop (React 19 feature, not onSubmit for API calls)
<form action={formAction}>
  <input name="email" placeholder="Email" />
  <button disabled={isPending}>
    {isPending ? 'Subscribing...' : 'Subscribe'}
  </button>
</form>
```

### `useOptimistic` for UI Feedback
```tsx
import { useOptimistic } from 'react'

const [optimisticFavorited, addOptimistic] = useOptimistic(
  favorites.has(productId),
  (state) => !state
)

const handleClick = () => {
  addOptimistic(null)           // Instant UI update
  await toggleFavorite(id)      // Actual API call
}
```

---

## 9. `inert` and Boolean Props (TS2322 Trap)

```tsx
// ❌ WRONG: `inert` is a BOOLEAN React prop, not a string
<aside inert={isOpen ? undefined : 'true'} />  // TS2322 error

// ✅ CORRECT: Boolean expression or omitted when false
<aside inert={!isOpen} />

// Rule: inert, contentEditable, autoFocus, readOnly are ALL boolean props.
// Never pass a string value.
```

---

## 10. Testing — TDD with Vitest + jsdom

### Test Setup (`vitest.config.ts`)
```typescript
export default defineConfig({
  plugins: [/* ... */],
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts'
  }
})
```

### Setup file (`src/test/setup.ts`)
```typescript
import '@testing-library/jest-dom'
```

### TanStack Router `Link` Mocking
```typescript
vi.mock('@tanstack/react-router', () => ({
  Link: ({ children, ...props }: { children: React.ReactNode } & Record<string, unknown>) => (
    <a {...props}>{children}</a>
  )
}))
```

### React 19 Async State Updates in Tests
```typescript
import { act, render, screen } from '@testing-library/react'

// ❌ WRONG: State updates outside fireEvent need act()
useCartStore.getState().openCart()
expect(screen.getByRole('dialog')).toHaveClass('translate-x-0')  // FAILS

// ✅ CORRECT: Wrap store mutations in act() so DOM flushes
await act(async () => {
  useCartStore.getState().openCart()
})
```

### TDD Template
```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, fireEvent, act } from '@testing-library/react'

describe('MyComponent', () => {
  beforeEach(() => {
    // Reset store before each test
    useStore.getState().reset()
  })

  it('renders empty state', () => {
    render(<MyComponent />)
    expect(screen.getByText('Empty')).toBeDefined()
  })

  it('updates on user action', async () => {
    render(<MyComponent />)
    const btn = screen.getByLabelText('Action')
    fireEvent.click(btn)
    expect(screen.getByText('Updated')).toBeDefined()
  })
})
```

### Testing Standards
- **Behavior-driven**: Test user actions, not implementation
- **Factory pattern**: `getMockProduct(overrides)` for test data
- **Time-dependent**: Use `vi.useFakeTimers()` / `vi.useRealTimers()`
- **No placeholders**: No `expect(true).toBe(true)`

---

## 11. Component Design Patterns

### shadcn/ui + Tailwind Override
```tsx
// Use shadcn primitives, customize via Tailwind
import { Button } from '@components/ui/button'

<Button size="lg" className="bg-[var(--color-terracotta)] text-white">
  Custom styled
</Button>
```

### Early Returns (Anti-Nesting)
```tsx
// ✅ CORRECT
export function CartPanel() {
  if (count === 0) return <EmptyCart />
  return <CartItems />   
}

// ❌ WRONG (deep nesting)
export function CartPanel() {
  return (
    <div>
      {count === 0 ? (
        <div>
          <p>...</p>
        </div>
      ) : (
        <div>
          {items.map(...)}
        </div>
      )}
    </div>
  )
}
```

### `cn()` Helper for Conditional Classes
```tsx
import { cn } from '@lib/utils'

className={cn(
  'fixed inset-y-0 right-0 transition-transform duration-300',
  isOpen ? 'translate-x-0' : 'translate-x-full'
)}
```

---

## 12. Build & QA Pipeline

### Commands
```bash
npm run build          # TypeScript check + Vite build (< 1s via Rolldown)
npm test               # Vitest watch mode
npx vitest run         # CI: run tests once
npx tsc --noEmit       # TypeScript type check
```

### Success Criteria
| Metric | Target |
|---|---|
| `npm run build` | < 1s |
| `npx vitest run` | All tests pass |
| `npx tsc --noEmit` | Zero errors |

### CI/CD Stages
1. `npm install --legacy-peer-deps`
2. `npx tsc --noEmit`
3. `npx vitest run`
4. `npm run build`

---

## 13. Common Gotchas Summary

| Gotcha | Fix |
|---|---|
| `manualChunks` object form | Must be a function in Vite 8 |
| `baseUrl` deprecated | Remove, use `"./"` in `paths` |
| `bottom--24` invalid | Use `-bottom-24` (single hyphen) |
| `inert` as string | Must be boolean |
| `getState()` in JSX | Use selector `useStore(s => s.x)` |
| TanStack `Link` in tests | Mock with `vi.mock('@tanstack/react-router')` |
| State updates in tests | Wrap in `act()` |
| Toast auto-remove | Use `vi.useFakeTimers()` / `vi.advanceTimersByTime()` |

---

## 14. Project File Structure (Reference)

```
src/
├── main.tsx              # Entry + ErrorBoundary
├── globals.css           # Tailwind v4 @theme inline
├── components/
│   ├── ui/               # shadcn primitives (Button, Card, Input, Badge)
│   ├── layout/           # Navbar, Footer
│   ├── sections/         # Hero, TrustBar, ProductGrid, Newsletter
│   └── cart/             # [NEW] CartPanel, CartItem, CartDrawer, CartOverlay
├── stores/               # Zustand (.ts), persist middleware
├── routes/               # TanStack file-based routing
│   ├── __root.tsx        # Root layout + overlay + drawer
│   ├── index.tsx         # Home
│   ├── about.tsx
│   ├── cart.tsx
│   └── products.index.tsx
├── types/                # TS definitions
├── lib/                  # Utilities (cn helper)
└── test/                 # Vitest (jsdom, setup.ts, *.test.ts)
```

---

## 15. Anti-Pattern Reference Card

| # | Anti-Pattern | Fix |
|---|---|---|
| 1 | `getState()` in JSX | Selector subscription |
| 2 | Stubbed test `expect(true).toBe(true)` | Implement real assertions |
| 3 | Non-functional input | `useActionState` + `disabled` |
| 4 | Undefined CSS class | Define in `@theme inline` |
| 5 | Deprecated `baseUrl` | Remove, use relative `paths` |
| 6 | Double-hyphen negatives | Single hyphen prefix |
| 7 | `inert` as string | Boolean expression |
| 8 | Persisting `isOpen` / UI state | `partialize` to data only |
| 9 | `return null` on overlay close | Keep in DOM, toggle `opacity` |
| 10 | Building custom components instead of using shadcn | Use shadcn primitives |

---

Built from meticulous review of the WOOLSTEP MVP codebase — a production-grade React 19, TypeScript 6, Vite 8, Tailwind v4 MVP shipped with 15 passing behavioral tests and zero TypeScript errors.
