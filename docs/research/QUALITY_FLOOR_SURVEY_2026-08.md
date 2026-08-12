# Quality-floor survey — 2026-08

- **Status:** Research snapshot
- **Last verified:** 2026-08-12
- **Scope:** Quality-first candidate backends for the future economic/elastic worker role
- **Baseline:** DeepSeek V4 Flash, including the 2026-07-31 API update commonly referred to as `DeepSeek-V4-Flash-0731`
- **Branch intent:** Research/design only. No runtime selection changes are introduced by this document.

## Why this supersedes the first ranking

The earlier `FREE_TIER_SURVEY_2026-08.md` ranked providers too early by free-tier generosity and integration convenience. That is the wrong optimization order for this project.

The worker exists to absorb meaningful agentic engineering work without wasting premium OpenAI quota. A large free quota attached to a materially weaker coding model is not an acceptable replacement for a strong worker.

The new rule is:

```text
candidate backend
       |
       v
passes agentic quality floor?
       |
   no  +----> reject as worker backend
       |
      yes
       v
now compare economics, quota,
privacy, latency and stability
```

The economic survey remains useful as a catalog of providers and quota classes, but its old A1/A2 ranking is superseded by this document.

## Baseline: DeepSeek V4 Flash 0731

DeepSeek's public API model ID remains `deepseek-v4-flash`. The 2026-07-31 release communication refers to the upgraded API model as `DeepSeek-V4-Flash-0731`; the official model card continues to present it as DeepSeek V4 Flash.

Architecture and service characteristics currently documented:

- 284B total parameters;
- 13B activated parameters;
- 1M context;
- tool calling;
- thinking and non-thinking modes;
- official API pricing of $0.14/M uncached input and $0.28/M output;
- cache-hit input price of $0.0028/M.

### Agentic/coding benchmark reference

Official current DeepSeek model-card results for V4 Flash include:

| Benchmark | High | Max |
| --- | ---: | ---: |
| LiveCodeBench | 88.4 | 91.6 |
| Codeforces rating | 2816 | 3052 |
| Terminal-Bench 2.0 | 56.6 | 56.9 |
| SWE-bench Verified | 78.6 | 79.0 |
| SWE-bench Pro | 52.3 | 52.6 |
| SWE-bench Multilingual | 70.2 | 73.3 |
| MCPAtlas | 67.4 | 69.0 |
| Toolathlon | 43.5 | 47.8 |

This is the **reference class**, not a requirement to beat every individual number.

Sources:

- https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash
- https://api-docs.deepseek.com/quick_start/pricing/
- https://api-docs.deepseek.com/api/list-models

## Strategic finding: the fallback does not have to be free

The worker role exists to protect premium OpenAI quota while retaining enough quality to perform useful engineering work. That means `free` should not be a hard architectural requirement.

The official DeepSeek API currently provides the exact V4 Flash model at extremely low pay-as-you-go pricing:

| Usage | Price / 1M tokens |
| --- | ---: |
| Input, cache hit | $0.0028 |
| Input, cache miss | $0.14 |
| Output | $0.28 |

This creates a special backend class for the orchestrator:

```text
OpenCode Zen / DeepSeek V4 Flash Free
              |
              | quota/promotion unavailable
              v
Direct DeepSeek API / DeepSeek V4 Flash
              |
              | same model family and quality class
              v
continue without capability downgrade
```

This is not proposed as the default paid path and requires explicit user configuration/balance. It is important architecturally because a deterministic same-model `payg-cheap` fallback may be preferable to an automatic switch to a materially weaker free model.

The profile design should therefore optimize for **economic capacity**, not strictly `free capacity`.

## Important benchmark caveat

Cross-vendor benchmark numbers are not automatically comparable. Providers may use different:

- benchmark versions, e.g. Terminal-Bench 2.0 versus 2.1;
- harnesses;
- reasoning settings;
- token budgets;
- tool schemas;
- sampling parameters;
- step limits.

