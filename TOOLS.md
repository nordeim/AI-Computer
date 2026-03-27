# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## Workspace
- **Primary workspace**: `/home/project/openclaw/`
- **OpenClaw config**: `/home/pete/.openclaw/workspace/`
- **Purpose**: Save logs, working documents, ToDos, and project files

## Coding Agents (Configured)
When invoking sub-agents for coding tasks, use these agents:

| Agent | Path | Purpose |
|-------|------|---------|
| OpenCode | `/usr/bin/opencode` | General coding, full-stack development |
| Kimi CLI | `/home/pete/.local/bin/kimi-cli` | Code analysis, debugging, optimization |
| Gemini | `/usr/bin/gemini` | Quick Q&A, summaries, generation |

## Usage Pattern
```bash
# When spawning sub-agents, reference these paths
sessions_spawn(task="...", agentId="opencode")
```

## Project Workspace Skills (`/home/project/openclaw/skills/`)
**115 skills** across 9 categories. Use the skill search tool to find the right one:

```bash
# Search by keyword
python3 ~/.openclaw/workspace/scripts/skill-search.py "email"

# Get recommendations for a task
python3 ~/.openclaw/workspace/scripts/skill-search.py --recommend "create a github issue"

# List by category
python3 ~/.openclaw/workspace/scripts/skill-search.py --category development

# Show skill details
python3 ~/.openclaw/workspace/scripts/skill-search.py --detail mcp-builder

# List all categories
python3 ~/.openclaw/workspace/scripts/skill-search.py --list
```

**Catalog**: `memory/skills-catalog.json` — full inventory with use-case mapping

### Key Skills Quick Reference
| Skill | Purpose | Category |
|-------|---------|----------|
| mcp-builder | Create MCP servers (Python/TypeScript) | development |
| artifacts-builder | React + Tailwind + shadcn/ui artifacts | development |
| opencode-orchestrator | Autonomous coding via OpenCode CLI | development |
| webapp-testing | Playwright testing for local webapps | development |
| canvas-design | Visual art in PNG/PDF | creative_media |
| file-organizer | Organize files, find duplicates | productivity |
| connect | Connect to 1000+ apps via Composio | meta_utility |
| skill-creator | Create new Claude skills | meta_utility |

### App Automation Skills (78 via Rube MCP/Composio)
Categories: crm_sales, project_management, communication, email, devops, storage, spreadsheets, calendar, social_media, support, ecommerce, design_collab, analytics, hr

All require: `RUBE_SEARCH_TOOLS` available + OAuth connection via `RUBE_MANAGE_CONNECTIONS`

## Global Skills (`/home/pete/.claude/skills/`)
- Primary skill for Next.js/Tailwind: `nextjs-tailwind-v4-luxe`

## Active Automations
- **Daily Ping**: 7:00 AM SGT — Bitcoin, stocks (NVDA, MSFT, GOOGL, INTC, META, AMD), GitHub repos → Telegram
- **S&P 500 Monitor**: Every 30 min heartbeat — Alert if ≥10% drop

## Knowledge Work Plugins (`/home/project/openclaw/knowledge-work-plugins/`)
11 domain plugins with 55 skills + 42 commands:
- **bio-research** — Life sciences R&D, genomics, scRNA-seq
- **customer-support** — Ticket triage, responses, escalations
- **data** — SQL, visualization, statistical analysis
- **enterprise-search** — Cross-tool search
- **finance** — Journal entries, reconciliation, SOX
- **legal** — Contract review, NDA triage, compliance
- **marketing** — Content, campaigns, brand voice
- **product-management** — Specs, roadmaps, user research
- **productivity** — Tasks, workplace memory
- **sales** — Account research, call prep, pipeline
- **cowork-plugin-management** — Create/customize plugins

> See `memory/knowledge-work-plugins-inventory.md` for full details

## Agent-Kit Skills Integration

**Location:** `/home/pete/.openclaw/workspace/agent-kit/skills/`

High-quality domain knowledge modules to load on-demand. Use when working in these domains:

### Priority Skills to Load

| Skill | Use Case | Load Command |
|-------|----------|--------------|
| `plan-writing` | Task breakdown, multi-step work | Read `agent-kit/skills/plan-writing/SKILL.md` |
| `systematic-debugging` | Root cause analysis, bug fixes | Read `agent-kit/skills/systematic-debugging/SKILL.md` |
| `web-design-guidelines` | UI audit, accessibility, UX | Read `agent-kit/skills/web-design-guidelines/SKILL.md` |
| `testing-patterns` | Test strategy, coverage | Read `agent-kit/skills/testing-patterns/SKILL.md` |
| `code-review-checklist` | PR reviews, code quality | Read `agent-kit/skills/code-review-checklist/SKILL.md` |
| `api-patterns` | REST/GraphQL design | Read `agent-kit/skills/api-patterns/SKILL.md` |
| `performance-profiling` | Optimization, Web Vitals | Read `agent-kit/skills/performance-profiling/SKILL.md` |
| `vulnerability-scanner` | Security auditing | Read `agent-kit/skills/vulnerability-scanner/SKILL.md` |

### Skill Loading Protocol

**Before complex tasks:**
1. Classify the request: QUESTION | SURVEY | SIMPLE CODE | COMPLEX CODE | DESIGN/UI
2. If COMPLEX CODE or DESIGN/UI → Load relevant skill's SKILL.md
3. Apply domain expertise to task
4. No need to memorize — load on demand

**Example:**
```
Task: "Debug why the API returns 500 errors"
  → Load: agent-kit/skills/systematic-debugging/SKILL.md
  → Apply: 4-phase debugging (Reproduce → Isolate → Understand → Fix)
  → Output: Root cause documented + regression test added
```

### Request Classification Quick Reference

| Type | Trigger Words | Action |
|------|---------------|--------|
| QUESTION | "what is", "how does", "explain" | Direct answer, no skills |
| SURVEY | "analyze", "list", "overview" | Load skill if domain-specific |
| SIMPLE CODE | "fix", "add" (single file) | Direct edit, minimal skill load |
| COMPLEX CODE | "build", "create", "implement", "refactor" | Load skill, plan, then execute |
| DESIGN/UI | "design", "UI", "page", "dashboard" | Load design skills |

---

## User Contacts
- Primary phone: +6591127357
- Backup phone: +6597730111 (task completion notifications)
- **External channel:** Telegram only (WhatsApp disabled 2026-03-15)

