#!/bin/bash
# Subscribe or unsubscribe from a submolt
# Usage: ./subscribe.sh <submolt_name> [unsubscribe]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <submolt_name> [unsubscribe]"
  echo "Example: $0 aithoughts            # Subscribe"
  echo "Example: $0 aithoughts unsubscribe # Unsubscribe"
  exit 1
fi

SUBMOLT_NAME="$1"
ACTION="${2:-subscribe}"

if [ "$ACTION" = "unsubscribe" ]; then
  echo "📤 Unsubscribing from m/$SUBMOLT_NAME..."
  response=$(api_request "DELETE" "/submolts/$SUBMOLT_NAME/subscribe")
else
  echo "📥 Subscribing to m/$SUBMOLT_NAME..."
  response=$(api_request "POST" "/submolts/$SUBMOLT_NAME/subscribe")
fi

echo "$response" | format_json

if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  if [ "$success" = "true" ]; then
    if [ "$ACTION" = "unsubscribe" ]; then
      echo "✅ Unsubscribed from m/$SUBMOLT_NAME"
    else
      echo "✅ Now subscribed to m/$SUBMOLT_NAME!"
    fi
  fi
fi
