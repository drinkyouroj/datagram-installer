#!/bin/bash

# Change to user's home directory
cd ~

echo "Downloading Datagram CLI..."
wget -q https://github.com/Datagram-Group/datagram-cli-release/releases/latest/download/datagram-cli-x86_64-linux

# Make the downloaded file executable
chmod +x ./datagram-cli-x86_64-linux

# Prompt for license key
read -p "Please enter your Datagram License key (find it at https://app.datagram.com/wallet/licenses): " LICENSE_KEY

# Check if the key was provided
if [ -z "$LICENSE_KEY" ]; then
    echo "Error: No license key provided. Exiting."
    exit 1
fi

# Create log directory if it doesn't exist
sudo mkdir -p /var/log

echo "Starting Datagram CLI in the background..."
# Run in background and redirect output to log file
nohup ./datagram-cli-x86_64-linux run -- -key "$LICENSE_KEY" > /var/tmp/datagram_log 2>&1 &

echo "Datagram CLI has been started in the background."
echo "Logs are being written to /var/tmp/datagram_log"