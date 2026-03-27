# AI Agent Handbook: Skill Security Scanning 📖

This handbook provides a methodical, step-by-step procedure for auditing OpenClaw skills. Follow this guide to replicate the "TrustSkill Deep Scan" methodology and achieve high-fidelity security results without requiring internal knowledge of the scanner's source code.

---

## Phase 1: Environment & Discovery

### 1. Identify the Target
Locate the `skills/` directory and ensure the `trustskill/` tool is present in the workspace.

### 2. Generate the Scan List
The batch scanner requires a list of absolute paths. Generate this using the following command:
```bash
find $(pwd)/skills -maxdepth 1 -mindepth 1 -type d > /tmp/skill_paths.txt
```

---

## Phase 2: Execution

### 3. Trigger the Deep Scan
Run the batch execution script. This script orchestrates individual scans for every directory listed in `/tmp/skill_paths.txt` using the `deep` analysis mode.
```bash
python3 trustskill/scripts/batch_scan.py
```

---

## Phase 3: Triage & Analysis

### 4. Locate the Results
The scan produces a consolidated report in JSON format. Open this file to begin the triage:
`trustskill/security_scan_results/consolidated_report.json`

### 5. Filter for High/Medium Findings
Focus exclusively on the `high_risk_skills` and `medium_risk_skills` arrays within the JSON. Ignore `LOW` findings unless directed otherwise.

---

## Phase 4: Manual Validation Protocol (Crucial) 🛡️

Automated scanners frequently flag documentation as code. An AI agent MUST perform contextual validation to separate "True Risks" from "False Positives."

### 6. The Context Check
For every `HIGH` or `MEDIUM` finding, inspect the source file at the reported line number.

#### **Case A: Documentation Reference (Safe)**
If the finding occurs in a `.md`, `.txt`, or `checklists` file and the context is:
- A recommendation (e.g., "Do not use eval").
- A placeholder (e.g., "your_api_key_here").
- A code example inside a markdown block (e.g., ` ```tsx ... ``` `).
- A URL to a public repository (e.g., `raw.githubusercontent.com`).
**Action**: Mark as **FALSE POSITIVE**.

#### **Case B: Executable Code (Risk)**
If the finding occurs in a `.py`, `.js`, `.sh`, or `.go` file and the context is:
- A variable being passed directly into a sink (e.g., `os.system(user_input)`).
- Hardcoded sensitive strings (e.g., `API_KEY = "sk-..."`).
- Network uploads of system files (e.g., `requests.post(url, data=open('/etc/passwd'))`).
**Action**: Mark as **TRUE POSITIVE**.

---

## Phase 5: Reporting

### 7. Final Classification
Sort all skills into three categories based on the validation:
1.  **✅ CLEAN**: No high/medium findings.
2.  **⚠️ VALIDATED**: Had findings, but all were manually verified as False Positives.
3.  **🔴 MALICIOUS**: Confirmed True Positives (Executable risks).

### 8. Verification Command
If you encounter a suspicious `subprocess` or `eval` in a script, verify the intent with a targeted read:
```python
# Strategy: Read 10 lines around the reported line to understand the flow.
read_file(file_path="...", start_line=line-5, end_line=line+5)
```

---
**Protocol End**
*Follow these steps exactly to ensure the safety of the OpenClaw Skill ecosystem.*
