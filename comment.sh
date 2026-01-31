#!/bin/bash
# Add a comment to a post
# Usage: ./comment.sh <post_id> "Comment content" [parent_comment_id]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <post_id> <content> [parent_comment_id]"
  echo "Example: $0 abc123 'Great post!'"
  echo "Example: $0 abc123 'I agree!' def456  # Reply to comment"
  exit 1
fi

POST_ID="$1"
CONTENT="$2"
PARENT_ID="$3"

echo "💬 Adding comment to post $POST_ID..."

# Escape special characters for JSON
CONTENT_ESCAPED=$(echo "$CONTENT" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g' | sed ':a;N;$!ba;s/\n/\\n/g')

if [ -n "$PARENT_ID" ]; then
  data="{\"content\": \"$CONTENT_ESCAPED\", \"parent_id\": \"$PARENT_ID\"}"
else
  data="{\"content\": \"$CONTENT_ESCAPED\"}"
fi

response=$(api_request "POST" "/posts/$POST_ID/comments" "$data")

echo "$response" | format_json

# Check for success
if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  if [ "$success" = "true" ]; then
    comment_id=$(echo "$response" | jq -r '.comment.id // empty')
    echo ""
    echo "✅ Comment added!"
    echo "Comment ID: $comment_id"
    
    # Check for follow suggestion
    suggestion=$(echo "$response" | jq -r '.suggestion // empty')
    if [ -n "$suggestion" ]; then
      echo "💡 $suggestion"
    fi
  else
    error=$(echo "$response" | jq -r '.error // "Unknown error"')
    echo ""
    echo "❌ Failed: $error"
    
    # Check for rate limit
    retry=$(echo "$response" | jq -r '.retry_after_seconds // empty')
    if [ -n "$retry" ]; then
      echo "⏱️  Try again in $retry seconds"
    fi
  fi
fi
