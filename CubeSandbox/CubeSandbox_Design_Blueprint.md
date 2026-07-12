# CubeSandbox Design Blueprint
## Comprehensive Architecture & Deployment Guide for Ubuntu Linux 24.04.4 LTS

**Version:** 2.0 (Validated & Augmented)  
**Source:** [`https://github.com/TencentCloud/CubeSandbox`](https://github.com/TencentCloud/CubeSandbox)  
**Target Platform:** Ubuntu Linux 24.04.4 LTS (x86_64 / aarch64)  
**Latest Validated Release:** v0.5.0 (2026-07-03)  
**Date:** 2026-07-12

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Design Principles & Philosophy](#2-design-principles--philosophy)
3. [High-Level System Architecture](#3-high-level-system-architecture)
4. [Core Component Deep Dive](#4-core-component-deep-dive)
5. [Control Plane Architecture](#5-control-plane-architecture)
6. [Data Plane Architecture](#6-data-plane-architecture)
7. [Network Architecture (CubeVS)](#7-network-architecture-cubevs)
8. [Storage Architecture (CubeCoW)](#8-storage-architecture-cubecow)
9. [Security Architecture](#9-security-architecture)
10. [Deployment & Installation Model](#10-deployment--installation-model)
11. [Ubuntu 24.04.4 Adaptation Guide](#11-ubuntu-24044-adaptation-guide)
12. [Configuration Management](#12-configuration-management)
13. [Integration Interfaces](#13-integration-interfaces)
14. [Operational Model & Lifecycle](#14-operational-model--lifecycle)
15. [Competitive Landscape & Positioning](#15-competitive-landscape--positioning)
16. [Appendix](#16-appendix)

---

## 1. Executive Summary

**CubeSandbox** is a high-performance, hardware-isolated sandbox service purpose-built for AI Agent workloads. Released by Tencent Cloud's IaaS Frontier Technology Team in April 2026 under the Apache 2.0 license, it provisions MicroVMs (KVM-based) with **sub-60ms cold start times** and **<5MB memory overhead per instance** — enabling thousands of concurrent sandboxes on a single compute node.

Unlike container-based sandboxes that share a host kernel, each CubeSandbox instance runs its own dedicated Linux kernel inside a KVM MicroVM, eliminating shared-kernel escape surfaces entirely. The system is designed as a **cloud-native, horizontally scalable platform** with a stateless control plane, eBPF-accelerated data plane, and **E2B-compatible API surface** that allows zero-code migration from existing E2B-based solutions.

### Key Metrics at a Glance

| Metric | Target | Implementation Mechanism |
|--------|--------|--------------------------|
| **Boot Speed** | < 60ms (Cold Start) | Pre-snapshotted templates + RustVMM restore path |
| **Memory Overhead** | < 5MB per instance | Aggressively stripped VMM + virtio-minimal drivers |
| **Isolation Level** | Extreme (Hardware + eBPF) | Dedicated Guest OS kernel per sandbox; no shared namespaces |
| **API Compatibility** | E2B SDK Drop-in | Custom REST Gateway mapping E2B protocols to local VM lifecycle |
| **State Management** | < 100ms Snapshots | Copy-on-Write (CoW) block storage + VM memory state serialization |
| **Concurrent Density** | ~2,000 sandboxes / 96-core node | MicroVM architecture + resource overcommit |

### What This Blueprint Covers

This document extracts, validates, and augments the core design principles, architecture, and operational procedures from the CubeSandbox GitHub repository to enable you to build, deploy, and operate a similar sandbox environment on your Ubuntu 24.04.4 host. It serves as both an **architectural reference** and a **practical deployment guide**.

---

## 2. Design Principles & Philosophy

CubeSandbox is built on six core design principles that differentiate it from traditional container or VM-based sandbox solutions:

| Principle | Manifestation | Benefit |
|-----------|---------------|---------|
| **Agent-First** | Lifecycle semantics, SDK shape, auto-pause/resume, and lightning-fast clone/rollback are designed to host long-running agents and stateful services (e.g., persistent dev environments, web services, databases) directly inside sandboxes | Optimized for AI agent workloads rather than simple ephemeral code execution |
| **Hardware Isolation** | Each sandbox runs its own Linux kernel inside a KVM MicroVM via RustVMM | Eliminates shared-kernel escape vulnerabilities present in Docker containers |
| **Millisecond-Class Boot** | Pre-snapshotted templates plus RustVMM restore path yield sub-100ms cold starts | Enables real-time, interactive AI agent workflows |
| **Zero-Trust Egress** | All outbound traffic traverses CubeEgress (L7 MITM proxy). Domains must be explicitly allowed | Prevents data exfiltration and unauthorized API access |
| **Stateless Control Plane** | CubeAPI and CubeMaster hold no local state; all coordination goes through Redis | Trivial horizontal scaling of control plane components |
| **Efficient Storage** | CubeCoW leverages kernel `FICLONE` ioctl for O(1) snapshots and clones with zero data copying | Near-instant snapshots with minimal disk overhead |

### The AI Agent Execution Trilemma

AI Agents need to execute LLM-generated, untrusted code rapidly and safely. Traditional environments force an uncomfortable compromise:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     THE AI AGENT EXECUTION TRILEMMA                         │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   🐳 Docker Containers          💻 Traditional VMs           ⚡ CubeSandbox │
│   ─────────────────────         ──────────────────         ─────────────── │
│   ✅ Fast & Lightweight         ✅ High Security             ✅ Hardware Iso │
│   ❌ Shared Kernel              ❌ Slow Boot (Seconds)      ✅ <60ms Boot   │
│   ❌ Low Security               ❌ Heavy Memory (GBs)       ✅ <5MB Overhead│
│                                                                             │
│   CubeSandbox bridges the gap: the SPEED of containers + SECURITY of VMs   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. High-Level System Architecture

### 3.1 System Topology

The architecture is divided into three planes: the **Client/SDK Layer**, the **Control Plane** (cluster management), and the **Data Plane** (local execution per node).

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        CLIENT / SDK LAYER                                   │
│         (E2B-compatible REST API, Python/Node/Go SDKs)                      │
└──────────────────────────┬────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────────────────────────┐
│                      CONTROL PLANE (Stateless)                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   CubeAPI   │  │  CubeMaster │  │    WebUI    │  │  Redis (State)  │  │
│  │   (Rust)    │  │    (Go)     │  │  (OpenResty)│  │  MySQL (Meta)   │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────┘  │
│         │                │                                                    │
│         └────────────────┴────────────────────────────────────────────────────┘
│                           gRPC
└──────────────────────────┬────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼────────────────────────────────────────────────┐
│                        DATA PLANE (Node-Local)                             │
│                                                                            │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌────────────────┐  │
│  │ Cubelet │  │CubeShim │  │CubeHyper│  │  CubeVS │  │   CubeCoW      │  │
│  │  (Go)   │  │ (Rust)  │  │  (Rust) │  │ (eBPF)  │  │   (XFS reflink)│  │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  └────────────────┘  │
│       │            │            │            │                              │
│       └────────────┴────────────┴────────────┘                              │
│                         │                                                  │
│                  ┌──────▼──────┐                                           │
│                  │   MicroVM   │                                           │
│                  │  (Sandbox)  │                                           │
│                  └──────┬──────┘                                           │
│                         │                                                  │
│              ┌──────────┴──────────┐                                        │
│              │    CubeEgress       │  (OpenResty + Lua)                    │
│              │  (L7 Security Proxy)│                                        │
│              └──────────┬──────────┘                                        │
│                         │                                                  │
│              ┌──────────▼──────────┐                                        │
│              │     Internet        │                                        │
│              └─────────────────────┘                                        │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Control Plane vs Data Plane

| Layer | Components | Responsibilities |
|-------|-----------|-----------------|
| **Control Plane** | CubeAPI, CubeMaster, WebUI, Redis, MySQL | API gateway, scheduling, state coordination, operator dashboard, persistent metadata |
| **Data Plane** | Cubelet, CubeShim, CubeHypervisor, CubeCoW, CubeVS, CubeEgress, CubeProxy | VM lifecycle, storage, networking, security enforcement, request routing |

**Key Characteristic:** The control plane is **stateless** — Redis is the single source of truth for sandbox metadata and lifecycle events. Any CubeAPI or CubeMaster instance can serve any request. The data plane is **node-local** — each compute node runs its own isolated set of daemons.

### 3.3 Request Lifecycle (Typical `Sandbox.create()` Flow)

```
Client / SDK
    │
    ▼ POST /sandboxes (E2B-compatible REST)
CubeAPI (Port 3000)
    │
    ▼ gRPC CreateSandbox
CubeMaster (Port 8089)
    │
    ├─ Select target node (resource fit)
    │
    ▼ gRPC RunCubeSandbox
Cubelet (Node Agent)
    │
    ├─ Prepare rootfs (CubeCoW clone from template — O(1))
    │
    ▼ containerd Shim v2 → Create + Start
CubeShim
    │
    ▼ launch_vmm() → create_vm() → restore_vm()
CubeHypervisor (RustVMM + KVM)
    │
    ▼ VM ready (vsock listening) — < 60ms
MicroVM (Sandbox)
    │
    ▼ Add TAP Device + Attach eBPF Filter
CubeVS
    │
    ▼ Publish lifecycle event
Redis
    │
    ▼ Return Sandbox ID + metadata
Client
```

---

## 4. Core Component Deep Dive

### 4.1 CubeAPI (Rust / Axum)

| Attribute | Detail |
|-----------|--------|
| **Role** | E2B-compatible REST API gateway |
| **Language** | Rust (Axum framework) |
| **Port** | `3000` (default) |
| **Key Functions** | Translates E2B SDK calls into internal gRPC; handles authentication callbacks; forwards requests to CubeMaster |

Switching from E2B Cloud to Cube Sandbox requires only changing environment variables such as `E2B_API_URL` — zero business code changes.

### 4.2 CubeMaster (Go)

| Attribute | Detail |
|-----------|--------|
| **Role** | Cluster-level orchestration scheduler |
| **Language** | Go |
| **Port** | `8089` (gRPC meta endpoint) |
| **Key Functions** | Receives sandbox create/destroy/pause/resume/snapshot requests; selects target nodes based on resource availability; dispatches work to Cubelet; publishes lifecycle events to Redis |
| **CLI Tool** | `cubemastercli` |

### 4.3 CubeProxy (OpenResty / Lua + Go Sidecar)

| Attribute | Detail |
|-----------|--------|
| **Role** | Reverse proxy, request routing, auto-pause/resume orchestration |
| **Technology** | OpenResty (nginx + Lua) + Go (`cube-lifecycle-manager` sidecar) |
| **Ports** | `80` / `443` (default) |

**Routing Modes:**
- **Host-based:** Parses `<port>-<sandbox_id>.<domain>` from the `Host` header
- **Path-based:** Parses `/sandbox/<sandbox_id>/<port>/...` from the URL path (useful when wildcard DNS and TLS are inconvenient)

**Auto-Pause/Auto-Resume (v0.5.0):**
- The Go sidecar watches lifecycle events via Redis
- Transparently pauses idle sandboxes after a configurable timeout
- Resumes paused sandboxes on incoming requests
- Concurrent resumes for the same sandbox are coalesced (singleflight pattern)
- Cross-replica coordination uses Redis SETNX locks

### 4.4 Cubelet (Go)

| Attribute | Detail |
|-----------|--------|
| **Role** | Node-local scheduling agent |
| **Language** | Go |
| **Ports** | gRPC `9999`, HTTP `9998` (debug/metrics) |
| **Key Functions** | Manages full lifecycle of all sandbox instances on a single node: `create → run → pause → resume → snapshot → destroy`; integrates with containerd for image pull; integrates with CubeCoW for volume management |
| **CLI Tool** | `cubecli` |

### 4.5 CubeShim (Rust)

| Attribute | Detail |
|-----------|--------|
| **Role** | containerd Shim v2 interface implementation |
| **Language** | Rust |
| **Standard** | containerd Shim v2 |
| **Key Functions** | Bridges container runtime abstraction to actual MicroVM; handles sandbox resource preparation (rootfs via CubeCoW, memory file, kernel `vmlinux`); VM boot/restore; vsock communication; in-place snapshot for auto-pause |

### 4.6 CubeHypervisor (Rust / RustVMM + KVM)

| Attribute | Detail |
|-----------|--------|
| **Role** | Lightweight VMM (Virtual Machine Monitor) |
| **Language** | Rust (RustVMM crates) |
| **Hypervisor** | KVM |
| **Key Functions** | vCPU setup and management; memory region mapping; virtio device emulation (virtio-net, virtio-blk, virtio-vsock, virtio-fs); MicroVM boot and restore from pre-snapshotted templates; seccomp-hardened with minimal syscall surface |

The CubeHypervisor is built on **RustVMM** (not QEMU), specifically leveraging components from **Cloud Hypervisor** and **Kata Containers** upstream — tailored and modified for the CubeSandbox execution model.

### 4.7 CubeAgent (Rust)

| Attribute | Detail |
|-----------|--------|
| **Role** | Guest OS agent |
| **Language** | Rust |
| **Location** | Runs inside the MicroVM as `/sbin/init` |
| **Key Functions** | Receives commands from Cubelet via vsock; manages guest-side lifecycle operations; handles file operations, exec requests, and health checks inside the sandbox |

### 4.8 network-agent (Go)

| Attribute | Detail |
|-----------|--------|
| **Role** | Network control plane agent |
| **Language** | Go |
| **Key Functions** | Manages CubeVS eBPF programs; configures TAP devices, SNAT pools, port mappings; applies network policies per sandbox |

---

## 5. Control Plane Architecture

### 5.1 API Flow

```
Client (E2B SDK)
    │
    ▼ HTTP/REST
CubeAPI (Port 3000)
    │
    ▼ gRPC
CubeMaster (Port 8089)
    │
    ├─────────────┬─────────────┐
    ▼             ▼             ▼
  Redis        Cubelet      MySQL
 (State)     (Node 1..N)  (Metadata)
```

### 5.2 State Management

| Store | Technology | Purpose |
|-------|-----------|---------|
| **Redis** | Redis 7+ | Runtime state, lifecycle events, node registration, sandbox metadata cache, CubeProxy service discovery |
| **MySQL** | MySQL 8.0 | Persistent metadata: templates, sandbox records, audit logs, user data |

### 5.3 WebUI Dashboard

- **Technology:** OpenResty + Frontend
- **Port:** `12088`
- **Capabilities:**
  - **Overview:** Cluster KPIs (running sandboxes, CPU/memory utilization, healthy nodes)
  - **Sandboxes:** MicroVM real-time list with pause/resume/terminate actions
  - **Templates:** Reusable sandbox snapshot directory; create from OCI images
  - **Nodes:** Node health status and resource utilization
  - **Versions:** Component version matrix (kernel, agent, guest image)
  - **Network:** API gateway configuration and rate limiting
  - **API Keys:** API key management

---

## 6. Data Plane Architecture

### 6.1 Node-Local Stack

Each compute node runs the following processes:

| Process | Binary | Responsibility |
|---------|--------|---------------|
| `cubelet` | `cubelet` | Node agent, containerd integration |
| `containerd-shim-cube-rs` | `containerd-shim-cube-rs` | Shim v2 implementation |
| `cube-runtime` | `cube-runtime` | Runtime helper |
| `network-agent` | `network-agent` | eBPF network control |
| `cube-proxy` | Docker container | Reverse proxy (if enabled) |
| `cube-lifecycle-manager` | Docker container | Auto-pause/resume orchestrator |

### 6.2 MicroVM Lifecycle

```
Template (OCI Image)
    │
    ▼
CubeMaster schedules to Node
    │
    ▼
Cubelet pulls image via containerd
    │
    ▼
CubeShim prepares rootfs via CubeCoW (XFS reflink — O(1))
    │
    ▼
CubeShim prepares memory file + kernel (vmlinux)
    │
    ▼
CubeHypervisor restores MicroVM from template snapshot
    │
    ▼
MicroVM boots (< 60ms)
    │
    ▼
CubeAgent (guest /sbin/init) ready via vsock
```

### 6.3 AutoPause / AutoResume Lifecycle (v0.5.0)

```
RUNNING ──[idle timeout]──► PAUSED
   ▲                          │
   │                          │
   └────[incoming request]────┘
         (CubeProxy sidecar
          triggers resume via
          CubeMaster → Cubelet)
```

- **AutoPause:** A sweeper tracks sandbox activity via `last_active` timestamps. When idle ≥ timeout, the sidecar triggers a pause through CubeMaster → Cubelet, which snapshots the full VM state (memory + filesystem) to `/data/cubelet/root/pausevm/<sandbox>`, then shuts down the MicroVM.
- **AutoResume:** When a dataplane request arrives for a paused sandbox, CubeProxy intercepts it and fires an internal sub-request to the sidecar's `/internal/resume`. The sidecar drives a resume RPC through CubeMaster → Cubelet → containerd, which restores the VM from the pause snapshot.
- **Resource Release Ratio:** A node-level configuration `host.quota.paused_resource_release_ratio` (float `[0, 1]`, default `0`) controls how much CPU/memory quota paused sandboxes release back to the scheduler.

---

## 7. Network Architecture (CubeVS)

### 7.1 Design Philosophy

CubeVS replaces traditional container networking (Linux Bridge, OVS, iptables) with a purpose-built eBPF stack for:
- Point-to-point low latency
- Kernel-space policy enforcement
- Scalable NAT without iptables rule explosion

### 7.2 The Three eBPF Programs

| Program | Source File | Attach Point | Direction | Role |
|---------|-------------|-------------|-----------|------|
| `from_cube` | `mvmtap.bpf.c` | TC ingress on each TAP | Sandbox → Host | SNAT, policy check, L7 proxy selection, session creation, ARP proxy |
| `from_world` | `nodenic.bpf.c` | TC ingress on host NIC | External → Host | Reverse NAT, port-mapping proxy |
| `from_envoy` | `localgw.bpf.c` | TC egress on `cube-dev` | Proxy → Sandbox | DNAT to sandbox IP, preserve TPROXY source IP |

### 7.3 Pinned BPF Maps

Located under `/sys/fs/bpf/`, shared between programs and Go control plane:

| Map | Type | Purpose |
|-----|------|---------|
| `mvmip_to_ifindex` | Hash | Sandbox IP → TAP ifindex |
| `ifindex_to_mvmmeta` | Hash | TAP ifindex → Sandbox metadata |
| `egress_sessions` | Hash | 5-tuple → NAT session state |
| `ingress_sessions` | Hash | External 5-tuple → reverse lookup |
| `snat_iplist` | Array | SNAT IP pool |
| `allow_out` | Hash-of-Maps | Per-sandbox egress allowlist (LPM trie) |
| `deny_out` | Hash-of-Maps | Per-sandbox egress denylist (LPM trie) |
| `remote_port_mapping` | Hash | Host port → sandbox service |
| `local_port_mapping` | Hash | Sandbox port → host port |

### 7.4 Traffic Flows

#### Egress: Sandbox → External
1. Sandbox sends packet (src: `169.254.68.6`)
2. Packet enters TAP → `from_cube` TC ingress
3. Policy evaluation against destination IP
4. L7 proxy selection for TCP `:80`/`:443` (redirect to `cube-dev`)
5. SNAT: replace sandbox IP with host SNAT pool IP + allocated port
6. Redirect to host NIC (`eth0`)

#### Ingress: External → Sandbox
1. Reply packet arrives host NIC
2. `from_world` TC ingress
3. Lookup `ingress_sessions` by external 5-tuple
4. Reverse NAT: rewrite dst to sandbox internal IP/port
5. Redirect to correct TAP device

#### Proxy/Overlay → Sandbox
1. Traffic from OpenResty TPROXY arrives at `cube-dev`
2. `from_envoy` TC egress
3. DNAT destination to sandbox IP (`169.254.68.6`)
4. Redirect to TAP device

### 7.5 Session Tracking

- **Dual-map design:** `egress_sessions` (primary) + `ingress_sessions` (reverse lookup)
- **TCP state machine:** 11 states modeled after `nf_conntrack` (SYN_SENT, ESTABLISHED, TIME_WAIT, etc.)
- **Timeouts:** ESTABLISHED = 3 hours, SYN_SENT = 1 minute, UDP unreplied = 30s, UDP replied = 180s
- **Session reaper:** Background goroutine sweeps expired NAT sessions

### 7.6 Network Policy Engine

- **Per-sandbox policies** stored in `allow_out` / `deny_out` BPF maps
- **LPM (Longest Prefix Match) tries** for CIDR-based rules
- **Default-deny posture:** Traffic not explicitly allowed is blocked
- **L7_REQUIRED flag:** Matched TCP `:80`/`:443` traffic is redirected to CubeEgress (OpenResty) for MITM inspection

### 7.7 Traffic Access Token Gating (v0.5.0)

Sandboxes created with `network.allow_public_traffic=false` receive a per-sandbox `traffic_access_token` (UUID v4). CubeProxy enforces this token on every inbound request, returning HTTP 403 for missing or mismatched tokens. Token values are redacted from all logs.

---

## 8. Storage Architecture (CubeCoW)

### 8.1 Technology: XFS Reflink + `FICLONE`

CubeCoW (Copy-on-Write) is the snapshot and clone engine.

- **Requirement:** `/data/cubelet` must be mounted on **XFS** with reflink enabled
- **Mechanism:** Uses `FICLONE` ioctl for O(1) file cloning
- **Benefits:** Zero data copying, near-instant snapshots, minimal disk overhead

### 8.2 Why XFS?

Ubuntu/Debian default to ext4, which does not support reflink. CubeSandbox **requires** XFS for `/data/cubelet`.

### 8.3 Storage Layer Diagram

```
Template (read-only base)
  └── FICLONE ──→ Sandbox rootfs volume (CoW)
                      ├── FICLONE ──→ Snapshot A
                      └── FICLONE ──→ Clone 1, Clone 2, ...
```

- **Template creation:** OCI image → Buildkit → rootfs + cold-boot → memory snapshot → registered as a template
- **Sandbox boot:** Cubelet clones the template's rootfs and memory volumes via CubeCoW (O(1), no data copy), then CubeShim restores the VM from the memory snapshot
- **Incremental snapshot:** Only anonymous (dirty) pages are written; base pages are shared with the previous snapshot via reflink

### 8.4 Disk Requirements

| Use Case | Minimum Free Space | Recommended |
|----------|-------------------|-------------|
| Functional experience | 50 GB | 100 GB |
| Production / multiple templates | 200 GB | 500 GB+ |

---

## 9. Security Architecture

### 9.1 Isolation Model

| Layer | Mechanism |
|-------|-----------|
| **Kernel Isolation** | Each MicroVM runs its own Linux kernel via KVM + RustVMM |
| **Network Isolation** | Dedicated TAP device per sandbox, eBPF-enforced policies |
| **Storage Isolation** | Separate reflink-cloned rootfs per sandbox |
| **Resource Isolation** | vCPU and memory limits enforced by VMM |
| **Seccomp** | CubeHypervisor seccomp-hardened with minimal syscall surface |

### 9.2 Egress Security (CubeEgress)

- **Technology:** OpenResty + Lua (~2,200 lines across 9 modules)
- **Function:** L7 MITM proxy for all outbound HTTP/HTTPS via TPROXY
- **Domain Allowlist:** Only explicitly approved domains are accessible
- **Credential Injection:** External API keys never enter the sandbox; intercepted at proxy layer
- **Access Auditing:** Full request/response JSONL logging for compliance
- **Fail-Closed Bootstrap:** CubeEgress starts in deny-all mode until policies are loaded

**Intercept Principle:**

```
Sandbox → cube-dev (host iface)
            │
            ├─ iptables mangle/PREROUTING -j TPROXY
            │   Port 80  → 192.168.0.1:8080 (HTTP)
            │   Port 443 → 192.168.0.1:8443 (HTTPS)
            ▼
       CubeEgress (OpenResty + Lua)
            │
            ├─ ssl_certificate_by_lua → Issue leaf cert for SNI
            ├─ access_by_lua → Match L7 rules (allow/deny/inject)
            └─ proxy_pass → Original target IP
```

The sandbox trusts a CubeEgress-issued root CA (baked into the template), enabling transparent TLS inspection.

### 9.3 Credential Vault

- Agents call external APIs as usual (e.g., `fetch("https://api.openai.com/...")`)
- API keys are intercepted by CubeProxy/CubeEgress
- Keys never enter sandbox memory, model context, or logs
- Injected at the L7 proxy layer via `EgressRule.inject`

### 9.4 Sandbox Internal Addressing

- Fixed internal IP: `169.254.68.6/30`
- Gateway IP: `169.254.68.5`
- This is consistent across all sandbox instances

### 9.5 Network Hardening (Production)

Before exposing to untrusted networks:

1. **Enable domain allowlists** in CubeEgress configuration
2. **Configure TLS** using real certificates (replace mkcert defaults)
3. **Restrict Redis/MySQL** to localhost or internal network
4. **Enable API authentication** (see `docs/guide/authentication.md`)
5. **Review CIDR allocation** to avoid conflicts with host network
6. **Configure firewall rules** for CubeProxy ports

---

## 10. Deployment & Installation Model

### 10.1 Deployment Roles

| Role | Components | Use Case |
|------|-----------|----------|
| **Control** | All-in-one: CubeAPI, CubeMaster, Cubelet, MySQL, Redis, CubeProxy, WebUI | Single node, evaluation, small deployments |
| **Compute** | Cubelet, CubeShim, CubeHypervisor, CubeVS, network-agent | Additional compute nodes registering to existing control plane |

### 10.2 One-Click Installation (Binary Release)

The project provides a release bundle (`cube-sandbox-one-click-<version>.tar.gz`) containing:

- All compiled binaries
- Guest VM image (`cube-guest-image-cpu.img`)
- Kernel package (`cube-kernel-scf.zip`)
- Docker Compose templates for CubeProxy, CoreDNS, MySQL, Redis, WebUI
- Installation scripts (`install.sh`, `install-compute.sh`, `down.sh`, `smoke.sh`)
- Environment template (`env.example`)
- systemd unit files

### 10.3 systemd Service Architecture

All components are managed as systemd services:

| Service | Description |
|---------|-------------|
| `cube-sandbox-cube-api.service` | REST API gateway |
| `cube-sandbox-cubemaster.service` | Cluster orchestrator |
| `cube-sandbox-cubelet.service` | Node agent |
| `cube-sandbox-network-agent.service` | eBPF network control |
| `cube-sandbox-cube-proxy.service` | Reverse proxy |
| `cube-sandbox-cube-lifecycle-manager.service` | Auto-pause/resume |
| `cube-sandbox-cube-egress.service` | Egress proxy |
| `cube-sandbox-cube-egress-net.service` | Egress network |
| `cube-sandbox-mysql.service` | Metadata database (Docker) |
| `cube-sandbox-redis.service` | State store (Docker) |
| `cube-sandbox-coredns.service` | Internal DNS (Docker) |
| `cube-sandbox-dns.service` | Host DNS integration |
| `cube-sandbox-webui.service` | Dashboard (Docker) |

### 10.4 Directory Layout on Target Host

```
/usr/local/services/cubetoolbox/
├── cube-api/
│   └── bin/cube-api
├── cubemaster/
│   ├── bin/cubemaster
│   └── bin/cubemastercli
├── cubelet/
│   ├── bin/cubelet
│   └── bin/cubecli
├── cube-shim/
│   ├── bin/containerd-shim-cube-rs
│   └── bin/cube-runtime
├── network-agent/
│   └── bin/network-agent
├── cube-kernel-scf/
│   └── vmlinux
├── cube-image/
│   └── cube-guest-image-cpu.img
├── cubeproxy/
│   ├── certs/
│   └── conf/
├── cube-egress/
│   └── conf/
└── ...

/var/run/cube-sandbox-one-click/   # Runtime state
/var/log/cube-sandbox-one-click/   # Logs
/data/cubelet/                     # VM storage (MUST be XFS)
```

---

## 11. Ubuntu 24.04.4 Adaptation Guide

### 11.1 Prerequisites Checklist

| Requirement | Command to Verify | Notes |
|-------------|-------------------|-------|
| **Architecture** | `uname -m` | `x86_64` or `aarch64` |
| **KVM Support** | `ls -la /dev/kvm` | Must exist and be read/writable |
| **glibc Version** | `ldd --version` | Must be ≥ 2.31 (Ubuntu 24.04 has 2.39 — backward compatible) |
| **Docker** | `docker info` | Must be installed and running |
| **Root Access** | `whoami` | All installation commands as root |
| **XFS Filesystem** | `findmnt /data/cubelet` | **Must be XFS with reflink** |
| **Disk Space** | `df -h /data/cubelet` | ≥ 50 GB free (200 GB recommended) |
| **RAM** | `free -h` | ≥ 8 GB (64 GB recommended for production) |
| **CPU Cores** | `nproc` | ≥ 4 cores (32 recommended) |

> ⚠️ **PVM Limitation:** PVM (Pseudo-Virtual Machine) enables KVM on standard cloud VMs without nested virtualization, but it is **x86_64-only**. On ARM64, you must use a physical machine or cloud VM with native KVM support.

### 11.2 Critical: XFS Setup for Ubuntu 24.04

Ubuntu defaults to ext4. You **must** provide an XFS volume for `/data/cubelet`:

```bash
# Option 1: Dedicated disk/partition
sudo mkfs.xfs -f -m reflink=1 /dev/sdX
sudo mkdir -p /data/cubelet
sudo mount /dev/sdX /data/cubelet
echo '/dev/sdX /data/cubelet xfs defaults 0 0' | sudo tee -a /etc/fstab

# Option 2: Loopback file (for testing only)
sudo mkdir -p /data
sudo truncate -s 200G /data/cubelet.img
sudo mkfs.xfs -f -m reflink=1 /data/cubelet.img
echo '/data/cubelet.img /data/cubelet xfs loop 0 0' | sudo tee -a /etc/fstab
sudo mount /data/cubelet
```

### 11.3 Step-by-Step Installation for Ubuntu 24.04.4

#### Step 1: Prepare System

```bash
# Switch to root
sudo su root

# Update and install dependencies
apt update && apt install -y curl wget tar docker.io

# Verify Docker is running
systemctl enable --now docker

# Verify KVM (for bare-metal or nested-virt VMs)
ls -la /dev/kvm
# If missing on cloud VMs, use PVM mode (x86_64 only)
```

#### Step 2: Download Release Bundle

```bash
# For x86_64
wget https://github.com/TencentCloud/CubeSandbox/releases/download/v0.5.0/cube-sandbox-one-click-v0.5.0.tar.gz

# For ARM64 (aarch64)
wget https://github.com/TencentCloud/CubeSandbox/releases/download/v0.5.0/cube-sandbox-one-click-v0.5.0-arm64.tar.gz

tar -xzf cube-sandbox-one-click-*.tar.gz
cd cube-sandbox-one-click-*
```

#### Step 3: Configure Environment

```bash
cp env.example .env

# Edit .env for your environment:
# - CUBE_SANDBOX_NODE_IP=<your_ip>
# - CUBE_SANDBOX_NETWORK_CIDR=10.100.0.0/18 (adjust to avoid conflicts)
# - ONE_CLICK_DEPLOY_ROLE=control
# - CUBE_PVM_ENABLE=1 (only for x86_64 cloud VMs without /dev/kvm)
```

#### Step 4: Run Installer

```bash
chmod +x install.sh
./install.sh
```

> 💡 **Upgrade Mode:** `install.sh --mode=upgrade` detects existing installations, performs three-way `.env` config merge (new defaults + old customizations + explicit overrides), runs fail-fast preflight checks, and backs up configuration before any destructive change.

#### Step 5: Verify Installation

```bash
./smoke.sh

systemctl status cube-sandbox-cube-api
systemctl status cube-sandbox-cubemaster
systemctl status cube-sandbox-cubelet
systemctl status cube-sandbox-network-agent

# Check API health
curl http://127.0.0.1:3000/health

# Check WebUI
curl http://127.0.0.1:12088
```

#### Step 6: Create First Template

```bash
# Install CLI tools if not in PATH
export PATH=$PATH:/usr/local/services/cubetoolbox/cubemaster/bin

# Create template from official image
cubemastercli tpl create-from-image   --image cube-sandbox-int.tencentcloudcr.com/cube-sandbox/sandbox-code:latest   --writable-layer-size 1G   --expose-port 49999   --expose-port 49983   --probe 49999

# Watch template creation progress
cubemastercli tpl watch --job-id <job_id>
```

#### Step 7: Test with Python SDK (E2B Compatible)

```bash
pip install e2b-code-interpreter
```

```python
import os
from e2b_code_interpreter import Sandbox

os.environ["E2B_API_URL"] = "http://127.0.0.1:3000"
os.environ["E2B_API_KEY"] = "e2b_000000"

with Sandbox.create(template="<your-template-id>") as sandbox:
    result = sandbox.run_code("print('Hello from Cube Sandbox!')")
    print(result)
```

### 11.4 Known Ubuntu-Specific Considerations

| Issue | Solution |
|-------|----------|
| ext4 default for `/data/cubelet` | Reformat or mount XFS volume explicitly |
| systemd-resolved DNS | CubeProxy DNS integration works; use `networkmanager` or `standalone` dnsmasq mode |
| AppArmor blocking KVM | Ensure AppArmor allows `/dev/kvm` access |
| glibc compatibility | Binaries built on Ubuntu 20.04 (glibc 2.31); Ubuntu 24.04 has newer glibc — backward compatible |
| ARM64 PVM | Not supported; use bare-metal with native KVM |

---

## 12. Configuration Management

### 12.1 Environment Variables (Primary Control)

Configuration is driven by environment variables consumed by `install.sh` and runtime components:

| Variable | Description | Default |
|----------|-------------|---------|
| `ONE_CLICK_DEPLOY_ROLE` | Node role: `control` or `compute` | `control` |
| `CUBE_SANDBOX_NODE_IP` | Node IP for registration | Auto-detect `eth0` |
| `CUBE_SANDBOX_NETWORK_CIDR` | Sandbox IP allocation range | `192.168.0.0/18` |
| `CUBE_PROXY_ENABLE` | Enable reverse proxy | `1` |
| `CUBE_PROXY_HTTPS_PORT` | HTTPS listener port | `443` |
| `CUBE_PROXY_HTTP_PORT` | HTTP listener port | `80` |
| `CUBE_PROXY_DNS_ENABLE` | Enable internal DNS | `1` |
| `CUBE_SANDBOX_MYSQL_PORT` | MySQL port | `3306` |
| `CUBE_SANDBOX_REDIS_PORT` | Redis port | `6379` |
| `CUBE_SANDBOX_REDIS_PASSWORD` | Redis password | `ceuhvu123` |
| `CUBE_SANDBOX_MYSQL_ROOT_PASSWORD` | MySQL root password | `cube_root` |
| `CUBE_SANDBOX_MYSQL_DB` | MySQL database | `cube_mvp` |
| `CUBE_SANDBOX_MYSQL_USER` | MySQL user | `cube` |
| `CUBE_SANDBOX_MYSQL_PASSWORD` | MySQL password | `cube_pass` |
| `CUBE_PVM_ENABLE` | Enable PVM guest kernel | `0` |
| `CUBE_SANDBOX_CUBE_ROUTER_ENABLE` | Route-aware egress | `0` |
| `CUBE_EXTERNAL_MYSQL_HOST` | External MySQL host (optional) | — |
| `CUBE_EXTERNAL_REDIS_HOST` | External Redis host (optional) | — |

### 12.2 Runtime Configuration (`config-cube.toml`)

Used by `containerd-shim-cube-rs` to locate:
- Shim binary path
- `cube-runtime` path
- Guest kernel (`vmlinux`)
- Guest image (`cube-guest-image-cpu.img`)
- Guest init (`/sbin/init` inside image)

### 12.3 Three-Way Configuration Merge

The install system supports a layered configuration merge:
1. Built-in defaults
2. `env.example` (or user-provided env file)
3. Runtime environment overrides

This allows upgrades without losing customizations.

---

## 13. Integration Interfaces

### 13.1 E2B SDK Compatibility

CubeSandbox is API-compatible with E2B (Execution Environment for AI Agents):

| E2B Feature | CubeSandbox Support |
|-------------|---------------------|
| `Sandbox.create()` | ✅ Full support |
| `sandbox.run_code()` | ✅ Full support |
| `sandbox.filesystem.*` | ✅ Full support (v0.5.0+) |
| `sandbox.process.*` | ✅ Full support (v0.5.0+) |
| `sandbox.close()` | ✅ Full support |

**Migration:** Change only `E2B_API_URL` environment variable.

### 13.2 SDK Support

| SDK | Package | Status |
|-----|---------|--------|
| Python | `e2b-code-interpreter` | ✅ Compatible |
| Node.js | `e2b` | ✅ Compatible |
| Go | `github.com/e2b-dev/e2b` | ✅ Compatible |

### 13.3 API Endpoints

- **REST API:** Port `3000` (E2B-compatible)
- **gRPC (internal):** CubeMaster port `8089`
- **WebUI:** Port `12088`

---

## 14. Operational Model & Lifecycle

### 14.1 Sandbox Lifecycle States

```
CREATING → RUNNING → [PAUSED] → [RESUMED] → [SNAPSHOT] → DESTROYED
              ↑_________↓
```

- **AutoPause:** Idle sandboxes automatically suspend to disk (v0.5.0)
- **AutoResume:** Incoming requests trigger instant restoration from snapshot (v0.5.0)
- **Snapshot/Clone:** Hundred-millisecond checkpoints; fork from any saved state

### 14.2 Default Listening Ports

| Process | Default Bind | Port | Description |
|---------|-------------|------|-------------|
| CubeMaster | `0.0.0.0` | `8089` | Cluster management HTTP API |
| CubeAPI | `0.0.0.0` | `3000` | Sandbox lifecycle API (E2B-compatible) |
| Cubelet gRPC | `0.0.0.0` | `9999` | Node management RPC |
| Cubelet HTTP | `0.0.0.0` | `9998` | Debug / metrics |
| CubeProxy | `0.0.0.0` | `80` / `443` | Public-facing reverse proxy |
| WebUI | `0.0.0.0` | `12088` | Dashboard |
| MySQL | `127.0.0.1` | `3306` | Metadata database (loopback) |
| Redis | `127.0.0.1` | `6379` | State store (loopback) |

> ⚠️ **Production Warning:** One-click deployment binds management endpoints to `0.0.0.0` with no authentication or TLS by default. Production deployments must execute network hardening before exposing to untrusted networks.

### 14.3 Network Hardening Strategy

```bash
# .env file configuration for production
CUBEMASTER_HTTP_BIND=10.0.0.11          # Private NIC (multi-node)
CUBE_API_BIND=10.0.0.11:3000
CUBE_API_HEALTH_ADDR=10.0.0.11:3000
```

**Cubelet configuration** (`/Cubelet/config/config.toml`):
```toml
[http]
address = "10.0.0.11:9998"
[grpc]
address = "10.0.0.11:9999"
```

### 14.4 Health Checks & QuickCheck

The `install.sh` includes a `quickcheck` phase that probes:
- systemd units are active
- Health endpoints respond
- Sockets are listening
- Runtime files exist
- Node registration succeeds

Timeout: 120 seconds (configurable via `CUBE_QUICKCHECK_READY_TIMEOUT`)

### 14.5 Troubleshooting Checklist

- [ ] **System Requirements:** Verify Ubuntu 24.04.4, KVM availability, sufficient resources
- [ ] **Installation:** Check all components installed correctly (`systemctl status cube-*`)
- [ ] **Configuration:** Validate configuration files (`sudo cube-master config-validate`)
- [ ] **Network:** Verify network connectivity and policies (`sudo cube-master network-check`)
- [ ] **Templates:** Ensure templates are ready (`sudo cube-master template-list`)
- [ ] **Permissions:** Check file permissions and user groups
- [ ] **Logs:** Review component logs for errors (`sudo journalctl -u cube-*`)
- [ ] **API Access:** Test API endpoint (`curl http://localhost:3000/health`)
- [ ] **WebUI:** Verify WebUI accessibility (`http://your-ip:12088`)
- [ ] **Security:** Validate egress policies and credential vault
- [ ] **XFS:** Confirm `/data/cubelet` is XFS with reflink (`xfs_info /data/cubelet`)

---

## 15. Competitive Landscape & Positioning

### 15.1 CubeSandbox vs. Alternatives

| Feature | 🐳 Docker / gVisor | 💻 Traditional VMs | ⚡ CubeSandbox | 🔥 E2B (Firecracker) |
| :--- | :--- | :--- | :--- | :--- |
| **Isolation** | Shared Kernel (Escape risk) | Dedicated Kernel | Dedicated Kernel + eBPF | Dedicated Kernel (Firecracker) |
| **Startup** | ~200ms (Namespace setup) | Seconds (Full BIOS/OS boot) | **<60ms** (Pre-snapshotted restore) | ~150–200ms (Pre-warmed pools) |
| **Memory** | Low (Shared) | High (Full OS overhead) | **<5MB** (Aggressively stripped) | ~5MB (Firecracker) |
| **Snapshot/Clone** | Slow (Block-level copy) | Slow (VDI copy) | **O(1) via FICLONE CoW** | Fast (Snapshot pools) |
| **Egress Security** | Basic (IPTables) | Basic | **L7 MITM, Credential Vault, Auditing** | L7 filtering (managed) |
| **Distribution** | Self-hosted | Self-hosted | **Self-hosted (full stack)** | Managed SaaS + self-host |
| **E2B Compatible** | ❌ No | ❌ No | **✅ Drop-in** | ✅ Native |
| **Best For** | Trusted microservices | Multi-tenant enterprise | **Untrusted AI Agent code execution** | AI Agent code execution |

### 15.2 When to Choose CubeSandbox

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         DECISION FLOWCHART                               │
│                                                                          │
│   Need to run untrusted LLM-generated code?                              │
│       │                                                                  │
│       ├── Yes ──► Have KVM access or x86_64 cloud VM?                  │
│       │               │                                                    │
│       │               ├── Yes ──► ✅ USE CUBESANDBOX                     │
│       │               │                                                    │
│       │               └── No ──► ⚠️ Use PVM (x86_64 only) or           │
│       │                              bare metal / nested virt              │
│       │                                                                  │
│       └── No, trusted internal code ──► 🐳 Stick to Docker / K8s         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### 15.3 Pros & Cons

#### ✅ Pros
- **Unbeatable Speed:** Cold starts under 60ms enable real-time, interactive AI agent workflows
- **Ironclad Security:** KVM hardware isolation + eBPF network policies prevent container escapes
- **Resource Efficiency:** Run thousands of sandboxes on a single bare-metal node
- **Stateful Magic:** CubeCoW allows instantaneous cloning and rollback of running environments
- **Zero-Code Migration:** E2B SDK drop-in compatibility
- **Open Source:** Full stack under Apache 2.0; no vendor lock-in

#### ❌ Cons & Trade-offs
- **Hardware Dependency:** Requires KVM access (`/dev/kvm`). Fails on standard cheap cloud VMs unless using PVM (x86_64 only) or bare metal
- **Ecosystem Maturity:** As a newer open-source project (launched April 2026), it lacks the massive community tooling and battle-tested edge cases of Docker/Kubernetes
- **Operational Complexity:** Managing RustVMM, eBPF policies, OpenResty proxies, and Go control planes requires specialized Linux systems knowledge
- **ARM64 Limitations:** PVM workaround for cloud VMs without native KVM is x86_64 only; ARM64 requires bare metal with native KVM
- **Storage Requirement:** Mandates XFS with reflink — incompatible with default ext4 on Ubuntu

---

## 16. Appendix

### 16.1 Repository Structure

```
CubeSandbox/
├── CubeAPI/                 # Rust REST API gateway
├── CubeEgress/              # OpenResty + Lua L7 proxy
├── CubeMaster/              # Go orchestrator
├── CubeNet/                 # CubeVS eBPF networking
├── CubeProxy/               # OpenResty reverse proxy + Go sidecar
├── CubeShim/                # Rust containerd shim v2
├── Cubelet/                 # Go node agent
├── agent/                   # Rust guest agent (cube-agent)
├── configs/                 # Configuration templates
├── cube-lifecycle-manager/  # Go auto-pause/resume service
├── cubecow/                 # Rust CoW storage library
├── cubelog/                 # Rust logging library
├── deploy/                  # Deployment scripts & assets
│   ├── guest-image/         # Guest VM Dockerfile
│   ├── one-click/           # One-click installer
│   └── pvm/                 # PVM kernel build scripts
├── docs/                    # Documentation
├── examples/                # Integration examples
├── hypervisor/              # RustVMM-based VMM
├── network-agent/           # Go network control plane
├── sdk/                     # SDKs (Go, Node, Python)
├── scripts/                 # Helper scripts
└── web/                     # WebUI frontend
```

### 16.2 Key Configuration Files

| File | Purpose |
|------|---------|
| `deploy/one-click/env.example` | Master environment configuration template |
| `deploy/one-click/config-cube.toml` | containerd shim runtime configuration |
| `deploy/one-click/cubeproxy/global.conf.template` | OpenResty global config |
| `deploy/one-click/coredns/Corefile.template` | CoreDNS configuration |
| `deploy/one-click/systemd/*.service` | systemd unit templates |
| `deploy/one-click/docker-compose.yaml.template` | Support services composition |

### 16.3 Glossary

| Term | Definition |
|------|------------|
| **MicroVM** | Lightweight virtual machine using KVM, optimized for fast boot |
| **PVM** | Pseudo-Virtual Machine — Tencent's kernel module for enabling KVM on cloud VMs without nested virtualization (x86_64 only) |
| **CoW** | Copy-on-Write — storage optimization for instant cloning |
| **Reflink** | XFS feature enabling O(1) file cloning |
| **eBPF** | Extended Berkeley Packet Filter — kernel bytecode for custom data plane logic |
| **TC** | Traffic Control — Linux kernel subsystem for packet scheduling/filtering |
| **TAP** | Virtual network interface for bridging VMs to host network |
| **TPROXY** | Transparent proxy — Linux mechanism for intercepting traffic without NAT |
| **vsock** | Virtual socket — host-guest communication channel for VMs |
| **Shim v2** | containerd runtime interface for custom container backends |
| **RustVMM** | Collection of Rust crates for building VMMs (includes Cloud Hypervisor components) |
| **FICLONE** | Linux ioctl for reflink-based file cloning (XFS) |
| **LPM Trie** | Longest Prefix Match trie — efficient IP prefix matching in eBPF |
| **SNAT** | Source Network Address Translation |
| **DNAT** | Destination Network Address Translation |
| **Seccomp** | Secure computing mode — kernel feature restricting syscalls |

### 16.4 Additional Resources

- **GitHub Repository:** [https://github.com/TencentCloud/CubeSandbox](https://github.com/TencentCloud/CubeSandbox)
- **Documentation:** [https://docs.cubesandbox.ai/](https://docs.cubesandbox.ai/)
- **Quick Start Guide:** [https://github.com/TencentCloud/CubeSandbox/blob/master/docs/guide/quickstart.md](https://github.com/TencentCloud/CubeSandbox/blob/master/docs/guide/quickstart.md)
- **Architecture Overview:** [https://github.com/TencentCloud/CubeSandbox/blob/master/docs/architecture/overview.md](https://github.com/TencentCloud/CubeSandbox/blob/master/docs/architecture/overview.md)
- **Releases:** [https://github.com/TencentCloud/CubeSandbox/releases](https://github.com/TencentCloud/CubeSandbox/releases)
- **Contributing:** [https://github.com/TencentCloud/CubeSandbox/blob/master/CONTRIBUTING.md](https://github.com/TencentCloud/CubeSandbox/blob/master/CONTRIBUTING.md)
- **License:** Apache 2.0

### 16.5 Acknowledgments

CubeSandbox stands on the shoulders of open-source giants. Special thanks to:
- **Cloud Hypervisor** — Rust VMM foundation
- **Kata Containers** — Container runtime integration patterns
- **virtiofsd** — Virtio filesystem daemon
- **containerd-shim-rs** — Rust shim v2 implementation
- **ttrpc-rust** — Rust ttrpc implementation

All original in-file copyright notices are preserved in the CubeSandbox codebase.

---

*End of Design Blueprint*

---

> **Disclaimer:** This blueprint is a synthesized architectural reference derived from the Tencent Cloud CubeSandbox open-source project (Apache 2.0). It is intended for educational and deployment planning purposes. Always refer to the official GitHub repository and documentation for the latest updates, security advisories, and release notes before production deployment.
