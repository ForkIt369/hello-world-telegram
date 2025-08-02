#!/bin/bash

# Package Hello World App for SSH-Free Deployment
# This creates a ready-to-deploy package that can be uploaded via web interface

echo "📦 Packaging Hello World Telegram Mini App for Deployment"
echo "========================================================"

# Configuration
APP_NAME="hello-world"
SERVER_IP="157.245.12.58"
DOMAIN="hello-world.broquests.com"

# Create deployment directory
DEPLOY_DIR="deployment-package-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$DEPLOY_DIR"

echo "📁 Creating deployment package in: $DEPLOY_DIR"

# Copy built files
echo "📋 Copying built application files..."
cp -r dist/* "$DEPLOY_DIR/"

# Create Dockerfile for production
echo "🐳 Creating production Dockerfile..."
cat > "$DEPLOY_DIR/Dockerfile" << 'EOF'
FROM nginx:alpine

# Copy built app
COPY . /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx configuration
echo "⚙️  Creating nginx configuration..."
cat > "$DEPLOY_DIR/nginx.conf" << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    
    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    
    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Create docker-compose file
echo "🔧 Creating docker-compose configuration..."
cat > "$DEPLOY_DIR/docker-compose.yml" << EOF
version: '3.8'

services:
  hello-world:
    build: .
    container_name: hello-world-app
    restart: unless-stopped
    networks:
      - web
    environment:
      - VIRTUAL_HOST=$DOMAIN
      - LETSENCRYPT_HOST=$DOMAIN
      - LETSENCRYPT_EMAIL=admin@broquests.com
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.hello-world.rule=Host(\`$DOMAIN\`)"
      - "traefik.http.routers.hello-world.tls=true"
      - "traefik.http.routers.hello-world.tls.certresolver=letsencrypt"
      - "traefik.http.services.hello-world.loadbalancer.server.port=80"

networks:
  web:
    external: true
EOF

# Create deployment script for server
echo "🚀 Creating server deployment script..."
cat > "$DEPLOY_DIR/deploy.sh" << 'EOF'
#!/bin/bash

# Server-side deployment script
# Run this on the DigitalOcean droplet

echo "🚀 Deploying Hello World Telegram Mini App"

# Create app directory
sudo mkdir -p /opt/telegram-apps/hello-world
cd /opt/telegram-apps/hello-world

# Create Docker network if it doesn't exist
docker network create web 2>/dev/null || true

# Stop and remove existing container
docker-compose down 2>/dev/null || true
docker stop hello-world-app 2>/dev/null || true
docker rm hello-world-app 2>/dev/null || true

# Build and start the new container
docker-compose up -d --build

# Show status
docker ps | grep hello-world

echo "✅ Deployment complete!"
echo "🌐 App should be available at: https://hello-world.broquests.com"
EOF

chmod +x "$DEPLOY_DIR/deploy.sh"

# Create README with deployment instructions
echo "📝 Creating deployment instructions..."
cat > "$DEPLOY_DIR/README.md" << EOF
# Hello World Telegram Mini App - Deployment Package

## Quick Deployment Options

### Option 1: DigitalOcean App Platform (Recommended)
1. Upload this package to GitHub
2. Create new app at: https://cloud.digitalocean.com/apps
3. Connect your GitHub repo
4. Deploy automatically with SSL

### Option 2: Manual Upload to Droplet
1. Upload this entire folder to your droplet via web interface
2. SSH into droplet: \`ssh root@$SERVER_IP\`
3. Navigate to uploaded folder
4. Run: \`chmod +x deploy.sh && ./deploy.sh\`

### Option 3: Alternative Upload Methods
- Use DigitalOcean's web-based file manager
- Upload via FTP/SFTP client like FileZilla
- Use DigitalOcean Spaces for file storage

## Files Included
- \`dist/\` - Built application files
- \`Dockerfile\` - Production container configuration
- \`nginx.conf\` - Web server configuration
- \`docker-compose.yml\` - Container orchestration
- \`deploy.sh\` - Server deployment script

## Environment Variables
The app expects these environment variables:
- \`VITE_TELEGRAM_BOT_TOKEN\`: 7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg
- \`VITE_TELEGRAM_BOT_USERNAME\`: hello_world_bot
- \`VITE_WEBAPP_URL\`: https://hello-world.broquests.com

## DNS Configuration
Ensure your domain points to: $SERVER_IP
\`A record: hello-world.broquests.com → $SERVER_IP\`

## Support
- Droplet IP: $SERVER_IP
- Domain: $DOMAIN
- App Name: $APP_NAME
EOF

# Create a tarball for easy upload
echo "📦 Creating deployment archive..."
tar -czf "${APP_NAME}-deployment-$(date +%Y%m%d-%H%M%S).tar.gz" "$DEPLOY_DIR"

echo ""
echo "✅ Deployment package created successfully!"
echo ""
echo "📁 Package location: $DEPLOY_DIR"
echo "📦 Archive: ${APP_NAME}-deployment-$(date +%Y%m%d-%H%M%S).tar.gz"
echo ""
echo "🚀 Next steps:"
echo "1. Upload the deployment package to your droplet"
echo "2. Extract and run the deploy.sh script"
echo "3. Configure DNS if needed"
echo "4. Test at: https://$DOMAIN"
echo ""
echo "💡 Alternative: Use DigitalOcean App Platform for zero-config deployment"