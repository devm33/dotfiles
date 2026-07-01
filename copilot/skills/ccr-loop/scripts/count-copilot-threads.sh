#!/usr/bin/env bash
# Count unresolved review threads authored by Copilot.
# Usage: count-copilot-threads.sh OWNER REPO PR_NUMBER
set -euo pipefail
OWNER=$1 REPO=$2 PR=$3

gh api graphql --paginate -f query="
  query(\$cursor: String) {
    repository(owner: \"$OWNER\", name: \"$REPO\") {
      pullRequest(number: $PR) {
        reviewThreads(first: 100, after: \$cursor) {
          pageInfo { hasNextPage endCursor }
          nodes {
            id
            isResolved
            comments(first: 1) {
              nodes { author { login } }
            }
          }
        }
      }
    }
  }" --jq '
  [.data.repository.pullRequest.reviewThreads.nodes[]
   | select(.isResolved == false)
   | select(.comments.nodes[0].author.login | startswith("copilot-pull-request-reviewer"))]
  | length'
