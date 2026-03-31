## Executive summary (as of **March 31, 2026**)

- **OpenClaw is vastly more popular** (≈**342k GitHub stars**, **67.5k forks**, **1,424 contributors**) and has the larger “consumer-like” ecosystem (many channels, Control UI, optional desktop/mobile “nodes,” big plugin surface).   
- **Hermes Agent is much smaller but moving fast** (≈**18.5k stars**, **2.2k forks**, **218 contributors**) and is architected around a **self-improving loop** (skills + bounded memory + cross-session search) plus strong “agent ops” primitives (profiles/multi-instance, MCP server mode, research/RL tooling).   
- **If you want the biggest community + widest channel/app surface + plugin-first extensibility:** pick **OpenClaw**.   
- **If you want a persistent, server-friendly agent with explicit learning/memory mechanics + MCP interoperability + research readiness:** pick **Hermes Agent**.   
- **Security posture:** both take it seriously, but their trade-offs differ. OpenClaw is building a formal security program and marketplace scanning (VirusTotal for ClawHub) while also emphasizing correct configuration and acknowledging agent risk.  Hermes centers defense-in-depth with explicit approval/sandbox layers and tight env filtering for MCP subprocesses.   

---

## 1) Research plan (what I evaluated, and how)

### 1.1 Method (structured + evidence-based)
I evaluated **Hermes Agent** and **OpenClaw** along 6 axes, using primarily **first-party sources** (GitHub repos/releases, official docs, official blogs/security pages), then triangulated with community discussion where helpful:

1. **Popularity & momentum**  
   - GitHub stars/forks/contributors, issues/PR volume  
   - Release recency + cadence signals (commits since release tags)

2. **Ecosystem size & extensibility model**  
   - Skills format compatibility (Agent Skills / SKILL.md), hubs/registries  
   - Plugin systems vs MCP (Model Context Protocol) integration  
   - Marketplace/skill distribution and safety scanning

3. **Support & adoption signals**  
   - Sponsors/organizational backing  
   - Number of platforms/channels/integrations documented  
   - Migration tooling and interoperability

4. **Security model (defense-in-depth)**  
   - Sandbox/isolations, approval gates, allowlists/pairing  
   - Supply-chain controls (skill/plugin scanning, provenance)

5. **Strengths/weaknesses by use case**  
   - Personal assistant, team/ops delegate, research/RL, high-security deployments, multi-agent/multi-instance

6. **Practical recommendation rules**  
   - What to choose under concrete constraints (OS, scale, threat model, maintenance tolerance)

Key primary sources used include: the two GitHub repos and their latest releases, Hermes docs (memory/skills/MCP/security/architecture), OpenClaw docs (plugins/sandboxing/security), OpenClaw Trust site, and OpenClaw’s VirusTotal/ClawHub security announcement.   

---

## 2) Popularity, momentum, and “ecosystem gravity”

### 2.1 Raw popularity (GitHub)
| Metric | Hermes Agent | OpenClaw |
|---|---:|---:|
| Stars | ~**18.5k** | ~**342k** |
| Forks | ~**2.2k** | ~**67.5k** |
| Contributors | **218** | **1,424** |
| Issues / PRs | ~390–405 / ~617–626 | **5k+ / 5k+** |

Hermes Agent GitHub shows ~18.5k stars and ~2.2k forks with 218 contributors.   
OpenClaw GitHub shows ~342k stars and ~67.5k forks with 1,424 contributors, and a very large issue/PR backlog.   

**Interpretation (practical):** OpenClaw has far more “ecosystem gravity”: more third-party attention, more derivative work, more community troubleshooting, more plugins, and faster emergence of conventions. Hermes is big for a new agent project, but it’s operating in OpenClaw’s shadow in raw network effects.

### 2.2 Momentum via release recency + churn
- **Hermes Agent v0.6.0** released **March 30, 2026**, positioned as a major multi-instance/MCP/container/fallback-provider/platform expansion release.   
- **OpenClaw v2026.3.28** released **March 29, 2026**, with a very large change list (providers, plugin hooks for approval gating, channel behavior, CLI backends).   

A subtle but useful “velocity signal” is the “commits since this release” shown on the release pages: Hermes shows **22 commits** since v2026.3.30; OpenClaw shows **502 commits** since v2026.3.28—indicative of extremely high churn.   

**Interpretation:** OpenClaw is evolving at a rate that can be a superpower (fast fixes/features) or a liability (update treadmill, more regressions). Hermes is also moving quickly, but at a pace that is typically easier to operationalize.

---

