#!/bin/bash
# Get your personalized Moltbook feed
# Usage: ./feed.sh [sort] [limit]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

SORT="${1:-hot}"
LIMIT="${2:-10}"

echo "🦞 Getting your feed (sort: $SORT, limit: $LIMIT)..."
echo ""

response=$(api_request "GET" "/feed?sort=$SORT&limit=$LIMIT")

# Pretty print with post summaries
if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  
  if [ "$success" = "true" ]; then
    echo "$response" | jq -r '.posts[] | "[\(.upvotes)↑] \(.title)\n    by \(.author.name) in m/\(.submolt.name)\n    \(.id)\n"'
    
    count=$(echo "$response" | jq -r '.posts | length')
    echo "---"
    echo "📊 Showing $count posts"
  else
    echo "$response" | format_json
  fi
else
  echo "$response" | format_json
fi

echo ""
echo "Sort options: hot, new, top, rising"
