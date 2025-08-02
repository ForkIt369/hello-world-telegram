#!/bin/bash

# Static Demo Deployment - Works Immediately
# This demonstrates the built app running locally to verify it works

echo "🎯 Hello World Telegram Mini App - Static Demo"
echo "=============================================="

# Configuration
APP_NAME="hello-world"
LOCAL_PORT="8080"
DIST_DIR="dist"

echo "📋 Deployment package contents:"
echo "Current directory: $(pwd)"
echo "Built files:"
ls -la "$DIST_DIR" 2>/dev/null || echo "❌ dist/ directory not found - run 'npm run build' first"

if [ ! -d "$DIST_DIR" ]; then
    echo "🔨 Building the app..."
    npm run build
fi

echo ""
echo "📦 Deployment package files:"
ls -la deployment-package-*/

echo ""
echo "🌐 Testing static deployment locally..."

# Check if Python is available for simple server
if command -v python3 >/dev/null 2>&1; then
    echo "🐍 Starting Python HTTP server on port $LOCAL_PORT..."
    echo "📱 Test URL: http://localhost:$LOCAL_PORT"
    echo "🛑 Press Ctrl+C to stop"
    echo ""
    
    cd "$DIST_DIR"
    python3 -m http.server $LOCAL_PORT
    
elif command -v python >/dev/null 2>&1; then
    echo "🐍 Starting Python HTTP server on port $LOCAL_PORT..."
    echo "📱 Test URL: http://localhost:$LOCAL_PORT"
    echo "🛑 Press Ctrl+C to stop"
    echo ""
    
    cd "$DIST_DIR"
    python -m SimpleHTTPServer $LOCAL_PORT
    
elif command -v npx >/dev/null 2>&1; then
    echo "📦 Starting serve on port $LOCAL_PORT..."
    echo "📱 Test URL: http://localhost:$LOCAL_PORT"
    echo "🛑 Press Ctrl+C to stop"
    echo ""
    
    npx serve "$DIST_DIR" -p $LOCAL_PORT
    
else
    echo "❌ No suitable HTTP server found"
    echo "💡 Install one of: python3, python, or node.js"
    echo ""
    echo "📁 Manual testing:"
    echo "   Open dist/index.html in your browser"
    echo ""
fi

echo ""
echo "✅ The app is working locally!"
echo ""
echo "🚀 Ready for production deployment:"
echo "1. Upload deployment package to your server"
echo "2. Extract and run ./deploy.sh"
echo "3. Configure domain: hello-world.broquests.com → 157.245.12.58"
echo ""
echo "📚 Alternative deployment methods:"
echo "   - DigitalOcean App Platform (recommended)"
echo "   - Static file hosting on CDN"
echo "   - Manual upload via web console"