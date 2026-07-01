---
name: merge-pr
description: Watch a PR until it merges, requeuing until merged
allowed-tools: "*"
---

# Merge PR

Monitor a PR until it merges. Requeue when CI fails until merged.

## Identify the PR

Use `gh pr view` on the current branch. If no PR exists, ask the user for a PR number.

```bash
gh pr view --json number,title,url,state,isDraft,mergeable,mergeStateStatus,headRefName,statusCheckRollup,reviewDecision,mergeQueueEntry
```

## Monitor Loop

**CRITICAL: Never exit or stop unless the PR has merged or a hard failure has occurred (same check failing 3+ times).** This skill's entire purpose is to persist and keep polling so the user doesn't have to babysit the PR. Waiting states (checks in progress, in merge queue, pending review) are NOT reasons to stop — they are reasons to reschedule and poll again.

**Use `manage_schedule`, not busy-sleep loops.** Do NOT sit in a `sleep 60` loop — that burns tokens and context while waiting. Instead, create a scheduled prompt that wakes you to re-check the PR, then end your turn. Each tick does one cheap `gh pr view` and reschedules as needed. This keeps token usage low between checks.

Pick the schedule interval based on what the PR is waiting on:

| State | Interval | Why |
| --- | --- | --- |
| Checks running / in merge queue | `2m` | CI is actively progressing |
| **Waiting only on PR approval** (mergeable, checks green, `reviewDecision` is `REVIEW_REQUIRED` or no approval yet) | `30m` | A human must act; polling fast wastes tokens |
| Changes requested | `30m` | A human must act |

On each tick, run one check and reschedule only if the appropriate interval changed:

```bash
gh pr view <number> --json state,mergeable,mergeStateStatus,isDraft,reviewDecision,statusCheckRollup,mergeQueueEntry
```

Decision per tick:

- **Merged?** → Report success, `manage_schedule` action `stop` the schedule. This is the ONLY normal exit condition.
- **Mergeable + checks green + approved?** → Merge (see below). Keep the schedule until state is `MERGED`.
- **Mergeable + checks green but waiting on approval** (`reviewDecision` not `APPROVED`) → Inform the user once that it's waiting for review, set the schedule to `30m`, end turn.
- **`mergeable` is `CONFLICTING`?** → Inform the user (cannot auto-resolve), set schedule to `30m`, end turn.
- **In merge queue?** → Keep the `2m` schedule. If dequeued due to failure, requeue and continue.
- **Checks in progress?** → Keep the `2m` schedule, end turn. Do NOT stop.
- **Checks failed?** → Handle failures (see below), then continue on the `2m` schedule.

When you change cadence, `stop` the old schedule and `create` a new one at the new interval (or just `create` if none is active). Always keep exactly one active schedule for the PR.

## Handle Failed Checks

1. Get failed check details and logs (`gh run view <run-id> --log-failed`).
2. If retriable (flaky test, infra timeout, network error) → rerun: `gh run rerun <run-id>`.
3. If dequeued from merge queue → re-enqueue: `gh pr merge <number> --merge-queue`.
4. If same check fails 3+ times → stop and report to user, it's likely a real failure.
5. Return to monitor loop.

## Merge

When ready (checks green, approved, no conflicts):

- If merge queue enabled → `gh pr merge <number> --merge-queue`, then monitor the queue.
- Otherwise → `gh pr merge <number> --squash || gh pr merge <number> --merge`.
- If conflicts → inform the user.

## Rules

- **NEVER quit, stop, or exit early.** The only valid exit conditions are: (1) PR merged, or (2) same check has failed 3+ times indicating a real failure.
- "Waiting" is not "done" — if you're waiting for checks, reviews, or the merge queue, keep a schedule active and keep polling.
- **Use `manage_schedule` to poll; do not busy-sleep.** End your turn after each tick so you don't burn tokens waiting.
- Keep exactly one active schedule for the PR. When changing cadence, `stop` the old one and `create` the new one.
- Slow the cadence to `30m` when the PR can only progress via human action (waiting on approval, changes requested, or conflicts); use `2m` while CI is active.
- Always `stop` the schedule once the PR is merged.
- Never force-merge or bypass required checks.
- Poll with `gh pr view --json statusCheckRollup`, not `gh pr checks --watch`.
- Use `gh` CLI for all GitHub operations.
- If you encounter transient errors (API timeouts, network issues), keep the schedule and retry on the next tick — do NOT treat these as reasons to stop.
