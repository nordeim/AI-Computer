Please meticulously research with extensive web searches, on the WHAT, WHY and HOW of Perplexity Computer. Research to have a good understanding on how Perplexity might create and make their "computer" work. Then meticulously think and plan how we can re-create similar computer for my personal use. Will a Docker container running Ubuntu 24.04 or Debian Trixie with bash shell and the usual filesystem utilities, curl, playwright, and python and node.js packages be sufficient to form the basis of our "clone" equivalent of Perplexity computer?

Below are some references for your research and consideration:

1. https://www.perplexity.ai/hub/blog/introducing-perplexity-computer 
2. https://www.theverge.com/ai-artificial-intelligence/893536/perplexitys-personal-computer-turns-your-spare-mac-into-an-ai-agent 
3. https://www.builder.io/blog/perplexity-computer

---

Based on the provided references and supporting search results, here is a detailed analysis of Perplexity Computer and a practical plan for recreating its core functionality for your personal use.

### **What, Why, and How of Perplexity Computer**

#### **What It Is**
Perplexity Computer is not a physical device but a **cloud-based, multi-model AI agent platform** launched on February 25, 2026 . It functions as a "general-purpose digital worker" that can autonomously execute complex, end-to-end workflows that may run for hours or months . It orchestrates up to 19 different AI models simultaneously, routing specific subtasks to the model best suited for them (e.g., Opus 4.6 for reasoning, Gemini for deep research, GPT-5.2 for long-context recall) . The system operates within an **isolated cloud sandbox** (with specs like 2 vCPU, 8GB RAM) that includes a real filesystem, browser access, and pre-installed tools like Python, Node.js, and ffmpeg . It features **persistent memory** across sessions and hundreds of pre-built OAuth connectors for services like Gmail, GitHub, and Slack .

A related but distinct offering is **Perplexity Personal Computer**, which runs a control plane on a local device (like a Mac Mini) while the core compute remains in Perplexity's secure cloud, offering a hybrid local-control/cloud-execution model .

#### **Why It Was Created**
1.  **To Unify Specialized Models**: The core insight is that AI models are specializing, not commoditizing. Perplexity Computer was built to harness the best capability for each task within a single, cohesive workflow, overcoming the limitations of any single model .
2.  **To Move from Answers to Outcomes**: It represents an evolution from chat interfaces (which provide answers) and simple agents (which do isolated tasks) to a system that manages entire, multi-step projects autonomously .
3.  **To Provide Consistency and Safety**: By running in a managed cloud sandbox, it eliminates the "works on my machine" problem and offers a more secure, controlled environment compared to locally-run agents like OpenClaw, with features like scoped credentials and the ability to review/approve sensitive actions .

#### **How It Works: A Technical Breakdown**
1.  **User Input**: You describe a desired outcome in natural language .
2.  **Orchestration & Decomposition**: The platform's core reasoning engine (currently Opus 4.6) analyzes the goal and breaks it down into a directed acyclic graph of tasks and subtasks .
3.  **Dynamic Sub-Agent Creation**: It spawns multiple, parallel sub-agents, each operating in its own isolated environment. The system dynamically assigns the most appropriate AI model to each sub-agent based on the task (e.g., a coding sub-agent might use a Claude model, while a research sub-agent uses Gemini) .
4.  **Tool Execution & Integration**: These sub-agents perform their tasks using the sandboxed environment. They can execute code (Python/Node.js), perform web research via a real browser instance, read/write to the filesystem, or interact with external services through 400+ managed OAuth connectors .
5.  **Synthesis & Delivery**: The sub-agents report back, and the orchestrator synthesizes their work into a final result, which is then delivered to the user. The system maintains context across long-running projects through persistent memory .

### **Recreating a Similar "Computer" for Personal Use**

Your idea of using a Docker container is an excellent foundation. Here is a practical plan to build a personal clone, acknowledging what you can replicate easily and where the significant complexity lies.

#### **The Core Architecture**

A self-hosted equivalent would have two main layers:
1.  **The Sandbox (Execution Layer)**: The environment where tasks are performed. This is what your Docker container will be.
2.  **The Orchestrator (Control Layer)**: The "brain" that plans tasks, chooses models, and manages sub-agents. This is the most complex part to build from scratch.

#### **Phase 1: Building the Sandbox (Your Docker Approach is Perfect)**

Your proposed stack is a fantastic starting point and directly mirrors the sandbox environment of Perplexity Computer.

*   **Base Image**: A Docker container running **Ubuntu 24.04 or Debian Trixie** is ideal. Debian Trixie (13) is a perfectly viable choice, and scripts exist to help set up Docker on it .
*   **Core Utilities**: `bash`, `curl`, `wget`, `git`, `ffmpeg`, and standard Unix filesystem tools are essential, just like in the official version .
*   **Language Runtimes**: Installing **Python** (with package managers like `pip`) and **Node.js** (with `npm`) gives your agent the ability to run virtually any script or tool, mirroring the flexibility of the Perplexity Computer sandbox .
*   **Browser Automation**: Including **Playwright** (or Puppeteer) is critical. It allows your agent to perform "real" web research and interact with websites just as a human would, which is a core capability of Perplexity Computer .

**Example `Dockerfile` snippet:**
```dockerfile
FROM debian:trixie-slim

# Install system dependencies, including Python, Node.js, and browser tools
RUN apt-get update && apt-get install -y \
    curl wget git ffmpeg \
    python3 python3-pip \
    nodejs npm \
    # ... and dependencies for Playwright ...
    && apt-get clean

# Install Playwright and its browsers
RUN pip install playwright && playwright install
```

#### **Phase 2: Building the Orchestrator (The Real Challenge)**

This is where a simple Docker container falls short and where you'll need to build or integrate significant logic. Your Docker sandbox is the *worker*, but you need a *foreman*.

*   **The Orchestrator Script (Your "Reasoning Engine")**:
    *   **WHAT**: A central Python or Node.js application that runs on your host machine (or in a separate "controller" container).
    *   **HOW**: This script would:
        1.  Accept your high-level goal.
        2.  Use a powerful LLM (like Claude or GPT-4) to decompose the goal into a step-by-step plan.
        3.  For each step, it would decide which tool to use and which specific model (if you have multiple API keys) would be best suited.
        4.  It would then spin up your Docker sandbox container (or a new one for each sub-task), pass it the specific instructions, and monitor its execution.

