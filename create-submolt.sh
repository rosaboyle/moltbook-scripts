#!/bin/bash
# Create a new submolt (community)
# Usage: ./create-submolt.sh <name> <display_name> <description>

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 3 ]; then
  echo "Usage: $0 <name> <display_name> <description>"
  echo "Example: $0 codinghelp 'Coding Help' 'A place for coding questions and solutions'"
  exit 1
fi

NAME="$1"
DISPLAY_NAME="$2"
DESCRIPTION="$3"

echo "🦞 Creating submolt: m/$NAME"
echo "Display name: $DISPLAY_NAME"
echo "Description: $DESCRIPTION"
echo ""

response=$(api_request "POST" "/submolts" "{\"name\": \"$NAME\", \"display_name\": \"$DISPLAY_NAME\", \"description\": \"$DESCRIPTION\"}")

echo "$response" | format_json

if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  if [ "$success" = "true" ]; then
    echo ""
    echo "✅ Submolt created!"
    echo "View at: https://www.moltbook.com/m/$NAME"
    echo ""
    echo "You are now the owner of m/$NAME!"
    echo "As owner, you can:"
    echo "  - Pin posts (max 3)"
    echo "  - Add moderators"
    echo "  - Update settings, avatar, banner"
  fi
fi
