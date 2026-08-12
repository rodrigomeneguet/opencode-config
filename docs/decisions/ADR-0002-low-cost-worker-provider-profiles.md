# ADR-0002: Provider profiles for the Low-Cost Worker

- **Status:** Proposed
- **Date:** 2026-08-12
- **Scope:** Low-cost worker abstraction, provider setup and installer design
- **Branch:** `feat/low-cost-worker-profiles`

## Context

The current orchestration topology binds the economic worker role directly to one implementation:

```text
deepseek-worker
  -> opencode/deepseek-v4-flash-free
```

This works today, but the role and the model are different concepts.

The orchestration requirement is actually:

> Route independent, objectively verifiable and economically suitable work to an auxiliary low-cost capacity source.

That capacity source may be:

- a free model from OpenCode;
- another provider with a free tier;
- a provider already connected by the user;
- a local model;
- a future provider or model that does not exist today.

Therefore, a model-specific agent name creates unnecessary coupling.

## Decision direction

Replace the conceptual role:

```text
deepseek-worker
```

with:

```text
low-cost-worker
```

The role must remain stable while its provider and model are selected through an installer-managed **profile**.

The model is an implementation detail of the role.

## Core principle

> **Low-Cost Worker is a role, not a model.**

This is the same separation already used by `strategic-advisor`: the role remains stable even if its backing model changes.

## Why a model environment variable is insufficient

A single variable such as:

```text
OPENCODE_LOW_COST_MODEL=provider/model
```

is not enough because selecting a model may also require:

- provider authentication;
- provider-specific configuration;
- enabling the provider in OpenCode;
- a custom base URL or AI SDK adapter;
- user-specific account setup;
- different privacy or retention considerations;
- validation that the selected model is actually available.

Authentication must remain under OpenCode/provider control. The orchestrator must not write secrets into OpenCode's auth store.

## Proposed profile object

The orchestrator should maintain a non-secret profile describing the selected backend.

Example state:

```json
{
  "schema_version": 1,
  "low_cost_worker": {
    "profile": "opencode-deepseek-v4-flash-free",
    "provider": "opencode",
    "model": "deepseek-v4-flash-free",
    "full_model_id": "opencode/deepseek-v4-flash-free",
    "auth": {
      "mode": "opencode",
      "provider_id": "opencode"
    }
  }
}
```

Suggested location for a global installation:

```text
~/.config/opencode/orchestrator.json
```

This file contains **no credentials**. It is state for the orchestrator installer, not an alternative authentication database.

## Profile catalog

Repository profiles should live under:

```text
profiles/low-cost/
```

Each profile declares:

- stable profile ID;
- provider ID;
- model ID;
- human-readable name;
- authentication mode;
- whether OpenCode `/connect` or `opencode auth login` is expected;
- whether extra provider configuration is required;
- notes and last verification date.

Profiles are presets, not guarantees of perpetual free availability.

Free-tier limits and model catalogs change. A profile must always carry a verification date.

## Authentication policy

The installer must **never** edit OpenCode credential values directly.

OpenCode documents provider credentials as being managed by `/connect` / `opencode auth login`, with credentials stored in OpenCode's own auth store.

The installer may:

1. run `opencode auth list` to detect configured providers;
2. explain the required provider connection step;
3. pause or exit cleanly when authentication is missing;
4. resume configuration after the provider is connected.

The installer must not print, copy, parse or back up credential values as part of profile selection.

## Provider allowlist interaction

The current repository uses:

```json
"enabled_providers": ["openai", "opencode"]
```

This is incompatible with an arbitrary future Low-Cost provider unless the installer updates the allowlist.

Two designs must be evaluated:

### Option A: dynamic allowlist

Keep `enabled_providers`, but have the installer add the selected Low-Cost provider.

Advantages:

- explicit provider surface;
- predictable model list.

Disadvantages:

- installer must safely merge configuration;
- switching profiles requires configuration mutation.

### Option B: remove the allowlist

Let OpenCode expose providers for which the user has configured credentials.

Advantages:

- simpler provider extensibility;
- less installer mutation;
- better fit for a public repository.

Disadvantages:

- more providers may appear in the model picker;
- less restrictive by default.

**No option is accepted yet.**

## Proposed interactive setup flow

```text
Configure Low-Cost Worker?
        |
        +-- No --> install orchestration without economic worker
        |
        +-- Yes
              |
              v
       List profile presets
              |
              +-- OpenCode preset
              +-- Other known preset
              +-- Custom provider/model
              |
              v
       Check provider availability/auth
              |
       +------+------+
       |             |
     ready        missing
       |             |
       |        show /connect or
       |        auth instructions
       |             |
       +------<------+
              |
              v
       validate model availability
              |
              v
       render low-cost-worker agent
              |
              v
       save non-secret orchestrator state
```

## Rendering strategy

The installed `low-cost-worker.md` ultimately needs a concrete OpenCode model ID in its frontmatter:

```yaml
model: provider/model
```

Therefore the installer should render the final worker from a template or patch the model field in the installation target.

The repository source should not require users to manually edit agent prompts for each provider change.

Potential source layout:

```text
.opencode/
  agents/
    luna-lead.md
    luna-worker.md
    luna-worker-xhigh.md
    terra-diagnostician.md
    terra-planner.md
    strategic-advisor.md

templates/
  low-cost-worker.md

profiles/
  low-cost/
    README.md
    opencode-deepseek-v4-flash-free.json
    custom.example.json
```

## Provider-specific policy

The generic worker prompt must contain only role-level rules.

Provider-specific restrictions such as data retention, privacy or free-tier conditions must not be hard-coded as universal Low-Cost Worker behavior.

Those concerns belong to profile metadata and documentation.

## Migration from `deepseek-worker`

A future implementation should:

1. create `low-cost-worker`;
2. update `luna-lead` routing references;
3. update setup scripts and validation;
4. remove managed legacy `deepseek-worker.md` only after backup;
5. preserve the current DeepSeek configuration as the first built-in profile;
6. keep the master branch unchanged until the new flow is tested end to end.

## Non-goals for this ADR

This ADR does not yet implement:

- automatic provider discovery beyond OpenCode-supported commands;
- ranking free tiers;
- automatic selection of the cheapest provider;
- provider health monitoring;
- multi-provider pools;
- automatic failover between different models.

Those capabilities may be evaluated after the single-profile abstraction is stable.

## Acceptance criteria

Promote this design only if a prototype can demonstrate:

- Linux/WSL and Windows setup parity;
- no credential manipulation by the orchestrator;
- successful selection of the current DeepSeek free profile;
- successful configuration of at least one second provider/model profile;
- safe backups before profile changes;
- deterministic generation of `low-cost-worker`;
- clean disable path when no Low-Cost Worker is desired;
- no regression to Luna/Terra routing.

## References

- OpenCode providers: https://opencode.ai/docs/providers/
- OpenCode models: https://opencode.ai/docs/models/
- OpenCode configuration: https://opencode.ai/docs/config/