*   **Multi-Model Routing**:
    *   **WHAT**: The ability to use different AI models for different sub-tasks.
    *   **HOW**: You would need API keys for various services (OpenAI, Anthropic, Google, Groq, etc.). Your orchestrator script would contain logic to decide, for example: *"This is a coding task, so I'll use the Anthropic API. This is a quick search, so I'll use the Perplexity API ."*

*   **The Connector Framework**:
    *   **WHAT**: Pre-built ways to interact with services like Gmail, GitHub, etc.
    *   **HOW**: This is the biggest development task. For each service you want to automate, you would need to:
        1.  Implement the OAuth flow to get and securely store access tokens.
        2.  Write functions that use the service's API to perform actions (send email, create a repo, etc.). Your orchestrator would call these functions, and they could be executed either in the orchestrator or passed as instructions to the sandbox.

#### **Phase 3: Addressing the "Personal Computer" Aspect**

If you want the always-on, local-control aspect of Perplexity's Personal Computer :
1.  **Hardware**: A low-power, always-on device like a **Raspberry Pi 5** or an old **Mac Mini** is perfect.
2.  **Software**: Install Docker on this device. Your orchestrator script would run here, managing the sandbox containers. You could then build a simple web dashboard or expose an API to send tasks to it from your other devices.

### **Will Your Proposed Stack Be Sufficient?**

**Yes, your proposed Docker container is a sufficient and excellent foundation for the *execution environment* (the "sandbox") of your personal AI computer.**

However, it is only one piece of the puzzle. To build a complete system, you will need to invest significant effort in building the **orchestration logic**, **model routing**, and **connector ecosystem** that sits outside that container.

| Feature | Perplexity Computer | Your DIY Clone |
| :--- | :--- | :--- |
| **Execution Sandbox** | Managed cloud Linux env (2 vCPU, 8GB) with Python, Node.js, ffmpeg, etc.  | **✅ Docker container (Ubuntu/Debian)** with Python, Node.js, Playwright, etc. |
| **Orchestration** | Proprietary system using Opus 4.6 to decompose tasks and spawn sub-agents  | **❌ You build it.** A Python/Node.js script using an LLM (via API) for task planning. |
| **Multi-Model Access** | Dynamically routes subtasks to 19+ models (Gemini, Grok, GPT-5.2, etc.)  | **🟡 You build it.** Requires multiple API keys and logic to choose between them. |
| **Tool Integrations** | 400+ managed OAuth connectors (Gmail, GitHub, Slack)  | **❌ You build it.** Implement OAuth flows and API calls for each service you need. |
| **Persistence** | Cross-session memory and project state  | **🟡 You build it.** Store conversation summaries and project state in a database. |
| **User Interface** | Web interface on perplexity.ai | **🟡 You build it.** A simple web UI, an API, or a command-line interface. |

**Recommendation:**
Start by building your Docker sandbox. Then, instead of building everything from scratch, look into open-source orchestrator projects like **OpenClaw**  or **Farfalle** . These projects have already solved parts of the orchestration, tool-use, and memory problem. You could potentially configure them to use your Docker container as the secure, disposable execution environment for code and browser actions, giving you a powerful and more manageable DIY system.

---

Now I have comprehensive research on Perplexity Computer. Let me compile this into a detailed analysis and implementation plan for you.

---

# 🔍 PERPLEXITY COMPUTER: COMPREHENSIVE RESEARCH ANALYSIS

## PART 1: WHAT IS PERPLEXITY COMPUTER?

### Core Definition
Perplexity Computer is a **cloud-based multi-model AI agent system** that orchestrates 19+ different frontier AI models to execute complex, autonomous workflows [[1]]. It's positioned as a "general-purpose digital worker" that creates and executes entire workflows, capable of running for hours or even months [[2]]. Unlike traditional chatbots that provide answers, Computer executes tasks and delivers finished artifacts [[58]].

### Key Specifications

| Component | Specification |
|-----------|---------------|
| **Launch Date** | February 25, 2026 [[2]] |
| **Pricing** | $200/month (Perplexity Max tier) [[1]], [[9]] |
| **Models Orchestrated** | 19+ frontier AI models [[1]], [[10]] |
| **Sandbox Environment** | Isolated Linux (2 vCPU, 8GB RAM) [[1]] |
| **Integrations** | 400+ managed OAuth connectors [[1]] |
| **Platform** | Web desktop only (no mobile/offline) [[67]] |
| **Skill Playbooks** | 50+ domain-specific templates [[1]] |

### Pre-installed Sandbox Tools
The cloud sandbox includes [[1]], [[43]]:
- Python & Node.js runtime environments
- ffmpeg for media processing
- Standard Unix utilities (bash, curl, etc.)
- Real filesystem access
- Real browser automation capabilities
- API call capabilities to connected services

---

## PART 2: WHY WAS PERPLEXITY COMPUTER CREATED?

### Strategic Rationale

**1. Models Are Specializing, Not Commoditizing** [[9]], [[55]]
Perplexity's research shows users naturally switch between models for different tasks:
- Visual outputs → Gemini Flash
- Software engineering → Claude Sonnet 4.5
- Medical research → GPT-5.1

Their bet: "Multi-model is the future" because no single model excels at everything [[9]].

**2. Shift from Chat to Action** [[2]], [[50]]
Traditional AI assistants answer questions. Computer executes tasks:
- "Chat interfaces have answers, while agents can do tasks" [[2]]
- Moves from advice/assistance roles to operational ones [[62]]

**3. Enterprise Focus** [[9]], [[13]]
CEO Aravind Srinivas described targeting users making "GDP-moving decisions" [[9]]. The system is designed for:
- Competitive intelligence workflows
- Due diligence across multiple sources
- Strategic analysis synthesizing hundreds of sources
- Audit trails and compliance requirements [[13]]

**4. Safer Alternative to OpenClaw** [[62]], [[63]]
Perplexity positions Computer as more secure than open-source alternatives:
- Cloud isolation vs. local system access
- Full audit trail of all actions [[3]]
- Kill switch for rogue behavior [[3]]
- Ability to approve/reverse sensitive actions [[3]]

---

