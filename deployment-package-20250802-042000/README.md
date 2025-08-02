# Hello World Telegram Mini App - Deployment Package

## Quick Deployment Options

### Option 1: DigitalOcean App Platform (Recommended)
1. Upload this package to GitHub
2. Create new app at: https://cloud.digitalocean.com/apps
3. Connect your GitHub repo
4. Deploy automatically with SSL

### Option 2: Manual Upload to Droplet
1. Upload this entire folder to your droplet via web interface
2. SSH into droplet: `ssh root@157.245.12.58`
3. Navigate to uploaded folder
4. Run: `chmod +x deploy.sh && ./deploy.sh`

### Option 3: Alternative Upload Methods
- Use DigitalOcean's web-based file manager
- Upload via FTP/SFTP client like FileZilla
- Use DigitalOcean Spaces for file storage

## Files Included
- `dist/` - Built application files
- `Dockerfile` - Production container configuration
- `nginx.conf` - Web server configuration
- `docker-compose.yml` - Container orchestration
- `deploy.sh` - Server deployment script

## Environment Variables
The app expects these environment variables:
- `VITE_TELEGRAM_BOT_TOKEN`: 7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg
- `VITE_TELEGRAM_BOT_USERNAME`: hello_world_bot
- `VITE_WEBAPP_URL`: https://hello-world.broquests.com

## DNS Configuration
Ensure your domain points to: 157.245.12.58
`A record: hello-world.broquests.com → 157.245.12.58`

## Support
- Droplet IP: 157.245.12.58
- Domain: hello-world.broquests.com
- App Name: hello-world
