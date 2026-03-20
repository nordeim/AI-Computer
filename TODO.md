# TODO.md — Action Items & Optimization Tracker

> **Review cadence:** Check once per day during heartbeat/session start
> **Status legend:** `KIV` = Keep In View (pending) | `IN-PROGRESS` = Working on it | `DONE` = Completed | `BLOCKED` = Needs input
> **Rule:** KIV items stay on this list until Matt provides a status update. Never auto-dismiss.

---

## Active Items

### 1. Route cron jobs to cheaper models
- **Status:** KIV
- **Priority:** High (cost savings compound daily)
- **Effort:** ~10 minutes
- **What:** Audit all 30+ cron jobs, identify which ones are burning `hunter-alpha` tokens for simple tasks (daily ping, health checks, maintenance). Set `model` field in each `agentTurn` job to match task complexity. Reserve premium model for meta-analysis and heavy reasoning tasks.
- **Blocked on:** Need to confirm which models are available in the fallback chain and their relative costs
- **Notes:** Suggested 2026-03-16. Quick config edit, immediate ROI.

### 2. Add backup notification channel
- **Status:** KIV
- **Priority:** Medium (reduces single point of failure)
- **Effort:** ~15 minutes
- **What:** Add a secondary notification channel (Signal, or second Telegram bot/chat) for critical alerts only — cron failures, heartbeat alerts, daily ping failures. Not general chat, just failover for important notifications.
- **Blocked on:** Need to source provider (Signal setup or second Telegram bot)
- **Notes:** Suggested 2026-03-16. Current setup is Telegram-only, which means API outage = total notification blackout.

---

## Completed

*(Items move here when done, with date)*

---

## Dismissed / No Longer Relevant

*(Items Matt explicitly rejects or that become irrelevant, with reason)*

---

*Created: 2026-03-16 09:44 SGT*
*Last reviewed: 2026-03-20 08:11 SGT*
