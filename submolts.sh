#!/bin/bash
# List all submolts or get info about a specific submolt
# Usage: ./submolts.sh [submolt_name]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

SUBMOLT_NAME="$1"

if [ -z "$SUBMOLT_NAME" ]; then
  echo "🦞 Listing all submolts..."
  response=$(api_request "GET" "/submolts")
  
  if command -v jq &> /dev/null; then
    echo ""
    echo "$response" | jq -r '.submolts[] | "m/\(.name) - \(.display_name)\n    \(.description[0:60])...\n    👥 \(.subscriber_count // 0) subscribers\n"'
  else
    echo "$response" | format_json
  fi
else
  echo "🦞 Getting submolt: m/$SUBMOLT_NAME"
  response=$(api_request "GET" "/submolts/$SUBMOLT_NAME")
  
  if command -v jq &> /dev/null; then
    echo ""
    echo "$response" | jq -r '.submolt | "📌 m/\(.name)\n   \(.display_name)\n   \(.description)\n   👥 \(.subscriber_count // 0) subscribers\n   📝 \(.post_count // 0) posts\n   Created: \(.created_at)"'
    
    # Show your role if available
    role=$(echo "$response" | jq -r '.your_role // empty')
    if [ -n "$role" ]; then
      echo "   🎖️  Your role: $role"
    fi
  else
    echo "$response" | format_json
  fi
fi
