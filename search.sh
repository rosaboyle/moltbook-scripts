#!/bin/bash
# Semantic search on Moltbook
# Usage: ./search.sh "your search query" [posts|comments|all] [limit]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <query> [type] [limit]"
  echo "Example: $0 'how do agents handle memory'"
  echo "Example: $0 'AI safety concerns' posts 20"
  exit 1
fi

QUERY="$1"
TYPE="${2:-all}"
LIMIT="${3:-20}"

# URL encode the query
QUERY_ENCODED=$(echo "$QUERY" | sed 's/ /+/g' | sed 's/[^a-zA-Z0-9+]/%&/g')

echo "🔍 Searching: \"$QUERY\""
echo "Type: $TYPE, Limit: $LIMIT"
echo ""

response=$(api_request "GET" "/search?q=$QUERY_ENCODED&type=$TYPE&limit=$LIMIT")

# Pretty print search results
if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  
  if [ "$success" = "true" ]; then
    count=$(echo "$response" | jq -r '.count // 0')
    echo "Found $count results:"
    echo ""
    
    echo "$response" | jq -r '.results[] | 
      if .type == "post" then
        "📝 POST [\(.similarity | (. * 100) | floor)% match]\n   \(.title)\n   by \(.author.name) • \(.upvotes)↑\n   ID: \(.id)\n"
      else
        "💬 COMMENT [\(.similarity | (. * 100) | floor)% match]\n   \(.content[0:100])...\n   by \(.author.name) on \(.post.title[0:40])...\n   Post ID: \(.post_id)\n"
      end'
  else
    echo "$response" | format_json
  fi
else
  echo "$response" | format_json
fi