## PART 3: HOW DOES PERPLEXITY COMPUTER WORK?

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER NATURAL LANGUAGE PROMPT                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│              ORCHESTRATION LAYER (Claude Opus 4.6)              │
│  • Task decomposition into subtasks                             │
│  • Model routing decisions                                      │
│  • State management across workflow                             │
│  • Sub-agent creation & coordination                            │
└─────────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌───────────────┐   ┌───────────────┐
│  SUB-AGENT 1  │   │  SUB-AGENT 2  │   │  SUB-AGENT N  │
│  (Research)   │   │  (Code)       │   │  (Design)     │
│  Gemini       │   │  Opus 4.6     │   │  Nano Banana  │
└───────────────┘   └───────────────┘   └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    TOOL EXECUTION LAYER                         │
│  • Web browsing (Playwright-based)                              │
│  • File system operations                                       │
│  • API calls (400+ connectors)                                  │
│  • Code execution (Python/Node.js)                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    ASSEMBLY & DELIVERY                          │
│  • Output synthesis from all sub-agents                         │
│  • Quality assurance cross-reference                            │
│  • Final artifact delivery                                      │
└─────────────────────────────────────────────────────────────────┘
```

### Model Routing Framework [[1]], [[10]], [[55]]

| Model | Primary Function | Use Case |
|-------|-----------------|----------|
| **Claude Opus 4.6** | Core reasoning engine | Orchestration decisions, complex problem-solving |
| **Gemini** | Deep research | Multi-source investigations, sub-agent creation |
| **GPT-5.2** | Long-context recall | Wide search, maintaining state across large documents |
| **Grok** | Lightweight tasks | Speed-sensitive operations, quick lookups |
| **Nano Banana** | Image generation | Visual content creation |
| **Veo 3.1** | Video production | Video content generation |

### Sub-Agent Architecture [[1]], [[49]]

When Computer receives a task, it:
1. **Decomposes** the outcome into discrete subtasks
2. **Creates specialized sub-agents** for each part
3. **Executes in parallel** where possible
4. **Coordinates automatically** without user intervention
5. **Spawns additional sub-agents** when encountering problems [[2]]

Example workflow for "research competitors and create presentation" [[49]]:
- Sub-agent 1: Web research (Gemini)
- Sub-agent 2: Slide drafting (Opus 4.6)
- Sub-agent 3: Output formatting (GPT-5.2)
- Sub-agent 4: Team delivery (via Slack connector)

### Security & Isolation [[13]], [[41]], [[45]]

- **Firecracker VM isolation** for each task session [[13]]
- **SOC 2 Type II compliance** for enterprise deployments [[13]]
- **Zero data retention options** available [[13]]
- **Audit logging** for all agent actions [[13]]
- **Scoped API tokens** per workflow session (not persisted broadly) [[58]]
- **Human-in-the-loop checkpoints** for sensitive actions [[58]]

---

## PART 4: CAN YOU RECREATE THIS FOR PERSONAL USE?

### Short Answer: **Partially, Yes**

A Docker container with Ubuntu 24.04 or Debian Trixie **can form the foundation**, but it's only **one component** of a much larger system. Here's what you'd need:

### ✅ What Your Docker Setup CAN Provide

| Component | Docker Implementation | Perplexity Equivalent |
|-----------|----------------------|----------------------|
| **OS Environment** | Ubuntu 24.04/Debian Trixie | Isolated Linux sandbox [[1]] |
| **Shell Access** | Bash shell | Standard Unix tools [[1]] |
| **Filesystem** | Container volumes | Real filesystem access [[41]] |
| **Web Automation** | Playwright | Real browser [[41]] |
| **HTTP Client** | curl, Python requests | API calls [[58]] |
| **Code Execution** | Python, Node.js | Python, Node.js, npm [[1]], [[43]] |
| **Media Processing** | ffmpeg | ffmpeg [[1]] |

### ❌ What Your Docker Setup CANNOT Provide (Without Additional Work)

| Component | Challenge | Solution Required |
|-----------|-----------|-------------------|
| **Multi-Model Orchestration** | Need 19+ API integrations | Build routing layer with multiple LLM APIs |
| **Sub-Agent System** | Complex coordination logic | Implement agent spawning & state management |
| **400+ OAuth Connectors** | Massive integration effort | Use MCP servers or existing frameworks |
| **Persistent Memory** | Cross-session state | Database + vector store implementation |
| **Security Isolation** | Container ≠ VM isolation | Firecracker microVMs or gVisor |
| **Model Selection Logic** | Intelligent routing | Build evaluation framework per task type |
| **Quality Assurance** | Self-verification | Implement cross-reference checking |
| **Audit Logging** | Action tracking | Comprehensive logging infrastructure |

---

## PART 5: IMPLEMENTATION PLAN FOR PERSONAL "COMPUTER" CLONE

### Phase 1: Foundation (Docker Base)

```dockerfile
FROM ubuntu:24.04

# Install core utilities
RUN apt-get update && apt-get install -y \
    python3 python3-pip \
    nodejs npm \
    curl wget git \
    ffmpeg \
    playwright-dependencies \
    && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install \
    playwright \
    requests \
    aiohttp \
    beautifulsoup4 \
    markdownify

# Install Node.js packages
RUN npm install -g \
    playwright \
    puppeteer

# Create workspace
WORKDIR /workspace
VOLUME /workspace

# Default command
CMD ["/bin/bash"]
```

**Assessment:** This gives you the **execution environment** but none of the **intelligence layer** [[76]], [[79]].

### Phase 2: Core Agent Framework

You'll need an orchestration framework. Options:

| Framework | Pros | Cons |
|-----------|------|------|
| **OpenClaw** (open-source) | 247K GitHub stars, active community [[11]], Runs locally with Docker sandbox [[77]], [[79]] | Less polished than Perplexity, requires more setup [[1]] |
| **LangGraph** | Production-ready, good observability | More complex, enterprise-focused |
| **CrewAI** | Multi-agent support out of box | Less flexible for custom routing |
| **Custom Build** | Full control | Significant development time |

**Recommendation:** Start with **OpenClaw in Docker** [[79]], [[81]] as it already implements:
- Sandbox execution [[75]], [[81]]
- Tool registry [[75]]
- Model integration layer [[59]]

### Phase 3: Multi-Model Integration

```python
# Simplified model routing example
MODEL_ROUTING = {
    'reasoning': 'claude-opus-4.6',
    'research': 'gemini-2.0-pro',
    'code': 'claude-sonnet-4.5',
    'long_context': 'gpt-5.2-turbo',
    'speed': 'grok-2',
    'images': 'nano-banana',
    'video': 'veo-3.1'
}

