# Methodologies Quick Reference

> Extracted from Agent-Kit skills: `plan-writing` and `systematic-debugging`
> Use these frameworks when approaching complex tasks.

---

## Task Planning (from plan-writing)

### The 5 Principles

1. **Keep It SHORT** — Max 5-10 tasks. If longer, split into multiple plans.
2. **Be SPECIFIC** — Not "Add authentication" → "Install next-auth, create `/api/auth/[...nextauth].ts`"
3. **Dynamic Content** — Plans are unique to the task. No copy-paste templates.
4. **Project-Specific Scripts** — Only use scripts relevant to THIS task.
5. **Simple Verification** — "Run `npm run dev`, click button, see toast" not "Verify it works"

### Plan Structure (Minimal)

```markdown
# [Task Name]

## Goal
One sentence: What are we building/fixing?

## Tasks
- [ ] Task 1: [Specific action] → Verify: [How to check]
- [ ] Task 2: [Specific action] → Verify: [How to check]
- [ ] Task 3: [Specific action] → Verify: [How to check]

## Done When
- [ ] [Main success criteria]
```

### Task Size Rule
- Each task: 2-5 minutes
- One clear outcome per task
- Independently verifiable

---

## Debugging (from systematic-debugging)

### 4-Phase Process

```
Phase 1: REPRODUCE
  → Before fixing, reliably reproduce the issue
  → Document exact steps, expected vs actual

Phase 2: ISOLATE
  → When did this start? What changed?
  → Can we reproduce with minimal code?
  → What's the smallest change that triggers it?

Phase 3: UNDERSTAND
  → The 5 Whys:
    1. Why: [First observation]
    2. Why: [Deeper reason]
    3. Why: [Still deeper]
    4. Why: [Getting closer]
    5. Why: [Root cause]

Phase 4: FIX & VERIFY
  → Bug no longer reproduces
  → Related functionality still works
  → No new issues introduced
  → Test added to prevent regression
```

### Debugging Checklist

**Before Starting:**
- [ ] Can reproduce consistently
- [ ] Have minimal reproduction case
- [ ] Understand expected behavior

**During Investigation:**
- [ ] Check recent changes (git log)
- [ ] Check logs for errors
- [ ] Add logging if needed

**After Fix:**
- [ ] Root cause documented
- [ ] Fix verified
- [ ] Regression test added
- [ ] Similar code checked

### Anti-Patterns to Avoid

| ❌ Wrong | ✅ Right |
|----------|----------|
| "Maybe if I change this..." | Reproduce first, then isolate |
| "That can't be the cause" | Follow the evidence |
| "It must be X" without proof | Verify assumptions |
| Fixing blindly | Understand before fixing |
| Stopping at symptoms | Find root cause (5 Whys) |

---

## Quick Decision Tree

```
COMPLEX TASK?
  ├─ Is it a bug?
  │    └─ YES → Use systematic-debugging (Reproduce → Isolate → Understand → Fix)
  │
  ├─ Is it new feature/build?
  │    └─ YES → Use plan-writing (Goal → Tasks → Verification)
  │
  └─ Is it code review?
       └─ YES → Load code-review-checklist
```

---

*Reference: Agent-Kit Integration Plan*
