To configure a [LiteLLM Proxy](https://docs.litellm.ai/docs/proxy/configs) server to route traffic through [OpenRouter](https://openrouter.ai/blog/insights/openrouter-vs-litellm/), you must map your custom model names to OpenRouter’s upstream identifiers. [1, 2, 3] 
A comprehensive config.yaml blueprint maps models, injects API credentials via environment variables, enables Anthropic extended thinking, manages timeouts, and controls token fallback rules. [1, 4, 5] 
## Complete Production config.yaml Blueprint

model_list:
  # 1. Standard Text/Chat Model Mapping
  - model_name: openrouter-gpt-4o
    litellm_params:
      model: openrouter/openai/gpt-4o
      api_key: "os.environ/OPENROUTER_API_KEY"
      rpm: 200                         # Optional: Rate limit per minute
      timeout: 30                      # Optional: Request timeout in seconds

  # 2. Advanced Anthropic Model with Extended Thinking
  - model_name: openrouter-claude-thinking
    litellm_params:
      model: openrouter/anthropic/claude-3.7-sonnet
      api_key: "os.environ/OPENROUTER_API_KEY"
      # Forward provider-specific flags directly to OpenRouter
      thinking:
        type: "enabled"
        budget_tokens: 4000            # Dedicate a slice of max_tokens for reasoning

  # 3. Dynamic Model Routing (Passes through requested string directly to OpenRouter)
  - model_name: openrouter/*
    litellm_params:
      model: openrouter/*
      api_key: "os.environ/OPENROUTER_API_KEY"
router_settings:
  routing_strategy: "latency-based"    # Routes traffic based on lowest round-trip times
  num_retries: 3                       # Retries upstream if OpenRouter drops a request
  fallbacks:                           # Automatic fallback if your chosen model returns errors
    - openrouter-gpt-4o: ["openrouter-claude-thinking"]
litellm_settings:
  drop_params: true                    # Automatically strips client parameters unsupported by OpenRouter
  set_verbose: false                   # Change to true to debug underlying API headers
general_settings:
  master_key: "os.environ/LITELLM_MASTER_KEY" # Secure key used to connect your local clients to LiteLLM

------------------------------
## Critical Settings Deep Dive## 1. The model Naming Convention
To trigger LiteLLM's specialized OpenRouter integration, the model parameter inside litellm_params must be prefixed with openrouter/ followed by the native OpenRouter model string (e.g., openrouter/meta-llama/llama-3.3-70b-instruct). [6] 

* Avoid using custom_llm_provider: "openrouter" inside your configurations. This can introduce strict routing errors across certain minor proxy releases. Instead, embed the provider namespace natively in the string format. [6, 7, 8] 

## 2. Dynamic Wildcard Catch-Alls (openrouter/*)
Maintaining massive YAML configurations for every open-source model released can cause config fatigue. By declaring a wildcard route (openrouter/*), any client request sent to your proxy containing openrouter/google/gemini-2.5-pro will automatically have its string forwarded verbatim to OpenRouter without requiring an explicit static declaration.
## 3. Handling Anthropic Extended Thinking
When calling modern reasoning models through OpenRouter (such as Claude 3.7 Sonnet), you must explicitly manage your thinking budgets. By packing the thinking parameters under litellm_params, LiteLLM passes the specific instruction block directly to OpenRouter so that it does not drop your reasoning tokens mid-stream. [5] 
## 4. Setting drop_params: true
Client applications (like LibreChat or Open WebUI) often bundle OpenAI-specific query flags like frequency_penalty or user tags. If these flags are forwarded blindly to certain open-source backends on OpenRouter, they will trigger a 400 Bad Request. Enabling drop_params: true ensures LiteLLM acts as a scrub buffer, automatically filtering non-standard keys before they reach the endpoint. [9, 10, 11, 12, 13] 
------------------------------
## Launching the Proxy
To protect your secrets, never hardcode actual API strings into your YAML files. Inject them using os.environ/ and pass them during runtime deployment: [14, 15] 

export OPENROUTER_API_KEY="sk-or-v1-xxxxxxxxxxxx..."
export LITELLM_MASTER_KEY="sk-mylocalproxykey123"
# Start via CLI
litellm --config config.yaml

If you want, I can:
Show you how to set up Redis caching to save costs on redundant queriesConfigure Langfuse tracking to monitor OpenRouter token spendWrite a Docker Compose template to host this proxy seamlessly

[1] [https://railway.com](https://railway.com/deploy/Lm9gxI)
[2] [https://medium.com](https://medium.com/@fengliplatform/claude-code-using-litellm-to-access-openrouter-models-bd5ee95a1e55)
[3] [https://github.com](https://github.com/BerriAI/litellm/issues/29844)
[4] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/pass_through)
[5] [https://www.youtube.com](https://www.youtube.com/watch?v=4gR8BqhBtpk&t=216)
[6] [https://docs.litellm.ai](https://docs.litellm.ai/docs/providers/openrouter)
[7] [https://github.com](https://github.com/BerriAI/litellm/issues/22667)
[8] [https://github.com](https://github.com/BerriAI/litellm/issues/25629)
[9] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/configs)
[10] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/config_settings)
[11] [https://www.librechat.ai](https://www.librechat.ai/docs/configuration/librechat_yaml/ai_endpoints/litellm)
[12] [https://robert-mcdermott.medium.com](https://robert-mcdermott.medium.com/centralizing-multi-vendor-llm-services-with-litellm-9874563f3062)
[13] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/custom_auth)
[14] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/docker_quick_start)
[15] [https://www.linkedin.com](https://www.linkedin.com/pulse/running-litellm-proxy-front-multiple-model-providers-gary-stafford-o38qc)

---

OpenRouter calculates rate limits for free model variants (model IDs ending in :free) based on a combination of concurrency caps and your account's financial history. [1] 
The official OpenRouter free model rate limits map out as follows:
## 📊 The Rate Limit Tiers

| Parameter [1, 2, 3] | Unpaid / New Accounts (< $10 purchased) | Paid Accounts (≥ $10 lifetime credit purchase) |
|---|---|---|
| Requests Per Minute (RPM) | 20 RPM | 20 RPM |
| Requests Per Day (RPD) | 50 RPD | 1,000 RPD |
| Failed Requests Count? | Yes (counts toward daily quota) | Yes (counts toward daily quota) |

------------------------------
## 🔍 Key Nuances & Hidden Constraints## 1. The $10 Unlock Trigger
To bump your daily allowance from 50 to 1,000 requests on free models, you must purchase at least $10 worth of platform credits. This is not a monthly subscription fee; it is a permanent one-time or pay-as-you-go top-up that unlocks the higher free-tier ceiling. [1, 4, 5, 6] 
## 2. Upstream Provider Choke Points
Even if your OpenRouter dashboard shows you have remaining requests within your 20 RPM limit, the individual underlying provider hosting that free model (e.g., Lepton, Together AI, Novita) might be heavily congested. During peak hours, you may encounter 429 Too Many Requests or 503 Service Unavailable errors generated directly by the host, completely independent of OpenRouter's limits. [2, 3, 7, 8, 9] 
## 3. Tracking Your Real-Time Quota
You can dynamically check your exact remaining daily limits and minute limits by making a GET request from your code to OpenRouter's key status endpoint: [1] 

curl -X GET "https://openrouter.ai/api/v1/key" \
  -H "Authorization: Bearer YOUR_OPENROUTER_API_KEY"

------------------------------
## 🛠️ Developer Mitigation Strategies (for LiteLLM Proxy)
If you are running the free models via a local proxy config, implement these architectural workarounds to handle the tight 50–1,000 RPD limits:

* Implement Model Rotation: Free tiers are calculated per account, but upstream provider errors are often model-specific. Group multiple free alternatives (e.g., meta-llama/llama-3.3-70b-instruct:free, qwen/qwen-2.5-72b-instruct:free, and deepseek/deepseek-r1:free) into a LiteLLM fallback array. [7, 10, 11, 12] 
* Enforce Client-Side Throttling: Set your proxy config's client-facing limit to rpm: 15 instead of 20 to account for network bursts and prevent abrupt rate-limiting drops.

Would you like to see how to configure LiteLLM's automatic retry back-off loop specifically to catch OpenRouter 429 errors? [3] 

[1] [https://openrouter.ai](https://openrouter.ai/docs/api/reference/limits)
[2] [https://openrouter.ai](https://openrouter.ai/pricing)
[3] [https://openrouter.zendesk.com](https://openrouter.zendesk.com/hc/en-us/articles/39501163636379-OpenRouter-Rate-Limits-What-You-Need-to-Know)
[4] [https://www.reddit.com](https://www.reddit.com/r/openrouter/comments/1mdwxmr/do_i_need_any_minimum_credits_to_use_free_models/)
[5] [https://www.reddit.com](https://www.reddit.com/r/openrouter/comments/1sin0fx/whats_wrong_with_free_models_every_decent_option/)
[6] [https://openrouter.ai](https://openrouter.ai/blog/tutorials/sillytavern-openrouter/)
[7] [https://www.datastudios.org](https://www.datastudios.org/post/openrouter-rate-limits-explained-request-caps-free-model-limits-provider-quotas-scaling-issues)
[8] [https://ofox.ai](https://ofox.ai/blog/openrouter-alternatives-2026/)
[9] [https://openrouter.zendesk.com](https://openrouter.zendesk.com/hc/en-us/articles/39501163636379-OpenRouter-Rate-Limits-What-You-Need-to-Know)
[10] [https://www.mindstudio.ai](https://www.mindstudio.ai/blog/open-router-free-models-claude-code-cost-reduction)
[11] [https://openrouter.ai](https://openrouter.ai/docs/guides/routing/routers/free-router)
[12] [https://openrouter.ai](https://openrouter.ai/meta-llama/llama-3.3-70b-instruct:free)

---

No, OpenRouter will not deduct from your $10 in credits as long as you strictly call models ending with the :free suffix. [1, 2] 
The $10 top-up functions purely as an identity verification mechanism and account milestone. The credits will sit securely in your balance wallet and remain untouched until you intentionally choose to route a query to a paid model. [1, 2, 3, 4] 
## Crucial Safety Check for LiteLLM
If your goal is to utilize the expanded 1,000 requests/day tier without touching your $10 balance, ensure your config.yaml points exactly to the free variants: [1, 2, 3] 

* ⚠️ Incorrect (Deducts Credits): model: openrouter/meta-llama/llama-3.3-70b-instruct
* ✅ Correct (Completely Free): model: openrouter/meta-llama/llama-3.3-70b-instruct:free [2, 5] 

Note: If you query a paid model variant by accident, OpenRouter will automatically start pulling money from that $10 balance per token. [3, 6] 
Would you like help setting up a spending alert or hard quota cap inside OpenRouter's dashboard to guarantee your $10 is never accidentally depleted? [7] 

[1] [https://www.reddit.com](https://www.reddit.com/r/JanitorAI_Official/comments/1knyp66/deepseek_tutorial_easy_and_quick/)
[2] [https://buldrr.com](https://buldrr.com/openrouter-free-api-keys-free-models-simple-guide/)
[3] [https://www.reddit.com](https://www.reddit.com/r/openrouter/comments/1sasps8/how_does_10_openrouter_work/)
[4] [https://www.reddit.com](https://www.reddit.com/r/openrouter/comments/1mdwxmr/do_i_need_any_minimum_credits_to_use_free_models/)
[5] [https://klymentiev.com](https://klymentiev.com/blog/openrouter-free-tier)
[6] [https://openrouter.ai](https://openrouter.ai/support)
[7] [https://sidsaladi.substack.com](https://sidsaladi.substack.com/p/openrouter-101-the-complete-guide)

---

Yes, you can safely omit the rpm setting under model_list in LiteLLM. [1] 
By default, LiteLLM does not require an rpm cap to function; it will simply forward as many requests as your client applications throw at it until OpenRouter itself blocks the traffic.
However, completely omitting the rpm setting introduces specific structural risks to your local setup:
## Why Keeping a Soft rpm Cap is Recommended
Even with the $10 unlock trigger bumping your daily allowance to 1,000 requests, OpenRouter still enforces a strict 20 Requests Per Minute (RPM) ceiling on all :free models. [2, 3] 
If you omit the parameter, the following complications can occur:

   1. Proxy-Level 429 Flooding: If multiple users or an automated agent script bombard your LiteLLM proxy with 30 requests in a single minute, LiteLLM will blindly pass them all to OpenRouter. OpenRouter will reject 10 of those requests with a 429 Too Many Requests error. [1, 4] 
   2. Wasteful Fallback Triggers: If you have configured automated fallbacks in LiteLLM, hitting OpenRouter's 20 RPM wall will trick LiteLLM into thinking a model is down. This causes unnecessary fallback routing to other models, which risks depleting your limits on secondary options faster. [1, 3] 

## The Recommended Setup
To keep your configuration clean while protecting your application from hitting OpenRouter's hard limits, configure a "soft cap" of rpm: 20 directly in LiteLLM: [2, 3] 

model_list:
  - model_name: openrouter-llama-free
    litellm_params:
      model: openrouter/meta-llama/llama-3.3-70b-instruct:free
      api_key: "os.environ/OPENROUTER_API_KEY"
      rpm: 20  # Matches OpenRouter's maximum allowable rate for free endpoints

By keeping this parameter, LiteLLM localizes queue management. Instead of making a wasteful roundtrip to OpenRouter only to receive an error, LiteLLM immediately queues or safely handles client requests locally as soon as the threshold is breached. [1, 5] 
If you want, I can show you how to write a global router_settings default block so you don't have to type the rpm: 20 line manually for every single free model in your list.

[1] [https://medium.com](https://medium.com/@aiforhuman/litellm-routing-e02004053602)
[2] [https://openrouter.ai](https://openrouter.ai/docs/api/reference/limits)
[3] [https://openrouter.ai](https://openrouter.ai/pricing)
[4] [https://openrouter.ai](https://openrouter.ai/docs/api/reference/errors-and-debugging)
[5] [https://www.requesty.ai](https://www.requesty.ai/blog/rate-limits-for-llm-providers-openai-anthropic-and-deepseek)

---

Yes, you can absolutely run multiple LiteLLM proxy instances. In fact, scaling out horizontally across multiple instances behind a load balancer is the standard best-practice architecture for production environments to handle high traffic and avoid a single point of failure. [1, 2] 
Because LiteLLM is natively stateless, you can easily run multiple replicas as long as you hook them up to a shared state layer. Here is a meticulous research breakdown and architectural blueprint on how to do this correctly. [1] 
------------------------------
## 🏗️ The Multi-Instance Architecture Blueprint
To run multiple instances without losing tracking functionality, your infrastructure must centralize its data using three key layers:

   1. A Shared Redis Layer: Centralizes real-time tracking for Tokens Per Minute (TPM), Requests Per Minute (RPM), key cooling periods, and model health stats across all proxy replicas. [1, 3] 
   2. A Shared PostgreSQL Database: Stores persistent virtual keys, team/org metadata, and user query spend history. [1, 4] 
   3. An External Load Balancer: Sits in front of your instances (e.g., Nginx, AWS ALB, Cloudflare, or an ingress controller) to distribute incoming application traffic. [1, 5, 6] 

                [ Client Applications ]
                         │
                         ▼
               [ Load Balancer (ALB / Nginx) ]
                /        │        \
               ▼         ▼         ▼
          [Instance 1] [Instance 2] [Instance 3]  <-- LiteLLM Proxies
               \         │         /
          ┌─────┴────────┼─────────┴─────┐
          ▼                              ▼
    [Shared Redis]              [Shared PostgreSQL]
 (RPM/TPM Rate Limits)        (Virtual Keys & Budgets)

------------------------------
## 🛠️ Step-by-Step Implementation Guide## Step 1: Update your config.yaml for Shared Tracking
Every LiteLLM proxy instance must utilize the exact same config.yaml. To ensure that instance #1 knows if instance #2 just consumed user quota, you must configure the global router_settings to leverage Redis. [3, 7] 

model_list:
  - model_name: openrouter-llama-free
    litellm_params:
      model: openrouter/meta-llama/llama-3.3-70b-instruct:free
      api_key: "os.environ/OPENROUTER_API_KEY"
      rpm: 20
router_settings:
  routing_strategy: "latency-based"
  redis_host: "os.environ/REDIS_HOST"
  redis_port: "os.environ/REDIS_PORT"
  redis_password: "os.environ/REDIS_PASSWORD"

## Step 2: Spin Up Your Infrastructure (Docker Compose Example)
Using a container orchestrator ensures your instances receive identical parameters. This docker-compose.yml blueprint provisions a Redis cache, a Postgres database, and scales up two parallel LiteLLM instances mapped behind an Nginx reverse proxy. [8, 9, 10] 

version: '3.8'
services:
  # 1. Central Database for Persistent Key Configurations
  postgres-db:
    image: postgres:16
    environment:
      POSTGRES_DB: litellm_db
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: securepassword123
    ports:
      - "5432:5432"

  # 2. Central Redis Cache for Shared RPM/TPM Rate Limiting
  redis-cache:
    image: redis:7
    command: redis-server --requirepass redissecure456
    ports:
      - "6379:6379"

  # 3. LiteLLM Proxy Instance #1
  litellm-proxy-1:
    image: ghcr.io/berriai/litellm:main-latest
    volumes:
      - ./config.yaml:/app/config.yaml
    environment:
      - DATABASE_URL=postgresql://admin:securepassword123@postgres-db:5432/litellm_db
      - REDIS_HOST=redis-cache
      - REDIS_PORT=6379
      - REDIS_PASSWORD=redissecure456
      - OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxx...
      - LITELLM_MASTER_KEY=sk-proxy-master-key
    command: ["--config", "/app/config.yaml", "--port", "4000"]
    depends_on:
      - postgres-db
      - redis-cache

  # 4. LiteLLM Proxy Instance #2 (Identical configuration, separate node)
  litellm-proxy-2:
    image: ghcr.io/berriai/litellm:main-latest
    volumes:
      - ./config.yaml:/app/config.yaml
    environment:
      - DATABASE_URL=postgresql://admin:securepassword123@postgres-db:5432/litellm_db
      - REDIS_HOST=redis-cache
      - REDIS_PORT=6379
      - REDIS_PASSWORD=redissecure456
      - OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxx...
      - LITELLM_MASTER_KEY=sk-proxy-master-key
    command: ["--config", "/app/config.yaml", "--port", "4000"]
    depends_on:
      - postgres-db
      - redis-cache

  # 5. Simple Nginx Load Balancer to split traffic 50/50
  load-balancer:
    image: nginx:alpine
    ports:
      - "8000:80"
    entrypoint: >
      sh -c "echo '
      upstream litellm_servers {
          server litellm-proxy-1:4000;
          server litellm-proxy-2:4000;
      }
      server {
          listen 80;
          location / {
              proxy_pass http://litellm_servers;
              proxy_set_header Host $$host;
              proxy_set_header X-Real-IP $$remote_addr;
          }
      }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"    depends_on:
      - litellm-proxy-1
      - litellm-proxy-2

------------------------------
## ⚠️ Pitfalls & Critical Production Requirements
If you proceed with deploying a multi-instance setup, keep these production caveats in mind:

* Upstream Connection Multiplying: LiteLLM creates a pooling layer inside each replica container. If your Postgres pool allows 10 connections per container, running 3 instances with 4 worker threads will quickly spike your active DB pool allocations ($3 \times 4 \times 10 = 120$ open database threads). Scale your shared database sizing accordingly. [11, 12, 13] 
* The Config Reload Synchronization Trap: If you modify your config.yaml on disk, you must trigger a rolling update or pod restart across all running instances. If instance #1 pulls a new YAML configuration while instance #2 runs on the old model mappings, your load balancer will throw uneven model errors to users. [5] 
* Graceful Shutdowns: Ensure your container lifecycle orchestrator allows for a healthy SIGTERM wait threshold. Because LLM requests heavily utilize streaming, abruptly dropping a container instance mid-stream without a graceful buffer will cleanly break client user experiences. [5] 

If you want, I can:
Provide a production Kubernetes Deployment / Helm configuration for this setupShow you how to set up Prometheus metrics to monitor instance traffic splitsDemonstrate how to scale instances dynamically using AWS Auto Scaling groups

[1] [https://medium.com](https://medium.com/data-science-collective/running-litellm-as-a-proxy-in-front-of-multiple-llm-providers-528f74ebb30b)
[2] [https://www.instagram.com](https://www.instagram.com/reel/DMFrBFpOOrC/)
[3] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/load_balancing)
[4] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/multi_tenant_architecture)
[5] [https://github.com](https://github.com/BerriAI/litellm/discussions/2032)
[6] [https://apxml.com](https://apxml.com/courses/how-to-build-a-large-language-model/chapter-29-serving-llms-at-scale/load-balancing-across-model-instances)
[7] [https://dev.to](https://dev.to/silverfoxai/litellm-proxy-setup-guide-for-macos-with-uv-beginner-friendly-pac)
[8] [https://nextagile.ai](https://nextagile.ai/blog/devops/container-orchestration/)
[9] [https://railway.com](https://railway.com/deploy/litellm-proxy)
[10] [https://docs.litellm.ai](https://docs.litellm.ai/docs/routing)
[11] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/prod)
[12] [https://docs.litellm.ai](https://docs.litellm.ai/docs/proxy/prod)
[13] [https://medium.com](https://medium.com/@orami98/the-n8n-scaling-reliability-guide-queue-mode-topologies-error-handling-at-scale-and-production-9f33b13d2be8)

---

Yes, you can absolutely run one LiteLLM instance on port 4000 and another on port 4001 on the exact same machine.
Since they run as completely independent processes, they will not conflict over networking ports.
## Option 1: Running via CLI
Open two separate terminal windows or run them in the background by manually assigning the ports with the --port flag:
Terminal 1 (Instance 1):

litellm --config config1.yaml --port 4000

Terminal 2 (Instance 2):

litellm --config config2.yaml --port 4001

------------------------------
## Option 2: Running via Docker Compose
If you prefer containerized management, you can map the internal container ports to different host ports (4000 and 4001) in a simple docker-compose.yml file:

version: '3.8'
services:
  litellm-proxy-4000:
    image: ghcr.io/berriai/litellm:main-latest
    volumes:
      - ./config.yaml:/app/config.yaml
    ports:
      - "4000:4000" # Maps local port 4000 to container port 4000
    command: ["--config", "/app/config.yaml", "--port", "4000"]

  litellm-proxy-4001:
    image: ghcr.io/berriai/litellm:main-latest
    volumes:
      - ./config.yaml:/app/config.yaml
    ports:
      - "4001:4001" # Maps local port 4001 to container port 4001
    command: ["--config", "/app/config.yaml", "--port", "4001"]

------------------------------
## ⚠️ Important: The Rate Limit Catch
If both ports (4000 and 4001) are querying your OpenRouter free models using the same API key, they will blindly compete for that 20 RPM (Requests Per Minute) limit.
Because they cannot naturally see each other's traffic trends in isolation, a heavy burst of requests sent to port 4000 will cause port 4001 to suddenly hit unexpected 429 Too Many Requests errors from OpenRouter.
If you want, I can show you how to link both local ports to a local Redis cache so they can intelligently share and respect the 20 RPM limit without breaking each other.

---

Your LiteLLM proxy instance on port 4001 successfully initialized and is online (Application startup complete.), but your logs reveal one critical security risk and four cost-tracking configuration warnings.
Here is a meticulous validation of your startup messages and how to fix them:
------------------------------
## 🚨 1. The Critical Security Risk

07:39:20 - LiteLLM Proxy:CRITICAL: proxy_server.py:4522 - LITELLM_MASTER_KEY is not set! All requests will be treated as INTERNAL_USER with no admin access. Set LITELLM_MASTER_KEY for production use.


* What it means: You did not set a master password/API key for your proxy wrapper. Anyone who can reach port 4001 on your machine or network can execute requests against your OpenRouter API key without authentication.
* The Fix: Before launching your proxy command, set the LITELLM_MASTER_KEY environment variable in your terminal:

export LITELLM_MASTER_KEY="your-secure-proxy-password-here"
/opt/venv/bin/python3 /opt/venv/bin/litellm --config /home/pete/nvidia-proxy/openrouter.yaml --port 4001


------------------------------
## ⚠️ 2. The Cost-Tracking Warnings

07:39:20 - LiteLLM:WARNING: utils.py:3007 - register_model: model=openrouter/tencent/hy3:free not in built-in cost map and no prefix/region variant matched; cache cost fields will default to 0...
07:39:20 - LiteLLM:WARNING: utils.py:3007 - register_model: model=4802fdb3e21bed99a90cb3f730b200b7c70dd3b64893af17ebb5a4561c540a35 not in built-in cost map...


* What it means: LiteLLM checks models against its internal pricing spreadsheet to calculate prompt and completion costs.
* For openrouter/tencent/hy3:free, it doesn't recognize the exact string to track prompt caching costs (it defaults to $0, which is perfectly safe for a free model anyway).
   * For strings like 4802fdb3..., it looks like a long hash ID or an internal provider identifier is being read as a model name inside your openrouter.yaml model list.
* The Fix: If you want accurate token metrics or to clear these warnings, define explicit model_info metadata inside your openrouter.yaml for these models:

model_list:
  - model_name: openrouter-hunyuan-free
    litellm_params:
      model: openrouter/tencent/hy3:free
      model_info:
        input_cost_per_token: 0.0
        output_cost_per_token: 0.0


------------------------------
## 3. The Initialization Summary

LiteLLM: Proxy initialized with Config, Set models:
    minimax-m3
    gpt-4o
    claude-3-5-sonnet-20241022


* What it means: This confirms LiteLLM successfully parsed and registered your primary custom routing mappings (minimax-m3, gpt-4o, and claude-3-5-sonnet-20241022). Your underlying clients can immediately target these three exact text strings on port 4001.

## Summary Status: SUCCESS WITH WARNINGS
Your server is running successfully on http://0.0.0.0:4001. If this is purely a local sandbox experiment, you can ignore the warnings. If this machine faces the internet, you should stop it immediately using CTRL+C and inject a LITELLM_MASTER_KEY.
If you want, I can help you update your openrouter.yaml structure to properly set up that master key block and clean out those rogue hash strings from your model list.

---

Based on a meticulous cross-examination of your openrouter.yaml syntax and the resulting startup log, your configuration contains one hidden typo that will break your API calls, syntactical redundancy, and one insecure omission.
Here is the full breakdown of issues found and how to fix them:
## ❌ 1. Breaking Defect: Environmental Variable Typo
Look closely at your api_key definition for all three models:

api_key: os.environ/OPENROUTR_API_KEY


* The Issue: You are missing the letter E at the end of OpenRouter (OPENROUTR instead of OPENROUTER).
* The Consequence: Unless you explicitly exported your token as export OPENROUTR_API_KEY="..." in your Linux environment, LiteLLM will fail to resolve the key at runtime. When a client attempts to query the proxy, LiteLLM will throw an authentication error because the variable string evaluates to None.

------------------------------
## ⚠️ 2. Syntax Defect: Duplicate thinking: Keys
Under both gpt-4o and claude-3-5-sonnet-20241022, you have an empty thinking: key directly duplicated above the active block:

      thinking:
      thinking:
        type: "enabled"


* The Issue: While standard YAML parsers usually overwrite the first key with the second one without crashing, duplicate keys are bad practice and can cause unpredictable dictionary parsing behaviors depending on the exact minor version of Python's PyYAML parser you are running.

------------------------------
## 🚨 3. Security Risk: Missing Master Key

07:44:30 - LiteLLM Proxy:CRITICAL: proxy_server.py:4522 - LITELLM_MASTER_KEY is not set!


* The Issue: Your general_settings block has the master key commented out (# master_key: os.environ/LOCAL_PROXY_KEY). Because the server binds to 0.0.0.0:4001, anyone on your local network (or the public internet if the port is port-forwarded) can freely make API calls through your proxy, exhausting your OpenRouter quota.

------------------------------
## 🔍 4. The Mystery Behind those Long Hash Warning Logs

register_model: model=ed2f8fc0bc1cc9b0b3fa0339090fc79031deff79... not in built-in cost map

You might wonder where those random hex hashes are coming from since they aren't explicitly typed in your model names.

* The Explanation: When you configure model_info manually inside a config.yaml, LiteLLM takes your custom properties, hashes the internal registration block to track it uniquely in its memory table, and assigns a temporary tracking ID. These warnings are completely benign; it's just LiteLLM letting you know it won't cross-reference those custom blocks with its global internal price spreadsheet.

------------------------------
## 🛠️ The Meticulously Corrected openrouter.yaml
To resolve all structural, typing, and syntax errors, update your file to match this validated schema:

# /home/pete/nvidia-proxy/openrouter.yaml# -----------------------------------------------------------------------------# LiteLLM Proxy configuration for routing local traffic to OpenRouter# -----------------------------------------------------------------------------
model_list:
  # --- Primary alias: minimax-m3 ---
  - model_name: minimax-m3
    litellm_params:
      model: openrouter/tencent/hy3:free
      api_key: os.environ/OPENROUTER_API_KEY  # FIXED: Added missing 'E'
      rpm: 10
      model_info:
        input_cost_per_token: 0.0
        output_cost_per_token: 0.0
      thinking:
        type: "enabled"

  # --- Optional convenience alias: gpt-4o ---
  - model_name: gpt-4o
    litellm_params:
      model: openrouter/tencent/hy3:free
      api_key: os.environ/OPENROUTER_API_KEY  # FIXED: Added missing 'E'
      rpm: 10
      model_info:
        input_cost_per_token: 0.0
        output_cost_per_token: 0.0
      thinking:                                # FIXED: Removed duplicate line
        type: "enabled"

  # --- Optional convenience alias: claude-3-5-sonnet-20241022 ---
  - model_name: claude-3-5-sonnet-20241022
    litellm_params:
      model: openrouter/tencent/hy3:free
      api_key: os.environ/OPENROUTER_API_KEY  # FIXED: Added missing 'E'
      rpm: 10
      model_info:
        input_cost_per_token: 0.0
        output_cost_per_token: 0.0
      thinking:                                # FIXED: Removed duplicate line
        type: "enabled"
# --- LiteLLM-wide settings --------------------------------------------------litellm_settings:
  drop_params: true        
  set_verbose: false                   
  num_retries: 3           
  request_timeout: 600     
  streaming_timeout: 600
# --- Proxy-wide settings ----------------------------------------------------general_settings:
  master_key: os.environ/LITELLM_MASTER_KEY    # UNCOMMENTED: Secures your proxy endpoint
  disable_admin_ui: true

## Next Step Verification
Make sure to export your fixed env variables in your Pop!_OS terminal before re-running the launch script:

export OPENROUTER_API_KEY="your-real-openrouter-key"
export LITELLM_MASTER_KEY="your-chosen-local-proxy-password"

/opt/venv/bin/python3 /opt/venv/bin/litellm --config /home/pete/nvidia-proxy/openrouter.yaml --port 4001

If you want, I can show you how to write a Python test script using the openai library to quickly verify that port 4001 is accepting connections and passing back streaming tokens correctly.

---

Yes, you can absolutely omit the master key on a trusted home network. If you do not set a LITELLM_MASTER_KEY (or if you leave it commented out), LiteLLM switches to an "open authentication" mode. [1] 
This means down-stream applications (like LibreChat, Open WebUI, or custom scripts) can pass any dummy value—or nothing at all—in their Authorization: Bearer <key> header, and LiteLLM will successfully accept and route the request.
## The Downstream Benefit
Omitting the master key is a highly effective way to eliminate friction when setting up local developer environments. Many legacy or simpler client applications will crash or throw generic 401 Unauthorized errors if they are not explicitly configured to pass an exact matching security string. Removing the key requirement completely avoids this configuration step.
## ⚠️ Two Local Security Risks to Keep in Mind
Even on a secure home network, leaving the proxy wide open introduces two minor exposures:

   1. Local Network Exposure (0.0.0.0): Because Uvicorn is binding to http://0.0.0, your LiteLLM instance is listening on all network interfaces. Any device connected to your home Wi-Fi (smart TVs, guests, family phones, or IoT devices) can theoretically discover your computer's local IP address and send requests to port 4001, utilizing your API quota. [2, 3, 4] 
   2. Container or App Vulnerabilities: If a local application on your machine is compromised or behaves unexpectedly, it has direct, unauthenticated access to make unlimited API requests through your proxy.

## 🛠️ The Ideal Compromise: Bind to localhost Only
If you want to completely omit the master key to avoid client application configuration headaches, but want to guarantee that nobody else on your home Wi-Fi can abuse your API key, restrict LiteLLM's networking surface.
Change your startup command to bind explicitly to 127.0.0.1 (localhost) instead of the default 0.0.0.0: [5] 

/opt/venv/bin/python3 /opt/venv/bin/litellm --config /home/pete/nvidia-proxy/openrouter.yaml --host 127.0.0.1 --port 4001

Why this works perfectly:

* Any downstream application running on your same computer can connect instantly without needing an API key.
* The proxy will reject any incoming traffic hitting your machine from outside devices over the local Wi-Fi router.

If you want, I can show you how to test a direct client connection using curl from your terminal to verify that your keyless setup is working correctly. [6] 

[1] [https://wiki.debian.org](https://wiki.debian.org/OfflineMasterKey)
[2] [https://www.vyprvpn.com](https://www.vyprvpn.com/blog/post/how-iot-is-changing-home-security)
[3] [https://www.pcworld.com](https://www.pcworld.com/article/2220812/the-internal-domain-could-be-the-new-name-for-your-home-network.html)
[4] [https://www.reddit.com](https://www.reddit.com/r/HomeNetworking/comments/11trf9i/best_way_to_limit_one_part_of_my_network_to/)
[5] [https://superuser.com](https://superuser.com/questions/1571984/how-to-block-access-to-localhost-from-the-internet-in-xampp)
[6] [https://www.fixrunner.com](https://www.fixrunner.com/how-to-fix-error-521-with-wordpress-and-cloudflare/)
