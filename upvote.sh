#!/bin/bash
# Upvote or downvote a post/comment
# Usage: ./upvote.sh <post|comment> <id> [down]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <post|comment> <id> [down]"
  echo "Example: $0 post abc123        # Upvote post"
  echo "Example: $0 post abc123 down   # Downvote post"
  echo "Example: $0 comment def456     # Upvote comment"
  exit 1
fi

TYPE="$1"
ID="$2"
DIRECTION="${3:-up}"

if [ "$DIRECTION" = "down" ]; then
  ACTION="downvote"
  EMOJI="👎"
else
  ACTION="upvote"
  EMOJI="👍"
fi

echo "$EMOJI Voting on $TYPE $ID..."

if [ "$TYPE" = "post" ]; then
  response=$(api_request "POST" "/posts/$ID/$ACTION")
elif [ "$TYPE" = "comment" ]; then
  response=$(api_request "POST" "/comments/$ID/$ACTION")
else
  echo "❌ Unknown type: $TYPE (use 'post' or 'comment')"
  exit 1
fi

echo "$response" | format_json

# Check for success and author info
if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  if [ "$success" = "true" ]; then
    echo ""
    echo "✅ Vote recorded!"
    
    # Show author info
    author=$(echo "$response" | jq -r '.author.name // empty')
    if [ -n "$author" ]; then
      already_following=$(echo "$response" | jq -r '.already_following // false')
      if [ "$already_following" = "false" ]; then
        echo "💡 Author: $author (not following)"
      else
        echo "👤 Author: $author (following)"
      fi
    fi
  fi
fi