def route_task(task_type, task_description):
    """Route task to appropriate model"""
    model = MODEL_ROUTING.get(task_type, 'claude-opus-4.6')
    return call_llm_api(model, task_description)
```

**Required API Integrations:**
- Anthropic (Claude) [[1]], [[10]]
- Google (Gemini) [[1]], [[10]]
- OpenAI (GPT) [[1]], [[10]]
- xAI (Grok) [[1]], [[10]]
- Additional models for images/video [[1]]

**Cost Consideration:** Perplexity's $200/month includes all model costs. Your personal setup will incur separate API charges per model [[54]].

### Phase 4: Tool Integration Layer

**Option A: Model Context Protocol (MCP)** [[91]], [[95]], [[97]]
- Open standard for AI tool integration
- Growing ecosystem of MCP servers
- Microsoft, Red Hat, Cloudflare all supporting [[91]], [[92]], [[95]]

**Option B: Direct Integration**
- Playwright for browser automation [[100]], [[107]]
- Custom API connectors for each service
- More control, more maintenance

**MCP Server Examples** [[92]], [[94]], [[97]]:
- Filesystem access
- Database queries
- API integrations
- Browser automation

### Phase 5: Sub-Agent System

```python
class SubAgent:
    def __init__(self, task_type, model, tools):
        self.task_type = task_type
        self.model = model
        self.tools = tools
        self.state = {}
    
    def execute(self, task):
        # Decompose task
        subtasks = self.decompose(task)
        
        # Execute in parallel where possible
        results = await self.parallel_execute(subtasks)
        
        # Synthesize results
        return self.synthesize(results)
    
    def spawn_child(self, problem):
        """Create sub-agent for specific problem"""
        return SubAgent(
            task_type=self.identify_problem_type(problem),
            model=self.select_model_for_problem(problem),
            tools=self.get_required_tools(problem)
        )
```

**Key Features Needed:**
- Task decomposition logic [[2]], [[49]]
- Parallel execution coordination [[1]]
- State sharing between agents [[50]]
- Problem detection & child agent spawning [[2]]

### Phase 6: Memory & Persistence

```python
# Simple persistent memory system
class AgentMemory:
    def __init__(self, user_id):
        self.user_id = user_id
        self.vector_store = ChromaDB(collection=f"user_{user_id}")
        self.session_store = Redis(key_prefix=f"session_{user_id}")
    
    def store_context(self, conversation_id, content):
        """Store conversation with embeddings"""
        embedding = self.embed(content)
        self.vector_store.add(conversation_id, content, embedding)
    
    def retrieve_context(self, query, limit=5):
        """Retrieve relevant past context"""
        query_embedding = self.embed(query)
        return self.vector_store.similarity_search(query_embedding, limit)
    
    def persist_preferences(self, preferences):
        """Store user preferences across sessions"""
        self.session_store.set('preferences', preferences)
```

**Requirements:**
- Vector database (ChromaDB, Qdrant, pgvector) [[73]]
- Session storage (Redis, PostgreSQL)
- Embedding model for semantic search
- Context compaction for long conversations [[1]]

---

## PART 6: REALISTIC ASSESSMENT

### What's Achievable for Personal Use

| Component | Feasibility | Effort Level |
|-----------|-------------|--------------|
| Docker sandbox environment | ✅ High | Low |
| Single-model agent with tools | ✅ High | Medium |
| Multi-model routing (3-5 models) | ✅ Medium | High |
| Basic sub-agent system | ✅ Medium | High |
| 400+ OAuth connectors | ❌ Low | Very High |
| Enterprise-grade security | ❌ Low | Very High |
| Perplexity-level polish | ❌ Low | Very High |

### Recommended Approach for Personal Use

**Start Small, Iterate:**

1. **Week 1-2:** Docker container + OpenClaw [[79]], [[81]]
   - Get basic agent running in isolated environment
   - Test file operations, web browsing

2. **Week 3-4:** Add 2-3 model integrations
   - Claude for reasoning
   - Gemini for research
   - Build simple routing logic

3. **Month 2:** Implement sub-agent system
   - Task decomposition
   - Parallel execution
   - Basic state management

4. **Month 3+:** Add connectors as needed
   - Focus on YOUR most-used services
   - Don't try to match 400+ integrations
   - Use MCP servers where available [[91]], [[95]]

### Cost Comparison

| Component | Perplexity Computer | Personal Clone (Estimated) |
|-----------|--------------------|---------------------------|
| **Subscription** | $200/month | $0 (self-hosted) |
| **Model API Costs** | Included | $50-300/month (usage dependent) [[54]] |
| **Infrastructure** | Included | $10-50/month (cloud VM) or $0 (local) |
| **Development Time** | N/A | 100-300 hours initial build |
| **Maintenance** | Included | 10-20 hours/month |

---

## PART 7: FINAL RECOMMENDATIONS

### ✅ Your Docker Plan IS Sufficient For:
- Base execution environment [[76]], [[79]]
- Tool isolation and security boundary [[77]]
- Reproducible development setup [[80]]

### ❌ Your Docker Plan IS NOT Sufficient For:
- Multi-model orchestration (needs additional framework)
- Sub-agent coordination (needs custom logic)
- OAuth connector management (needs integration layer)
- Persistent memory (needs database layer)
- Production security (needs VM-level isolation) [[13]]

### 🎯 Recommended Stack for Personal Clone:

```
┌─────────────────────────────────────────────────────────┐
│                    Docker Container                      │
│  Ubuntu 24.04 + Python + Node.js + Playwright + Tools   │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│              OpenClaw Framework (Modified)              │
│  Agent orchestration + Tool registry + Sandbox mgmt     │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│              MCP Server Layer                           │
│  Standardized tool integrations (filesystem, APIs, etc.)│
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│              Multi-Model Router                         │
│  Claude + Gemini + GPT + Grok (your selection)          │
└─────────────────────────────────────────────────────────┘
                          │
