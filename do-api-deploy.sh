#!/bin/bash

# DigitalOcean API-based deployment
# This script uses DO's API to deploy without SSH access

echo "🚀 DigitalOcean API Deployment for Hello World"
echo "=============================================="

# Configuration
DO_TOKEN="${DO_TOKEN:-your_do_token_here}"
DROPLET_ID="${DROPLET_ID:-your_droplet_id_here}"
APP_NAME="hello-world"
DOMAIN="hello-world.broquests.com"

# Check if DO token is provided
if [ "$DO_TOKEN" = "your_do_token_here" ]; then
    echo "❌ Error: Please set your DigitalOcean API token"
    echo "   export DO_TOKEN=your_actual_token"
    echo "   Get token from: https://cloud.digitalocean.com/account/api/tokens"
    exit 1
fi

echo "🔑 Using DigitalOcean API for deployment..."

# Function to call DO API
call_do_api() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H "Authorization: Bearer $DO_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "https://api.digitalocean.com/v2$endpoint"
    else
        curl -s -X "$method" \
            -H "Authorization: Bearer $DO_TOKEN" \
            "https://api.digitalocean.com/v2$endpoint"
    fi
}

# List available droplets to find the right one
echo "📋 Listing your droplets..."
DROPLETS=$(call_do_api "GET" "/droplets")
echo "$DROPLETS" | jq -r '.droplets[] | "\(.id): \(.name) (\(.networks.v4[0].ip_address))"' 2>/dev/null || echo "Install jq for better output formatting"

# Get droplet info
if [ "$DROPLET_ID" = "your_droplet_id_here" ]; then
    echo ""
    echo "💡 Please set your droplet ID:"
    echo "   export DROPLET_ID=your_actual_droplet_id"
    echo ""
    echo "🔍 Available droplets listed above"
    echo "   Look for the one with IP: 157.245.12.58"
fi

# Create App Platform app specification
APP_SPEC=$(cat << EOF
{
  "spec": {
    "name": "$APP_NAME",
    "region": "nyc",
    "services": [
      {
        "name": "web",
        "build_command": "npm run build",
        "run_command": "npm start",
        "environment_slug": "node-js",
        "instance_count": 1,
        "instance_size_slug": "professional-xs",
        "http_port": 8080,
        "routes": [
          {
            "path": "/"
          }
        ],
        "envs": [
          {
            "key": "VITE_TELEGRAM_BOT_TOKEN",
            "value": "7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg",
            "scope": "RUN_AND_BUILD_TIME"
          },
          {
            "key": "VITE_TELEGRAM_BOT_USERNAME", 
            "value": "hello_world_bot",
            "scope": "RUN_AND_BUILD_TIME"
          },
          {
            "key": "VITE_WEBAPP_URL",
            "value": "https://$DOMAIN",
            "scope": "RUN_AND_BUILD_TIME"
          }
        ],
        "source_dir": "/",
        "github": {
          "repo": "your-username/hello-world-repo",
          "branch": "main",
          "deploy_on_push": true
        }
      }
    ],
    "domains": [
      {
        "domain": "$DOMAIN",
        "type": "PRIMARY"
      }
    ]
  }
}
EOF
)

echo ""
echo "📝 App Platform Specification:"
echo "$APP_SPEC" | jq . 2>/dev/null || echo "$APP_SPEC"

echo ""
echo "🚀 Deployment Options:"
echo ""
echo "1. 📱 DigitalOcean App Platform (Recommended)"
echo "   - Zero SSH required"
echo "   - Automatic SSL certificates"
echo "   - Auto-scaling and monitoring"
echo "   - GitHub integration"
echo ""
echo "2. 🖥️  Web Console Deployment"
echo "   - Go to: https://cloud.digitalocean.com/droplets"
echo "   - Use the web console to upload files"
echo "   - No SSH keys needed"
echo ""
echo "3. 🗂️  Spaces Upload"
echo "   - Upload to DigitalOcean Spaces"
echo "   - Serve as static website"
echo "   - CDN acceleration included"

# Save the app spec for manual use
echo "$APP_SPEC" > app-platform-spec.json
echo ""
echo "✅ App Platform specification saved to: app-platform-spec.json"

echo ""
echo "🔧 Next Steps:"
echo "1. Create GitHub repo with your hello-world code"
echo "2. Update the repo URL in app-platform-spec.json"
echo "3. Create app: doctl apps create --spec app-platform-spec.json"
echo "4. Or use web interface: https://cloud.digitalocean.com/apps"