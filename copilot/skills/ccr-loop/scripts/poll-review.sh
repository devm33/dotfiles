#!/usr/bin/env bash
# Poll for a new Copilot review after a trigger.
# Usage: poll-review.sh OWNER REPO PR_NUMBER BASELINE_REVIEW_COUNT [MAX_POLLS]
# Exits 0 and prints the latest review JSON when a new review arrives.
# Exits 1 if no new review appears within the polling window.
set -euo pipefail
OWNER=$1 REPO=$2 PR=$3 BASELINE=$4
MAX_POLLS=${5:-20}

for i in $(seq 1 "$MAX_POLLS"); do
  review=$(gh api "repos/$OWNER/$REPO/pulls/$PR/reviews" --jq '
    [.[] | select(.user.login == "copilot-pull-request-reviewer[bot]")] | last |
    {id, state, submitted_at}')
  count=$(gh api "repos/$OWNER/$REPO/pulls/$PR/reviews" --jq 'length')

  if [ "$count" -gt "$BASELINE" ] && [ -n "$review" ]; then
    echo "$review"
    exit 0
  fi

  echo "Poll $i/$MAX_POLLS: waiting 30s..." >&2
  sleep 30
done

echo "ERROR: No new Copilot review after $MAX_POLLS polls" >&2
exit 1
