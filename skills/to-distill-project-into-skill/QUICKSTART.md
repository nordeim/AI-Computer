# QUICKSTART — Distill Your First SKILL.md

> **Time estimate:** 2-4 hours for a mid-size project (500-2,000 source files)  
> **Output:** A verified `PROJECT_NAME_SKILL.md` ready for future AI coding agents

---

## Prerequisites

- [ ] codebase exists and builds successfully (`pnpm build` passes)
- [ ] test suite passes (`pnpm test` passes) — or you know why it doesn't
- [ ] you have read access to all configuration files
- [ ] you know the deployment target (Vercel, AWS, Docker, etc.)

---

## Phase 1: ANALYZE (45 min)

Run these commands to gather intelligence:

```bash
# 1. Project identity
cat package.json | jq '.name, .version'
head -20 README.md

# 2. Tech stack inventory
npm list --depth=0 2>/dev/null || pnpm list --depth=0 2>/dev/null

# 3. Directory structure
find src -type f | head -100

# 4. Test count
pnpm test 2>&1 | grep -E "(Test Files|Tests)" | head -5

# 5. Component breakdown
grep -r "'use client'" src --include="*.tsx" | wc -l  # client components
grep -rL "'use client'" src --include="*.tsx" | wc -l  # server (approximate)

# 6. Env var count
grep -c "\.env\|process.env" src/lib/env* 2>/dev/null || echo "no env module found"
```

**Deliverable:** A one-paragraph project summary + version table

---

## Phase 2: PLAN (30 min)

Map the 20 sections to actual files:

```bash
# Map sections to source files
echo "Paste into the 20-section plan:"
for section in {1..20}; do
  echo "§$section → "
done
```

**Deliverable:** Numbered checklist with file paths for each section

---

## Phase 3: VALIDATE (15 min)

Confirm your plan before writing:

```bash
# Verify all planned source files exist
# (check phase 2 paths with ls -la)
```

**Deliverable:** Go/no-go decision with explicit gap list

---

## Phase 4: IMPLEMENT (90-180 min)

Write the SKILL.md section by section. For each section:

1. **Read the source files** (for code-specific sections)
2. **Write the section** following SPEC.md format
3. **Verify** by running the verification commands
4. **Commit** (mentally or actually) — "Section X done, verified"

**Pacing:** Expect 10-15 min per section for code-specific sections, 5-10 min for knowledge-specific sections.

---

## Phase 5: VERIFY (30 min)

Run the full validation checklist:

```bash
# 1. Version accuracy
npm list next react react-dom | grep "@"

# 2. Test counts match
pnpm test 2>&1 | grep -E "Test Files|Tests"

# 3. Grep for red flags
grep -n "TODO\|FIXME\|placeholder\|example.com" PROJECT_SKILL.md || echo "Clean!"

# 4. Verify file paths exist (spot-check 10)
awk '/src\// {print}' PROJECT_SKILL.md | head -10

# 5. Copy-paste a code snippet into the project to verify it compiles
```

---

## Phase 6: DELIVER (15 min)

1. Rename to `PROJECT_NAME_SKILL.md`
2. Add version stamp: `v1.0.0` with date
3. Write one-paragraph summary of what was added
4. Move to project root or `docs/` directory

---

## Troubleshooting

| Problem | Solution |
|---|---|
| "I don't know what goes in §7" | Skip it, mark as `[WIP]`, come back after writing other sections |
| "Test counts don't match" | Run tests again; if counts are different, document which are flaky |
| "I found a file that's not in the plan" | Add it to §5 component inventory; evaluate if it needs new anti-patterns |
| "§12 is empty because we haven't learnt anything" | Then skip it! Only document lessons that actually happened |
| "The document is getting too long" | Good — verbosity is better than omission. Focus on §1-§5 for brevity. |

---

*For complete specifications, see `SKILL.md` (the meta-skill).*
