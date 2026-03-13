We'll create a single, self-contained Docker image that runs a personal "Perplexity Computer" clone. The container includes:

- **Execution sandbox** (Python, Node.js, Playwright, ffmpeg, bash, etc.)
- **Orchestrator** (FastAPI web server with task decomposition, model routing, sub‑agent management)
- **Safety gate** (mandatory `confirm_action` for sensitive operations)
- **Connector framework** (stub for OAuth/API integrations – extend as needed)
- **Web terminal** (ttyd) for direct shell access
- **Cron** for scheduled background tasks

All services run inside the same container, started by an entrypoint script. The web UI (on port 7860) lets you submit goals, view pending approvals, and monitor progress. The orchestrator uses API keys you provide as environment variables.

---

## File Structure

Place these files in one directory before building:

```
.
├── Dockerfile
├── docker-entrypoint.sh
├── app/
│   ├── main.py                 # FastAPI entrypoint
│   ├── orchestrator.py         # core orchestration logic
│   ├── model_routing.py
│   ├── task_decomposer.py
│   ├── safety.py               # confirm_action
│   ├── connectors.py           # external service stubs
│   └── templates/              # (optional) HTML for web UI
```

---

## 1. Enhanced Dockerfile

```dockerfile
# syntax=docker/dockerfile:1

# ----------------------------------------------------------------------
# SINGLE STAGE: all-in-one container for personal Perplexity Computer clone
# ----------------------------------------------------------------------
FROM python:3.13-trixie

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    TTYD_PORT=7681 \
    APP_PORT=7860 \
    XDG_RUNTIME_DIR=/tmp/runtime-user \
    PATH="/home/user/.local/bin:/usr/local/bin:${PATH}"

# ----------------------------------------------------------------------
# 1. Install system dependencies (all in one layer)
# ----------------------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    bash coreutils ca-certificates cron curl git less procps sudo vim \
    tar wget zip unzip tmux jq \
    # Build tools for ttyd
    build-essential cmake pkg-config \
    # ttyd dependencies
    libjson-c-dev libssl-dev libwebsockets-dev \
    # Node.js prerequisites
    gnupg \
    # Playwright system dependencies
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libcairo2 libcups2 \
    libdbus-1-3 libdrm2 libgbm1 libglib2.0-0 libnspr4 libnss3 \
    libpango-1.0-0 libx11-6 libxcb1 libxcomposite1 libxdamage1 \
    libxext6 libxfixes3 libxrandr2 libxshmfence1 \
    # Cleanup
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------------------
# 2. Install bun, uv, uvx (from your provided binaries)
# ----------------------------------------------------------------------
RUN cd /usr/bin && wget https://github.com/nordeim/HF-Space/raw/refs/heads/main/bun
RUN cd /usr/bin && wget https://github.com/nordeim/HF-Space/raw/refs/heads/main/uv
RUN cd /usr/bin && wget https://github.com/nordeim/HF-Space/raw/refs/heads/main/uvx
RUN chmod a+x /usr/bin/bun /usr/bin/uv*

# ----------------------------------------------------------------------
# 3. Install Node.js via NodeSource (LTS version)
# ----------------------------------------------------------------------
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    node --version && npm --version

# ----------------------------------------------------------------------
# 4. Build ttyd (web terminal)
# ----------------------------------------------------------------------
RUN cd /tmp && \
    git clone --depth 1 --branch 1.7.4 https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && make install && \
    cd / && rm -rf /tmp/ttyd && \
    ttyd --version

# ----------------------------------------------------------------------
# 5. Install global npm packages (useful for agents)
# ----------------------------------------------------------------------
RUN npm install -g --omit=dev \
    pnpm@latest \
    @google/gemini-cli@latest \
    vite@latest \
    vitest@latest \
    clawhub@latest \
    openclaw@latest \
    @playwright/mcp@latest \
    agent-browser@latest \
    @anthropic-ai/claude-code@latest

# ----------------------------------------------------------------------
# 6. Install Python packages (including FastAPI and AI libraries)
# ----------------------------------------------------------------------
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    fastapi uvicorn httpx pydantic python-multipart \
    sqlalchemy alembic aiofiles jinja2 \
    playwright \
    anthropic google-generativeai openai

# ----------------------------------------------------------------------
# 7. Install Playwright browsers and dependencies
# ----------------------------------------------------------------------
RUN npx playwright install chromium && \
    npx playwright install-deps chromium

# ----------------------------------------------------------------------
# 8. Create non-root user (for security and Hugging Face compatibility)
# ----------------------------------------------------------------------
RUN groupadd -g 1000 user && \
    useradd -m -u 1000 -g user -d /home/user user && \
    # Limited sudo for cron only
    echo "user ALL=(ALL) NOPASSWD: /usr/sbin/cron" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user && \
    # Create directories for IPC, artifacts, etc.
    mkdir -p ${XDG_RUNTIME_DIR} /data /app /workspace/{ipc,tasks,artifacts,logs,memory} && \
    chown -R user:user ${XDG_RUNTIME_DIR} /data /app /workspace

# ----------------------------------------------------------------------
# 9. Switch to non-root user for the rest
# ----------------------------------------------------------------------
USER user
WORKDIR /app

# ----------------------------------------------------------------------
# 10. Copy application code (scripts)
# ----------------------------------------------------------------------
COPY --chown=user:user app/ /app/
COPY --chown=user:user docker-entrypoint.sh /usr/local/bin/

# ----------------------------------------------------------------------
# 11. Install any Python dependencies from requirements.txt (if present)
# ----------------------------------------------------------------------
RUN if [ -f "requirements.txt" ]; then \
        pip install --no-cache-dir --user -r requirements.txt; \
    fi

# ----------------------------------------------------------------------
# 12. Expose ports: ttyd (7681) and web app (7860)
# ----------------------------------------------------------------------
EXPOSE ${TTYD_PORT} ${APP_PORT}

# ----------------------------------------------------------------------
# 13. Health check (required by some cloud platforms)
# ----------------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${APP_PORT}/health || exit 1

# ----------------------------------------------------------------------
# 14. Entrypoint
# ----------------------------------------------------------------------
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
```

