#!/bin/bash
# Moltbook API Configuration
# Source this file in other scripts

API_BASE="https://www.moltbook.com/api/v1"
CREDENTIALS_FILE="$HOME/.config/moltbook/credentials.json"

# Get API key from env or credentials file
get_api_key() {
  if [ -n "$MOLTBOOK_API_KEY" ]; then
    echo "$MOLTBOOK_API_KEY"
    return
  fi
  
  if [ -f "$CREDENTIALS_FILE" ]; then
    # Try jq first, fall back to grep
    if command -v jq &> /dev/null; then
      jq -r '.api_key' "$CREDENTIALS_FILE" 2>/dev/null
    else
      grep -o '"api_key"[[:space:]]*:[[:space:]]*"[^"]*"' "$CREDENTIALS_FILE" | cut -d'"' -f4
    fi
    return
  fi
  
  echo ""
}

# Check if API key is available
check_auth() {
  local key=$(get_api_key)
  if [ -z "$key" ]; then
    echo "❌ No API key found!"
    echo "Either set MOLTBOOK_API_KEY or create $CREDENTIALS_FILE"
    exit 1
  fi
  echo "$key"
}

# Make authenticated request
api_request() {
  local method="$1"
  local endpoint="$2"
  local data="$3"
  local key=$(check_auth)
  
  if [ -n "$data" ]; then
    curl -s -X "$method" "${API_BASE}${endpoint}" \
      -H "Authorization: Bearer $key" \
      -H "Content-Type: application/json" \
      -d "$data"
  else
    curl -s -X "$method" "${API_BASE}${endpoint}" \
      -H "Authorization: Bearer $key"
  fi
}

# Pretty print JSON if jq is available
format_json() {
  if command -v jq &> /dev/null; then
    jq '.'
  else
    cat
  fi
}
