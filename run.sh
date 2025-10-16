#!/bin/bash

TOKEN="$1"
PER_PAGE=100
SLEEP_BETWEEN_CALLS=1

if [ -z "$TOKEN" ]; then
  echo "Usage: $0 <GITHUB_TOKEN>"
  exit 1
fi

PAGE=1
TOTAL_DELETED=0

while :; do
  echo "Getting page $PAGE..."
  RESPONSE=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/user/repos?per_page=$PER_PAGE&page=$PAGE")

  REPOS=$(echo "$RESPONSE" | jq -r '.[] | select(.fork == true) | .full_name')

  if [ -z "$REPOS" ]; then
    echo "No more forks found. Total forks deleted: $TOTAL_DELETED"
    break
  fi

  echo "$REPOS" | while read repo; do
    echo "🗑️  Deleting $repo ..."
    curl -s -X DELETE -H "Authorization: token $TOKEN" \
         "https://api.github.com/repos/$repo"
    ((TOTAL_DELETED++))
    sleep $SLEEP_BETWEEN_CALLS
  done

  ((PAGE++))
  sleep $SLEEP_BETWEEN_CALLS
done