---

## 2. docker‑entrypoint.sh (Process Launcher)

```bash
#!/usr/bin/env bash
set -e

# Start cron as root (requires sudo)
start_cron() {
    echo "Starting cron service..."
    # Load user's crontab if exists (from /app/crontab)
    if [ -f "/app/crontab" ]; then
        crontab /app/crontab
    fi
    sudo /usr/sbin/cron -f &
    CRON_PID=$!
    echo "Cron started with PID: ${CRON_PID}"
}

# Start ttyd web terminal
start_ttyd() {
    echo "Starting ttyd web terminal on port ${TTYD_PORT:-7681}..."
    /usr/local/bin/ttyd \
        -p "${TTYD_PORT:-7681}" \
        --writable \
        -t theme='{"background": "#0a0a0a"}' \
        bash --login &
    TTYD_PID=$!
    echo "ttyd started with PID: ${TTYD_PID}"
}

# Start the FastAPI app (orchestrator)
start_app() {
    echo "Starting FastAPI orchestrator on port ${APP_PORT:-7860}..."
    uvicorn main:app --host 0.0.0.0 --port "${APP_PORT:-7860}" &
    APP_PID=$!
    echo "FastAPI started with PID: ${APP_PID}"
}

# Cleanup on exit
cleanup() {
    echo "Shutting down services..."
    [ -n "${TTYD_PID}" ] && kill ${TTYD_PID} 2>/dev/null || true
    [ -n "${CRON_PID}" ] && sudo kill ${CRON_PID} 2>/dev/null || true
    [ -n "${APP_PID}" ] && kill ${APP_PID} 2>/dev/null || true
    exit 0
}
trap cleanup SIGINT SIGTERM

# Main entrypoint logic
case "${1}" in
    "start")
        start_cron
        start_app
        start_ttyd
        ;;
    "cron-only")
        start_cron
        tail -f /dev/null
        ;;
    "ttyd-only")
        start_ttyd
        tail -f /dev/null
        ;;
    "app-only")
        start_app
        tail -f /dev/null
        ;;
    *)
        exec "$@"
        ;;
esac

# Wait for any process to exit
wait -n
```

Make it executable:

```bash
chmod +x docker-entrypoint.sh
```

---

## 3. Application Scripts (inside `app/` directory)

### `app/main.py` – FastAPI entrypoint

