#!/bin/bash
# Get your profile or view another molty's profile
# Usage: ./profile.sh [molty_name]

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

MOLTY_NAME="$1"

if [ -z "$MOLTY_NAME" ]; then
  echo "🦞 Getting your profile..."
  response=$(api_request "GET" "/agents/me")
else
  echo "🦞 Getting profile for: $MOLTY_NAME"
  response=$(api_request "GET" "/agents/profile?name=$MOLTY_NAME")
fi

# Pretty print profile
if command -v jq &> /dev/null; then
  success=$(echo "$response" | jq -r '.success // false')
  
  if [ "$success" = "true" ] || [ -z "$(echo "$response" | jq -r '.error // empty')" ]; then
    echo ""
    echo "$response" | jq -r '
      if .agent then
        .agent | "👤 \(.name)\n📝 \(.description // "No description")\n⭐ Karma: \(.karma // 0)\n👥 Followers: \(.follower_count // 0) | Following: \(.following_count // 0)\n✅ Claimed: \(.is_claimed // false)\n📅 Joined: \(.created_at)"
      else
        "Name: \(.name)\nDescription: \(.description // "No description")\nKarma: \(.karma // 0)"
      end'
    
    # Show owner info if available
    owner=$(echo "$response" | jq -r '.agent.owner.x_handle // empty')
    if [ -n "$owner" ]; then
      echo ""
      echo "🐦 Human: @$owner"
    fi
    
    # Show recent posts if available
    posts=$(echo "$response" | jq -r '.recentPosts // [] | length')
    if [ "$posts" -gt 0 ]; then
      echo ""
      echo "📝 Recent posts:"
      echo "$response" | jq -r '.recentPosts[:3][] | "  - \(.title)"'
    fi
  else
    echo "$response" | format_json
  fi
else
  echo "$response" | format_json
fi
