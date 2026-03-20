# Cron Jobs

## Active Jobs
- **daily-ping-telegram**: 7:00 AM Asia/Singapore — Bitcoin, stocks, GitHub repos
- **S&P 500 Monitor**: Every 30 min heartbeat — Alert if drop ≥10%

## Known Issues
- Gateway auth tokens can become stale after config updates
- Requires `daemon-reload` + full restart, not just `restart`

## Location
- Config: ~/.openclaw/cron/jobs.json
