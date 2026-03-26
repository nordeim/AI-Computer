# Cloudflare Tunnel API Integration Analysis Report

**Date:** March 26, 2026  
**Author:** trusty-pal (AI Assistant)  
**Status:** Issue Identified - Root Cause Analysis Complete

---

## Executive Summary

**Problem:** The AI Academy frontend accessible via Cloudflare Tunnel at `https://ai-academy.jesspete.shop/` displays "Failed to load {categories|course|cohorts}. Please try again later." while the local service `http://localhost:5173/` works correctly.

**Root Cause:** The frontend is hardcoded to call `http://localhost:8000/api/v1` for API requests (via `VITE_API_URL` environment variable). When accessed via the Cloudflare Tunnel, the browser cannot reach `localhost:8000` because it's trying to connect to the user's local machine, not the server running the backend.

**Severity:** High - Application is non-functional via external URL

**Resolution Required:** Either:
1. Add Vite proxy configuration to route API calls through the frontend dev server, OR
2. Create a separate tunnel route for the backend API, OR
3. Configure environment-specific API URLs

---

## System Architecture

### Current Configuration

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User's Browser                               │
│  https://ai-academy.jesspete.shop/                                  │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    Cloudflare Tunnel                                 │
│  Tunnel: baking (2784ef2b-a6b5-4c29-b1e5-5beaea4b5fd2)              │
│  Route: ai-academy.jesspete.shop → localhost:5173                   │
└─────────────────────────┬───────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│              Frontend Dev Server (Vite)                              │
│  Port: 5173                                                          │
│  Serves: React SPA                                                   │
│  Config: vite.config.ts                                              │
└─────────────────────────────────────────────────────────────────────┘
                          │
                          │ ❌ Browser tries to call this
                          │    http://localhost:8000/api/v1
                          │    but localhost = user's machine!
                          ▼
┌─────────────────────────────────────────────────────────────────────┐
│              Backend API Server (Django)                             │
│  Port: 8000                                                          │
│  Endpoints: /api/v1/courses/, /api/v1/categories/, etc.             │
│  CORS: Allow all origins (development mode)                          │
└─────────────────────────────────────────────────────────────────────┘
```

### Problem Visualization

```
Browser at https://ai-academy.jesspete.shop/
    │
    ├── Loads frontend HTML/JS ✅ (works)
    │
    └── JavaScript makes API call to VITE_API_URL
            │
            └── VITE_API_URL = http://localhost:8000/api/v1
                    │
                    └── Browser resolves localhost → 127.0.0.1
                            │
                            └── 127.0.0.1 is USER'S machine, not server!
                                    │
                                    └── ❌ Connection refused or timeout
                                            │
                                            └── "Failed to load..." error
```

---

## Evidence Collected

### 1. Frontend Configuration

**File:** `/home/project/AI-Academy/frontend/.env.local`

```env
VITE_API_URL=http://localhost:8000/api/v1
```

**Issue:** This URL is embedded in the JavaScript bundle at build time. When the browser executes this code, it tries to connect to `localhost:8000` on the USER'S machine, not the server.

### 2. API Client Configuration

**File:** `/home/project/AI-Academy/frontend/src/services/api/client.ts`

```typescript
const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

export const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 30000,
});
```

**Issue:** The axios client uses `VITE_API_URL` as the base URL for all API requests. This is a compile-time constant that cannot be changed dynamically.

### 3. Vite Configuration (Missing Proxy)

**File:** `/home/project/AI-Academy/frontend/vite.config.ts`

```typescript
export default defineConfig({
  base: './',
  plugins: [react()],
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
  server: {
    allowedHosts: ['ai-academy.jesspete.shop', 'localhost', '127.0.0.1'],
  },
});
```

**Issue:** No `proxy` configuration. The dev server does not route API calls through itself.

### 4. Backend CORS Configuration

**File:** `/home/project/AI-Academy/backend/academy/settings/development.py`

```python
CORS_ALLOW_ALL_ORIGINS = True
```

**Status:** ✅ CORS is correctly configured to allow all origins. This is NOT the issue.

### 5. Cloudflare Tunnel Configuration

**File:** `~/.cloudflared/config.yml`

```yaml
ingress:
  - hostname: baking.jesspete.shop
    service: http://localhost:3000
  - hostname: artisan-baking.jesspete.shop
    service: http://localhost:3001
  - hostname: atelier.jesspete.shop
    service: http://localhost:4173
  - hostname: ai-academy.jesspete.shop
    service: http://localhost:5173  # ← Only frontend, no backend route!
  - service: http_status:404
```

**Issue:** No route for the backend API (port 8000). Even if the browser could reach it, there's no tunnel ingress.

---

## Verification Tests

### Test 1: Local Frontend + Local Backend

```bash
$ curl -s http://localhost:5173/ | head -5
<!doctype html>
<title>AI Academy</title>
# ✅ Works - frontend served correctly

