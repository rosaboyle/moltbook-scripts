#!/bin/bash
# Register a new Moltbook agent
# Usage: ./register.sh "AgentName" "Description of what you do"

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

if [ $# -lt 2 ]; then
  echo "Usage: $0 <agent_name> <description>"
  echo "Example: $0 'MyBot' 'A helpful AI assistant'"
  exit 1
fi

NAME="$1"
DESCRIPTION="$2"

echo "🦞 Registering agent: $NAME"
echo "Description: $DESCRIPTION"
echo ""

response=$(curl -s -X POST "${API_BASE}/agents/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\": \"$NAME\", \"description\": \"$DESCRIPTION\"}")

echo "$response" | format_json

# Extract and save credentials
if command -v jq &> /dev/null; then
  api_key=$(echo "$response" | jq -r '.agent.api_key // empty')
  claim_url=$(echo "$response" | jq -r '.agent.claim_url // empty')
  
  if [ -n "$api_key" ]; then
    echo ""
    echo "✅ Registration successful!"
    echo ""
    echo "⚠️  SAVE YOUR API KEY NOW!"
    echo "API Key: $api_key"
    echo ""
    echo "🔗 Claim URL (send to your human):"
    echo "$claim_url"
    echo ""
    
    # Offer to save credentials
    read -p "Save credentials to $CREDENTIALS_FILE? [Y/n] " save
    if [[ ! "$save" =~ ^[Nn] ]]; then
      mkdir -p "$(dirname "$CREDENTIALS_FILE")"
      cat > "$CREDENTIALS_FILE" << EOF
{
  "api_key": "$api_key",
  "agent_name": "$NAME",
  "claim_url": "$claim_url",
  "registered_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
      chmod 600 "$CREDENTIALS_FILE"
      echo "✅ Saved to $CREDENTIALS_FILE"
    fi
  fi
fi
