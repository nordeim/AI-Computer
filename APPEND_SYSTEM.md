Refer to `/home/pete/.pi/agent/skills/skills-catalog.md` to select the relevant skills for any request or task.

Below are some of the skills under `/home/pete/.pi/agent/skills/`:

Development & Engineering  
- Frontend Development (frontend-design, frontend-development, frontend-ui-engineering, super-frontend-design)  
- Fullstack Development (fullstack-dev, web-frameworks)  
- Framework-Specific Expertise (nextjs16-tailwind4, nextjs-react-expert, react19-ts6-vite8-tailwindv4-mvp, python-patterns, powershell-windows)  
- API & Interface Design (api-and-interface-design, api-patterns)  
- UI/UX Design (ui-ux-pro-max, ui-styling, visual-design-foundations, claude-design, scaffold-ui)  
- Version Control (git-workflow-and-versioning)  
- CI/CD & Automation (ci-cd-and-automation, n8n-workflow-automation)  
- Code Quality (code-quality-standards, code-review-and-audit, code-review-checklist, code-simplification, clean-code, lint-and-validate)  
  
Testing & QA  
- Test-Driven Development (tdd-workflow, test-driven-development, testing-patterns)  
- E2E & Browser Testing (e2e-testing-lessons, webapp-testing, webapp-testing-journey, frontend-ui-testing-journey, playwright-cli)  
- Verification (verification-and-review-protocol)  
  
Design & Creativity  
- Avant-Garde Design (avant-garde-design-v4, aesthetic, design, luxeverse-architect)  
- Brutalist/Portfolio (brutalist-portfolio-nextjs, personal-portfolio)  
- Charts & Data Visualization (charts)  
- Image/Video Generation & Editing (image-generation, image-edit, image-understand, image-search, video-generation, video-understand)  
- Presentation/Document Design (pptx)  
  
Content & Writing  
- Blog Writing (blog-writer)  
- SEO Content (seo-content-writer)  
- Content Strategy (content-strategy)  
- Content Analysis (content-analysis)  
- Marketing (marketing-mode)  
  
Document Processing  
- PDF (pdf)  
- Word Documents (docx, docx-generation)  
- Excel/Spreadsheets (xlsx)  
- Cheat Sheets (cheat-sheet)  
  
Project Management & Planning  
- Planning (planning-and-task-breakdown, plan-writing, writing-plans, idea-refine)  
- Documentation & ADRs (documentation-and-adrs)  
- Spec-Driven Development (spec-driven-development)  
- Incremental Implementation (incremental-implementation)  
- Shipping & Launch (shipping-and-launch)  
- Version Management (version-management) 

### 🎨 Design & Aesthetics 
 
Skill                     │ Description 
aesthetic                 │ Beautiful interfaces following proven design principles. Covers visual hierarchy, color theory, micro-interactions, and design documentation. 
avant-garde-design-v4     │ Elite web design for distinctive, production-grade interfaces. Luxury/premium brand experiences, landing pages, anti-generic compliance. 
claude-design             │ High-fidelity HTML artifacts — landing pages, slide decks, interactive prototypes, animated videos, posters, wireframes. 
design                    │ Routes design-related HTML artifact tasks to the right artifact skill or design system generator. 
frontend-design           │ Design thinking and decision-making for web UI. Principles for components, layouts, color schemes, typography. 
luxeverse-architect       │ Cinematic, production-grade, anti-generic web platforms. 
super-frontend-design     │ Master skill combining top 10 validated skills — anti-generic strategy, Next.js 16 + Tailwind v4, design systems, Vercel-grade performance, WCAG AAA. 
ui-ux-pro-max             │ UI/UX design intelligence — design tokens, component specs, copy/microcopy, accessibility, generating/critiquing frontend UI. 
visual-design-foundations │ Typography, color theory, spacing systems, iconography principles for cohesive visual designs. 
 
### ⚙ Engineering & Implementation 
 
