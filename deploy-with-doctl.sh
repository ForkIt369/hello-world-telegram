#!/bin/bash

# Deploy Hello World using DigitalOcean CLI (doctl)
# This bypasses SSH completely and uses DO's managed services

echo "🚀 Deploying Hello World with DigitalOcean CLI"
echo "=============================================="

# Configuration
APP_NAME="hello-world-telegram"
DOMAIN="hello-world.broquests.com"

# Check if doctl is authenticated
echo "🔑 Checking DigitalOcean CLI authentication..."
if ! doctl account get >/dev/null 2>&1; then
    echo "❌ DigitalOcean CLI not authenticated"
    echo "   Run: doctl auth init"
    echo "   Get token from: https://cloud.digitalocean.com/account/api/tokens"
    exit 1
fi

echo "✅ DigitalOcean CLI authenticated"

# Show account info
echo "📋 Account information:"
doctl account get

# Create App Platform specification
echo "📝 Creating App Platform specification..."
cat > app-spec.yaml << EOF
name: $APP_NAME
region: nyc
services:
- name: web
  source_dir: /
  github:
    repo: digitaldavinci/hello-world-telegram
    branch: main
    deploy_on_push: true
  run_command: npm start
  build_command: npm run build
  environment_slug: node-js
  instance_count: 1
  instance_size_slug: professional-xs
  http_port: 8080
  routes:
  - path: /
  envs:
  - key: VITE_TELEGRAM_BOT_TOKEN
    value: "7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg"
    scope: RUN_AND_BUILD_TIME
  - key: VITE_TELEGRAM_BOT_USERNAME
    value: "hello_world_bot"
    scope: RUN_AND_BUILD_TIME
  - key: VITE_WEBAPP_URL
    value: "https://$DOMAIN"
    scope: RUN_AND_BUILD_TIME
domains:
- domain: $DOMAIN
  type: PRIMARY
EOF

echo "✅ App specification created"

echo ""
echo "📋 Deployment options:"
echo ""
echo "1. 🚀 Create App Platform app (if you have GitHub repo):"
echo "   doctl apps create --spec app-spec.yaml"
echo ""
echo "2. 📁 List existing apps:"
echo "   doctl apps list"
echo ""
echo "3. 🗂️  Upload to Spaces as static site:"
echo "   doctl spaces create hello-world-static --region nyc3"
echo "   doctl spaces upload dist/* hello-world-static --recursive"
echo ""

# Try to list existing apps
echo "📋 Existing App Platform apps:"
doctl apps list || echo "No apps found or error accessing apps"

echo ""
echo "🌐 Static hosting option (immediate deployment):"
echo "   This creates a CDN-backed static site without GitHub"

# Create Spaces bucket for static hosting
BUCKET_NAME="hello-world-static-$(date +%s)"
echo "📦 Creating Spaces bucket: $BUCKET_NAME"

if doctl spaces create "$BUCKET_NAME" --region nyc3; then
    echo "✅ Spaces bucket created successfully"
    
    # Upload files
    echo "📤 Uploading built files to Spaces..."
    if doctl spaces upload dist/* "$BUCKET_NAME" --recursive; then
        echo "✅ Files uploaded successfully"
        
        # Make bucket public for website hosting
        echo "🌐 Configuring bucket for website hosting..."
        doctl spaces set-cors "$BUCKET_NAME" --cors-rules '{"allowed_origins":["*"],"allowed_methods":["GET"],"allowed_headers":["*"],"max_age_seconds":3600}'
        
        echo ""
        echo "✅ Static site deployed successfully!"
        echo "🌐 Your app is available at:"
        echo "   https://$BUCKET_NAME.nyc3.digitaloceanspaces.com"
        echo ""
        echo "🔧 To use custom domain ($DOMAIN):"
        echo "   1. Create CNAME record: $DOMAIN → $BUCKET_NAME.nyc3.digitaloceanspaces.com"
        echo "   2. Configure CDN endpoint in DigitalOcean control panel"
        
    else
        echo "❌ Failed to upload files"
    fi
else
    echo "❌ Failed to create Spaces bucket"
    echo "💡 You can still use the App Platform option with a GitHub repo"
fi

echo ""
echo "📚 Additional resources:"
echo "   - DigitalOcean Console: https://cloud.digitalocean.com"
echo "   - App Platform Apps: https://cloud.digitalocean.com/apps"
echo "   - Spaces: https://cloud.digitalocean.com/spaces"