# ADR-0001: Context continuity in worker routing

- **Status:** Under Observation
- **Date:** 2026-08-12
- **Scope:** Worker selection and escalation policy
- **Decision owner:** project maintainers

## Context

The current routing strategy chooses a worker primarily by task risk, cost, sensitivity, integration depth, and the kind of uncertainty involved.

A real execution produced a useful additional signal: **continuity of worker context may itself have operational value**.

In the observed case, Luna Lead kept the existing Luna Worker instead of switching the task to DeepSeek. The worker had already inspected and modified the relevant execution path and was operating on tightly coupled runtime behavior.

The Lead justified continuity using three factors:

1. the task was on the critical integration path;
2. fidelity to the existing call graph and prior implementation phases mattered;
3. the same worker had already accumulated useful implementation context.

The observed worker session lasted roughly 17 minutes and involved 97 tool calls before the continuity question was raised.

The project does **not** currently treat this observation as an active routing rule.

## Hypothesis

Switching to a cheaper worker can increase total execution cost when the current worker already holds valuable implementation context.

A worker change may introduce a **context reconstruction cost** through:

- repeated repository exploration;
- repeated hypothesis formation;
- loss of implicit knowledge about previous edits;
- inconsistent implementation choices;
- extra integration and validation work.

Therefore, routing cost may be better modeled as:

```text
Total routing cost
  = model cost
  + context reconstruction cost
  + integration risk
  + validation/rework cost
```

This document calls the possible routing effect a **continuity bonus**: an incumbent worker may receive additional preference when its accumulated context is demonstrably useful to the next tightly coupled task.

## Important non-decision

**No routing rule is changed by this ADR.**

Luna Lead must continue using the existing routing policy. Context continuity is being documented only as a candidate signal for future evaluation.

In particular, the Lead should not keep an expensive worker alive merely because it has already been used.

## Observed case 001

| Field | Observation |
| --- | --- |
| Date | 2026-08-12 |
| Task class | Runtime integration across tightly coupled execution paths |
| Incumbent worker | Luna Worker High |
| Approximate worker session | 17 minutes |
| Tool calls observed | 97 |
| Alternative considered | DeepSeek Worker |
| Worker retained | Yes |
| Reasons stated by Lead | critical-path integration, call-graph fidelity, continuity of context |
| Outcome | Pending broader evaluation |
| Evidence strength | Initial anecdotal evidence |

The underlying project-specific implementation details are intentionally omitted. The architectural observation is sufficient for this ADR.

## Questions to answer before implementation

1. Does reusing the same worker measurably improve correctness or completion time?
2. At what point does accumulated context become valuable enough to outweigh model cost?
3. Is tool-call count a useful proxy for accumulated context, or merely activity?
4. Is elapsed worker time a useful signal?
5. Should continuity matter only for tightly coupled implementation tasks?
6. Should it also affect troubleshooting and RCA?
7. Can continuity create anchoring, confirmation bias, or tunnel vision?
8. When should a fresh worker be preferred specifically because it has no prior assumptions?
9. Should independent review always favor a fresh worker even when implementation favors continuity?
10. Can useful continuity be detected from task relationships instead of arbitrary thresholds?
11. Would an explicit continuity rule make routing less predictable or harder to audit?

## Candidate signals

Signals that may indicate valuable continuity:

- same execution path or tightly coupled modules;
- direct dependency on edits made by the incumbent worker;
- unresolved hypotheses already investigated by that worker;
- current task is a correction or continuation of the worker's own prior change;
- expensive repository or runtime exploration would otherwise need to be repeated;
- integration consistency matters more than independent perspective.

Signals against continuity:

- task is independent and objectively verifiable;
- a fresh review perspective is desirable;
- incumbent worker is repeating failed hypotheses;
- model capability is the actual bottleneck;
- task has changed category, for example execution to architecture;
- continuity would keep a materially more expensive worker active without clear benefit.

## Possible future heuristic

A future implementation could use a rule conceptually similar to:

```text
if task_is_tightly_coupled_to_previous_worker_output
and incumbent_context_is_still_relevant
and no_capability_jump_is_required:
    penalize_worker_switch()
else:
    route_normally()
```

This is illustrative only. No thresholds or implementation details are approved yet.

## Evaluation plan

Collect at least **3 to 5 real routing cases** before changing prompts or routing behavior.

For each case record:

| Field | Description |
| --- | --- |
| Date | Observation date |
| Task class | Implementation, RCA, review, planning, etc. |
| Incumbent worker | Worker already holding context |
| Alternative | Worker/model that could replace it |
| Coupling | Low / Medium / High |
| Existing context | What the incumbent already knows or changed |
| Decision | Keep / Switch |
| Reason | Why |
| Result | Success, rework, failure, unknown |
| Extra exploration avoided | Yes / No / Unknown |
| Fresh-worker benefit observed | Yes / No / Unknown |
| Evidence | Supports / Contradicts / Neutral |

## Acceptance criteria

Consider promoting continuity into an explicit routing rule only if repeated observations suggest that:

- continuity reduces duplicated exploration or rework;
- tightly coupled implementation remains more consistent;
- the behavior is explainable and predictable;
- quota usage does not increase materially without measurable benefit;
- the Lead can distinguish valuable context from simple sunk cost.

## Rejection or revision criteria

Reject or substantially revise the hypothesis if:

- fresh workers consistently catch mistakes the incumbent misses;
- continuity produces anchoring or circular debugging;
- worker reuse increases quota significantly without measurable improvement;
- reliable signals for useful context cannot be identified;
- the heuristic makes routing unnecessarily complex or opaque.

## Possible outcomes

```text
UNDER OBSERVATION
       |
       +--> ACCEPTED    -> becomes an explicit routing signal
       |
       +--> REJECTED    -> evidence does not support the heuristic
       |
       +--> SUPERSEDED  -> replaced by a better routing model
```

## Evidence log

Add future observations below without changing the routing policy merely because a new row was added.

| # | Date | Case | Keep/Switch | Result | Evidence |
| --- | --- | --- | --- | --- | --- |
| 001 | 2026-08-12 | Critical runtime integration with accumulated Luna Worker context | Keep | Pending broader evaluation | Initial support |
