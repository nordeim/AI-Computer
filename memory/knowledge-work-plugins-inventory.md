# Knowledge Work Plugins Inventory

**Location:** `/home/project/openclaw/knowledge-work-plugins/`

A comprehensive collection of 11 domain-specific plugins that enhance Claude's capabilities for specialized workflows. Each plugin bundles skills, slash commands, and MCP connectors.

---

## Plugin Summary

| Plugin | Skills | Commands | Primary Use |
|--------|--------|----------|-------------|
| **bio-research** | 5 | 1 | Life sciences R&D, genomics, target prioritization |
| **customer-support** | 5 | 5 | Ticket triage, response drafting, escalations |
| **data** | 7 | 6 | SQL queries, visualization, statistical analysis |
| **enterprise-search** | 3 | 2 | Cross-tool search (email, chat, docs, wikis) |
| **finance** | 6 | 5 | Journal entries, reconciliation, financial statements |
| **legal** | 6 | 5 | Contract review, NDA triage, compliance |
| **marketing** | 5 | 7 | Content creation, campaigns, brand voice |
| **product-management** | 6 | 6 | Specs, roadmaps, user research synthesis |
| **productivity** | 2 | 2 | Task management, workplace memory |
| **sales** | 6 | 3 | Account research, call prep, pipeline review |
| **cowork-plugin-management** | 1 | 0 | Create/customize plugins |

---

## Detailed Skills Inventory

### 🔬 Bio-Research (5 skills)
- `instrument-data-to-allotrope` — Convert instrument data to Allotrope format
- `nextflow-development` — Bioinformatics pipeline development (RNA-seq, ATAC-seq, Sarek)
- `scientific-problem-selection` — Framework for selecting research problems
- `scvi-tools` — Single-cell analysis with scVI/scanpy (batch correction, integration, velocity)
- `single-cell-rna-qc` — Quality control for single-cell RNA-seq data

### 🎧 Customer Support (5 skills)
- `customer-research` — Multi-source customer context research
- `escalation` — Package escalations with full context
- `knowledge-management` — KB article creation from resolved issues
- `response-drafting` — Professional response drafting by channel
- `ticket-triage` — Categorize, prioritize, and route tickets

### 📊 Data (7 skills)
- `data-context-extractor` — Extract metadata and context from datasets
- `data-exploration` — Explore schemas, tables, distributions
- `data-validation` — Validate data quality and consistency
- `data-visualization` — Create charts, graphs, visualizations
- `interactive-dashboard-builder` — Build interactive dashboards
- `sql-queries` — Write optimized SQL for any dialect
- `statistical-analysis` — Statistical tests, significance, correlations

### 🔍 Enterprise Search (3 skills)
- `knowledge-synthesis` — Synthesize results from multiple sources
- `search-strategy` — Decompose queries for multi-source search
- `source-management` — Manage connected data sources

### 💰 Finance (6 skills)
- `audit-support` — SOX compliance, control testing
- `close-management` — Month-end close workflows
- `financial-statements` — P&L, balance sheet, cash flow
- `journal-entry-prep` — Accruals, fixed assets, payroll entries
- `reconciliation` — GL-to-subledger, bank recs
- `variance-analysis` — Price/volume, rate/mix decomposition

### ⚖️ Legal (6 skills)
- `canned-responses` — Templated legal responses
- `compliance` — Regulatory monitoring, DPA reviews
- `contract-review` — Contract analysis and redlining
- `legal-risk-assessment` — Risk evaluation for decisions
- `meeting-briefing` — Prep for legal meetings
- `nda-triage` — Quick NDA assessment and routing

### 📢 Marketing (5 skills)
- `brand-voice` — Voice/tone consistency, style enforcement
- `campaign-planning` — Campaign frameworks, content calendars
- `competitive-analysis` — Competitor research, battlecards
- `content-creation` — Blog, social, email, landing pages
- `performance-analytics` — Marketing metrics, optimization

### 📦 Product Management (6 skills)
- `competitive-analysis` — Competitor feature comparison
- `feature-spec` — PRDs, user stories, requirements
- `metrics-tracking` — Product metrics analysis
- `roadmap-management` — Now/Next/Later, OKR-aligned
- `stakeholder-comms` — Status updates by audience
- `user-research-synthesis` — Interview/survey insights

