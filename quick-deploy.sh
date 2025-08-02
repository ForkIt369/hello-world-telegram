#!/bin/bash

# Quick Deploy Script for Hello World Telegram Mini App
# Run this on your local machine

echo "🚀 Deploying Hello World Telegram Mini App to broquests.com"

# Configuration
APP_NAME="hello-world"
SERVER_IP="157.245.12.58"
SERVER_USER="root"  # Change to 'deploy' if that's your user

# Build the app locally
echo "📦 Building the app..."
npm install
npm run build

# Create deployment package
echo "📦 Creating deployment package..."
cat > deploy-on-server.sh << 'EOF'
#!/bin/bash
cd /opt/telegram-apps/hello-world

# Create Docker network if it doesn't exist
docker network create web 2>/dev/null || true

# Build and run the container
docker build -t hello-world-app .
docker stop hello-world 2>/dev/null || true
docker rm hello-world 2>/dev/null || true

# Run with Traefik labels for automatic SSL
docker run -d \
  --name hello-world \
  --network web \
  --restart unless-stopped \
  -e VITE_TELEGRAM_BOT_TOKEN=7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg \
  -e VITE_TELEGRAM_BOT_USERNAME=hello_world_bot \
  -e VITE_WEBAPP_URL=https://hello-world.broquests.com \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.hello-world.rule=Host(\`hello-world.broquests.com\`)" \
  -l "traefik.http.routers.hello-world.tls=true" \
  -l "traefik.http.routers.hello-world.tls.certresolver=letsencrypt" \
  -l "traefik.http.services.hello-world.loadbalancer.server.port=80" \
  hello-world-app

echo "✅ Deployment complete!"
echo "🌐 App should be available at: https://hello-world.broquests.com"
EOF

# Create a simple Dockerfile for production
cat > Dockerfile.prod << 'EOF'
FROM nginx:alpine
COPY dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Create nginx config
cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
EOF

echo ""
echo "📋 Manual deployment steps:"
echo ""
echo "1. Copy files to your server:"
echo "   scp -r dist ${SERVER_USER}@${SERVER_IP}:/opt/telegram-apps/hello-world/"
echo "   scp Dockerfile.prod ${SERVER_USER}@${SERVER_IP}:/opt/telegram-apps/hello-world/Dockerfile"
echo "   scp nginx.conf ${SERVER_USER}@${SERVER_IP}:/opt/telegram-apps/hello-world/"
echo "   scp deploy-on-server.sh ${SERVER_USER}@${SERVER_IP}:/opt/telegram-apps/hello-world/"
echo ""
echo "2. SSH into your server:"
echo "   ssh ${SERVER_USER}@${SERVER_IP}"
echo ""
echo "3. Run the deployment script:"
echo "   cd /opt/telegram-apps/hello-world"
echo "   chmod +x deploy-on-server.sh"
echo "   ./deploy-on-server.sh"
echo ""
echo "4. Update DNS (if needed):"
echo "   Add A record: hello-world.broquests.com → ${SERVER_IP}"
echo ""
echo "5. Configure your Telegram bot:"
echo "   Open @BotFather"
echo "   /setmenubutton"
echo "   Select your bot"
echo "   Enter URL: https://hello-world.broquests.com"