## 3) Product philosophy & architecture (what each is “optimizing for”)

### 3.1 OpenClaw: “universal chat-gateway + plugin platform + optional apps/nodes”
OpenClaw positions itself as a personal assistant you run on your own devices, reachable from many chat channels, with a “Gateway” as the control plane plus optional apps (macOS app, iOS/Android nodes, Web UI).   
It also emphasizes onboarding (`openclaw onboard`), a daemonized gateway, and “multi-agent routing” where inbound channels/accounts/peers map to isolated agents/workspaces.   

**What this implies technically:** OpenClaw behaves like an *agent operating system*: lots of surfaces, lots of integration points, lots of policy knobs. That makes it very powerful, but it also increases configuration complexity and the number of things that can go wrong.

### 3.2 Hermes Agent: “persistent self-improving agent + toolsets + research-grade plumbing”
Hermes centers “the agent that grows with you”: a closed learning loop, procedural skills, bounded persistent memory, cron automation, subagents, multi-platform messaging gateway, and MCP integration.   
Its developer docs explicitly frame the codebase as multiple subsystems (agent loop, prompt system, provider runtime resolution, tools runtime, session persistence, gateway, ACP, cron, RL environments/trajectories).   

**What this implies technically:** Hermes is optimizing for *agent longevity* (memory/skills that remain useful over time), *predictable ops* (profiles / multi-instance isolation), and *interop* (MCP as the universal adapter layer).   

---

## 4) Ecosystems & extensibility (skills, plugins, interoperability)

### 4.1 Skills ecosystem: both participate in the Agent Skills (SKILL.md) world
Hermes explicitly states skills follow the **agentskills.io** open standard and are built around progressive disclosure (list → view → file) to manage token costs.   
Agent Skills describes the format as an open standard originally developed by Anthropic and adopted by multiple tools, with open development on GitHub/Discord.   

OpenClaw’s docs and repo structure also use the **workspace skills folder** pattern with `SKILL.md` per skill directory.   

**Big difference in practice:**  
- Hermes treats skills as **procedural memory** and has a first-class **“Skills Hub”** concept that can pull from multiple registries (official optional skills, skills.sh, well-known endpoints, GitHub, plus integrations like ClawHub).   
- OpenClaw treats skills as part of the platform too, but the center of gravity for extensibility is its **plugin system** (channels, providers, tools, hooks) distributed through npm.   

### 4.2 Hermes “hub aggregator” vs OpenClaw “platform marketplace” dynamics
Hermes’s Skills Hub lists `skills.sh` as a source, and `skills.sh` itself shows a very large directory/leaderboard with high install counts.   
OpenClaw points to **ClawHub** as a minimal skills registry that the agent can search and pull from automatically.   

However, when I loaded ClawHub’s front page it displayed “no skills yet” in highlighted/popular sections (which may be a sign-in issue, early-stage UI, or simply that “popular” lists are not populated).   

### 4.3 OpenClaw plugins: deep, typed, runtime-extending
OpenClaw’s plugin docs describe a multi-layer plugin system (manifest/discovery, enablement/validation, runtime loading, then exposing tools/channels/providers/hooks/routes/commands).   
Its “Building Plugins” doc explicitly encourages external plugin development published to npm and installable via `openclaw plugins install …`.   

Additionally, OpenClaw v2026.3.28 adds a notable capability: plugin hooks can now *pause tool execution and request approval* via an async `requireApproval` mechanism in `before_tool_call` hooks—i.e., plugins can become enforcement points, not just functionality add-ons.   

**Implication:** OpenClaw is a better fit when you want to build a *first-class extension* that behaves like a native subsystem (new channel adapter, provider integration, policy enforcement, UI surfaces, etc.).

### 4.4 Hermes extensibility: MCP-first + a lighter internal plugin/skill story
Hermes’s MCP docs emphasize connecting to external tool servers (stdio or HTTP), automatic discovery, and per-server tool filtering (include/exclude) for safety.   
Hermes v0.6.0 also introduced **MCP server mode** (`hermes mcp serve`) to expose Hermes sessions/conversations to MCP clients (Claude Desktop, Cursor, VS Code), making Hermes itself a tool-server for other ecosystems.   

Hermes also ships a skills system where missing secrets are requested only locally (CLI), not via chat platforms, and it supports quarantining/auditing of hub-installed skills.   

**Implication:** Hermes is a better fit when your integration plan is “compose existing tools safely” (MCP) rather than “extend the platform in-process.”

---

## 5) Support, adoption, and “institutional backing”

### 5.1 OpenClaw: sponsors + formal trust/security program
OpenClaw’s repo lists sponsors including **OpenAI, Vercel, Blacksmith, Convex**.   
OpenClaw also runs a dedicated **Trust** site describing a structured security program (threat model, public roadmap, code review, triage SLAs) and emphasizes that agent security risks (prompt injection/tool abuse/identity risks) are real and documented.   

### 5.2 Hermes Agent: Nous Research as the “core lab,” plus cross-ecosystem compatibility
Hermes is presented as built by **Nous Research**, and explicitly highlights compatibility with the Agent Skills open standard and MCP.   
It also includes a first-class **migration path from OpenClaw** (`hermes claw migrate`) importing memories, skills, allowlists, messaging settings, and selected API keys.   

**Interpretation:** OpenClaw has more external institutional scaffolding today (sponsors + trust program); Hermes has a clearer “lab-engineered” architecture story and a deliberate bridge for OpenClaw users.

---

## 6) Community reviews & sentiment (what users praise/complain about)

### 6.1 OpenClaw: “wow” factor + real frustration (especially around stability/sandboxing)
OpenClaw’s own site curates many enthusiastic quotes emphasizing persistent context, skills, proactive automation, and the experience of controlling real integrations from chat.   
At the same time, community threads report that OpenClaw can feel “buggy” or unstable for some setups.   
A recurring pain point is **sandbox configuration friction**: users report that once sandboxing is enabled, things fail due to tool/network restrictions, and it can be hard to reason about layered policies.   

### 6.2 Hermes: early but positive signals, with “engineered” safety/ops features
Hermes has fewer broad public testimonials simply because it’s smaller, but there are community posts about migrating from OpenClaw and finding Hermes smoother or more effective in side-by-side usage.   
From the release notes and docs, Hermes is clearly investing in operational ergonomics: **profiles** (multi-instance isolation), **fallback providers**, and explicit, documented security layers.   

**My synthesis:** OpenClaw’s community is large enough that you’ll see *everything*—genius workflows, broken upgrades, security drama, amazing plugins, and endless troubleshooting. Hermes’s community footprint is smaller, so signals skew more “early adopter / engineering-driven.”

---

## 7) Security model comparison (what’s actually different)

### 7.1 OpenClaw security posture (official framing)
OpenClaw’s Trust page is blunt that agents can execute commands, send messages as you, fetch arbitrary URLs, and schedule tasks—making security critical—and it lays out a phased security program and default controls (pairing, exec deny-by-default with approval on miss, allowFrom defaults, SSRF protection, gateway auth).   
OpenClaw’s security docs also explicitly state it is **not a hostile multi-tenant boundary** and provides guidance around sandbox/workspace access defaults.   

On supply chain: OpenClaw announced **VirusTotal scanning for ClawHub** skill bundles, including hash-based lookups and LLM-based “Code Insight,” plus re-scans.   

### 7.2 Hermes security posture (official framing)
Hermes documents a 5-layer defense-in-depth model: user authorization, dangerous command approval, container isolation, MCP credential filtering, and context file scanning for injection.   
Hermes also provides very explicit container hardening flags for Docker backend (cap-drop, no-new-privileges, pid limits, tmpfs mounts) and defaults to “fail-closed” approval timeouts.   
On MCP specifically, Hermes emphasizes filtering what env vars reach MCP subprocesses and supports per-server tool allow/deny lists (a meaningful control when MCP servers expose powerful actions).   

### 7.3 Practical security trade-off (how I’d reason about it)
- OpenClaw’s advantage: a **platform-wide** security program, plus plugin hooks that can enforce approval flows, plus marketplace scanning.   
- Hermes’s advantage: simpler-to-audit security story for “agent runs commands” with explicit approval modes + container backends, plus aggressive environment filtering for integrations like MCP.   

If you are operating under a strict threat model, the *real* differentiator often becomes: **How many surfaces are you enabling?** OpenClaw can sprawl into many channels/apps/nodes quickly; Hermes tends to keep the core surfaces more concentrated (CLI + gateway + toolsets + MCP).   

---

## 8) Strengths/weaknesses by use case (where each wins)

### Use case A — “Personal assistant across many chat apps, with optional desktop/mobile UX”
**Recommend: OpenClaw**, because it is explicitly designed as a gateway spanning a huge set of chat channels plus optional apps/nodes and a Control UI/dashboard.   

**Hermes can do this too** (Telegram/Discord/Slack/WhatsApp + gateway), but OpenClaw’s surface area here is simply broader and more productized.   

