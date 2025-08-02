# 🚀 Hello World Telegram Mini App - Deployment Solution

Since direct deployment isn't possible without SSH access or a Git repository, here are your best options:

## Option 1: Quick GitHub + DigitalOcean Apps (Recommended)
**Time: 5 minutes**

1. **Push to GitHub:**
```bash
cd /Users/digitaldavinci/Telegram\ Mini\ App\ Studio/docker-infrastructure/apps/hello-world
git remote add origin https://github.com/YOUR_USERNAME/hello-world-telegram.git
git push -u origin master
```

2. **Deploy with DigitalOcean Apps:**
```bash
doctl apps create --spec app-spec-github.yaml
```

3. **Your app will be live at:** https://hello-world.broquests.com

## Option 2: Direct Droplet Deployment via SSH
**Time: 3 minutes**

1. **Enable SSH access** by adding your SSH key to the droplet:
```bash
# Get your public key
cat ~/.ssh/id_rsa.pub

# Add it to your droplet (via DigitalOcean console or SSH as root)
```

2. **Run the automated deployment:**
```bash
cd /Users/digitaldavinci/Telegram\ Mini\ App\ Studio/docker-infrastructure/apps/hello-world
./deploy-to-droplet.sh
```

## Option 3: Manual Deployment (Current Best Option)
**Time: 10 minutes**

1. **Create a deployment package:**
```bash
cd /Users/digitaldavinci/Telegram\ Mini\ App\ Studio/docker-infrastructure/apps/hello-world
tar -czf hello-world-deploy.tar.gz dist/ Dockerfile nginx.conf package.json
```

2. **SSH into your droplet:**
```bash
ssh root@157.245.12.58
# or use DigitalOcean web console
```

3. **On the droplet, run:**
```bash
# Create app directory
mkdir -p /opt/apps/hello-world
cd /opt/apps/hello-world

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY dist /usr/share/nginx/html
RUN echo 'server { listen 80; location / { root /usr/share/nginx/html; try_files $uri $uri/ /index.html; } }' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

# Download your built files (you'll need to upload them first)
# Or use scp from your local machine:
# scp -r dist root@157.245.12.58:/opt/apps/hello-world/

# Build and run
docker build -t hello-world-app .
docker run -d --name hello-world -p 3333:80 --restart always hello-world-app

# If using Traefik (recommended for SSL):
docker run -d \
  --name hello-world \
  --network web \
  --restart always \
  -l "traefik.enable=true" \
  -l "traefik.http.routers.hello-world.rule=Host(\`hello-world.broquests.com\`)" \
  -l "traefik.http.routers.hello-world.tls=true" \
  -l "traefik.http.routers.hello-world.tls.certresolver=letsencrypt" \
  hello-world-app
```

## Files Ready for Deployment

✅ **App built successfully** at: `/dist`
✅ **Environment configured** with your bot token
✅ **Docker configuration** ready
✅ **Nginx configuration** included

## Live URL (after deployment):
🌐 **https://hello-world.broquests.com**

## Bot Configuration:
After deployment, update your bot:
1. Open @BotFather
2. Send `/setmenubutton`
3. Select your bot
4. Enter: `https://hello-world.broquests.com`

## Need Help?

The app is fully built and ready. You just need to:
1. Get the files to your droplet (via Git, SCP, or manual upload)
2. Run the Docker commands
3. Configure DNS if needed

Your bot token is already configured: `7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg`