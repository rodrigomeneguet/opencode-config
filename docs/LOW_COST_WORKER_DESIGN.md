# Low-Cost Worker design

This document describes the proposed abstraction for an economic worker backend without binding the orchestration role to DeepSeek or any single provider.

**Status: prototype / branch-only.**

## Current state

```text
Luna Lead
   |
   +-- deepseek-worker
          |
          +-- opencode/deepseek-v4-flash-free
```

The role, provider and model are coupled.

## Proposed state

```text
Luna Lead
   |
   +-- low-cost-worker
          |
          +-- selected profile
                 |
                 +-- provider
                 +-- model
                 +-- auth expectations
                 +-- economics metadata
                 +-- provider policy metadata
```

The orchestration prompt reasons about `low-cost-worker`. The installer decides which backend implements that role.

## Separation of responsibilities

```text
ROLE
low-cost-worker
  -> when to route work here
  -> scope and execution discipline
  -> fallback semantics

PROFILE
provider/model preset
  -> concrete model ID
  -> provider ID
  -> auth expectations
  -> economics classification
  -> verification date

OPENCODE
  -> actual credential storage
  -> provider authentication
  -> model execution
```

The orchestrator must not become a credential manager.

## Installer flow

```text
                    setup
                      |
                      v
          configure Low-Cost Worker?
                 /           \
               no             yes
               |               |
               |               v
               |        choose profile
               |               |
               |               v
               |      provider authenticated?
               |          /          \
               |        yes           no
               |         |             |
               |         |       show OpenCode
               |         |       connect/auth step
               |         |             |
               |         +------<------+
               |               |
               |               v
               |        validate selection
               |               |
               |               v
               |      render low-cost-worker
               |               |
               |               v
               |      save non-secret state
               |               |
               +-------+-------+
                       |
                       v
                install topology
```

## Suggested persistent state

Global install:

```text
~/.config/opencode/orchestrator.json
```

Conceptual example:

```json
{
  "schema_version": 1,
  "low_cost_worker": {
    "profile": "opencode-deepseek-v4-flash-free",
    "provider": "opencode",
    "model": "deepseek-v4-flash-free",
    "full_model_id": "opencode/deepseek-v4-flash-free"
  }
}
```

No secrets belong in this file.

## Agent rendering

The source repository should eventually hold a generic template:

```text
templates/low-cost-worker.md
```

The installer renders the installed file with the selected model:

```yaml
---
description: Economic auxiliary worker...
mode: subagent
model: <provider/model selected by profile>
...
---
```

This avoids rewriting the generic routing prompt whenever the backend changes.

## Provider discovery

A first implementation should stay conservative.

Recommended minimum:

1. offer built-in profiles from `profiles/low-cost/`;
2. allow a custom `provider/model` profile;
3. use OpenCode's own auth commands/listing to verify provider setup when possible;
4. never inspect or copy credential values;
5. validate that the selected model appears available before writing the final worker.

Automatic ranking of every provider is deliberately postponed.

## `enabled_providers`

The current config uses an explicit provider allowlist.

This creates a design decision:

```text
A) keep allowlist
   -> installer must add selected Low-Cost provider

B) remove allowlist
   -> providers connected by the user can coexist naturally
```

For a public project, option B may ultimately be cleaner, but it should be tested before changing the validated master configuration.

## Failure flow

Desired policy after OpenCode returns control:

```text
low-cost-worker
      |
      +-- success ----------------------> continue
      |
      +-- terminal provider failure
      |        |
      |        +--> mark unavailable this session
      |        +--> Luna Worker High
      |
      +-- transient provider failure
               |
               +--> at most one retry
               +--> Luna Worker High if repeated
```

This is **best-effort fallback**, not true failover, while OpenCode itself can keep a child session inside an internal retry loop.

## Future pool, deliberately not now

The architecture could later support:

```text
Low-Cost Pool
   |
   +-- Provider A free tier
   +-- Provider B free tier
   +-- local model
```

But implementing a pool now would multiply authentication, health, privacy and retry complexity before the single-profile design is validated.

First make one replaceable backend boring and reliable. Then consider a pool.

## Evaluation checklist

Before merging an implementation into master, test:

- current DeepSeek profile on Linux/WSL;
- current DeepSeek profile on Windows PowerShell;
- a second real provider profile;
- provider already authenticated;
- provider not authenticated;
- custom provider/model entry;
- Low-Cost Worker disabled;
- backup before profile change;
- profile change from provider A to provider B;
- terminal quota failure;
- transient failure;
- no regression to Luna/Terra agents;
- installer idempotency.

## Related ADRs

- `ADR-0002-low-cost-worker-provider-profiles.md`
- `ADR-0003-low-cost-worker-failure-and-fallback.md`