### ✅ Productivity (2 skills)
- `memory-management` — Workplace context, people, terminology
- `task-management` — Markdown task lists, triage, sync

### 💼 Sales (6 skills)
- `account-research` — Company intel, contacts, signals
- `call-prep` — Pre-call research, agendas, discovery questions
- `competitive-intelligence` — Competitive landscape analysis
- `create-an-asset` — Sales collateral creation
- `daily-briefing` — Morning sales briefing
- `draft-outreach` — Personalized outreach emails

### 🛠️ Plugin Management (1 skill)
- `cowork-plugin-customizer` — Create/customize plugins for org

---

## Commands Quick Reference

### Customer Support
- `/triage` — Categorize and route ticket
- `/research` — Multi-source customer research
- `/draft-response` — Draft customer response
- `/escalate` — Package escalation
- `/kb-article` — Create KB article

### Data
- `/write-query` — Write SQL query
- `/explore-data` — Explore dataset
- `/analyze` — Statistical analysis
- `/create-viz` — Create visualization
- `/build-dashboard` — Build dashboard
- `/validate` — Validate data quality

### Finance
- `/journal-entry` — Prepare journal entry
- `/reconciliation` — Account reconciliation
- `/income-statement` — Generate P&L
- `/variance-analysis` — Analyze variances
- `/sox-testing` — SOX compliance testing

### Legal
- `/review-contract` — Review contract
- `/triage-nda` — Quick NDA assessment
- `/brief` — Meeting briefing
- `/respond` — Draft legal response
- `/vendor-check` — Vendor due diligence

### Marketing
- `/draft-content` — Create content
- `/campaign-plan` — Plan campaign
- `/brand-review` — Review against brand voice
- `/competitive-brief` — Competitor analysis
- `/performance-report` — Marketing report
- `/seo-audit` — SEO audit
- `/email-sequence` — Email sequence design

### Product Management
- `/write-spec` — Write PRD/feature spec
- `/roadmap-update` — Update roadmap
- `/stakeholder-update` — Status update
- `/synthesize-research` — User research synthesis
- `/competitive-brief` — Competitor brief
- `/metrics-review` — Metrics analysis

### Sales
- `/call-summary` — Process call notes
- `/forecast` — Sales forecast
- `/pipeline-review` — Pipeline health

### Productivity
- `/start` — Initialize tasks + memory
- `/update` — Triage stale items, sync

### Enterprise Search
- `/search` — Cross-tool search
- `/digest` — Synthesize results

### Bio-Research
- `/start` — Initialize bio-research workflow

---

## MCP Connectors by Domain

| Domain | Connectors |
|--------|------------|
| **Bio-Research** | PubMed, bioRxiv, ClinicalTrials.gov, ChEMBL, OpenTargets, Benchling, BioRender, Owkin, 10X Genomics |
| **Customer Support** | Slack, Intercom, HubSpot, Guru, Jira, Notion, Microsoft 365 |
| **Data** | Snowflake, Databricks, BigQuery, Hex, Amplitude, Jira |
| **Enterprise Search** | Slack, Notion, Guru, Jira, Asana, Microsoft 365 |
| **Finance** | Snowflake, Databricks, BigQuery, Slack, Microsoft 365 |
| **Legal** | Slack, Box, Egnyte, Jira, Microsoft 365 |
| **Marketing** | Slack, Canva, Figma, HubSpot, Amplitude, Notion, Ahrefs, SimilarWeb, Klaviyo |
| **Product Management** | Slack, Linear, Asana, Monday, ClickUp, Jira, Notion, Figma, Amplitude, Pendo, Intercom |
| **Sales** | Slack, HubSpot, Close, Clay, ZoomInfo, Notion, Jira, Fireflies, Microsoft 365 |
| **Productivity** | Slack, Notion, Asana, Linear, Jira, Monday, ClickUp, Microsoft 365 |

---

## Usage Notes

1. **Skills** activate automatically when relevant context is detected
2. **Commands** are explicit: `/domain:command-name`
3. **Connectors** configured via `.mcp.json` in each plugin folder
4. Plugins work standalone but are enhanced with MCP connections

---

**Created:** 2026-02-09
**Source:** `/home/project/openclaw/knowledge-work-plugins/`
