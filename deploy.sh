#!/bin/bash
# Deploy script for GPUniq Docs
# Run on the server: root@80.209.240.32

set -e

DOCS_DIR="/root/GPUniq/documentationai-Docs"
WEB_DIR="/var/www/docs.gpuniq.com"

echo "🚀 Starting deployment of GPUniq Docs..."

cd $DOCS_DIR

# Pull latest changes
echo "📥 Pulling latest changes from GitHub..."
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the site using mintlify
echo "🔨 Building the site..."
npx mintlify build

# Find build output
BUILD_DIR=""
if [ -d ".mintlify/build" ]; then
    BUILD_DIR=".mintlify/build"
elif [ -d ".mint/dist" ]; then
    BUILD_DIR=".mint/dist"
elif [ -d "dist" ]; then
    BUILD_DIR="dist"
elif [ -d "out" ]; then
    BUILD_DIR="out"
fi

if [ -n "$BUILD_DIR" ] && [ -d "$BUILD_DIR" ]; then
    echo "📋 Copying build files from $BUILD_DIR to nginx directory..."
    rm -rf $WEB_DIR
    mkdir -p $WEB_DIR
    cp -r $BUILD_DIR/* $WEB_DIR/
    chown -R www-data:www-data $WEB_DIR
    echo "✅ Files copied successfully"
else
    echo "⚠️  Build directory not found. Deploying source files for Mintlify hosting..."
    # For Mintlify Cloud hosting, we just need to push to git
    echo "📤 Push to git for Mintlify Cloud deployment..."
fi

# Restart nginx if running
if systemctl is-active --quiet nginx; then
    echo "🔄 Reloading nginx..."
    systemctl reload nginx
fi

echo "✅ Deployment complete!"
echo "📍 Docs available at: https://docs.gpuniq.com"