Therefore this survey uses public benchmarks only to choose candidates for a **same-harness OpenCode smoke test**. It does not declare a model superior merely because one number is larger.

## Proposed capability classes

| Class | Meaning |
| --- | --- |
| `PEER-CANDIDATE` | Public evidence suggests V4-Flash-class agentic capability; requires same-harness validation |
| `PEER-VERIFIED` | Passed the project's same-harness validation at an acceptable quality/reliability level |
| `FALLBACK` | Materially weaker than the peer floor but still useful for meaningful independent work |
| `UTILITY` | Suitable only for narrow, simple or highly verifiable work |
| `REJECT` | Does not justify the worker role despite attractive economics |

No external candidate is `PEER-VERIFIED` yet.

---

## PEER-CANDIDATE 1 — Gemini 3.6 Flash

This is the strongest recurring-free external candidate found in the quality-first pass.

Google currently reports:

| Benchmark | Gemini 3.6 Flash |
| --- | ---: |
| SWE-Bench Pro Public | 58.7% |
| DeepSWE v1.1 | 49% |
| Terminal-Bench 2.1 | 78.0% |
| OSWorld-Verified | 83.0% |

Google lists 1M input context, 64K output, function calling, search-as-tool and computer-use capabilities, and explicitly positions the model for agentic coding and advanced reasoning.

### Economics

The Gemini Developer API currently lists `gemini-3.6-flash` with a no-cost standard tier where input and output tokens are free. Google states that free-tier content is used to improve its products, while paid-tier content is not.

This makes the economics `free-recurring` at the time of this survey, but with a privacy classification that should default to **non-sensitive-only**.

### OpenCode integration

OpenCode supports 75+ providers through the AI SDK and allows custom providers, but its public provider guide currently documents Google Vertex AI rather than a dedicated Gemini Developer API free-tier walkthrough.

Therefore the direct Google free-tier path must be validated live before a preset is shipped:

1. authenticate without the orchestrator storing credentials;
2. confirm the actual provider/model ID shown by `/models` or configure the Google provider explicitly;
3. validate tool streaming and multi-turn tool use;
4. observe the real free-tier request/rate limits for the account.

Sources:

- https://deepmind.google/models/gemini/flash/
- https://ai.google.dev/gemini-api/docs/models/gemini-3.6-flash
- https://ai.google.dev/gemini-api/docs/pricing
- https://opencode.ai/docs/providers/

### Research verdict

**Highest-priority external `PEER-CANDIDATE` for live testing.** Quality evidence is strong and the API has a real no-cost tier. Integration and privacy policy are the gating factors, not model intelligence.

---

## PEER-CANDIDATE 2 — Laguna S 2.1

Poolside describes Laguna S 2.1 as an agentic coding and long-horizon model with:

- 118B total / ~8B active parameters;
- 1,048,576-token context;
- interleaved reasoning;
- explicit long-horizon software-engineering focus.

Official Poolside model-card results include:

| Benchmark | Laguna S 2.1 |
| --- | ---: |
| Terminal-Bench 2.1 | 70.2% |
| SWE-bench Multilingual | 78.5% |
| SWE-Bench Pro Public | 59.4% |
| DeepSWE | 40.4% |
| SWE Atlas | 46.2% |
| Toolathlon Verified | 49.7% |

These numbers are strong enough that Laguna cannot be dismissed as a cheap utility model. Because some benchmarks differ in harness/version from DeepSeek, this is a peer **candidate**, not a proven replacement.

### Economics and integration

OpenCode currently exposes `opencode/laguna-s-2.1-free` as a Zen free model. OpenCode states that Zen free models are limited-time evaluation offers and that data collected during Laguna's free period may be used to improve the model.

Therefore:

- quality class: `PEER-CANDIDATE`;
- economics: `free-temporary` through Zen;
- integration: lowest-friction, already in OpenCode's curated provider path;
- privacy: `non-sensitive-only` during the free period.

