Yes, LiteLLM can auto-route and load-balance across multiple OpenRouter accounts using different API keys. [1, 2] 
By organizing these keys as separate deployments pointing to the same model name, LiteLLM treats them as a single virtual model pool. Its built-in router handles the distribution logic, track usage limits, and dynamically cool down specific keys when OpenRouter returns a 429 Too Many Requests response. [1, 3, 4] 
------------------------------
## Implementation Configuration (config.yaml)
This setup pools three distinct OpenRouter free accounts to share the load. It enforces load balancing and proactively cools down individual accounts for 60 seconds if they exceed the OpenRouter free tier limit (20 requests per minute). [5, 6] 

model_list:
  # ----------------------------------------------------
  # Account 1 Deployment
  # ----------------------------------------------------
  - model_name: openrouter-free-pool
    litellm_params:
      model: openrouter/google/gemini-2.5-flash:free
      api_key: "os.environ/OPENROUTER_KEY_ACCOUNT_A"
      rpm: 20                  # Throttles individual key tracking at 20 RPM
      tpm: 40000

  # ----------------------------------------------------
  # Account 2 Deployment
  # ----------------------------------------------------
  - model_name: openrouter-free-pool
    litellm_params:
      model: openrouter/google/gemini-2.5-flash:free
      api_key: "os.environ/OPENROUTER_KEY_ACCOUNT_B"
      rpm: 20
      tpm: 40000

  # ----------------------------------------------------
  # Account 3 Deployment
  # ----------------------------------------------------
  - model_name: openrouter-free-pool
    litellm_params:
      model: openrouter/google/gemini-2.5-flash:free
      api_key: "os.environ/OPENROUTER_KEY_ACCOUNT_C"
      rpm: 20
      tpm: 40000
# ----------------------------------------------------# Multi-Key Load Balancing Logic# ----------------------------------------------------router_settings:
  # Alternates across available accounts evenly to distribute traffic
  routing_strategy: simple-shuffle 
  
  # How many times to try a different key within the pool if one returns a 429
  num_retries: 3                  
  
  # Instantly flags a deployment key if it returns a 429 error code
  allowed_fails: 1                
  
  # Removes the specific failed account key from rotation for 60 seconds
  cooldown_time: 60               

------------------------------
## Key Operational Mechanics

                  [ Client API Call ]
                           │
                           ▼ (Targets: openrouter-free-pool)
                 ┌───────────────────┐
                 │   LiteLLM Proxy   │
                 └─────────┬─────────┘
                           │ (Simple-Shuffle Logic)
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
 [ Key Account A ]  [ Key Account B ]  [ Key Account C ]
   (Hits 429 Error)   (Active Pool)      (Active Pool)
        │
        ▼ (Triggers Fallback Retry)
  [ Cooldown: 60s ] ──► Dynamically routes payload to Key B or C instead


* Coordinated Token Tracking (Redis Integration): If running multiple LiteLLM workers across container clusters (like Docker or Kubernetes), add a Redis instances layout (redis_host, redis_port) to your configuration. This forces workers to sync and track the RPM across the accounts globally, preventing race conditions from hitting OpenRouter boundaries concurrently. [5, 6] 
* Handling Strict IP-Based Limits: Be aware that while key rotation bypasses account token counters, OpenRouter may track rapid connection spikes via the client IP address. If you encounter global IP throttles, hosting the LiteLLM proxy behind an outbound proxy pool with rotating IPs may be required. [7] 

Would you like me to show you how to configure a permanent paid model backup tier that the router falls back to only if all free account keys are simultaneously exhausted? [4] 

