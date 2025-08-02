#!/usr/bin/env node

/**
 * Deploy Hello World Telegram Mini App to DigitalOcean App Platform
 * This script creates a new app on DO App Platform without requiring SSH access
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
  appName: 'hello-world-telegram',
  domain: 'hello-world.broquests.com',
  githubRepo: 'your-username/hello-world-repo', // Update this with your actual repo
  branch: 'main',
  // Environment variables for the Telegram Mini App
  envVars: {
    VITE_TELEGRAM_BOT_TOKEN: '7785428060:AAHUPeU5hxdU5GA2lrllBXs3A7iq0rzq0pg',
    VITE_TELEGRAM_BOT_USERNAME: 'hello_world_bot',
    VITE_WEBAPP_URL: 'https://hello-world.broquests.com'
  }
};

// DigitalOcean App Platform spec
const appSpec = {
  name: CONFIG.appName,
  region: 'nyc',
  services: [{
    name: 'web',
    source_dir: '/',
    github: {
      repo: CONFIG.githubRepo,
      branch: CONFIG.branch,
      deploy_on_push: true
    },
    run_command: 'npm start',
    build_command: 'npm run build',
    environment_slug: 'node-js',
    instance_count: 1,
    instance_size_slug: 'professional-xs',
    http_port: 3000,
    routes: [{
      path: '/'
    }],
    envs: Object.entries(CONFIG.envVars).map(([key, value]) => ({
      key,
      value,
      scope: 'RUN_AND_BUILD_TIME'
    }))
  }],
  domains: [{
    domain: CONFIG.domain,
    type: 'PRIMARY'
  }]
};

console.log('🚀 DigitalOcean App Platform Deployment Configuration');
console.log('====================================================');
console.log();
console.log('📋 App Specification:');
console.log(JSON.stringify(appSpec, null, 2));
console.log();
console.log('🔧 Next Steps:');
console.log('1. Create a GitHub repository for your hello-world app');
console.log('2. Push your code to the repository');
console.log('3. Use the DigitalOcean CLI or web interface to create the app');
console.log();
console.log('📚 DigitalOcean CLI Commands:');
console.log('   doctl apps create --spec app-spec.json');
console.log();
console.log('💡 Web Interface:');
console.log('   https://cloud.digitalocean.com/apps');

// Save the app spec to a file
fs.writeFileSync('app-spec.json', JSON.stringify(appSpec, null, 2));
console.log('✅ App specification saved to app-spec.json');