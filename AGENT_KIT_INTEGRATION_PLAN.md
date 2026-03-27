# Agent-Kit Integration Plan

> **Created:** 2026-03-27 09:52 SGT
> **Status:** Planning Phase

---

## 1. Integration Philosophy

**Goal:** Selectively integrate Agent-Kit skills and concepts that enhance my capabilities without duplicating existing OpenClaw patterns.

**Principle:** Agent-Kit provides **domain knowledge** (skills) and **prompt patterns** (agent personas). I'll use the knowledge, adapt the patterns.

---

## 2. Skills Integration — Domain Knowledge Loading

### 2.1 Skills Worth Loading (High-Value)

| Skill | Use Case | When to Load |
|-------|----------|--------------|
| `web-design-guidelines` | Web UI audit, accessibility, UX | Any frontend review or E2E testing |
| `systematic-debugging` | Root cause analysis | When troubleshooting complex issues |
| `testing-patterns` | Test strategy, coverage | When designing test suites |
| `plan-writing` | Task breakdown methodology | Complex multi-step tasks |
| `code-review-checklist` | PR reviews, code quality | Before any code submission |
| `api-patterns` | REST/GraphQL design | When building or reviewing APIs |
| `performance-profiling` | Optimization, Web Vitals | Performance-related tasks |
| `vulnerability-scanner` | Security auditing | Before deployment, security reviews |

### 2.2 Skills with Existing Equivalents (Skip or Supplement)

| Agent-Kit Skill | My Existing Resource | Decision |
|-----------------|---------------------|----------|
| `webapp-testing` | `webapp-testing-journey` skill | Use mine (has browser automation patterns) |
| `frontend-design` | `nextjs-tailwind-v4-luxe` skill | Use mine (project-specific) |
| `tailwind-patterns` | `tailwindcss-animations` knowledge | Supplement with Agent-Kit |
| `bash-linux` | Native knowledge | Load for complex scripting only |

### 2.3 Loading Protocol

**When a task matches a skill domain:**
1. Read the SKILL.md file (not all files in the skill folder)
2. Extract applicable rules/checklists
3. Apply to current task
4. No need to memorize — load on demand

**Example Flow:**
```
Task: "Review this React component for performance issues"
  → Load: skills/react-best-practices/SKILL.md
  → Apply: 57 rules from Vercel guidelines
  → Output: Review with specific violations cited
```

---

## 3. Agent Persona Patterns — Prompt Engineering Insights

### 3.1 Useful Patterns to Adopt

**A. Request Classification (from GEMINI.md)**
- Classify before acting: QUESTION | SURVEY | SIMPLE CODE | COMPLEX CODE | DESIGN/UI
- Determines response depth and whether to spawn sub-agents

**B. Specialist Activation Phrase**
- Agent-kit uses: `🤖 **Applying knowledge of @[agent-name]...**`
- I can use: `📋 Loading domain expertise: [skill-name]...`

**C. Structured Output Formats**
- Agent personas define specific output structures
- I can adopt similar discipline for complex tasks

### 3.2 Patterns Already Covered by OpenClaw

| Agent-Kit Pattern | OpenClaw Equivalent | Action |
|-------------------|--------------------| -------|
| Agent routing | `sessions_spawn` with `agentId` | No change needed |
| Multi-agent orchestration | `subagents` tool + `sessions_spawn` | No change needed |
| Skill loading | Skills system + SKILL.md files | No change needed |
| Validation scripts | TrustSkill, existing workflows | Use existing |

---

## 4. Workflow Integration Points

### 4.1 Before Starting Complex Tasks

**Step 1: Classify the Request**
```
QUESTION → Direct answer, no skills needed
SURVEY/INTEL → Read relevant skill, provide analysis
SIMPLE CODE → Direct edit, minimal skill loading
COMPLEX CODE → Load relevant skill(s), plan, then execute
DESIGN/UI → Load design skills, follow methodology
```

**Step 2: Load Appropriate Skill(s)**
- Complex code task → `plan-writing/SKILL.md`
- Bug fix → `systematic-debugging/SKILL.md`
- Frontend review → `web-design-guidelines/SKILL.md`
- API design → `api-patterns/SKILL.md`

**Step 3: Execute with Domain Expertise**

### 4.2 Before Sub-Agent Spawns

**For coding tasks:**
- Consider: Does this task need specific domain knowledge?
- If yes: Should I load a skill first, then spawn with context?
- Example: "Spawn opencode to implement auth → First load `api-patterns` for auth best practices"

### 4.3 Before Code Reviews

**Load:** `code-review-checklist/SKILL.md`
- Apply enterprise-grade review standards
- Check security, performance, maintainability

---

## 5. Skill Reading Queue (Prioritized)

### Immediate Load (Today)
- [ ] `plan-writing/SKILL.md` — Task breakdown methodology
- [ ] `systematic-debugging/SKILL.md` — Root cause analysis

### Load on Next Relevant Task
- [ ] `web-design-guidelines/SKILL.md` — UI audit rules
- [ ] `testing-patterns/SKILL.md` — Test strategies
- [ ] `code-review-checklist/SKILL.md` — Review standards

### Load as Needed
- [ ] `api-patterns/SKILL.md` — REST/GraphQL design
- [ ] `performance-profiling/SKILL.md` — Optimization
- [ ] `vulnerability-scanner/SKILL.md` — Security auditing
- [ ] `architecture/SKILL.md` — System design

---

## 6. Implementation in MEMORY.md

**Added:** Reference section for Agent-Kit with:
- Structure overview
- Key agents and skills
- Security audit status
- Use case guidance

**Next:** Update AGENTS.md or TOOLS.md with:
- Skill loading protocol
- When to load which skills
- Classification flow

---

## 7. Success Metrics

| Metric | Before | Target |
|--------|--------|--------|
| Skill loading on complex tasks | Ad-hoc | Systematic (classify → load → execute) |
| Domain expertise application | General knowledge | Skill-guided specific rules |
| Code review quality | Standard | Enterprise-grade checklist applied |
| Debugging approach | Iterative | Structured root cause analysis |

---

## 8. Next Actions

1. **Now:** Read `plan-writing/SKILL.md` and `systematic-debugging/SKILL.md`
2. **Update:** TOOLS.md with skill loading protocol
3. **Test:** Apply skill loading on next complex task
4. **Refine:** Adjust protocol based on what works

---

*Plan Created: 2026-03-27 09:52 SGT*
*Agent: trusty-pal*
