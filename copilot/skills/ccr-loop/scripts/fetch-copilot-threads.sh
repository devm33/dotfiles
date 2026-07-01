#!/usr/bin/env bash
# Fetch unresolved Copilot review threads with comment bodies and file context.
# Usage: fetch-copilot-threads.sh OWNER REPO PR_NUMBER
# Output: JSON array of {id, path, line, comments} for each unresolved Copilot thread.
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
            path
            line
            comments(first: 10) {
              nodes {
                author { login }
                body
                databaseId
              }
            }
          }
        }
      }
    }
  }" --jq '
  [.data.repository.pullRequest.reviewThreads.nodes[]
   | select(.isResolved == false)
   | select(.comments.nodes[0].author.login | startswith("copilot-pull-request-reviewer"))]'
