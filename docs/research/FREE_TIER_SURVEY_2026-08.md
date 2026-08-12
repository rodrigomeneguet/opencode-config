# Free-tier provider survey — 2026-08

- **Status:** Research snapshot
- **Last verified:** 2026-08-12
- **Scope:** Candidate backends for the future `low-cost-worker`
- **Branch intent:** Design/research only. No runtime selection is changed by this document.

## Why this survey exists

The `low-cost-worker` should be a stable orchestration **role**, not an alias for one provider or one model.

A useful backend must be evaluated as a bundle of:

- provider and model availability;
- recurring or temporary economics;
- OpenCode integration friction;
- authentication requirements;
- tool-calling/agentic capability;
- context limits;
- privacy/data handling;
- quota and failure behavior;
- stability of the offer over time.

A plain `free: true` flag is therefore insufficient.

## Economic/availability classes proposed by the research

| Class | Meaning |
| --- | --- |
| `free-recurring` | Provider documents an ongoing no-cost API tier/allocation |
| `free-temporary` | Promotional/evaluation model that may disappear or become paid |
| `paid-bundle` | Subscription includes a usage allowance but is not free |
| `payg-cheap` | Low per-token cost, but requires paid balance |
| `local` | No remote inference charge; cost is local compute |

Availability should be tracked independently, for example `stable`, `promotional`, `preview`, `rotating`, or `local`.

## Important correction: OpenCode Go is not the free tier

OpenCode Go is a paid subscription. The official documentation currently lists $5 for the first month and $10/month afterwards, with usage allowances defined in dollar value. When Go usage is exhausted, OpenCode says users can continue using free models.

The zero-price models are currently exposed through OpenCode Zen and are explicitly described as limited-time/free-period models.

Therefore:

- OpenCode Go belongs to `paid-bundle`;
- current Zen free models belong to `free-temporary`, not `free-recurring`.

Sources:

- https://opencode.ai/docs/go/
- https://opencode.ai/docs/zen/

## Candidate summary

| Rank | Provider/backend | Class | OpenCode integration | Agentic fit | Privacy posture | Main caveat |
| --- | --- | --- | --- | --- | --- | --- |
| A1 | Cerebras + GPT-OSS 120B | `free-recurring` / currently also free-credit onboarding | Native `/connect` | Strong | Strong | Free limits/offer can change; current pricing page also frames onboarding as $5 free credits |
| A2 | Groq + GPT-OSS 120B | `free-recurring` | Native `/connect` | Strong | Strong, ZDR available | Daily token cap can bind long agentic sessions |
| A3 | Groq + Qwen 3.6 27B | `free-recurring` | Native `/connect` | Strong | Strong, ZDR available | Preview model; same free-tier token cap class |
| A4 | OpenCode Zen free models | `free-temporary` | Native, lowest friction | Strong when model is suitable | Restricted for sensitive data | Promotional/rotating; quota is not a durable contract |
| B1 | Cloudflare Workers AI | `free-recurring` | Native `/connect` | Strong models available | Provider-specific review required | 10,000 neurons/day can be small for long agentic work |
| B2 | OpenRouter Free Router / `:free` | `free-recurring` but rotating | Native `/connect` | Capability-filtered | Varies by routed provider | 50 req/day without purchased credits; model/provider can vary |
| Watch | Mistral Studio Free mode | `free-recurring` | Needs live OpenCode verification before preset | Potentially strong | Needs policy review | Public docs do not expose one stable universal quota table |
| Watch | Gemini Developer API Free | `free-recurring` | Higher integration friction for this project | Strong models available | Free-tier content used to improve products | Not a first-wave preset until OpenCode path is validated |
| Local | Ollama / local providers | `local` | Native | Hardware/model dependent | Best privacy potential | Requires adequate local compute and live capability testing |

The ranking above is an **engineering shortlist**, not a benchmark ranking. A provider only becomes a shipped preset after an actual OpenCode `/connect` + `/models` + agentic smoke test.

---

## A1 — Cerebras

### Why it is interesting

OpenCode documents Cerebras as a native provider: create an API key, `/connect`, then `/models`.

Cerebras' current rate-limit documentation lists a Free tier including:

| Model | TPM | TPD | RPM | RPD |
| --- | ---: | ---: | ---: | ---: |
| `gpt-oss-120b` | 64K | 1M | 30 | 14.4K |
| `zai-glm-4.7` | 60K | 1M | 10 | 100 |

The provider warns that free-tier limits for high-demand models can be reduced temporarily.