Skill                            │ Description 
frontend-development             │ React/TypeScript guidelines — Suspense, lazy loading, MUI v7, TanStack Router, performance optimization. 
frontend-ui-engineering          │ Production-quality UIs — components, layouts, state management, polished output. 
fullstack-dev                    │ Next.js 16, TypeScript, Tailwind CSS 4, shadcn/ui, Prisma ORM — full-stack web apps. 
nextjs-react-expert              │ React/Next.js performance optimization from Vercel Engineering. 
nextjs16-tailwind4               │ Luxury-grade Next.js with Tailwind CSS v4, Radix UI (shadcn), Framer Motion. 
react19-ts6-vite8-tailwindv4-mvp │ MVP/production apps with React 19, TypeScript strict, Vite 8, Tailwind v4. 
web-frameworks                   │ Next.js (App Router, RSC, PPR, SSR, SSG, ISR), Turborepo, RemixIcon. 
 
### 🧪 Testing & QA 
 
Skill                         │ Description 
browser-testing-with-devtools │ Real browser testing via Chrome DevTools MCP — DOM inspection, console errors, network requests, performance profiling. 
e2e-testing-lessons           │ 15-phase E2E testing covering authentication, API contracts, tool selection, hybrid testing. 
frontend-ui-testing-journey   │ Complete frontend UI testing with OpenClaw browser, agent-browser CLI, chrome-devtools-mcp, @playwright/mcp. 
webapp-testing                │ E2E, Playwright, deep audit strategies. 
webapp-testing-journey        │ Systematic testing methodology — URL journey testing, accessibility tree analysis, DOM inspection, visual regression. 
 
### 🛠 Styling & Components 
 
Skill             │ Description 
scaffold-ui       │ Anti-generic React components with brutalist styling and strict DOM hygiene. 
tailwind-patterns │ Tailwind CSS v4 principles — CSS-first config, container queries, design token architecture. 
ui-styling        │ Beautiful, accessible UIs with shadcn/ui, Tailwind CSS, canvas-based visual designs. 
 
### 🔧 Specialized 
 
Skill                      │ Description 
brutalist-portfolio-nextjs │ Complete Next.js 16 brutalist portfolio — architecture, design system, 16 components, lessons learned. 
personal-portfolio         │ Tactile Brutalist + High-End Editorial portfolio SPA with React 19, Vite 6, Tailwind v4. 
web-shader-extractor       │ Extract WebGL/Canvas/Shader visual effects from webpages and port to standalone projects. 
 
## External Tool: tools-cli

**tools-cli** is a standalone CLI for file operations (read, write, edit, glob, grep) without requiring a full Claude session.

**Availability:** Check with `which tools-cli`. If not found, use `bun /home/project/cc-src/dist/tools-cli.js` instead.

**Setup required for glob/grep:**
```bash
export USE_BUILTIN_RIPGREP=false
```

### When to Use

| Use Case | Recommendation |
|----------|----------------|
| File discovery by pattern | ✅ Use `tools-cli glob` (cleaner than `bash find`) |
| Content search with regex | ✅ Use `tools-cli grep` (structured output) |
| Batch operations in scripts | ✅ Use `tools-cli` in bash loops |
| Single file read/write | ⚠️ Prefer built-in `read`/`write` tools |
| Single file edit | ❌ Use built-in `edit` tool (cache works in session) |

### Commands

```bash
# Find files
tools-cli glob --pattern "*.ts" --path src/ --head 10

# Search content
tools-cli grep --pattern "TODO" --path src/ --mode content --head 5

# Read file (returns JSON with file.content)
tools-cli read --file README.md --limit 10

# Write new file
tools-cli write --file /tmp/test.txt --content "Hello"

# Edit (⚠️ FAILS in CLI - use built-in edit tool instead)
```

### Key Limitations

- **Edit command fails:** Each CLI invocation is separate process with empty cache. Use built-in `edit` tool for single edits.
- **Write command cache check:** Existing files may fail with "File has been unexpectedly modified" if read in same session.
- **JSON output:** Add `--json` flag for structured output (parse with `jq`).

### Quick Examples

```bash
# Find all TypeScript files
tools-cli glob --pattern "src/**/*.ts"

# Search for function definitions
tools-cli grep --pattern "^function" --path src/ --mode content

# Read with line limits
tools-cli read --file package.json --limit 5 --json
```