┌─────────────────────────────────────────────────────────┐
│              Memory Layer                               │
│  PostgreSQL + pgvector + Redis                          │
└─────────────────────────────────────────────────────────┘
```

### 📚 Key Resources for Implementation:

1. **OpenClaw Documentation** - Sandbox configuration [[81]]
2. **Docker + OpenClaw Guide** - Secure deployment [[79]]
3. **MCP Protocol** - Tool integration standard [[95]], [[97]]
4. **AI Agent Roadmap 2026** - Implementation patterns [[83]]
5. **Multi-Agent Orchestration Guide** - Architecture patterns [[89]]

---

## CONCLUSION

**Yes, a Docker container with Ubuntu 24.04/Debian Trixie can form the BASIS** of your personal Perplexity Computer clone, but it's only the **foundation layer** [[76]], [[79]]. The real complexity lies in:

1. **Orchestration logic** (routing tasks to appropriate models)
2. **Sub-agent coordination** (parallel execution, state management)
3. **Tool integration** (400+ connectors vs. your essential 10-20)
4. **Memory systems** (persistent context across sessions)
5. **Security boundaries** (container vs. VM isolation)

**My Recommendation:** Start with OpenClaw in Docker [[79]], [[81]], add 2-3 model integrations you actually need, build connectors for YOUR workflows, and iterate from there. You won't match Perplexity's polish, but you can achieve 80% of the functionality for personal use at a fraction of the $200/month cost.

---

```dockerfile
# syntax=docker/dockerfile:1

# -------------------------------------------------------------------
# SINGLE STAGE: Simple, reliable build
# -------------------------------------------------------------------
FROM python:3.13-trixie

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    TTYD_PORT=7681 \
    APP_PORT=7860 \
    XDG_RUNTIME_DIR=/tmp/runtime-user \
    PATH="/home/user/.local/bin:/usr/local/bin:${PATH}"

# 1. Install ALL system dependencies in ONE layer
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Core utilities
    bash coreutils ca-certificates cron curl git less procps sudo vim tar wget zip unzip tmux \
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
    libxext6 libxfixes3 libxrandr2 libxshmfence1 && \
    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin && wget https://github.com/nordeim/HF-Space/raw/refs/heads/main/bun
RUN cd /usr/bin && wget https://github.com/nordeim/HF-Space/raw/refs/heads/main/uv
RUN cd /usr/bin && wget https://github.com/nordeim/HF-Space/raw/refs/heads/main/uvx
RUN chmod a+x /usr/bin/bun /usr/bin/uv*

# 2. Install Node.js via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    node --version && npm --version
# 3. Build ttyd
RUN cd /tmp && \
    git clone --depth 1 --branch 1.7.4 https://github.com/tsl0922/ttyd.git && \
    cd ttyd && mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local .. && \
    make -j$(nproc) && make install && \
    cd / && rm -rf /tmp/ttyd && \
    ttyd --version

# 4. Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    fastapi uvicorn httpx pydantic python-multipart \
    sqlalchemy alembic aiofiles jinja2 uv

# 6. Create non-root user (Hugging Face requirement)
RUN groupadd -g 1000 user && \
    useradd -m -u 1000 -g user -d /home/user user && \
    # Limited sudo for cron only
    echo "user ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user && \
    # Create directories
    mkdir -p ${XDG_RUNTIME_DIR} /data /app && \
    chown -R user:user ${XDG_RUNTIME_DIR} /data /app

# Install global npm packages
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

# CRITICAL: Install Playwright browsers AS ROOT, BEFORE switching user
# Install browsers first (without trying to get system deps)
RUN npx playwright install chromium
# Then install the system dependencies Playwright needs
RUN npx playwright install-deps chromium

# 7. Switch to non-root user
USER user
WORKDIR /app

# 8. Copy application code
COPY --chown=user:user . /app

# 9. Install project dependencies
RUN if [ -f "package.json" ]; then \
        npm ci --omit=dev 2>/dev/null || npm install --omit=dev; \
    fi
RUN if [ -f "requirements.txt" ]; then \
        pip install --no-cache-dir --user -r requirements.txt; \
    fi

# 10. Install Playwright browsers
#RUN npx playwright install --with-deps chromium

# 11. Setup cron
RUN mkdir -p /home/user/cron && \
    touch /home/user/cron/cron.log && \
    crontab -l 2>/dev/null || echo "# User cron jobs" | crontab -

# 12. Expose ports
EXPOSE ${TTYD_PORT} ${APP_PORT}

# 13. Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${TTYD_PORT} || exit 1
# 14. Entrypoint script
COPY --chown=user:user docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["start"]
```

```bash
#!/usr/bin/env bash
set -e

# Function to start cron service as user
start_cron() {
    echo "Starting cron service..."
    # Load user's crontab if exists
    if [ -f "/app/crontab" ]; then
        crontab /app/crontab
    fi
    # Start cron in foreground
    sudo /usr/sbin/cron -f &
    CRON_PID=$!
    echo "Cron started with PID: ${CRON_PID}"
}

# Function to start ttyd web terminal
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

# Function to start main application - SIMPLIFIED
start_app() {
    echo "Starting HTTP server on port ${APP_PORT:-7860}..."
    # Always start HTTP server (for Hugging Face health check)
    python -m http.server ${APP_PORT:-7860} --bind 0.0.0.0 > /dev/null 2>&1 &
    APP_PID=$!
    echo "HTTP server started with PID: ${APP_PID}"
}

# Function to handle graceful shutdown
cleanup() {
    echo "Shutting down services..."
    [ -n "${TTYD_PID}" ] && kill ${TTYD_PID} 2>/dev/null || true
    [ -n "${CRON_PID}" ] && sudo kill ${CRON_PID} 2>/dev/null || true
    [ -n "${APP_PID}" ] && kill ${APP_PID} 2>/dev/null || true
    exit 0
}

# Trap signals for graceful shutdown
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

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def greet_json():
    return {"Hello": "World!"}
