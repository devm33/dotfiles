#!/usr/bin/env zsh
# Shared helpers for the worktree scripts (wt, wtrm, cr). Sourced, not executed.
# Kept in bin/lib/ (off $PATH) so it doesn't show up as a command.

# Resolve a user-supplied branch argument to the actual branch name, applying
# the devm33/ prefix unless the name is already prefixed or already exists as a
# local or remote branch.
#   wt_branch_name <name>  ->  echoes the resolved branch name
wt_branch_name() {
  local name="$1"
  if [[ "$name" == devm33/* ]] \
    || git show-ref --verify --quiet "refs/heads/$name" \
    || git show-ref --verify --quiet "refs/remotes/origin/$name"; then
    printf '%s' "$name"
  else
    printf '%s' "devm33/$name"
  fi
}

# Print the worktree path checked out on the given branch, or nothing.
#   wt_path_for_branch <branch> [worktree-list-porcelain]
# The second arg lets a caller reuse a single `git worktree list --porcelain`
# capture; when omitted it is computed here.
wt_path_for_branch() {
  local branch="$1"
  local list="${2:-$(git worktree list --porcelain)}"
  printf '%s' "$list" | awk -v branch="refs/heads/$branch" '
    /^worktree /{wt=$0}
    $0 == "branch " branch {sub(/^worktree /, "", wt); print wt; exit}
  '
}
