# Deployment Instructions for Hello World Telegram Mini App

## Quick Deployment to broquests.com (157.245.12.58)

Since SSH access is not configured from this machine, follow these steps to deploy manually:

### 1. Connect to your server
```bash
ssh root@157.245.12.58
# or
ssh deploy@157.245.12.58
```

### 2. Create the app directory
```bash
mkdir -p /opt/telegram-apps/hello-world
cd /opt/telegram-apps/hello-world
```

### 3. Create the Dockerfile
```bash
cat > Dockerfile << 'EOF'
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF
```

### 4. Create nginx configuration
```bash
cat > nginx.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api {
        proxy_pass http://backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF
```

### 5. Upload the built app
From your local machine, run:
```bash
cd /Users/digitaldavinci/Telegram\ Mini\ App\ Studio/docker-infrastructure/apps/hello-world
scp -r dist/* root@157.245.12.58:/opt/telegram-apps/hello-world/
scp package*.json root@157.245.12.58:/opt/telegram-apps/hello-world/
scp -r src root@157.245.12.58:/opt/telegram-apps/hello-world/
scp -r public root@157.245.12.58:/opt/telegram-apps/hello-world/
scp *.config.* root@157.245.12.58:/opt/telegram-apps/hello-world/
scp tsconfig*.json root@157.245.12.58:/opt/telegram-apps/hello-world/
scp index.html root@157.245.12.58:/opt/telegram-apps/hello-world/
scp .env root@157.245.12.58:/opt/telegram-apps/hello-world/
```

### 6. Build and run with Docker
On the server:
```bash
cd /opt/telegram-apps/hello-world

# Build the Docker image
docker build -t hello-world-app .

# Run the container
docker run -d \
  --name hello-world \
  -p 3001:80 \
  --restart unless-stopped \
  hello-world-app
```

### 7. Configure Traefik (if not already done)
Add to your Traefik configuration:
```yaml
http:
  routers:
    hello-world:
      rule: "Host(`hello-world.broquests.com`)"
      service: hello-world
      tls:
        certResolver: letsencrypt
  
  services:
    hello-world:
      loadBalancer:
        servers:
          - url: "http://localhost:3001"
```

### 8. Update DNS
Add a subdomain for your app:
```
A Record: hello-world → 157.245.12.58
```

## Expected Live URLs:
- Development: https://hello-world.broquests.com
- Or with subdomain: https://app.broquests.com/hello-world

## Alternative: Use Docker Compose

Create docker-compose.yml on the server:
```yaml
version: '3.8'

services:
  hello-world:
    build: .
    container_name: hello-world-app
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.hello-world.rule=Host(`hello-world.broquests.com`)"
      - "traefik.http.routers.hello-world.tls.certresolver=letsencrypt"
      - "traefik.http.services.hello-world.loadbalancer.server.port=80"
    networks:
      - web

networks:
  web:
    external: true
```

Then run:
```bash
docker-compose up -d
```

## Verify Deployment
Once deployed, your app will be available at:
- https://hello-world.broquests.com (with proper DNS setup)
- http://157.245.12.58:3001 (direct access)

## Bot Configuration
Don't forget to update your bot's Web App URL in BotFather:
```
/setmenubutton
Select your bot
Enter URL: https://hello-world.broquests.com
```