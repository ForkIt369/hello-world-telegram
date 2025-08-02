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
