---
name: ccr-loop
description: Request Copilot code review, address feedback, and iterate until Copilot approves the PR. Creates the PR and commits local changes if needed. Monitors CI and fixes failures including flaky tests.
allowed-tools: "*"
---

# Copilot Code Review Loop

Request Copilot code review on the current branch's PR, address all review comments, and iterate until Copilot approves or deems the pull request requiring human review.

## Prerequisites

- The `gh` CLI is installed and authenticated
- You are in a git repository with a remote configured
- Helper scripts are in `scripts/` relative to this skill's base directory. Run them as `$SKILL_DIR/scripts/...` where `$SKILL_DIR` is the base directory shown in skill-context.

## Critical Invariants

1. **Review trigger rule**: Draft PRs require explicit reviewer request. Non-draft PRs are auto-reviewed on push — never manually request review via the `requested_reviewers` API for non-draft PRs.
2. **New review detection**: Never treat zero unresolved threads as success until a new Copilot review has arrived after the latest trigger (review count must exceed baseline).
3. **Always check threads**: Copilot can submit an APPROVED review that still contains unresolved inline comments. Always check unresolved thread count regardless of review state.
4. **Only act on Copilot comments**: Only address review comments from `copilot-pull-request-reviewer[bot]`. Ignore all others.
5. **Thread replies only**: Never leave top-level PR comments. Only reply within existing review comment threads.
6. **Completion requires all three**: (a) a Copilot review was submitted after the latest push/trigger, (b) zero unresolved Copilot review threads, (c) CI is green.

## Step 0: Ensure PR Exists

Check for uncommitted changes:

```bash
git status --short
```

If there are staged or unstaged changes:
1. Stage all changes: `git add -A`
2. Commit with an appropriate message.
3. Push: `git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)`

Check if a PR exists:

```bash
gh pr view --json number 2>/dev/null
```

If no PR exists, create one:
1. Check for a PR template in `.github/PULL_REQUEST_TEMPLATE.md` or `.github/PULL_REQUEST_TEMPLATE/`.
2. Review the diff: `git log --oneline origin/main..HEAD` and `git diff origin/main --stat`
3. Create a draft PR: `gh pr create --draft --title "..." --body "..."`
   - Conform to the repo's PR template if one exists.

## Step 1: Identify the PR

```bash
gh pr view --json number,url,headRefName,state,reviewDecision,isDraft
```

Extract **owner** and **repo** from the remote:

```bash
git remote get-url origin
```

## Step 2: Record Baseline and Trigger Review

Record current review count: `gh api repos/{owner}/{repo}/pulls/{pr-number}/reviews --jq 'length'`. Save as `baseline_review_count`.

**Trigger review per Invariant 1:**

- **Draft PR**: `gh api repos/{owner}/{repo}/pulls/{pr-number}/requested_reviewers --method POST -f 'reviewers[]=copilot-pull-request-reviewer[bot]'`
- **Non-draft PR**: Copilot reviews automatically on push. If no new push since the latest Copilot review, inspect existing review/threads instead of waiting.

## Step 3: Wait for Copilot Review

```bash
scripts/poll-review.sh {owner} {repo} {pr-number} {baseline_review_count}
```

Polls every 30s for up to 10 minutes. Exits 0 and prints the latest review JSON on success.

## Step 4: Check Review Result

```bash
scripts/count-copilot-threads.sh {owner} {repo} {pr-number}
```

- **> 0** → Step 5.
- **== 0** → Step 8 (CI check).

Only Copilot-authored threads are counted. Non-Copilot threads do not block the loop. Do NOT rely solely on `reviewDecision` — draft PRs may show `REVIEW_REQUIRED` even after approval.

## Step 5: Address Copilot Review Comments

```bash
scripts/fetch-copilot-threads.sh {owner} {repo} {pr-number}
```

Returns a JSON array. Each element has: `id` (thread node ID), `path`, `line`, and `comments` (with `author`, `body`, `databaseId`).

**Critically evaluate each Copilot comment.** Copilot review is automated — its suggestions are not always correct. For each thread:

- **Valid feedback**: Make the code change, commit, push. Reply with the short commit SHA using `in_reply_to` the first comment's `databaseId`:
  `gh api repos/{owner}/{repo}/pulls/{pr-number}/comments --method POST -f body="{sha}" -F in_reply_to={databaseId}`
  Then resolve: `scripts/resolve-thread.sh {thread-node-id}`

- **Invalid feedback**: Reply with a concise explanation. Then resolve: `scripts/resolve-thread.sh {thread-node-id}`

The resolve script verifies the mutation succeeded; report any failures.

**After resolving all threads**, re-run `scripts/count-copilot-threads.sh` to confirm zero remain. If any remain, repeat Step 5.

Group related fixes into focused commits. If one change addresses multiple comments, reply in all relevant threads.

## Step 6: Update PR Title and Description

After addressing all threads, update the PR to reflect the current state:

```bash
gh pr diff
gh pr edit {number} --title "New title" --body "Updated description"
```

Preserve the repo's PR template structure and any existing issue references.

## Step 7: Squash, Rebase, and Re-trigger Review

1. Squash all commits into one.
2. Invoke the **rebase** skill to rebase onto main with semantic conflict resolution.
3. Return to **Step 2** (record new baseline, trigger review per draft status, poll).

## Step 8: Wait for CI to Pass

```bash
gh pr checks {number} --watch --fail-fast
```

If CI fails:
1. Examine: `gh pr checks {number}` and `gh run view {run-id} --log-failed`
2. If flaky (intermittent, unrelated to changes): `gh run rerun {run-id} --failed`. If it fails again, treat as real.
3. For real failures: fix, commit, push, return to **Step 2**.

## Loop Termination

- **Success**: All three conditions from Invariant 6 are met. Report the approval and stop.
- **Needs human review**: After 5 review rounds with no convergence (same comments keep appearing), report the status and stop.