Sources:

- https://huggingface.co/poolside/Laguna-S-2.1
- https://opencode.ai/docs/zen/

### Research verdict

**First alternative to test inside the existing OpenCode Zen account.** It has essentially zero integration cost and unusually strong agentic evidence.

---

## PEER-CANDIDATE 3 — MiMo V2.5

Xiaomi describes MiMo V2.5 as a 311B-class omnimodal model with strong agentic capabilities and long-context workflows.

Current published evaluation results include:

| Benchmark | MiMo V2.5 |
| --- | ---: |
| SWE-Bench Pro | 56.1% |
| Terminal-Bench 2.0 | 65.8% |
| Claw-Eval General | 62.1% |
| Claw-Eval Multi-Turn | 63.2% |

The Terminal-Bench version matches DeepSeek's published 2.0 benchmark, although harness/settings can still differ.

### Economics and integration

OpenCode currently exposes `opencode/mimo-v2.5-free`. Like the other Zen free models, it is explicitly limited-time and its free-period data may be used for model improvement.

Therefore:

- quality class: `PEER-CANDIDATE`;
- economics: `free-temporary` through Zen;
- integration: very low friction;
- privacy: `non-sensitive-only` during the free period.

Sources:

- https://huggingface.co/XiaomiMiMo/MiMo-V2.5
- https://opencode.ai/docs/zen/

### Research verdict

**Strong second Zen alternative.** Public agentic numbers are much closer to V4 Flash than the older GPT-OSS candidates from the first survey.

---

## WATCH / PEER-CANDIDATE PENDING QUALITY TEST — Ling 3.0 Flash

Ling 3.0 Flash is interesting for a different reason: provider diversity plus a recurring direct-provider allocation.

The official Ling pricing page currently states:

- 500,000 free tokens per account per day, shared across input/output;
- quota resets daily and does not roll over;
- after promotional model pricing ends, the daily free-token allocation remains documented separately from the launch promotion.

The model is positioned for high-speed execution and agentic inference. However, this research pass did not find a vendor-published benchmark table directly comparable to V4 Flash, Laguna or MiMo.

OpenCode currently exposes `opencode/ling-3.0-flash-free` in Zen, but that is a separate temporary OpenCode promotion. A direct Ling provider profile would need its own authentication/configuration path and live tool-use validation.

Sources:

- https://developer.ant-ling.com/en/docs/models/price/
- https://opencode.ai/docs/zen/

### Research verdict

**Economically excellent, quality not yet proven against our floor.** Do not promote it to a shipped peer preset until the same OpenCode task suite passes.

---

## FALLBACK-CANDIDATE — North Mini Code

North Mini Code is a 30B total / 3B active open-weight model from Cohere Labs with 256K context. It deserves attention because it was explicitly trained for agentic software engineering and robustness across several harnesses, including OpenCode-style typed tool use.

Current model-card/evaluation artifacts report:

| Benchmark | North Mini Code |
| --- | ---: |
| SWE-bench Verified | 67.6% |
| SWE-bench Pro | 40.2% |
| Terminal-Bench 2.0 | 36.0% |

Cohere also reports that adding cross-harness training produced a 10% improvement on an OpenCode-harness evaluation and describes reduced malformed/repetitive tool calls after agentic RL.

OpenCode currently exposes `opencode/north-mini-code-free` as a limited-time Zen free model.

Sources:

- https://huggingface.co/CohereLabs/North-Mini-Code-1.0
- https://huggingface.co/blog/CohereLabs/introducing-north-mini-code
- https://opencode.ai/docs/zen/

### Research verdict

**Interesting specialized fallback, not a V4-Flash peer.** Its OpenCode-oriented training may make it more useful in practice than raw parameter count suggests, but the public agentic scores remain materially below our baseline.

---

