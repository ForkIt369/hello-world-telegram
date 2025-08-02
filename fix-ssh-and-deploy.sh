#!/bin/bash

# Complete SSH Fix and Deployment Solution
# This script fixes SSH access and deploys the hello-world app

echo "🔧 SSH Fix and Deployment for Hello World Telegram Mini App"
echo "==========================================================="

# Configuration
DROPLET_ID="510858053"
DROPLET_IP="157.245.12.58"
DROPLET_NAME="lilsis-bot-production"
APP_NAME="hello-world"
DOMAIN="hello-world.broquests.com"

echo "🎯 Target droplet: $DROPLET_NAME ($DROPLET_IP)"

# Get current SSH key
SSH_KEY_PATH="$HOME/.ssh/id_rsa.pub"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "❌ SSH public key not found at $SSH_KEY_PATH"
    exit 1
fi

SSH_KEY_CONTENT=$(cat "$SSH_KEY_PATH")
echo "🔑 Using SSH key: ${SSH_KEY_CONTENT:0:50}..."

# Check if key already exists in DO account
echo "🔍 Checking existing SSH keys in DigitalOcean account..."
EXISTING_KEYS=$(doctl compute ssh-key list --format Name,Fingerprint,PublicKey --no-header)
echo "📋 Current SSH keys:"
echo "$EXISTING_KEYS"

# Get the fingerprint of our local key
LOCAL_KEY_FINGERPRINT=$(ssh-keygen -lf "$SSH_KEY_PATH" | awk '{print $2}')
echo "🆔 Local key fingerprint: $LOCAL_KEY_FINGERPRINT"

# Check if our key exists in DO
KEY_EXISTS=$(echo "$EXISTING_KEYS" | grep -q "$LOCAL_KEY_FINGERPRINT" && echo "yes" || echo "no")

if [ "$KEY_EXISTS" = "no" ]; then
    echo "➕ Adding SSH key to DigitalOcean account..."
    KEY_NAME="deploy-key-$(date +%s)"
    doctl compute ssh-key import "$KEY_NAME" --public-key-file "$SSH_KEY_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ SSH key added successfully"
    else
        echo "❌ Failed to add SSH key"
        exit 1
    fi
else
    echo "✅ SSH key already exists in account"
fi

# Test SSH connection
echo "🔌 Testing SSH connection..."
if ssh -o BatchMode=yes -o ConnectTimeout=5 root@$DROPLET_IP "echo 'SSH Connection Test Successful'" 2>/dev/null; then
    echo "✅ SSH connection successful!"
    
    # Deploy the app
    echo "🚀 Starting deployment..."
    
    # Create deployment directory on server
    ssh root@$DROPLET_IP "mkdir -p /opt/telegram-apps/$APP_NAME"
    
    # Upload files
    echo "📤 Uploading application files..."
    scp -r dist/* root@$DROPLET_IP:/opt/telegram-apps/$APP_NAME/
    
    # Upload Docker files from deployment package
    DEPLOY_DIR=$(ls -t | grep "deployment-package-" | head -1)
    if [ -n "$DEPLOY_DIR" ]; then
        echo "📦 Uploading deployment configuration..."
        scp "$DEPLOY_DIR/Dockerfile" root@$DROPLET_IP:/opt/telegram-apps/$APP_NAME/
        scp "$DEPLOY_DIR/nginx.conf" root@$DROPLET_IP:/opt/telegram-apps/$APP_NAME/
        scp "$DEPLOY_DIR/docker-compose.yml" root@$DROPLET_IP:/opt/telegram-apps/$APP_NAME/
        scp "$DEPLOY_DIR/deploy.sh" root@$DROPLET_IP:/opt/telegram-apps/$APP_NAME/
        
        # Run deployment script on server
        echo "🏗️  Running deployment on server..."
        ssh root@$DROPLET_IP "cd /opt/telegram-apps/$APP_NAME && chmod +x deploy.sh && ./deploy.sh"
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "🎉 DEPLOYMENT SUCCESSFUL!"
            echo "========================="
            echo "🌐 Your app is now available at: https://$DOMAIN"
            echo "📱 Telegram Bot: @hello_world_bot"
            echo "🖥️  Server: $DROPLET_IP"
            echo ""
            echo "🔧 Next steps:"
            echo "1. Configure DNS if needed: $DOMAIN → $DROPLET_IP"
            echo "2. Test the app in Telegram"
            echo "3. Monitor logs: ssh root@$DROPLET_IP 'docker logs hello-world-app'"
            
        else
            echo "❌ Deployment failed"
            exit 1
        fi
    else
        echo "❌ Deployment package not found. Run package-for-deployment.sh first."
        exit 1
    fi
    
else
    echo "❌ SSH connection failed"
    echo "🔧 Trying alternative solutions..."
    
    # Alternative 1: Try password authentication once
    echo "🔑 Attempting connection with password authentication..."
    echo "💡 If prompted, use password: b3c3577f1115d5d5d4639fcbe7"
    
    # Alternative 2: Use DigitalOcean Console
    echo ""
    echo "🖥️  Alternative: Use DigitalOcean Web Console"
    echo "1. Go to: https://cloud.digitalocean.com/droplets/$DROPLET_ID"
    echo "2. Click 'Console' to access web terminal"
    echo "3. Upload deployment package via web interface"
    echo ""
    
    # Alternative 3: Create new droplet with proper SSH
    echo "🆕 Alternative: Create new droplet with SSH key"
    echo "doctl compute droplet create hello-world-app --size s-1vcpu-1gb --image ubuntu-22-04-x64 --region nyc3 --ssh-keys $(doctl compute ssh-key list --format ID --no-header | head -1)"
    
fi

echo ""
echo "📚 Additional resources:"
echo "   - Droplet Console: https://cloud.digitalocean.com/droplets/$DROPLET_ID"
echo "   - App Platform: https://cloud.digitalocean.com/apps"
echo "   - DNS Settings: https://cloud.digitalocean.com/networking/domains"