```

---

# Perplexity Computer: Comprehensive Research & Personal Clone Implementation Plan

Based on extensive research across official Perplexity announcements, developer teardowns, security analyses, and the latest open-source sandboxing ecosystem, here is a meticulously detailed analysis.

---

## PART 1: WHAT Is Perplexity Computer?

Perplexity Computer unifies every current AI capability into a single system. Computer is a general-purpose digital worker that operates the same interfaces you do. Despite its hardware-sounding name, it's not an actual computer. It's a cloud-based AI system made up of multiple agents.

**Two distinct products now exist:**

1. **Perplexity Computer (Cloud):** "Perplexity Computer," which was announced a few weeks ago, operates in the cloud. Perplexity Computer is a system that creates and executes entire workflows, capable of running for hours or even months.

2. **Personal Computer (Local+Cloud Hybrid):** Driving the news: "Personal Computer" software runs on a dedicated device — such as a Mac mini — with full local access to files and apps. At its first Ask 2026 developer conference, Perplexity unveiled Personal Computer, a software that runs continuously on a user's Mac mini to give Perplexity's cloud-based AI agent persistent access to local files, apps, and sessions.

### Key Specifications

It runs in an isolated Linux sandbox (2 vCPU, 8GB RAM) with Python, Node.js, ffmpeg, and standard Unix tools pre-installed. It has 400+ managed OAuth connectors for services like Slack, Gmail, GitHub, and Notion. It has 50+ domain-specific skill playbooks it loads on demand. Available on Perplexity Max at $200/month, it launched February 25, 2026.

### Sandbox Internals (Reverse-Engineered)

Every session runs inside its own isolated Firecracker virtual machine. Firecracker is the same microVM technology AWS built for Lambda. It boots in under 125 milliseconds and provides hardware-level isolation between sessions. The sandbox specs: 2 vCPUs, 8GB RAM, ~20GB disk. Pre-installed with Python, Node.js, ffmpeg, and standard Unix tools. A Go binary called envd manages the lifecycle via gRPC.

Perplexity runs a completely separate cloud browser instance for web automation. Yang Fan confirmed this by fetching httpbin.org/headers from both the sandbox and the browser tool. Different IP addresses, different User-Agent strings, different network fingerprints. Two separate machines. This means browser-based vulnerabilities cannot propagate back into the code execution environment. The two do not share memory, filesystem, or network stack.

Developer takeaway: This four-layer split (local device, cloud orchestrator, isolated execution, separate browser) is the pattern that matters.

### Network Isolation

The security architecture assumes untrusted code by default. Sandboxes have no direct network access. When outbound connectivity is required, traffic routes through an egress proxy running outside the sandbox.

---

## PART 2: WHY Was Perplexity Computer Created?

### 1. Models Are Specializing, Not Commoditizing

In January 2025, more than 90 percent of enterprise tasks on the Perplexity platform were spread across just two models. By December 2025, no single model commanded more than 25 percent of usage across businesses and task types. That shift, executives said, was driven partly by increasingly intelligent model routing on Perplexity's side, and partly by a simple reality: models are getting better at different things, not the same things. A new frontier model emerged on average every 17.5 days in 2025, and each one brought distinct strengths rather than uniform improvement.

Perplexity is making the same bet for AI: the orchestration layer, not the model layer, is where value accrues.

### 2. From Answers to Autonomous Outcomes

Chat interfaces have answers, while agents can do tasks. Perplexity Computer is a system that creates and executes entire workflows, capable of running for hours or even months.

### 3. Safer Than Local Agents

Perplexity says the setup is more secure than OpenClaw — requiring all actions to be confirmed by the user and including a built-in audit trail.

Computer aims to deliver OpenClaw-style autonomy without the chaos by combining model specialization, sandboxed execution, and human checkpoints.

### 4. Enterprise Revenue Engine

Perplexity announced that its multi-model AI agent, Computer, is now available to enterprise customers — a move that transforms the three-year-old startup from a consumer search disruptor into a direct competitor to Microsoft, Salesforce, and the legacy enterprise software stack. The enterprise launch arrives barely two weeks after Computer debuted for consumers, where it triggered what the company describes as a viral moment.

---

## PART 3: HOW Does Perplexity Computer Work?

### Architecture: Four Isolated Layers

```
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 1: LOCAL DEVICE (Mac mini / browser client)                  │
│  • Always-on file & app access • User approval gate • Kill switch   │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │ (secure connection)
┌─────────────────────────────────▼───────────────────────────────────┐
│  LAYER 2: CLOUD ORCHESTRATOR                                        │
│  • Claude Opus 4.6 core reasoning engine                            │
│  • Task decomposition into directed task graph                      │
│  • Dynamic model routing (19+ models)                               │
│  • Sub-agent creation & coordination                                │
│  • OAuth token management (server-side, never in sandbox)           │
│  • Protobuf/gRPC LlmApi abstraction layer                          │
└──────────┬──────────────────────────────────────┬───────────────────┘
           │                                      │
┌──────────▼──────────────────┐  ┌────────────────▼──────────────────┐
│  LAYER 3: EXECUTION SANDBOX │  │  LAYER 4: CLOUD BROWSER           │
│  • Firecracker microVM      │  │  • Separate IP/User-Agent         │
│  • 2 vCPU, 8GB RAM, 20GB   │  │  • Isolated network stack         │
│  • Python, Node.js, ffmpeg  │  │  • Web automation (Playwright)    │
│  • envd daemon (Go/gRPC)    │  │  • No shared memory/FS with L3   │
│  • No direct network access │  │                                   │
│  • Egress proxy for outbound│  │                                   │
└─────────────────────────────┘  └───────────────────────────────────┘
```

### Model Routing

As of this writing, Perplexity Computer runs Opus 4.6 for its core reasoning engine and orchestrates sub-agents with the best models for specific tasks: Gemini for deep research (creating sub-agents), Nano Banana for images, Veo 3.1 for video, Grok for speed in lightweight tasks, and ChatGPT 5.2 for long-context recall and wide search. Perplexity's model agnostic harness allows these to change as models advance. Computer also allows you to choose specific models for specific subtasks.

The internal API uses protobuf definitions with a service called LlmApi that handles both streaming and non-streaming completions. This clean abstraction separates the model routing logic from the LLM layer, meaning they can swap models without redesigning the system.

### Sub-Agent System

Perplexity Computer breaks it into tasks and subtasks, creating sub-agents for execution. The sub-agents might do web research, document generation, data processing, or API calls to your connected services. A document is drafted by one agent while another gathers the data it needs. The coordination is automatic, and the work is asynchronous.

When Computer runs into a problem, it creates sub-agents to solve it. It can find API keys, research supplemental information, code apps if necessary, and check in if it truly needs you.

Sub-agents communicate via filesystem. This is a critical architectural detail — inter-process communication happens through file I/O within the sandbox, not complex messaging.

### Security Model

Perplexity Computer has a tool called confirm_action. Before the agent sends an email, posts a message, makes a purchase, or deletes data, it must call confirm_action and wait for user approval. This is not a prompt instruction. It is a mandatory tool call baked into the execution model. No API keys, tokens, or secrets are visible inside the sandbox.

Security researcher Yang Fan confirmed this architecture by reverse-engineering the system from within its own sandbox. He verified that no API keys, tokens, or secrets are visible inside the execution environment. OAuth tokens for connectors are stored server-side on Perplexity's backend. The sandbox never sees a credential.

### Developer APIs (Now Public)

Perplexity's platform is expanding with four APIs: Search, Agent, Embeddings, and Sandbox. These are the same building blocks that power Computer, now available as APIs: cited outputs, multi-model routing, and the ability to move from retrieval to action in a secure environment.

Sandbox API provides isolated execution across Python, JavaScript, and SQL, with file system access, runtime package installation, and built-in resource limits.

---

## PART 4: IMPLEMENTATION PLAN — Recreating a Personal "Computer"

### Will Docker + Ubuntu/Debian Be Sufficient?

**Yes, for the execution sandbox layer — and that is a very substantial piece.** But it's only one of the four layers.

Here's an honest component-by-component assessment:

### Layer 3 Equivalent: The Execution Sandbox ✅ (Your Docker Approach)

Your proposed stack (Docker + Ubuntu 24.04/Debian Trixie + bash + curl + Playwright + Python + Node.js) **directly mirrors what Perplexity pre-installs in their sandbox**: The sandbox specs: 2 vCPUs, 8GB RAM, ~20GB disk. Pre-installed with Python, Node.js, ffmpeg, and standard Unix tools.

**Your Dockerfile already covers this well.** Some refinements I'd recommend:

```dockerfile
# Match Perplexity's sandbox specs
FROM python:3.13-trixie

