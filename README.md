# Personal Computer - AI Agent Orchestration System

> A Perplexity Computer-inspired multi-model AI agent system that runs entirely in a single Docker container.

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Quick Start](#quick-start)
4. [Configuration](#configuration)
5. [Components](#components)
6. [API Reference](#api-reference)
7. [Tools Reference](#tools-reference)
8. [Safety Features](#safety-features)
9. [Comparison with Perplexity Computer](#comparison-with-perplexity-computer)
10. [Troubleshooting](#troubleshooting)

---

## Overview

**Personal Computer** is a self-hosted AI agent orchestration system inspired by Perplexity Computer. It provides:

- **Multi-model orchestration** - Route tasks to the best AI model for each job
- **Autonomous task execution** - Break down goals into executable subtasks
- **Web automation** - Browser-based research and interaction via Playwright
- **Code execution** - Run Python and shell commands safely
- **Safety mechanisms** - Confirm dangerous actions before execution
- **Audit logging** - Complete trail of all agent actions
- **Web UI** - Clean interface for interaction and monitoring

### Key Features

| Feature | Description |
|---------|-------------|
| **Task Decomposition** | Break complex goals into executable subtasks |
| **Model Routing** | Automatically select the best model for each task type |
| **Filesystem IPC** | Sub-agents communicate via files (like Perplexity) |
| **confirm_action** | Mandatory approval for sensitive operations |
| **Audit Trail** | Log every action for compliance and debugging |
| **Web Terminal** | Full bash access via ttyd |

---

## Architecture

### Single-Container Design

Unlike Perplexity Computer's four-layer architecture, this implementation runs all components in a single Docker container:

```
┌─────────────────────────────────────────────────────────────────┐
│                    DOCKER CONTAINER                              │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐  │
│  │  FastAPI     │  │   ttyd       │  │   Orchestrator       │  │
│  │  Web UI      │  │   Terminal   │  │   (Python)           │  │
│  │  :7860       │  │   :7681      │  │                      │  │
│  └──────────────┘  └──────────────┘  └──────────────────────┘  │
│         │                 │                    │                │
│         └─────────────────┴────────────────────┘                │
│                           │                                      │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                     WORKSPACE                              │  │
│  │  /workspace                                               │  │
│  │  ├── ipc/           # Inter-agent communication           │  │
│  │  ├── artifacts/     # Output files                        │  │
│  │  ├── logs/          # Application logs                    │  │
│  │  ├── memory/        # Persistent memory                   │  │
│  │  ├── sessions/      # Session data                        │  │
│  │  └── skills/        # Custom skills/playbooks             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    TOOLS LAYER                             │  │
│  │  • Filesystem (read, write, delete, list)                 │  │
│  │  • Web (fetch, scrape)                                     │  │
│  │  • Browser (navigate, screenshot)                          │  │
│  │  • Code (execute_python, execute_shell)                    │  │
│  │  • IPC (send, receive)                                     │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
personal-computer/
├── Dockerfile              # Single-stage Docker build
├── scripts/
│   ├── docker-entrypoint.sh   # Container entrypoint
│   └── pc-cli.py              # CLI utility
├── app/
│   ├── config.py           # Configuration management
│   ├── orchestrator.py     # Main orchestration engine
│   ├── tools.py            # Tool implementations
│   ├── safety.py           # Safety mechanisms
│   └── server.py           # FastAPI web server
└── workspace/              # Persistent workspace (mounted volume)
    ├── ipc/                # Inter-agent communication
    ├── artifacts/          # Generated outputs
    ├── logs/               # Application logs
    ├── memory/             # Persistent memory
    ├── sessions/           # Session data
    └── skills/             # Custom skills
```

---

## Quick Start

### Prerequisites

- Docker installed on your system
- At least one AI API key (Anthropic, OpenAI, Google, or xAI)

### Build and Run

```bash
# 1. Clone or create the project directory
mkdir -p personal-computer && cd personal-computer

# 2. Create .env file with your API keys
cat > workspace/.env << EOF
ANTHROPIC_API_KEY=your-key-here
OPENAI_API_KEY=your-key-here
GOOGLE_API_KEY=your-key-here
EOF

# 3. Build the Docker image
docker build -t personal-computer .

# 4. Run the container
docker run -d \
    --name pc \
    -p 7860:7860 \
    -p 7681:7681 \
    -v $(pwd)/workspace:/workspace \
    -e ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY} \
    -e OPENAI_API_KEY=${OPENAI_API_KEY} \
    personal-computer

# 5. Access the web UI
open http://localhost:7860

# 6. Access the terminal
open http://localhost:7681
```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `ANTHROPIC_API_KEY` | Claude API key | Recommended |
| `OPENAI_API_KEY` | OpenAI API key | Optional |
| `GOOGLE_API_KEY` | Google Gemini API key | Optional |
| `XAI_API_KEY` | xAI Grok API key | Optional |
| `APP_PORT` | Web UI port (default: 7860) | Optional |
| `TTYD_PORT` | Terminal port (default: 7681) | Optional |

---

## Configuration

### Configuration File (config.py)

The system uses Pydantic Settings for configuration management. You can override any setting via environment variables or a `.env` file in the workspace directory.

```python
# Example .env file
ANTHROPIC_API_KEY=sk-ant-...
OPENAI_API_KEY=sk-...
GOOGLE_API_KEY=AI...

# Model routing
DEFAULT_MODEL=claude-sonnet-4-20250514
REASONING_MODEL=claude-sonnet-4-20250514
RESEARCH_MODEL=gemini-2.5-pro
CODE_MODEL=claude-sonnet-4-20250514
SPEED_MODEL=gpt-4.1-mini
LONG_CONTEXT_MODEL=gemini-2.5-pro

# Server
PORT=7860
DEBUG=false
```

### Model Routing Configuration

```python
MODEL_ROUTING = {
    "reasoning": {
        "model": "claude-sonnet-4-20250514",
        "provider": "anthropic",
        "max_tokens": 8192,
        "temperature": 0.5
    },
    "research": {
        "model": "gemini-2.5-pro",
        "provider": "google",
        "max_tokens": 8192,
        "temperature": 0.3
    },
    "code": {
        "model": "claude-sonnet-4-20250514",
        "provider": "anthropic",
        "max_tokens": 8192,
        "temperature": 0.3
    },
    "speed": {
        "model": "gpt-4.1-mini",
        "provider": "openai",
        "max_tokens": 2048,
        "temperature": 0.7
    },
    "long_context": {
        "model": "gemini-2.5-pro",
        "provider": "google",
        "max_tokens": 32768,
        "temperature": 0.5
    }
}
```

---

## Components

### 1. Orchestrator (orchestrator.py)

The orchestrator is the "brain" of the system, responsible for:
- Task decomposition
- Model routing
- Sub-agent coordination
- Workflow execution

```python
from orchestrator import Orchestrator

orchestrator = Orchestrator()

# Execute a goal
result = await orchestrator.run_workflow(
    goal="Research AI trends in 2026 and create a summary report",
    context="Focus on enterprise applications",
    provider="anthropic"
)
```

### 2. Tools (tools.py)

Comprehensive tool implementations for agent actions:

| Tool | Description |
|------|-------------|
| `fs_read` | Read file contents |
| `fs_write` | Write content to file |
| `fs_delete` | Delete file or directory |
| `fs_list` | List directory contents |
| `fs_mkdir` | Create directory |
| `web_fetch` | HTTP request to URL |
| `web_scrape` | Scrape and convert to markdown |
| `execute_python` | Run Python code |
| `execute_shell` | Run shell command |
| `browser_navigate` | Navigate to URL |
| `browser_screenshot` | Take webpage screenshot |
| `ipc_send` | Send message to IPC channel |
| `ipc_receive` | Receive messages from channel |

### 3. Safety (safety.py)

Safety mechanisms including:
- **confirm_action**: Require user approval for sensitive operations
- **AuditLog**: Comprehensive action logging
- **Credential Isolation**: Never expose API keys in sandbox

```python
from safety import confirm_action, ActionType

# Request confirmation before sending email
if confirm_action(
    ActionType.SEND_EMAIL,
    "Send email to john@example.com",
    {"to": "john@example.com", "subject": "Hello"}
):
    send_email(...)
```

### 4. Server (server.py)

FastAPI-based web server providing:
- REST API for programmatic access
- Web UI for interactive use
- WebSocket for real-time updates
- File upload/download

---

## API Reference

### Execute Goal

```http
POST /api/execute
Content-Type: application/json

{
    "goal": "Research competitor pricing strategies",
    "context": "Focus on SaaS companies",
    "provider": "anthropic"
}
```

Response:
```json
{
    "session_id": "abc12345",
    "goal": "Research competitor pricing strategies",
    "status": "completed",
    "results": [
        {
            "task": "Identify top competitors",
            "result": "..."
        }
    ],
    "tasks": {...}
}
```

### Execute Tool

```http
POST /api/tool
Content-Type: application/json

{
    "name": "fs_read",
    "parameters": {
        "path": "report.md"
    }
}
```

### Get Pending Confirmations

```http
GET /api/confirmations
```

Response:
```json
[
    {
        "id": "conf_123",
        "action_type": "send_email",
        "description": "Send email to john@example.com",
        "risk_level": "high",
        "status": "pending"
    }
]
```

### Approve/Reject Confirmation

```http
POST /api/confirmations/{id}/approve
POST /api/confirmations/{id}/reject
```

### WebSocket

```javascript
const ws = new WebSocket('ws://localhost:7860/ws');

// Send goal
ws.send(JSON.stringify({
    type: 'execute',
    goal: 'Research AI trends'
}));

// Receive result
ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log(data);
};
```

---

## Tools Reference

### Filesystem Tools

#### fs_read
Read file contents from the workspace.

```python
execute_tool("fs_read", path="example.txt")
```

#### fs_write
Write content to a file in the workspace.

```python
execute_tool("fs_write", path="output.md", content="# Hello\n\nWorld!")
```

#### fs_delete
Delete a file or directory (requires confirmation).

```python
execute_tool("fs_delete", path="old_file.txt")
```

#### fs_list
List directory contents.

```python
execute_tool("fs_list", path=".")
```

### Web Tools

#### web_fetch
Make HTTP request to a URL.

```python
execute_tool("web_fetch", url="https://api.example.com/data", method="GET")
```

#### web_scrape
Scrape webpage and convert to markdown.

```python
execute_tool("web_scrape", url="https://example.com/article", selector="article")
```

### Browser Tools

#### browser_navigate
Navigate to URL with headless browser.

```python
execute_tool("browser_navigate", url="https://example.com")
```

#### browser_screenshot
Take screenshot of webpage.

```python
execute_tool("browser_screenshot", url="https://example.com")
```

### Execution Tools

#### execute_python
Run Python code in sandboxed environment.

```python
execute_tool("execute_python", code="""
import pandas as pd
df = pd.DataFrame({'a': [1, 2, 3]})
print(df.describe())
""")
```

#### execute_shell
Execute shell command (requires confirmation).

```python
execute_tool("execute_shell", command="ls -la")
```

---

## Safety Features

### confirm_action Pattern

This is the key safety mechanism from Perplexity Computer. Before any sensitive operation, the agent must request explicit user approval.

```python
from safety import confirm_action, ActionType

# These action types ALWAYS require confirmation
HIGH_RISK_ACTIONS = {
    ActionType.SEND_EMAIL,
    ActionType.PAYMENT,
    ActionType.PURCHASE,
    ActionType.DELETE_DATA,
    ActionType.PUSH_CODE,
}

# Usage
if confirm_action(
    ActionType.DELETE_FILE,
    "Delete directory 'old_project'",
    {"path": "/workspace/old_project"}
):
    # Proceed with deletion
    delete_directory(...)
else:
    # User rejected
    print("Operation cancelled")
```

### Audit Logging

Every action is logged for compliance and debugging:

```python
from safety import audit_log

# Query recent actions
logs = audit_log.query(action="fs_write", limit=10)

for entry in logs:
    print(f"{entry['timestamp']}: {entry['action']}")
    print(f"  Details: {entry['details']}")
```

### Credential Isolation

API keys are never exposed to the sandbox environment:
- Keys are stored in environment variables on the host
- Tools that need external access use the orchestrator as a proxy
- The sandbox never sees raw credentials

---

## Comparison with Perplexity Computer

| Feature | Perplexity Computer | Personal Computer |
|---------|--------------------|--------------------|
| **Architecture** | 4-layer (Local, Orchestrator, Sandbox, Browser) | Single-container |
| **Isolation** | Firecracker microVMs | Docker container |
| **Models** | 19+ models, automatic routing | 3-5 models via API keys |
| **Connectors** | 400+ OAuth integrations | Build as needed |
| **Safety** | confirm_action, audit logs, VM isolation | confirm_action, audit logs |
| **IPC** | Filesystem-based | Filesystem-based (same pattern) |
| **Pricing** | $200/month | API costs only |
| **Customization** | Limited | Full control |

### What You Get

✅ **Execution Sandbox** - Same tool set (Python, Node.js, Playwright, ffmpeg)
✅ **Task Decomposition** - Break goals into subtasks
✅ **Model Routing** - Select best model for each task
✅ **Safety Mechanisms** - confirm_action pattern
✅ **Audit Trail** - Complete action logging
✅ **Filesystem IPC** - Same communication pattern

### What's Different

⚠️ **Isolation Level** - Docker containers share kernel (less isolated than Firecracker)
⚠️ **Model Selection** - Fewer models, manual configuration
⚠️ **Connectors** - Build your own integrations
⚠️ **Scale** - Designed for single-user, not enterprise

---

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker logs personal-computer

# Common issues:
# 1. Port already in use
docker run -p 7861:7860 -p 7682:7681 personal-computer

# 2. Missing API keys
docker run -e ANTHROPIC_API_KEY=sk-... personal-computer
```

### Playwright Browser Issues

```bash
# Install browsers manually
docker exec -it personal-computer bash
npx playwright install chromium --with-deps
```

### Permission Issues

```bash
# Fix workspace permissions
docker exec -it personal-computer bash
sudo chown -R user:user /workspace
```

### Memory Issues

```bash
# Increase container memory
docker run --memory=4g personal-computer
```

### Reset Everything

```bash
# Stop and remove container
docker stop personal-computer
docker rm personal-computer

# Clean workspace
rm -rf workspace/ipc/* workspace/logs/* workspace/sessions/*

# Rebuild
docker build -t personal-computer .
```

---

## License

MIT License - Use freely for personal and commercial projects.

---

## Acknowledgments

Inspired by Perplexity Computer and the vision of autonomous AI agents that can execute complex workflows. This implementation makes that vision accessible for personal use without the $200/month price tag.

Key architectural decisions were informed by:
- Perplexity's official blog posts and documentation
- Reverse-engineering analyses by security researchers
- Open-source alternatives like Agent Zero, OpenSandbox, and OpenClaw

# https://chat.z.ai/s/d1097f85-6240-48b7-94d2-492e4adb8a97