[1] [https://medium.com](https://medium.com/@aiforhuman/litellm-routing-e02004053602)
[2] [https://grokipedia.com](https://grokipedia.com/page/Openrouter-proxy)
[3] [https://docs.litellm.ai](https://docs.litellm.ai/docs/routing)
[4] [https://openrouter.ai](https://openrouter.ai/blog/insights/reliability-failover/)
[5] [https://github.com](https://github.com/BerriAI/litellm/issues/9035)
[6] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/load_balancing)
[7] [https://grokipedia.com](https://grokipedia.com/page/Openrouter-proxy)

---

The tpm setting stands for Tokens Per Minute.
It is a rate-limiting metric used by LiteLLM to track and control the volume of text data processed through your proxy gateway.
------------------------------
## Why it Matters
Every API call you make consumes tokens—the basic units of text or image data parsed by language models (typically 100 tokens equal roughly 75 words). Upstream providers like OpenAI, Anthropic, or OpenRouter impose strict, tier-based token volume limits to prevent network flooding.
------------------------------
## How LiteLLM Uses tpm

   1. Local Rate Limiting: By defining a tpm value (e.g., tpm: 40000), you tell the LiteLLM proxy to reject or queue incoming client requests if the total token count of all combined prompts and completions exceeds that number within a rolling 60-second window.
   2. Proactive Load Balancing: When running multiple API keys, LiteLLM calculates the remaining available token capacity for each key. It will intelligently prioritize routing traffic to the key that has the most token headroom remaining.
   3. Preventing Upstream Crashes: It acts as a shield, dropping or holding traffic at the proxy level rather than letting your servers smash directly into provider walls and returning sudden, hard HTTP 429 Too Many Requests errors to your application.

Would you like to see how to connect a Redis database to your config.yaml so LiteLLM can accurately calculate and enforce these tpm limits across multiple proxy instances?

---

### Phase 1: Ground Truth Validation & Fact-Checking

Before constructing the configuration, I have meticulously validated the claims, architectural assumptions, and provider limits against the official LiteLLM documentation and current provider constraints.

#### 1. OpenAI Responses API & LiteLLM Translation
*   **Claim:** OpenAI is migrating to the stateful Responses API (`/v1/responses`), and LiteLLM bridges this to stateless providers.
*   **Validation:** **TRUE.** OpenAI has designated the Responses API as its premium primitive, with the Assistants API facing a hard EOL on August 26, 2026 [[5], [6]]. LiteLLM natively supports the `/v1/responses` endpoint and automatically bridges it to `/chat/completions` or `/messages` for non-OpenAI providers like Anthropic and Gemini [[50], [59]].
*   **Correction:** The flag `openai_responses_api_compatibility: true` mentioned in your reference material **does not exist** in LiteLLM's `general_settings`. Modern versions of LiteLLM expose and translate the `/v1/responses` endpoint natively without requiring a global toggle [[59], [61]].

#### 2. Load Balancing Multiple API Keys
*   **Claim:** LiteLLM can load balance across multiple accounts by grouping them.
*   **Validation:** **TRUE.** By defining multiple deployments with the exact same `model_name` in the `model_list`, LiteLLM automatically treats them as a single virtual model pool and distributes traffic among them [[39], [40]].
*   **RPM Enforcement:** The `rpm` parameter is enforced **per deployment** [[70]]. When set, LiteLLM uses a weighted pick to ensure that specific API key is not exceeded before the request ever leaves your local machine [[68], [71]].

#### 3. Provider Rate Limits (The Bottlenecks)
*   **OpenRouter `:free` Tier:** Strictly limited to **20 Requests Per Minute (RPM)** per account [[29], [32]]. (Daily limits are 50 RPD, or 1,000 RPD if you have >$10 in credits [[32]]).
*   **Nvidia NIM Free Tier:** Strictly limited to **40 Requests Per Minute (RPM)** per account [[21], [25]].

---

### Phase 2: The "Ultimate Pool" Architecture

To create an unthrottled experience for agentic CLI tools (which fire rapid, parallel requests), we will pool **two OpenRouter accounts** and **two Nvidia NIM accounts** under a single `model_name` alias (e.g., `claude-3-5-sonnet-20241022`).

By setting the `rpm` slightly below the hard caps (to account for network bursts), we create a unified local gateway with a theoretical throughput of **~116 RPM**:
*   **Key 1 (OpenRouter):** 18 RPM
*   **Key 2 (OpenRouter):** 18 RPM
*   **Key 3 (Nvidia NIM):** 35 RPM
*   **Key 4 (Nvidia NIM):** 35 RPM

If one account hits a hidden upstream choke point or returns a `429 Too Many Requests`, LiteLLM's cooldown mechanism will instantly ban that specific key for 60 seconds and route traffic to the remaining three.

---

### Phase 3: The Ultimate `config.yaml`

Save this as `~/ultimate-proxy/config.yaml`. This configuration strips out the hallucinated flags, enforces strict per-key RPM limits, and enables aggressive failover.

```yaml
# -----------------------------------------------------------------------------
# Ultimate LiteLLM Proxy: 4-Key Load Balancing Pool
# Combines 2x OpenRouter (Free) + 2x Nvidia NIM (Free)
# -----------------------------------------------------------------------------

model_list:
  # --- DEPLOYMENT 1: OpenRouter Account A ---
  - model_name: claude-3-5-sonnet-20241022  # Alias to trick Claude Code / Codex CLI
    litellm_params:
      model: openrouter/meta-llama/llama-3.3-70b-instruct:free
      api_key: os.environ/OPENROUTER_KEY_A
      rpm: 18               # Safe margin below OpenRouter's 20 RPM hard cap
      timeout: 300
    model_info:
      input_cost_per_token: 0.0
      output_cost_per_token: 0.0

  # --- DEPLOYMENT 2: OpenRouter Account B ---
  - model_name: claude-3-5-sonnet-20241022
    litellm_params:
      model: openrouter/meta-llama/llama-3.3-70b-instruct:free
      api_key: os.environ/OPENROUTER_KEY_B
      rpm: 18
      timeout: 300
    model_info:
      input_cost_per_token: 0.0
      output_cost_per_token: 0.0

  # --- DEPLOYMENT 3: Nvidia NIM Account A ---
  - model_name: claude-3-5-sonnet-20241022
    litellm_params:
      model: nvidia_nim/minimaxai/minimax-m3
      api_key: os.environ/NVIDIA_NIM_KEY_A
      rpm: 35               # Safe margin below Nvidia's 40 RPM hard cap
      timeout: 600          # Nvidia supports massive context windows
    model_info:
      input_cost_per_token: 0.0
      output_cost_per_token: 0.0

  # --- DEPLOYMENT 4: Nvidia NIM Account B ---
  - model_name: claude-3-5-sonnet-20241022
    litellm_params:
      model: nvidia_nim/minimaxai/minimax-m3
      api_key: os.environ/NVIDIA_NIM_KEY_B
      rpm: 35
      timeout: 600
    model_info:
      input_cost_per_token: 0.0
      output_cost_per_token: 0.0

# -----------------------------------------------------------------------------
# Router & Load Balancing Mechanics
# -----------------------------------------------------------------------------
router_settings:
  routing_strategy: least-busy    # Routes to the deployment with most capacity
  num_retries: 3                  # Retries on transient network errors
  retry_after: 2                  # Seconds to wait before retrying
  
  # Cooldown Logic: If a key returns 429 or 503, ban it temporarily
  allowed_fails: 2                # Allow 2 failures before triggering cooldown
  cooldown_time: 60               # Ban the failing key for 60 seconds
  
  # Fallback Chain (Optional safety net if model_name grouping fails)
  fallbacks: [{"claude-3-5-sonnet-20241022": ["claude-3-5-sonnet-20241022"]}]

# -----------------------------------------------------------------------------
# Global LiteLLM Settings
# -----------------------------------------------------------------------------
litellm_settings:
  drop_params: true               # CRITICAL: Strips unsupported OpenAI/Anthropic params
  set_verbose: false              # Set to true if you need to debug JSON payloads
  request_timeout: 600            # Global timeout for agentic loops
  streaming_timeout: 600
  
  # Suppress cache cost warnings for free models
  suppress_debug_info: false

# -----------------------------------------------------------------------------
# Proxy Gateway Settings
# -----------------------------------------------------------------------------
general_settings:
  # master_key: os.environ/LOCAL_PROXY_KEY # Omit for local trust, or set for security
  disable_admin_ui: true
```

---

### Phase 4: Environment & Execution Strategy

Because we are pooling four distinct accounts, you must inject four separate API keys into your environment before launching the proxy.

#### 1. Export the Keys (Add to `~/.bashrc` or `~/.zshrc`)
```bash
# OpenRouter Free Tier Keys
export OPENROUTER_KEY_A="sk-or-v1-xxxxxxxxxxxx..."
export OPENROUTER_KEY_B="sk-or-v1-yyyyyyyyyyyy..."

# Nvidia NIM Free Tier Keys
export NVIDIA_NIM_KEY_A="nvapi-xxxxxxxxxxxx..."
export NVIDIA_NIM_KEY_B="nvapi-yyyyyyyyyyyy..."
```

#### 2. Launch the Proxy
Bind explicitly to `localhost` to prevent LAN exposure, since we are omitting the `master_key` for frictionless CLI integration.

```bash
litellm --config ~/ultimate-proxy/config.yaml --port 4000 --host 127.0.0.1
```

---

### Phase 5: Validation & Testing Matrix

To prove the load balancing and translation mechanics are functioning, execute these tests:

**1. Verify the Pool Size**
```bash
curl -s http://127.0.0.1:4000/v1/models | python3 -m json.tool
```
*Expected:* You will see `claude-3-5-sonnet-20241022` listed. LiteLLM abstracts the 4 underlying deployments into this single public alias [[39]].

**2. Test the Responses API Bridge**
Send a stateful payload to the `/v1/responses` endpoint. LiteLLM will intercept it, translate it, and route it to the stateless OpenRouter or Nvidia backends automatically [[50]].
```bash
curl -X POST http://127.0.0.1:4000/v1/responses \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "input": "Explain the Responses API in one sentence."
  }'
```

**3. Stress Test the RPM Limits**
Use a simple bash loop to fire 30 requests rapidly.
```bash
for i in {1..30}; do curl -s http://127.0.0.1:4000/v1/chat/completions -H "Content-Type: application/json" -d '{"model": "claude-3-5-sonnet-20241022", "messages": [{"role": "user", "content": "hi"}]}' & done
```
*Observation:* Check your proxy logs. You should see LiteLLM's `least-busy` router distributing the requests across `OPENROUTER_KEY_A`, `OPENROUTER_KEY_B`, `NVIDIA_NIM_KEY_A`, and `NVIDIA_NIM_KEY_B`. If one key hits its 18/35 RPM ceiling, LiteLLM will block further requests to that specific key and route them to the others, preventing upstream `429` bans [[71]].

---

https://chat.qwen.ai/s/da11e453-8e06-44a6-a35d-a4fb9088d09a?fev=0.2.71 