`gpt-oss-120b` is a production model on Cerebras and is advertised around 3,000 tokens/sec. This makes it unusually attractive for an elastic coding worker where wall-clock latency matters.

### Privacy

Cerebras states that inference inputs/outputs are not retained, and its terms state that Service Content is not used to train or fine-tune models.

### Caveat to verify live

The current public pricing page describes onboarding as a **Free Trial with $5 in credits**, while the inference rate-limit page still exposes a Free tier table. Before shipping a preset we must verify the actual account state created today and whether the documented free rate limits remain usable after trial credits are exhausted.

Sources:

- https://opencode.ai/docs/providers/
- https://inference-docs.cerebras.ai/support/rate-limits
- https://www.cerebras.ai/pricing
- https://support.cerebras.net/articles/1811589793-does-cerebras-retain-my-data
- https://www.cerebras.ai/terms-of-service

### Research verdict

**Top candidate, but requires a live account validation before being labeled durable `free-recurring`.**

---

## A2 — Groq GPT-OSS 120B

### Free limits currently documented

Groq's Free Plan currently lists `openai/gpt-oss-120b` at:

- 30 RPM;
- 1,000 RPD;
- 8K TPM;
- 200K TPD.

The model page lists:

- 131,072-token context;
- up to 65,536 output tokens;
- tool use;
- reasoning;
- JSON modes;
- approximately 500 tokens/sec.

Groq documents local/function tool calling and multi-turn agentic loops for this model.

### Privacy

Groq says normal inference customer data is not retained by default except limited reliability/abuse cases, and all customers may enable Zero Data Retention. Usage metadata is retained but excludes customer inputs/outputs.

Sources:

- https://console.groq.com/docs/rate-limits
- https://console.groq.com/docs/model/openai/gpt-oss-120b
- https://console.groq.com/docs/tool-use/local-tool-calling
- https://console.groq.com/docs/your-data
- https://opencode.ai/docs/providers/

### Research verdict

**Best currently evidenced external recurring-free candidate for a first real profile test.** The main constraint is the 200K-token daily free allowance, which may be consumed quickly by long-context agents.

---

## A3 — Groq Qwen 3.6 27B

Groq's Free Plan currently lists `qwen/qwen3.6-27b` with the same headline limits as GPT-OSS 120B:

- 30 RPM;
- 1,000 RPD;
- 8K TPM;
- 200K TPD.

The model is currently marked Preview and lists:

- 131,072-token context;
- tool use;
- reasoning;
- vision;
- approximately 500 tokens/sec.

Source:

- https://console.groq.com/docs/model/qwen/qwen3.6-27b

### Research verdict

**Excellent alternate profile candidate**, especially for comparative agentic testing. Preview status means it should not be the only fallback backend.

---

## A4 — OpenCode Zen free models

Current free Zen entries include:

- Big Pickle;
- DeepSeek V4 Flash Free;
- MiMo-V2.5 Free;
- Hy3 Free;
- Laguna S 2.1 Free;
- Ling-3.0-tiny Free;
- Nemotron 3 Ultra Free;
- Nemotron 3.5 Lightning Free.

OpenCode explicitly says these free periods are limited-time/evaluation opportunities. The free-model data policies also vary. Several may use collected data for model improvement; the NVIDIA evaluation endpoints explicitly warn not to send personal or confidential information.

Source:

- https://opencode.ai/docs/zen/

### Research verdict

**Keep as the zero-friction preset family, but classify as `free-temporary` and `non-sensitive-only` unless a specific model's current policy supports more.** This is exactly why the role must not be named after DeepSeek.

---

## B1 — Cloudflare Workers AI

Cloudflare currently provides **10,000 neurons/day at no charge**, resetting daily at 00:00 UTC. Exceeding the allocation on the Free Workers plan causes further operations to fail until reset or upgrade.

OpenCode has a native Cloudflare Workers AI `/connect` flow requiring Account ID and API token.

Interesting current agentic models include:

- `@cf/openai/gpt-oss-120b`: 128K context, function calling, reasoning;
- `@cf/zai-org/glm-4.7-flash`: 131,072 context, function calling, reasoning, multi-turn tool calling;
- other current Workers AI models also expose function-calling/reasoning capabilities.

Sources:

- https://developers.cloudflare.com/workers-ai/platform/pricing/
- https://developers.cloudflare.com/workers-ai/models/gpt-oss-120b/
- https://developers.cloudflare.com/workers-ai/models/glm-4.7-flash/
- https://opencode.ai/docs/providers/

### Research verdict