```python
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
import os
import json
import asyncio
from orchestrator import PerplexityCloneOrchestrator
from safety import pending_approvals

app = FastAPI(title="Personal Perplexity Computer")
templates = Jinja2Templates(directory="templates")

# Instantiate the orchestrator (could be done lazily)
orchestrator = PerplexityCloneOrchestrator()

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.post("/api/run")
async def run_goal(goal: str):
    """Submit a new goal to the orchestrator."""
    task_id = await orchestrator.submit_goal(goal)
    return {"task_id": task_id, "status": "queued"}

@app.get("/api/tasks/{task_id}")
async def get_task_status(task_id: str):
    task = orchestrator.get_task(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@app.get("/api/approvals")
async def list_approvals():
    """Return all actions waiting for user confirmation."""
    return {"pending": list(pending_approvals.values())}

@app.post("/api/approvals/{approval_id}")
async def decide_approval(approval_id: str, decision: bool):
    """Approve (true) or reject (false) a pending action."""
    if approval_id not in pending_approvals:
        raise HTTPException(status_code=404, detail="Approval not found")
    # Resume the waiting task with the decision
    pending_approvals[approval_id]["decision"] = decision
    pending_approvals[approval_id]["event"].set()
    return {"status": "decision recorded"}
```

### `app/orchestrator.py` – Core orchestration logic

```python
import asyncio
import uuid
import json
from typing import Dict, Any
from datetime import datetime
from model_routing import route_task
from task_decomposer import decompose_goal
from safety import confirm_action
from connectors import execute_connector_action

class PerplexityCloneOrchestrator:
    def __init__(self):
        self.tasks: Dict[str, Dict[str, Any]] = {}
        self.sub_agents = {}  # In-memory for simplicity

    async def submit_goal(self, goal: str) -> str:
        task_id = str(uuid.uuid4())
        self.tasks[task_id] = {
            "id": task_id,
            "goal": goal,
            "status": "decomposing",
            "created_at": datetime.now().isoformat(),
            "result": None,
            "subtasks": []
        }
        asyncio.create_task(self._process_goal(task_id))
        return task_id

    async def _process_goal(self, task_id: str):
        task = self.tasks[task_id]
        try:
            # 1. Decompose goal into subtasks using a reasoning model
            task["status"] = "decomposing"
            subtasks = await decompose_goal(task["goal"])
            task["subtasks"] = subtasks
            task["status"] = "executing"

            # 2. Execute subtasks in parallel (with dependency handling simplified)
            results = await asyncio.gather(*[
                self._execute_subtask(st) for st in subtasks
            ])

            # 3. Synthesize final result (could use another LLM call)
            task["result"] = {"subtask_results": results}
            task["status"] = "completed"
        except Exception as e:
            task["status"] = "failed"
            task["error"] = str(e)

    async def _execute_subtask(self, subtask: dict) -> dict:
        """Execute a single subtask using the appropriate model/tool."""
        # Determine which model to use
        model = route_task(subtask["type"], subtask["description"])

        # If the subtask requires an external connector (e.g., send email)
        if subtask.get("connector"):
            # Call safety gate before executing
            approved = await confirm_action(
                subtask["connector"]["action"],
                subtask["connector"]["params"]
            )
            if not approved:
                return {"status": "rejected", "subtask": subtask}
            # Execute with connector (credentials managed outside sandbox)
            result = await execute_connector_action(
                subtask["connector"]["service"],
                subtask["connector"]["action"],
                subtask["connector"]["params"]
            )
            return {"status": "done", "result": result}

        # Otherwise, it's an internal task (code, research, etc.)
        # For simplicity, we'll just call an LLM with the task description.
        # In a real implementation, you would spawn a subprocess with the sandbox.
        # Here we simulate by calling a generic LLM.
        from model_routing import call_llm
        response = await call_llm(model, subtask["description"])
        return {"status": "done", "result": response, "model_used": model}

    def get_task(self, task_id: str):
        return self.tasks.get(task_id)
```

### `app/model_routing.py` – Model selection and LLM calls

