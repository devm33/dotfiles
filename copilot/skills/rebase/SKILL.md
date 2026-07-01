---
name: rebase
description: Rebase the current branch onto the main branch, resolving conflicts with semantic understanding of both sides' intent
user-invocable: true
allowed-tools: "*"
---

# Semantic Rebase

Rebase the current branch onto the main branch, resolving any conflicts by understanding what both sides intended rather than mechanically picking lines.

## Steps

1. **Prepare**: Ensure the working tree is clean. If there are uncommitted changes, stash them.

2. **Fetch and identify the main branch**:
   ```bash
   git fetch origin
   main_branch=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')
   ```

3. **Understand the landscape before rebasing**:
   - Run `git log --oneline origin/$main_branch..HEAD` to see the current branch's commits.
   - Run `git log --oneline HEAD..origin/$main_branch` to see what's new on main.
   - Read commit messages and diffs to understand the *intent* behind each change.

4. **Start the rebase**:
   ```bash
   git rebase origin/$main_branch
   ```

5. **Resolve conflicts semantically**: If conflicts arise, apply the Conflict Resolution Philosophy below. After resolving each file, `git add` it and `git rebase --continue`.

6. **Restore stashed changes**: If you stashed changes in step 1, run `git stash pop`. Resolve any conflicts from the restore.

7. **Validate**: Once the rebase completes and any stashed changes are restored:
   - Check that the code compiles / lints if tooling is available.
   - Run tests if a test command is readily available.
   - If anything is broken, fix it as a fixup commit or amend the relevant commit.

8. **Push the rebased branch**:
   ```bash
   git push --force-with-lease
   ```

9. **Report a summary**: Tell the user how many commits were rebased, whether conflicts occurred and how they were resolved, and whether build/tests pass.

## Conflict Resolution Philosophy

The goal is to understand changes *semantically*, not syntactically:

- **Read surrounding context**: Don't just look at conflict markers. Read the full function/class/module to understand the conflicting code's role.
- **Check commit messages**: They explain *why* a change was made, which is critical for correct resolution.
- **Preserve intent from both sides**: The correct resolution usually isn't "pick one side" — it's a new version that achieves what both sides wanted.
- **Watch for indirect breakage**: A conflict-free rebase can still break things if main changed an interface the branch depends on. Look for renamed functions, changed signatures, moved files, or updated dependencies.
