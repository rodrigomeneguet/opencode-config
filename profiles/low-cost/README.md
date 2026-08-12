# Low-Cost Worker profiles

This directory is a **design/prototype catalog** for the `low-cost-worker` abstraction.

Nothing in this directory changes the installed orchestration yet.

## Principle

```text
Low-Cost Worker = stable orchestration role
Provider/model  = replaceable backend
```

The profile describes the backend without storing credentials.

## Intended flow

```text
setup.sh / setup.ps1
        |
        v
choose low-cost profile
        |
        v
check OpenCode-managed provider authentication
        |
        v
validate profile/model
        |
        v
render low-cost-worker.md
        |
        v
save non-secret selection state
```

## Files

- `profile.schema.json` — proposed profile schema
- `opencode-deepseek-v4-flash-free.json` — current DeepSeek free backend represented as a profile
- `custom.example.json` — example for a user-supplied provider/model

## Security boundary

Profiles MUST NOT contain:

- API keys;
- passwords;
- OAuth tokens;
- cookies;
- private keys;
- provider session data.

Authentication remains the responsibility of OpenCode and the selected provider.

## Availability boundary

A profile records a known configuration, not a promise that the model remains free or available.

Every built-in profile should include `verified_at` and be periodically rechecked before recommendations are made.

## Status

**PROTOTYPE ONLY.** See:

- `docs/decisions/ADR-0002-low-cost-worker-provider-profiles.md`
- `docs/decisions/ADR-0003-low-cost-worker-failure-and-fallback.md`