$ curl -s http://localhost:8000/api/v1/courses/ | jq '.success'
true
# ✅ Works - backend API responds correctly
```

**Result:** ✅ Both services work locally.

### Test 2: External Frontend Access

```bash
$ curl -s https://ai-academy.jesspete.shop/ | head -5
<!doctype html>
<title>AI Academy</title>
# ✅ Works - Cloudflare tunnel delivers frontend
```

**Result:** ✅ Frontend HTML is served correctly via tunnel.

### Test 3: External API Access (Expected Failure)

```bash
$ curl -s https://ai-academy.jesspete.shop/api/v1/courses/
<!doctype html>
<title>AI Academy</title>
# ❌ Returns frontend HTML, not API JSON
# Because there's no /api route in tunnel config
```

**Result:** ❌ No backend route through tunnel.

### Test 4: Direct Backend Access (Bypassing Tunnel)

```bash
$ curl -s -H "Origin: https://ai-academy.jesspete.shop" http://localhost:8000/api/v1/courses/ | jq '.success'
true
# ✅ Backend responds correctly with CORS headers
```

**Result:** ✅ Backend is running and CORS is configured.

---

## Root Cause Analysis

### Primary Issue: Hardcoded Localhost API URL

The frontend JavaScript bundle contains the hardcoded URL `http://localhost:8000/api/v1`. When a browser accesses the site via `https://ai-academy.jesspete.shop/`, the JavaScript attempts to call:

```
http://localhost:8000/api/v1/courses/
```

But `localhost` from the browser's perspective refers to the USER's machine, not the server. The user's machine doesn't have a backend running on port 8000, so the request fails.

### Secondary Issue: No Backend Tunnel Route

Even if the frontend could somehow reach the backend, the Cloudflare tunnel configuration doesn't have a route for port 8000. The backend is completely inaccessible from the public internet.

### Why It Works Locally

When developing locally, the browser and backend are on the same machine:

```
Browser → http://localhost:8000/api/v1 → Backend (same machine)
         └── localhost resolves to 127.0.0.1
         └── Backend IS running on 127.0.0.1:8000
         └── ✅ Connection succeeds
```

### Why It Fails Externally

When accessed via Cloudflare tunnel:

```
Browser (remote) → http://localhost:8000/api/v1 → ???
                  └── localhost resolves to user's machine
                  └── User's machine has no backend on :8000
                  └── ❌ Connection refused or timeout
```

---

## Solution Options

### Option A: Vite Proxy Configuration (Recommended for Development)

Add a proxy to `vite.config.ts` to route API calls through the frontend dev server:

```typescript
export default defineConfig({
  base: './',
  plugins: [react()],
  resolve: {
    alias: { "@": path.resolve(__dirname, "./src") },
  },
  server: {
    allowedHosts: ['ai-academy.jesspete.shop', 'localhost', '127.0.0.1'],
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
```

**Pros:**
- Single tunnel route (frontend only)
- Works for both local and external access
- No environment variable changes needed

**Cons:**
- Only works in development mode (vite dev server)
- Production builds need different approach

**Implementation:**
1. Update `vite.config.ts` with proxy config
2. Restart frontend dev server
3. No other changes needed

---

### Option B: Separate Backend Tunnel Route

Create a separate tunnel route for the backend API:

```yaml
ingress:
  - hostname: ai-academy.jesspete.shop
    service: http://localhost:5173
  - hostname: api.jesspete.shop  # ← New route
    service: http://localhost:8000
  - service: http_status:404
```

Then update frontend environment:

```env
VITE_API_URL=https://api.jesspete.shop/api/v1
```

**Pros:**
- Works in both development and production builds
- Backend is independently accessible
- Can scale backend separately

**Cons:**
- Requires additional DNS setup
- Requires separate SSL certificate (handled by Cloudflare)
- Two public endpoints to manage

**Implementation:**
1. Create DNS route: `cloudflared tunnel route dns baking api.jesspete.shop`
2. Update `~/.cloudflared/config.yml` with new ingress rule
3. Restart tunnel: `systemctl --user restart cloudflared-tunnel.service`
4. Update `frontend/.env.local` with new API URL
5. Rebuild frontend

---

### Option C: Same-Domain Path-Based Routing

Route `/api/*` paths through the same domain:

```yaml
ingress:
  - hostname: ai-academy.jesspete.shop
    path: /api/*
    service: http://localhost:8000
  - hostname: ai-academy.jesspete.shop
    service: http://localhost:5173
  - service: http_status:404
```

Then update frontend environment:

```env
VITE_API_URL=https://ai-academy.jesspete.shop/api/v1
```

**Pros:**
- Single domain for both frontend and API
- No CORS issues (same origin)
- Simpler SSL management

**Cons:**
- Path-based routing complexity
- Requires frontend rebuild