# Core: matches Perplexity's pre-installed tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash coreutils curl wget git ffmpeg \
    python3 python3-pip nodejs npm \
    # ... (your existing list is excellent)
    && apt-get clean

# Playwright for browser automation (Layer 4 equivalent)
RUN pip install playwright && npx playwright install chromium

# Key addition: filesystem-based IPC directory for sub-agents
RUN mkdir -p /workspace/ipc /workspace/artifacts /workspace/logs
```

**Security note:** Standard Docker containers won't cut it. They share the host kernel through namespace and cgroup isolation. A kernel vulnerability or misconfiguration hands attackers host access. For untrusted code, you need stronger boundaries: user-space kernels like gVisor, or hardware-enforced isolation via microVMs like Firecracker and Kata Containers.

For personal use, Docker containers are fine. For anything multi-tenant, you'd want to upgrade isolation.

### Layer 4 Equivalent: Browser Isolation ⚠️ (Partial)

Perplexity runs the browser on an entirely separate machine from the code sandbox. For personal use, running Playwright inside your Docker container is sufficient, but be aware you're combining two attack surfaces.

### Layer 2 Equivalent: The Orchestrator ❌ (Must Build)

This is the hard part. You need:

1. **Task Decomposition Engine** — An LLM call that breaks goals into a task graph
2. **Model Router** — Logic to pick the right LLM per subtask
3. **Sub-Agent Spawner** — Creates and monitors parallel workers
4. **Filesystem-based IPC** — Sub-agents communicate via filesystem. The filesystem-based IPC pattern is something every developer building agents should understand.
5. **Tool/Connector Framework** — API integrations for external services

### Open-Source Building Blocks Available NOW

Several excellent projects can dramatically accelerate your build:

**For Sandboxing:**

- **Docker Sandboxes (Docker Desktop 4.60+):** Docker Sandboxes solves this by providing isolated environments for running AI agents. As of Docker Desktop 4.60+, sandboxes run inside dedicated microVMs, providing a hard security boundary beyond traditional container isolation. Docker Sandboxes now natively supports six agent types: Claude Code, Gemini, Codex, Copilot, Agent, and Kiro.

- **OpenSandbox (Alibaba, Apache 2.0):** Alibaba open-sourced OpenSandbox on March 1, 2026, handing the AI agent community production-grade sandbox infrastructure at zero cost. The platform hit 3,845 GitHub stars in two days with multi-language SDKs, Docker and Kubernetes runtimes, and unified APIs for safely executing untrusted AI agent code. You get browser automation via Chrome and Playwright, desktop environments with VNC access for visual automation, VS Code integration for full IDE sandboxes, and network controls with per-sandbox egress filtering. Within each isolated container, a high-performance Go-based execution daemon called execd connects to internal Jupyter kernels. This daemon enables stateful code execution, real-time output streaming over Server-Sent Events (SSE), and full filesystem management.

**For Multi-Agent Orchestration:**

- **Agent Zero:** Agent Zero takes a different approach: it is a multi-agent framework where a primary agent can spawn subordinate agents, each running in isolated Docker containers with full code execution, browser access, and shell capabilities. Multi-agent orchestration, Dockerized sandbox, Hybrid memory, Model-agnostic (OpenAI, Anthropic, local models), Browser built-in, MCP support.

- **Docker cagent:** At its heart, cagent represents Docker's answer to the complexity of AI agent orchestration. This open-source runtime lets you define intelligent agent behaviors using straightforward YAML configuration files. YAML-Driven Configuration: Everything your agent needs is contained in one declarative file. Provider Flexibility: Seamlessly work with OpenAI, Anthropic, Google Gemini. Model Context Protocol (MCP) Support.

- **Goose (Block):** Goose acts as the orchestrator, the AI agent responsible for executing tasks. It's configured to use a local Large Language Model (LLM) for its thinking and an MCP Gateway for accessing those essential tools.

---

## PART 5: Concrete Implementation Blueprint

### Phase 1: Docker Sandbox (Week 1)

Your existing Dockerfile is excellent. I'd make these additions:

```dockerfile
# Add these to your existing Dockerfile:

# 1. Match Perplexity's sandbox resource limits
# (set via docker run --cpus=2 --memory=8g)

# 2. Add filesystem IPC directories (how Perplexity sub-agents communicate)
RUN mkdir -p /workspace/{ipc,artifacts,logs,memory}

# 3. Add jq for JSON manipulation (agents produce JSON constantly)
RUN apt-get install -y jq

# 4. Add a simple HTTP server for inter-container communication
# (already have FastAPI in your setup — perfect)
```

### Phase 2: Orchestrator (Weeks 2-3)

Build a Python orchestrator that mimics Perplexity's pattern:

```python
# orchestrator.py — Simplified Perplexity Computer clone

import json, asyncio, subprocess
from pathlib import Path

