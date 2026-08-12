# Google Developer Program credits + Vertex AI — 2026-08

- **Status:** Research snapshot
- **Last verified:** 2026-08-12
- **Branch:** `feat/low-cost-worker-profiles`
- **Purpose:** Validate whether Google Developer Program Cloud credits can fund Vertex AI and whether the recurring credit survives a downgrade from Google AI Pro to Google AI Plus.

## Executive result

1. Google AI Pro currently includes Google Developer Program Premium for eligible personal Google Accounts linked to a Developer Profile.
2. That Premium benefit currently grants **US$10 in Google Cloud credits per month** for AI Pro.
3. Google explicitly states that these Cloud credits can be used on **all Google Cloud products, including Vertex AI**.
4. Google AI Plus does **not** qualify for Google Developer Program Premium. Official eligibility requires an active **Google AI Pro or Google AI Ultra** subscription.
5. Therefore, downgrading from AI Pro to AI Plus should stop future monthly US$10 Google Cloud credit grants once the Pro billing period ends.
6. Already granted Cloud credits are documented with their own expiration, currently one year after grant for monthly/annual GDP credits. Public documentation does not explicitly state that downgrading to AI Plus immediately revokes already redeemed credits, so existing balance should be verified in Cloud Billing before changing plans.

## Credit applicability

Google Developer Program documentation states that the Google Cloud credit can be used on all Google Cloud products, explicitly naming:

- Firebase
- Vertex AI
- Google Maps Platform

This means a Vertex AI backend used by OpenCode can legitimately consume the GDP Cloud credit as long as the target Google Cloud project is linked to the billing account where the promotion was redeemed and the SKU is eligible under the promotion's terms.

Official sources:

- https://developers.google.com/profile/help/benefits?hl=pt-br
- https://support.google.com/googleone/answer/14534406?hl=pt-BR

## Why the user's recurring amount looks like about R$50/month

The official benefit is denominated in USD: **US$10/month** with Google AI Pro. Its BRL display value can naturally appear around R$50 depending on exchange rate and Cloud billing display conventions.

This is a Google Developer Program Premium benefit, not a generic free Google Cloud allowance.

## Downgrade to Google AI Plus

Google's current eligibility text says that Google Developer Program Premium requires an active Google AI Pro membership linked to the Google Developer Profile. The Developer Program FAQ says the Premium benefits are being consolidated into Google AI Pro and Google AI Ultra for personal accounts.

The Google AI Plus benefits page lists consumer AI benefits but does not include Google Developer Program Premium.

Therefore:

```text
Google AI Pro
  -> GDP Premium
  -> US$10/month Google Cloud credit
  -> Vertex AI eligible

Google AI Plus
  -> no GDP Premium entitlement documented
  -> no new US$10/month GDP Cloud credit
```

The downgrade should therefore be modeled as a change in **funding/account state**, not as a change in Vertex AI model availability.

## Existing accumulated credits

GDP documentation currently says Cloud credits from monthly and annual plans expire **one year after grant**.

It also says paid benefits continue until the end of the current billing period after cancellation.

No public source found in this research explicitly says that already redeemed promotional Cloud credits are immediately revoked when the associated AI Pro subscription is downgraded to AI Plus.

Before downgrading, inspect Cloud Billing -> Credits and record for each promotion:

- credit name
- remaining amount
- type
- start date
- end date
- scope

Cloud Billing exposes these fields for promotional credits.

Official source:

- https://docs.cloud.google.com/billing/docs/how-to/resolve-issues?hl=pt-BR

## Relevant current Gemini models and standard Vertex/Agent Platform pricing

Prices below are current public **Standard PayGo** list prices in USD per 1M tokens. Cached input prices are shown where relevant. Interactive OpenCode agent loops should be compared against Standard pricing; Flex/Batch is cheaper but is a different service mode and should not be assumed to behave as an interactive agent backend.

| Model | Input / 1M | Cached input / 1M | Output / 1M | Notes |
| --- | ---: | ---: | ---: | --- |
| Gemini 3.6 Flash | $1.50 | $0.15 | $7.50 | GA, 1,048,576 context, 65,536 max output, function calling, coding/agentic focus |
| Gemini 3.5 Flash | $1.50 global | $0.15 global | $9.00 global | Strong agentic/coding model, but 3.6 is currently cheaper on output and newer |
| Gemini 3.5 Flash-Lite | $0.30 global | $0.03 global | $2.50 global | 1M context; Google explicitly documents Medium/High thinking for autonomous subagents |
| Gemini 3.1 Flash-Lite | $0.25 global | $0.025 global | $1.50 global | Older, very low-cost utility/subagent candidate |
| Gemini 3.1 Pro Preview | $2.00 <=200K; $4.00 >200K | $0.20 / $0.40 | $12.00 <=200K; $18.00 >200K | Not an economic-worker candidate |