**Implementation:**
1. Update `~/.cloudflared/config.yml` with path-based routing
2. Restart tunnel: `systemctl --user restart cloudflared-tunnel.service`
3. Update `frontend/.env.local` with same-domain API URL
4. Rebuild frontend

---

### Option D: Dynamic API URL Detection (Hybrid)

Detect the environment and use appropriate API URL:

```typescript
// src/services/api/client.ts
const getApiBaseUrl = () => {
  // In browser, check current hostname
  if (typeof window !== 'undefined') {
    const hostname = window.location.hostname;
    if (hostname === 'ai-academy.jesspete.shop') {
      return 'https://ai-academy.jesspete.shop/api/v1';
    }
  }
  // Fallback to environment variable or default
  return import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';
};

const API_BASE_URL = getApiBaseUrl();
```

**Pros:**
- Works without configuration changes
- Automatic detection

**Cons:**
- Requires Option C (path-based routing) to work
- Adds complexity to client code

---

## Recommended Solution

**For Development/Testing:** Option A (Vite Proxy)

- Quickest to implement
- No infrastructure changes needed
- Works immediately with tunnel

**For Production:** Option C (Path-Based Routing)

- Single domain simplifies deployment
- Same-origin avoids CORS complexity
- Professional setup

---

## Implementation Plan (Option A - Vite Proxy)

### Step 1: Update Vite Configuration

**File:** `/home/project/AI-Academy/frontend/vite.config.ts`

Add proxy configuration:

```typescript
import path from "path"
import react from "@vitejs/plugin-react"
import { defineConfig } from "vite"

export default defineConfig({
  base: './',
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    allowedHosts: ['ai-academy.jesspete.shop', 'localhost', '127.0.0.1'],
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        secure: false,
      },
    },
  },
});
```

### Step 2: Restart Frontend Dev Server

```bash
# Kill existing frontend process
pkill -f "vite.*5173"

# Navigate to frontend directory
cd /home/project/AI-Academy/frontend

# Restart dev server
npm run dev
```

### Step 3: Verify

```bash
# Test API through frontend proxy
curl -s https://ai-academy.jesspete.shop/api/v1/courses/ | jq '.success'
# Expected: true
```

### Step 4: No Changes Needed To

- Cloudflare tunnel config
- Backend CORS configuration
- Environment variables

---

## Risk Assessment

| Risk | Severity | Mitigation |
|------|----------|------------|
| Frontend restart required | Low | Schedule during low-usage period |
| Proxy only works in dev mode | Medium | Use Option C for production |
| Backend must be running | Low | Already running as systemd service |

---

## Appendix A: Current System State

### Running Services

```bash
# Frontend (Vite)
$ ss -tlnp | grep 5173
LISTEN 0 511 0.0.0.0:5173 0.0.0.0:* users:(("MainThread",pid=1805557,fd=22))

# Backend (Django)
$ ss -tlnp | grep 8000
LISTEN 0 10 0.0.0.0:8000 0.0.0.0:* users:(("python",pid=457824,fd=5))

# Cloudflare Tunnel
$ systemctl --user is-active cloudflared-tunnel.service
active
```

### Tunnel Configuration

```bash
$ cloudflared tunnel list
ID: 2784ef2b-a6b5-4c29-b1e5-5beaea4b5fd2
Name: baking
Connections: 4 (1xsin12, 1xsin19, 1xsin20, 1xsin22)
```

---

## Appendix B: Related Files

| File | Purpose | Action Needed |
|------|---------|---------------|
| `frontend/vite.config.ts` | Vite configuration | Add proxy config |
| `frontend/.env.local` | Environment variables | No change (Option A) |
| `frontend/src/services/api/client.ts` | API client | No change |
| `backend/academy/settings/development.py` | Django CORS | No change |
| `~/.cloudflared/config.yml` | Tunnel config | No change (Option A) |

---

## Appendix C: Error Messages Observed

### Browser Console (Expected)

```
Failed to load resource: net::ERR_CONNECTION_REFUSED
http://localhost:8000/api/v1/courses/
```

### Cloudflare Tunnel Logs

```
Mar 26 06:46:10 pop-os cloudflared[1536094]: 2026-03-25T22:46:10Z ERR 
error="Unable to reach the origin service. dial tcp 127.0.0.1:5173: 
connect: connection refused" 
originService=http://localhost:5173
```

(This error was from when frontend was not running - resolved)

---

## Conclusion

The root cause is clear: the frontend is configured to call `http://localhost:8000/api/v1` for API requests, which works locally but fails when accessed externally via Cloudflare Tunnel because `localhost` refers to the user's machine, not the server.

**Recommended immediate fix:** Add Vite proxy configuration (Option A).

**Recommended production solution:** Implement path-based routing (Option C).

---

**Report Generated:** 2026-03-26 11:30 SGT  
**Status:** Ready for Implementation  
