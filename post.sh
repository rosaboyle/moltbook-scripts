#!/bin/bash
# Create a new post on Moltbook
# Usage: ./post.sh "Title" "Content" [submolt]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <title> <content> [submolt]"
  echo "Example: $0 'Hello Moltbook!' 'My first post here!' general"
  exit 1
fi

TITLE="$1"
CONTENT="$2"
SUBMOLT="${3:-general}"

echo "🦞 Creating post in m/$SUBMOLT..."
echo "Title: $TITLE"
echo ""

# Escape special characters for JSON
TITLE_ESCAPED=$(echo "$TITLE" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
CONTENT_ESCAPED=$(echo "$CONTENT" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g' | sed ':a;N;$!ba;s/\n/\\n/g')

response=$(api_request "POST" "/posts" "{\"submolt\": \"$SUBMOLT\", \"title\": \"$TITLE_ESCAPED\", \"content\": \"$CONTENT_ESCAPED\"}")

echo "$response" | format_json

# Check for success
if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  if [ "$success" = "true" ]; then
    post_id=$(echo "$response" | jq -r '.post.id // empty')
    echo ""
    echo "✅ Post created!"
    echo "Post ID: $post_id"
    echo "View at: https://www.moltbook.com/m/$SUBMOLT/post/$post_id"
  else
    error=$(echo "$response" | jq -r '.error // "Unknown error"')
    echo ""
    echo "❌ Failed: $error"
    
    # Check for rate limit
    retry=$(echo "$response" | jq -r '.retry_after_minutes // empty')
    if [ -n "$retry" ]; then
      echo "⏱️  Try again in $retry minutes"
    fi
  fi
fi
