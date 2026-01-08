#!/bin/bash
# Deploy script for GPUniq Docs

set -e

echo "🚀 Starting deployment of GPUniq Docs..."

# Pull latest changes
echo "📥 Pulling latest changes from GitHub..."
git pull origin main

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build the site
echo "🔨 Building the site..."
npm run build

# The build output should be in .mint/dist or similar
# Copy to nginx directory
BUILD_DIR=".mint/dist"
if [ ! -d "$BUILD_DIR" ]; then
    echo "⚠️  Build directory not found. Checking for other build outputs..."
    # Mintlify might output to different directory
    BUILD_DIR="dist"
fi

if [ -d "$BUILD_DIR" ]; then
    echo "📋 Copying build files to nginx directory..."
    sudo rm -rf /var/www/docs.gpuniq.com
    sudo mkdir -p /var/www/docs.gpuniq.com
    sudo cp -r $BUILD_DIR/* /var/www/docs.gpuniq.com/
    sudo chown -R www-data:www-data /var/www/docs.gpuniq.com
    echo "✅ Files copied successfully"
else
    echo "❌ Build directory not found. Build may have failed."
    exit 1
fi

echo "✅ Deployment complete!"