```python
import os
import httpx
from typing import Optional

# Define routing table (mimicking Perplexity's multi-model approach)
MODEL_ROUTING = {
    "reasoning": "claude-3-5-sonnet-20241022",   # Complex planning
    "research":  "gemini-2.0-pro-exp-02-05",     # Deep web research
    "code":      "claude-3-5-sonnet-20241022",    # Code generation
    "speed":     "gpt-4o-mini",                   # Fast lightweight tasks
    "long_ctx":  "gemini-2.0-flash-thinking-exp", # Long document analysis
    "images":    "dall-e-3",                      # Image generation (via OpenAI)
}

def route_task(task_type: str, description: str) -> str:
    """Return the model name best suited for this task type."""
    return MODEL_ROUTING.get(task_type, MODEL_ROUTING["reasoning"])

async def call_llm(model: str, prompt: str, temperature: float = 0.7) -> str:
    """
    Unified LLM caller – routes to the appropriate provider based on model name.
    You must set API keys in environment variables:
        ANTHROPIC_API_KEY, OPENAI_API_KEY, GOOGLE_API_KEY
    """
    if model.startswith("claude"):
        return await _call_anthropic(model, prompt, temperature)
    elif model.startswith("gpt"):
        return await _call_openai(model, prompt, temperature)
    elif model.startswith("gemini"):
        return await _call_google(model, prompt, temperature)
    else:
        raise ValueError(f"Unknown model: {model}")

async def _call_anthropic(model: str, prompt: str, temperature: float) -> str:
    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        return "[ANTHROPIC_API_KEY not set]"
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json"
            },
            json={
                "model": model,
                "max_tokens": 1024,
                "temperature": temperature,
                "messages": [{"role": "user", "content": prompt}]
            }
        )
        resp.raise_for_status()
        return resp.json()["content"][0]["text"]

async def _call_openai(model: str, prompt: str, temperature: float) -> str:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        return "[OPENAI_API_KEY not set]"
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(
            "https://api.openai.com/v1/chat/completions",
            headers={"Authorization": f"Bearer {api_key}"},
            json={
                "model": model,
                "messages": [{"role": "user", "content": prompt}],
                "temperature": temperature
            }
        )
        resp.raise_for_status()
        return resp.json()["choices"][0]["message"]["content"]

async def _call_google(model: str, prompt: str, temperature: float) -> str:
    api_key = os.getenv("GOOGLE_API_KEY")
    if not api_key:
        return "[GOOGLE_API_KEY not set]"
    # Gemini uses a different endpoint structure
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(
            url,
            json={"contents": [{"parts": [{"text": prompt}]}]}
        )
        resp.raise_for_status()
        return resp.json()["candidates"][0]["content"]["parts"][0]["text"]
```

### `app/task_decomposer.py` – Break goals into subtasks

```python
import json
from model_routing import call_llm

async def decompose_goal(goal: str) -> list:
    """Use a reasoning model to break the goal into a list of subtasks."""
    prompt = f"""You are an AI orchestrator. Break the following user goal into a list of subtasks that can be executed in parallel or sequentially.
Return a JSON array of objects, each with:
- "id": integer
- "type": one of ["reasoning", "research", "code", "speed", "long_ctx", "images"]
- "description": a clear description of what the subtask should do
- "depends_on": list of ids this subtask depends on (optional)
- "parallel": boolean indicating if it can run in parallel with others

Goal: {goal}

Return ONLY the JSON array, no other text.
"""
    response = await call_llm("claude-3-5-sonnet-20241022", prompt, temperature=0.2)
    try:
        # Extract JSON from response (in case model adds markdown)
        import re
        json_str = re.search(r'\[.*\]', response, re.DOTALL).group()
        subtasks = json.loads(json_str)
        return subtasks
    except Exception as e:
        # Fallback: return a single generic subtask
        return [{"id": 1, "type": "reasoning", "description": goal, "depends_on": [], "parallel": False}]
```

### `app/safety.py` – Mandatory approval mechanism

```python
import asyncio
import uuid
from typing import Dict, Any

# In-memory store for pending approvals
pending_approvals: Dict[str, dict] = {}

async def confirm_action(action: str, details: dict) -> bool:
    """
    Blocks until user approves or rejects the action via the web API.
    Returns True if approved, False if rejected.
    """
    approval_id = str(uuid.uuid4())
    event = asyncio.Event()
    pending_approvals[approval_id] = {
        "id": approval_id,
        "action": action,
        "details": details,
        "event": event,
        "decision": None
    }
    # In a real system, we would also notify the user via WebSocket or polling.
    # Here we wait for the decision to be set by the API endpoint.
    await event.wait()
    decision = pending_approvals[approval_id]["decision"]
    del pending_approvals[approval_id]
    return decision
```

### `app/connectors.py` – External service integrations (stub)

