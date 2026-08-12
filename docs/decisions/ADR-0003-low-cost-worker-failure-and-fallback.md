# ADR-0003: Low-Cost Worker failure classification and fallback boundaries

- **Status:** Proposed
- **Date:** 2026-08-12
- **Scope:** Worker failure handling, retry policy and fallback semantics
- **Branch:** `feat/low-cost-worker-profiles`

## Context

A real run exposed a critical weakness in the current economic-worker path:

```text
DeepSeek Worker
  -> Free usage exceeded
  -> OpenCode SessionRetry
  -> repeated retries
  -> parent Luna Lead remains blocked
```

The observed behavior is not only a routing problem. It crosses two layers:

1. **orchestrator policy** — which worker should receive the task after a provider failure;
2. **OpenCode runtime behavior** — whether the failed child task ever returns control to the parent.

These layers must not be confused.

## Upstream limitation

OpenCode currently has reports showing that retryable session errors can be retried without a maximum attempt count and that task/subagent execution can remain blocked without a top-level timeout.

OpenCode also has an open feature request for native model fallback/failover.

Therefore, the orchestrator cannot guarantee automatic fallback solely through an agent prompt when OpenCode itself keeps the child session inside an internal retry loop.

## Decision direction

The Low-Cost Worker must be treated as **optional capacity**, never as a mandatory dependency of the main delivery path.

When control returns to Luna Lead with a provider-level failure, the Lead should classify the failure and choose a deterministic fallback.

## Failure classes

### Terminal provider failure

Examples:

- free quota exhausted;
- account quota exhausted;
- authentication invalid or expired;
- model not available;
- provider not available for the account;
- explicit unsupported-model response.

Desired policy:

```text
terminal provider failure
        |
        v
no same-provider retry
        |
        v
mark Low-Cost Worker unavailable for current session
        |
        v
fallback to Luna Worker High
```

### Transient provider failure

Examples:

- temporary timeout;
- transient rate limit;
- provider overload;
- recoverable 5xx response.

Desired policy after control returns:

```text
transient failure
      |
      v
one retry maximum
      |
  +---+---+
  |       |
success  fail
          |
          v
     Luna Worker High
```

The orchestrator should not create its own long retry storm.

### Task failure

Examples:

- tests fail;
- build fails;
- incorrect implementation;
- configuration syntax error;
- hypothesis disproved;
- tool output indicates a real technical defect.

These are not provider failures and must not automatically trigger a model fallback.

They belong to normal troubleshooting and escalation policy.

## Session circuit breaker

After a terminal Low-Cost provider failure returns to Luna Lead, the Lead should treat the Low-Cost Worker as unavailable for the remainder of that session unless there is explicit evidence that availability was restored.

Conceptually:

```text
low_cost_worker.available = false
reason = terminal_provider_failure
scope = current_session
```

This is intentionally session-scoped. A free tier may become available again later.

## Review independence

If the failed Low-Cost task was intended to be an independent review, fallback must preserve that property.

Incorrect fallback:

```text
Low-Cost reviewer fails
   -> Luna Lead reviews its own implementation
```

Preferred fallback:

```text
Low-Cost reviewer fails
   -> new Luna Worker High session
   -> independent review continues
```

## Runtime limitation

The policy above is executable only after OpenCode returns an error to the parent agent.

If OpenCode internally classifies a persistent provider error as retryable and retries indefinitely, the parent cannot apply the fallback policy because it has not regained control.

Until OpenCode provides a native retry ceiling, task timeout or model failover, the practical escape hatch may remain:

```text
user/manual cancellation
        |
        v
parent regains control
        |
        v
orchestrator fallback policy
```

The project must document this honestly.

## Future implementation options

### Option A: prompt-level fallback only

Pros:
- simple;
- no plugin/runtime dependency;
- works whenever control returns normally.

Cons:
- cannot interrupt OpenCode's internal retry loop.

### Option B: orchestration plugin / external watchdog

A future plugin could watch session state, detect a child stuck in retry, cancel it and resume with another worker.

Pros:
- could implement a true circuit breaker before OpenCode adds native failover.

Cons:
- substantially more complexity;
- must interact safely with session/task lifecycle;
- may become obsolete when upstream fallback lands.

### Option C: external provider router

A gateway such as a model router could implement provider failover before OpenCode sees the failure.

Pros:
- robust at provider layer.

Cons:
- may break provider-specific auth semantics;
- changes cost/privacy topology;
- conflicts with the goal of using native account subscriptions and free tiers.

## Proposed near-term policy

1. Keep prompt-level classification and fallback.
2. Do not claim it solves OpenCode's internal infinite retry behavior.
3. Track upstream fallback/timeout support.
4. Design the Low-Cost profile abstraction independently of runtime failover.
5. Revisit a watchdog plugin only if upstream does not address the issue and real usage shows the problem is frequent enough.

## Acceptance criteria for true automatic failover

The project should only advertise automatic Low-Cost failover when a test can demonstrate:

1. Low-Cost provider returns a terminal quota failure;
2. the failed worker is stopped without manual intervention;
3. Luna Lead regains control;
4. the same task is rerouted to Luna Worker High;
5. the Low-Cost Worker is not retried again in that session;
6. final delivery completes normally.

Until all six are reproducible, call the behavior **best-effort fallback**, not automatic failover.

## Upstream references

- anomalyco/opencode#21960 — unbounded `SessionRetry` attempts
- anomalyco/opencode#7602 — native model fallback/failover request
- anomalyco/opencode#20096 — task/tool execution can block without top-level timeout
- anomalyco/opencode#31008 — `Free usage exceeded` entering retry behavior
