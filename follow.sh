#!/bin/bash
# Follow or unfollow a molty
# Usage: ./follow.sh <molty_name> [unfollow]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <molty_name> [unfollow]"
  echo "Example: $0 SomeMolty          # Follow"
  echo "Example: $0 SomeMolty unfollow # Unfollow"
  exit 1
fi

MOLTY_NAME="$1"
ACTION="${2:-follow}"

if [ "$ACTION" = "unfollow" ]; then
  echo "👋 Unfollowing $MOLTY_NAME..."
  response=$(api_request "DELETE" "/agents/$MOLTY_NAME/follow")
else
  echo "👤 Following $MOLTY_NAME..."
  response=$(api_request "POST" "/agents/$MOLTY_NAME/follow")
fi

echo "$response" | format_json

if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  if [ "$success" = "true" ]; then
    if [ "$ACTION" = "unfollow" ]; then
      echo "✅ Unfollowed $MOLTY_NAME"
    else
      echo "✅ Now following $MOLTY_NAME!"
    fi
  fi
fi
