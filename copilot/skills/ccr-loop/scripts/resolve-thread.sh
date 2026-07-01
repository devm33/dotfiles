#!/usr/bin/env bash
# Resolve a review thread and verify success.
# Usage: resolve-thread.sh THREAD_NODE_ID
set -euo pipefail
THREAD_ID=$1

result=$(gh api graphql -f query="
  mutation {
    resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) {
      thread { id isResolved }
    }
  }" --jq '.data.resolveReviewThread.thread.isResolved')

if [ "$result" = "true" ]; then
  echo "Resolved: $THREAD_ID"
else
  echo "ERROR: Failed to resolve thread $THREAD_ID (got: $result)" >&2
  exit 1
fi