## FALLBACK — Nemotron 3 Ultra Free

Nemotron remains useful as a fallback-class candidate, but current public evidence does not justify treating it as a peer to V4 Flash for this role.

OpenCode currently exposes `opencode/nemotron-3-ultra-free` as a temporary Zen evaluation model and explicitly warns that NVIDIA free endpoints are evaluation-only and should not receive personal or confidential data.

### Research verdict

**Fallback, not baseline replacement.**

Source:

- https://opencode.ai/docs/zen/

---

## FALLBACK / UTILITY — GPT-OSS 120B on Groq or Cerebras

The first economic survey over-ranked GPT-OSS 120B because Groq and Cerebras provide unusually attractive free quotas and high throughput.

That remains economically interesting, but it does not make GPT-OSS 120B a V4-Flash-class agentic worker.

### Research verdict

**Keep in the provider catalog as a fast fallback/utility option, not a first-wave peer backend.** Generous quota cannot compensate for a large quality gap in long-horizon coding work.

---

## UNKNOWN — Big Pickle and rotating stealth/free models

Unknown or stealth model identity prevents meaningful capability-floor validation. Rotating free routers may be useful later as emergency capacity, but they are poor deterministic worker backends until the selected model and provider can be observed and audited.

### Research verdict

**Do not use as a peer preset.**

---

## Revised test order

The next phase should not test every free provider. It should test the models most likely to clear the V4 Flash floor, then test specialized fallbacks separately.

| Order | Candidate | Access path | Economics | Why test |
| --- | --- | --- | --- | --- |
| Control | DeepSeek V4 Flash Free | OpenCode Zen | `free-temporary` | Current known worker baseline |
| 1 | Laguna S 2.1 Free | OpenCode Zen | `free-temporary` | Zero setup friction + strong agentic evidence |
| 2 | MiMo V2.5 Free | OpenCode Zen | `free-temporary` | Zero setup friction + strong Terminal/SWE evidence |
| 3 | Gemini 3.6 Flash | Google Developer API | `free-recurring` | Strongest recurring-free quality candidate |
| 4 | Ling 3.0 Flash | Direct provider | `free-recurring` daily allocation | Provider diversity; quality must be measured |
| 5 | North Mini Code | OpenCode Zen | `free-temporary` | OpenCode-specific training; fallback-class control |
| 6 | GPT-OSS 120B | Groq/Cerebras | `free-recurring` or trial-dependent | Lower-tier economic control |
| Operational fallback | DeepSeek V4 Flash | Direct DeepSeek API | `payg-cheap` | Same-model continuity when Zen quota/promotion is unavailable |

## Same-harness validation suite

Benchmark tables only nominate candidates. The project should decide based on real OpenCode behavior.

Every candidate should run the same task package against a disposable or intentionally selected test repository:

1. repository exploration and architecture summary;
2. multi-file bug diagnosis;
3. isolated implementation with tests;
4. modification requiring at least 5 tool turns;
5. independent diff review;
6. recovery after one failed test/hypothesis;
7. long-context continuation after prior tool history;
8. deliberate provider/quota failure when safely reproducible.

Record:

```text
model/provider
reasoning mode
wall-clock time
model calls
successful tool calls
tool-call corrections
repeated exploration
implementation correctness
tests passed
review defects found
context/retry failures
quota consumed
human intervention required
```

The control and candidate tasks must use the same repository state and acceptance criteria.

## Promotion rule

A backend becomes `PEER-VERIFIED` only if it demonstrates acceptable real-world behavior relative to DeepSeek V4 Flash on the same task suite.

Do **not** require a candidate to win every benchmark. Require it to be good enough that routing meaningful independent engineering work to it does not create disproportionate rework for Luna Lead.

This changes the optimization target from:

> maximize free tokens

into:

> maximize useful independently verifiable engineering work per unit of premium quota avoided.

That is the metric the economic worker actually exists to optimize.
