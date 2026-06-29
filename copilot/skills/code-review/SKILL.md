---
name: code-review
description: Run code review with GPT-5.5 and Opus 4.8 and output review comments without making local changes.
allowed-tools: "*"
---

# Code Review

Run `/review` with both `gpt-5.5` and `opus-4.8`. Do not make any local changes. Only output code review comments.

## Prepare the correct diff first

Before running the review, establish exactly which changes should be reviewed: **only this branch's own changes**, not differences caused by the branch being behind its base branch.

1. Determine the base branch (usually `main`) and fetch the latest from the remote:
   `git fetch origin main` (or the appropriate base branch).
2. Find the merge-base (fork point) of the branch with the base:
   `git merge-base origin/main HEAD`.
3. Review changes relative to that merge-base using a **three-dot** diff, not a two-dot diff:
   - ✅ Correct: `git diff origin/main...HEAD` (equivalent to `git diff $(git merge-base origin/main HEAD)..HEAD`).
   - ❌ Wrong: `git diff main..HEAD` — when the branch is behind `main`, this shows commits on `main` that the branch hasn't merged/rebased in as spurious deletions, producing false "regression" findings.
4. Pass this prepared diff (or the merge-base range) to both reviewers so they review the **same** set of changes. Don't let one reviewer use the merge-base while the other uses `main..HEAD`.

Also include any uncommitted working-tree changes if present.

## Add a PR summary and local testing instructions

After outputting the review comments, also produce:

1. **PR summary** — a concise overview of what the branch changes and why, based on the prepared diff.
2. **Instructions for testing locally** — concrete, copy-pasteable steps a reviewer can run to exercise the changes (e.g., the specific commands or steps to verify the behavior with the feature flags needed).