**OpenClaw downside:** more moving parts, more policy configuration, and community reports of sandbox confusion/friction.   

---

### Use case B — “A long-running agent on a VPS/server that ‘learns’ your projects and gets better over time”
**Recommend: Hermes Agent**, because its memory model is explicit and bounded (MEMORY.md + USER.md limits), it supports session search over stored transcripts (SQLite/FTS5), and it emphasizes persistence + learning loop as first-class product behavior.   

OpenClaw also has persistent workspace files and compaction/memory flush concepts, but Hermes’s “self-improving” and memory boundaries are more deliberately specified and operationally predictable.   

---

### Use case C — “You want extensibility via a real plugin platform (channels/providers/tools/hooks)”
**Recommend: OpenClaw**, because its plugin system is deep, typed, and designed for independent ownership/distribution via npm, plus it can intercept tool calls via hooks and approval gating.   

**Hermes** can extend via MCP (often the fastest route when an MCP server already exists), but it’s a different model: composition rather than in-process platform extension.   

---

### Use case D — “Security-sensitive automations, especially when exposing an agent in messaging/group contexts”
This is nuanced:

- **Hermes wins** when you want a very legible layered model: allowlists/pairing + dangerous command approval + hardened container backends, plus explicit env passthrough controls.   
- **OpenClaw wins** when you want ecosystem-level security investments (Trust program + marketplace scanning + platform enforcement hooks) and you’re willing to operate the platform carefully.   

If your deployment is “agent has real privileges + reachable by many people,” I generally prefer the system with the fewest enabled surfaces and the strongest default isolation story—which often points to **Hermes in Docker/Modal/Daytona backends** for execution, *or* OpenClaw with sandboxing + strict allowFrom/pairing + audited plugins.   

---

### Use case E — “Research / RL / dataset generation on tool-using agents”
**Recommend: Hermes Agent**. It explicitly advertises batch trajectory generation, RL training integration, and trajectory export/compression for training tool-calling models, and the architecture docs show this as a real subsystem (not an afterthought).   

OpenClaw can of course be used experimentally, but its center of gravity is a consumer/ops platform more than a research harness.

---

## 9) Concrete recommendation rules (when I’d pick each)

### I recommend **OpenClaw** when…
1. **Network effects matter**: you want the largest community, most examples, most plugins, most “someone already solved this.”   
2. You need **maximum channel/app coverage** and like the “gateway + dashboard + optional apps/nodes” direction.   
3. You want to build **first-class platform extensions** (channels/providers/tools) and distribute them cleanly via npm.   
4. You can tolerate (or even prefer) **very rapid iteration** and will pin versions / stage upgrades.   

**OpenClaw watch-outs (pragmatic):** expect higher operational complexity (policy layering, sandbox config), more churn, and more need for disciplined ops.   

---

### I recommend **Hermes Agent** when…
1. You want a **server-grade persistent agent** with an explicit **learning loop** and bounded memory model you can reason about.   
2. You want **multi-instance isolation** as a first-class primitive (profiles) rather than assembling it yourself.   
3. Your integration strategy is **MCP-first** (compose external tool servers safely, filter surfaces per server).   
4. You care about **research workflows** (trajectories, RL hooks, batch processing).   
5. You’re coming from OpenClaw and want a **supported migration** path for skills/memories/config.   

**Hermes watch-outs:** smaller community means fewer third-party integrations “by default,” and some things you’d get as an OpenClaw plugin may require MCP setup or custom tooling.

---

## 10) High-value “how to choose” checklist (fast but rigorous)

If I were advising a team in Silicon Valley to choose in a week, I’d do this:

1. **Pick 3 representative workflows** (e.g., inbox/calendar triage; repo maintenance + PR automation; weekly reporting/cron).  
2. For each system, measure:
   - Setup time to first successful run  
   - Number of “policy surprises” (sandbox blocks, missing permissions, secrets handling)  
   - Recovery time after one intentionally broken dependency/provider  
3. **Security drill** (tabletop):
   - Prompt injection attempt via a fetched web page or chat message  
   - Least-privilege check: can the agent reach secrets it shouldn’t?  
4. **Maintenance drill**:
   - Upgrade to the newest release and record what breaks (OpenClaw’s churn makes this especially important).   

---

## Small transparency note (one data gap)
I attempted to pull npm download statistics for the `openclaw` package, but npm blocked automated access (HTTP 403), so I did **not** include download counts as a primary popularity metric here. Instead, I relied on verifiable GitHub metrics plus ecosystem signals like skills.sh install leaderboard visibility and first-party docs/blog/trust materials. ([]())