For Gemini 3.5-family non-global endpoints, Google currently lists a 10% regional premium versus Global for Standard PayGo. Gemini 3.6 Flash is documented as Global-only for current Standard PayGo model availability.

Official sources:

- https://cloud.google.com/gemini-enterprise-agent-platform/generative-ai/pricing?hl=pt-BR
- https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-6-flash?hl=pt-br
- https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-5-flash?hl=pt-br
- https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/gemini/3-5-flash-lite?hl=pt-br

## What US$10/month buys, illustrative only

To make the monthly GDP credit intuitive, consider a synthetic workload of **1M input tokens + 100K output tokens** using Standard PayGo and no cache benefit:

| Model | Approx. cost per synthetic workload | Approx. workloads covered by US$10 |
| --- | ---: | ---: |
| Gemini 3.6 Flash | $2.25 | 4.44 |
| Gemini 3.5 Flash-Lite | $0.55 | 18.18 |
| Gemini 3.1 Flash-Lite | $0.40 | 25 |

This is only an arithmetic illustration. OpenCode agent costs depend heavily on repeated context, tool rounds, reasoning output, cache behavior, and task length.

## Quality interpretation for the orchestrator

### Gemini 3.6 Flash

Google positions Gemini 3.6 Flash specifically for agentic coding, multi-step orchestration and full-stack refactoring. Current Google-published results include:

- SWE-Bench Pro Public: 58.7%
- DeepSWE v1.1: 49%
- Terminal-Bench 2.1: 78.0%
- OSWorld-Verified: 83.0%

It is therefore a serious `PEER-CANDIDATE` against DeepSeek V4 Flash in the project's quality-first evaluation, but it is far more expensive per token than direct DeepSeek V4 Flash pricing.

### Gemini 3.5 Flash-Lite

Google explicitly documents `thinking_level.MEDIUM` or `HIGH` for autonomous subagents that write code, execute terminal commands or call external APIs. That makes it more interesting than its `Lite` name suggests for an inexpensive worker tier.

However it should be treated as a separate quality class until the same-harness OpenCode test establishes whether it can absorb meaningful engineering work without excessive rework.

### Gemini 3.1 Flash-Lite

This is economically attractive but should start as `UTILITY`/`FALLBACK-CANDIDATE`, not as a peer to V4 Flash.

## Vertex Model Garden caution

Vertex/Agent Platform also exposes third-party and open models through Model Garden/MaaS. Examples include Qwen, GLM and other families.

For this project they should not automatically be preferred merely because the billing account already has Cloud credit. Availability and lifecycle can be shorter than Gemini models. For example, Google has announced retirement dates in October 2026 for several Qwen3 MaaS offerings, including Qwen3 Coder 480B.

This strengthens the case for starting with Google-native Gemini models for the Google-funded backend, while keeping Model Garden as a later research surface.

Official sources:

- https://docs.cloud.google.com/vertex-ai/generative-ai/docs/open-models/use-maas
- https://docs.cloud.google.com/gemini-enterprise-agent-platform/models/deprecations/open-models?hl=pt-br

## Architectural consequence

The project should distinguish **backend economics** from **account funding**.

Example:

```text
backend profile
  provider = google-vertex
  model = gemini-3.6-flash
  economics = payg
  quality = peer-candidate

account state
  authenticated = true
  billing_enabled = true
  promotional_credit_available = true
  recurring_credit_source = google-ai-pro-gdp-premium
```

If the user downgrades AI Pro -> AI Plus:

```text
backend profile remains valid
funding source changes
  recurring_credit = false
existing promotional balance = inspect until expiry
```

This prevents the orchestrator from incorrectly calling Gemini 'free'.

## Research conclusion

For the user's current account state, Google Vertex is worth benchmarking now because the existing Cloud balance can pay for the experiment and the recurring US$10/month benefit is currently active while AI Pro remains active.

If AI Pro is downgraded to AI Plus, the current official rules indicate that **new monthly GDP Cloud credits stop**. The economic decision is therefore not just AI Pro vs AI Plus consumer features: retaining Pro also preserves a recurring US$10/month Cloud subsidy that can fund Vertex AI.