```python
import os
import httpx
from typing import Any

# This module should handle OAuth flows and secure token storage.
# For simplicity, we assume tokens are stored in environment variables
# or a secure vault. In a real implementation, you'd have per-service
# classes that manage credentials and API calls.

async def execute_connector_action(service: str, action: str, params: dict) -> Any:
    """
    Execute an action on an external service.
    Credentials are never passed to the sandbox; they are used here.
    """
    if service == "gmail" and action == "send_email":
        return await _gmail_send(params)
    elif service == "github" and action == "create_repo":
        return await _github_create_repo(params)
    else:
        return {"error": f"Unknown service/action: {service}/{action}"}

async def _gmail_send(params: dict):
    # Use Gmail API with OAuth2 token stored securely
    token = os.getenv("GMAIL_TOKEN")  # Not secure; use proper storage
    if not token:
        return {"error": "GMAIL_TOKEN not set"}
    # Implement actual Gmail send
    return {"status": "email sent (stub)"}

async def _github_create_repo(params: dict):
    token = os.getenv("GITHUB_TOKEN")
    if not token:
        return {"error": "GITHUB_TOKEN not set"}
    async with httpx.AsyncClient() as client:
        resp = await client.post(
            "https://api.github.com/user/repos",
            headers={"Authorization": f"token {token}"},
            json={"name": params.get("name"), "private": params.get("private", False)}
        )
        resp.raise_for_status()
        return resp.json()
```

### `app/templates/index.html` – Minimal web UI

```html
<!DOCTYPE html>
<html>
<head>
    <title>Perplexity Computer (Personal Clone)</title>
    <style>
        body { font-family: sans-serif; max-width: 800px; margin: 2rem auto; padding: 1rem; }
        textarea { width: 100%; height: 100px; margin-bottom: 1rem; }
        button { padding: 0.5rem 1rem; }
        #output { white-space: pre-wrap; background: #f4f4f4; padding: 1rem; margin-top: 1rem; }
    </style>
</head>
<body>
    <h1>Personal Perplexity Computer</h1>
    <textarea id="goal" placeholder="Enter your goal..."></textarea>
    <button onclick="submitGoal()">Run</button>
    <div id="output"></div>

    <h2>Pending Approvals</h2>
    <div id="approvals"></div>

    <script>
        async function submitGoal() {
            const goal = document.getElementById('goal').value;
            const res = await fetch('/api/run', { method: 'POST', body: new URLSearchParams({ goal }) });
            const data = await res.json();
            document.getElementById('output').innerText = JSON.stringify(data, null, 2);
            pollTask(data.task_id);
        }

        async function pollTask(taskId) {
            const interval = setInterval(async () => {
                const res = await fetch(`/api/tasks/${taskId}`);
                const task = await res.json();
                document.getElementById('output').innerText = JSON.stringify(task, null, 2);
                if (task.status === 'completed' || task.status === 'failed') {
                    clearInterval(interval);
                }
            }, 2000);
        }

        async function loadApprovals() {
            const res = await fetch('/api/approvals');
            const data = await res.json();
            const div = document.getElementById('approvals');
            div.innerHTML = data.pending.map(a => `
                <div>
                    <strong>${a.action}</strong> - ${JSON.stringify(a.details)}
                    <button onclick="decide('${a.id}', true)">Approve</button>
                    <button onclick="decide('${a.id}', false)">Reject</button>
                </div>
            `).join('');
        }

        async function decide(id, decision) {
            await fetch(`/api/approvals/${id}?decision=${decision}`, { method: 'POST' });
            loadApprovals();
        }

        setInterval(loadApprovals, 5000);
        loadApprovals();
    </script>
</body>
</html>
```

---

## Building and Running

1. Place all files in the structure above.
2. Build the image:
   ```bash
   docker build -t perplexity-clone .
   ```
3. Run with API keys and port mappings:
   ```bash
   docker run -d \
     --name my-pc \
     -p 7860:7860 \
     -p 7681:7681 \
     -e ANTHROPIC_API_KEY=your_key \
     -e OPENAI_API_KEY=your_key \
     -e GOOGLE_API_KEY=your_key \
     -e GITHUB_TOKEN=your_token \
     perplexity-clone
   ```
4. Access:
   - Web UI: http://localhost:7860
   - Terminal: http://localhost:7681

---

## What This Clone Achieves

- **Single container** – all processes (web server, ttyd, cron) run inside one container, launched by the entrypoint script.
- **Orchestration** – FastAPI app with task decomposition, model routing, and sub‑agent simulation.
- **Safety** – `confirm_action` blocks sensitive actions until you approve via the web UI.
- **Extensible** – Add more connectors, improve sub‑agent isolation (using sub‑processes within the container), and refine the model routing table.
- **No multi‑stage** – everything in one stage, satisfying your cloud provider’s constraints.

This gives you a solid foundation to iterate on and expand into a fully functional personal AI computer.

# https://chat.deepseek.com/share/v82jqmsf3v9ll6jk44