class TaskOrchestrator:
    """Mimics Perplexity's Opus 4.6-based orchestrator"""
    
    MODEL_ROUTING = {
        "reasoning": "claude-sonnet-4",     # Complex planning
        "research":  "gemini-2.5-pro",      # Web research
        "code":      "claude-sonnet-4",      # Code generation
        "speed":     "gpt-4o-mini",          # Fast lightweight tasks
        "long_ctx":  "gemini-2.5-pro",       # Long document analysis
    }
    
    async def decompose_task(self, goal: str) -> list[dict]:
        """Use LLM to break goal into task graph (like Perplexity does)"""
        prompt = f"""Decompose this goal into subtasks. Return JSON array:
        [{{"id": 1, "type": "research|code|reasoning", "description": "...", 
           "depends_on": [], "parallel": true}}]
        Goal: {goal}"""
        return await self.call_llm("reasoning", prompt)
    
    async def spawn_subagent(self, task: dict, sandbox_id: str):
        """Execute task in Docker sandbox (like Perplexity sub-agents)"""
        model = self.MODEL_ROUTING[task["type"]]
        # Write task to filesystem IPC (Perplexity's pattern)
        ipc_path = f"/workspace/ipc/task_{task['id']}.json"
        # Execute in sandbox...
        
    async def run(self, goal: str):
        tasks = await self.decompose_task(goal)
        # Execute parallel tasks concurrently
        parallel = [t for t in tasks if t.get("parallel")]
        await asyncio.gather(*[self.spawn_subagent(t, "sandbox-1") for t in parallel])
```

### Phase 3: Connector Framework (Weeks 3-4)

Mimic Perplexity's OAuth isolation pattern: Connectors use OAuth with tokens stored server-side. When the agent calls send_email, the backend handles the OAuth exchange. The sandbox never touches a credential.

```python
# connectors.py — Keep credentials OUTSIDE the sandbox

class ConnectorRegistry:
    """OAuth tokens stored in host, never passed to sandbox"""
    
    def __init__(self, credentials_db_path: str):
        self.creds = self._load_encrypted(credentials_db_path)
    
    async def execute_action(self, service: str, action: str, params: dict):
        """Sandbox requests action -> host executes with real credentials"""
        if service == "gmail" and action == "send_email":
            # Requires confirm_action equivalent
            if not await self.confirm_with_user(service, action, params):
                return {"status": "rejected_by_user"}
            return await self._gmail_send(self.creds["gmail"], params)
```

### Phase 4: confirm_action Safety Gate (Critical)

Before the agent sends an email, posts a message, makes a purchase, or deletes data, it must call confirm_action and wait for user approval. This is not a prompt instruction. It is a mandatory tool call baked into the execution model.

```python
# safety.py — Mandatory approval gate (not optional prompt instruction)

SENSITIVE_ACTIONS = {"send_email", "delete_file", "push_code", "post_message", "purchase"}

async def confirm_action(action: str, details: dict) -> bool:
    """Block execution until user explicitly approves"""
    if action not in SENSITIVE_ACTIONS:
        return True  # Auto-approve safe actions
    
    print(f"\n🔒 APPROVAL REQUIRED: {action}")
    print(f"   Details: {json.dumps(details, indent=2)}")
    response = input("   Approve? [y/N]: ")
    return response.lower() == 'y'
```

---

## PART 6: Recommended Architecture (docker-compose.yml)

```yaml
version: '3.8'
services:
  # Layer 2: Orchestrator (runs on host, manages everything)
  orchestrator:
    build: ./orchestrator
    volumes:
      - ./workspace:/workspace
      - /var/run/docker.sock:/var/run/docker.sock  # To spawn sandboxes
    environment:
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - GOOGLE_API_KEY=${GOOGLE_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    ports:
      - "7860:7860"  # Web UI

  # Layer 3: Execution Sandbox (your Docker container)
  sandbox:
    build: .  # Your existing Dockerfile
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 8G
    volumes:
      - ./workspace:/workspace
    # NO API keys passed here — matches Perplexity's security model
    
  # Layer 4: Browser (separate from sandbox, like Perplexity)
  browser:
    image: mcr.microsoft.com/playwright:v1.50.0-noble
    volumes:
      - ./workspace/artifacts:/artifacts
    # Separate network from sandbox

  # Memory/Persistence Layer
  memory:
    image: pgvector/pgvector:pg17
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
  workspace:
```

---

## PART 7: Summary Assessment

| Component | Perplexity Computer | Your Docker Clone | Gap |
|---|---|---|---|
| **Execution Sandbox** | Firecracker microVM, 2vCPU/8GB, Python/Node/ffmpeg | Docker container, same tools | ✅ Minimal gap |
| **Browser** | Separate cloud instance, isolated network | Playwright in-container (or separate container) | ⚠️ Minor gap |
| **Orchestrator** | Opus 4.6 + proprietary task graph engine | Custom Python + LLM API calls | ❌ Must build |
| **Model Routing** | 19+ models, automatic selection | 3-5 models via API keys, manual routing | ⚠️ Buildable |
| **Connectors** | 400+ managed OAuth | Build as needed (start with 5-10) | ❌ Incremental |
| **Security** | Firecracker VM isolation + confirm_action | Docker isolation + confirm_action | ⚠️ Adequate for personal use |
| **IPC** | Filesystem-based between sub-agents | Filesystem-based (same pattern) | ✅ Same approach |
| **Persistence** | Cross-session memory | pgvector + Redis | ⚠️ Must build |
| **Scale** | Thousands of sessions/minute | Single-user, 1-5 concurrent | N/A (personal use) |

### Bottom Line

**Your Docker container running Debian Trixie with bash, curl, Playwright, Python, and Node.js is an excellent and sufficient foundation for the execution layer.** It closely mirrors what Perplexity actually runs inside their Firecracker VMs. The critical pieces you must add are:

1. **An orchestrator process** (outside the sandbox) that uses LLM APIs for task decomposition and model routing
2. **A confirm_action safety gate** that blocks sensitive operations pending your approval
3. **Credential isolation** — keep all API keys and OAuth tokens on the host, never inside the sandbox
4. **Filesystem-based IPC** for sub-agent communication (cheap, effective, exactly what Perplexity does)

I strongly recommend starting with **OpenSandbox** or **Agent Zero** as your base framework rather than building from scratch, as they've already solved the sandbox lifecycle management, browser automation integration, and multi-agent spawning patterns that Perplexity spent significant engineering effort on.