**Good reserve provider.** The free allocation is real and recurring, but neurons make practical agent-session capacity less intuitive. We should measure one representative OpenCode task before ranking it above Groq.

---

## B2 — OpenRouter free models

OpenRouter's Free plan currently advertises:

- 25+ free models;
- 4 free providers;
- 50 requests/day.

Its FAQ says purchasing at least $10 in credits raises free-model API allowance to 1,000 requests/day.

`openrouter/free` dynamically filters the free pool for required capabilities such as tool calling or structured outputs, then chooses an available free model. Specific models can instead be pinned with a `:free` variant.

OpenCode has a native OpenRouter `/connect` integration.

Sources:

- https://openrouter.ai/pricing
- https://openrouter.ai/docs/faq
- https://openrouter.ai/docs/guides/routing/routers/free-router
- https://opencode.ai/docs/providers/

### Research verdict

**Very useful emergency/experimental backend, weak deterministic primary worker.** The free router is deliberately rotating and the free plan's 50 RPD is small for multi-agent workflows.

---

## Watchlist — Mistral Studio Free mode

Mistral currently documents a Studio Free mode with API access enabled by default and no credit card required. Usage and rate limits apply, with exact limits visible in the account's Usage/Limits area rather than one durable public universal table.

Sources:

- https://docs.mistral.ai/getting-started/quickstarts/studio/activate-and-generate-api-key
- https://docs.mistral.ai/admin/billing-usage/subscriptions
- https://docs.mistral.ai/admin/billing-usage/usage-limits

### Why not first-wave yet

Before shipping a preset we need to verify the actual provider/model IDs exposed by the user's current OpenCode `/models` and test tool-calling behavior in the exact OpenCode harness.

---

## Watchlist — Gemini Developer API Free

Google currently provides a no-cost Gemini Developer API tier for some models. Google also states that content on the free tier is used to improve its products, while paid-tier content is not.

Source:

- https://ai.google.dev/gemini-api/docs/pricing

### Why not first-wave yet

Our current OpenCode integration path is less turnkey than Groq/Cerebras/OpenRouter/Workers AI for this use case, and the free-tier data policy makes it unsuitable as a general corporate-data worker.

---

## Local class — Ollama and other local providers

OpenCode supports local models and documents Ollama/other local providers in its provider system.

Local inference is not a remote `free tier`; it is a separate economics/privacy class. It can become extremely useful for private code/log exploration if the machine has enough compute and the selected local model proves reliable at OpenCode tool calling.

Source:

- https://opencode.ai/docs/providers/

---

## Recommended first validation matrix

Do not implement a pool yet. Validate individual backends first.

| Test order | Backend | Reason |
| --- | --- | --- |
| 1 | Groq / GPT-OSS 120B | Clear recurring free limits, native OpenCode, tools, strong privacy controls |
| 2 | Cerebras / GPT-OSS 120B | Exceptional throughput and strong privacy, but free-vs-trial status needs live confirmation |
| 3 | Groq / Qwen 3.6 27B | Useful alternate model/provider-path comparison |
| 4 | Cloudflare / GLM-4.7-Flash | Recurring daily allocation and strong tool support |
| 5 | OpenRouter / `openrouter/free` | Tests rotating-provider behavior and failure semantics |
| Control | OpenCode Zen / DeepSeek V4 Flash Free | Current known baseline |

For every backend, run the same small OpenCode suite:

1. `/connect` succeeds without orchestrator touching credentials;
2. `/models` exposes a usable stable `provider/model` ID;
3. read-only repository exploration;
4. multi-tool task with at least 5 tool turns;
5. isolated code change plus tests;
6. independent review task;
7. deliberate quota/rate-limit failure if safely reproducible;
8. record latency, tool-call correctness, retries, failure shape, and context consumption.

A profile only moves from `candidate` to `verified` after this suite passes.

## Schema consequences

Research suggests the future profile schema should include at least:

```text
provider
model
economics.type
availability.class
auth.mode
privacy.class
capabilities.tool_calling
capabilities.reasoning
limits.kind
verification.status
verification.last_checked
fallback_eligible
```

No profile should contain API keys, tokens, passwords, or other credentials.

## Current architectural conclusion

The research strongly supports the abstraction:

> **Low-Cost Worker is a role, not a model.**

It also argues against automatic multi-provider routing in the first implementation. Provider offers, privacy policies, quotas, and error semantics are heterogeneous enough that we should first make **one selected profile** deterministic and observable. A future pool can then be built on verified profiles instead of optimistic assumptions.
