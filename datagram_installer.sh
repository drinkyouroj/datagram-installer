#!/bin/bash

# Exit on error
set -e

# Constants
CLI_BINARY="datagram-cli-x86_64-linux"
WRAPPER_SCRIPT="$HOME/datagram-cli-wrapper.sh"
SERVICE_NAME="datagram-cli"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
KEY_FILE="$HOME/.datagram_key"
LOG_FILE="/var/log/datagram.log"

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
    echo "Error: This script should not be run as root. Please run as a regular user with sudo privileges."
    exit 1
fi

# Function to create systemd service
create_systemd_service() {
    local user=$(whoami)
    local exec_path="$HOME/$CLI_BINARY"
    
    echo "Creating systemd service..."
    
    # Create the service file with proper permissions
    sudo bash -c "cat > $SERVICE_FILE" << EOF
[Unit]
Description=Datagram CLI
After=network.target

[Service]
Type=simple
User=$user
WorkingDirectory=$HOME
ExecStart=$WRAPPER_SCRIPT
Restart=always
RestartSec=10
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE
Environment="HOME=$HOME"

[Install]
WantedBy=multi-user.target
EOF

    # Set proper permissions
    sudo chmod 644 $SERVICE_FILE
    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
    
    echo "Systemd service created and enabled."
}

# Create wrapper script
create_wrapper_script() {
    echo "Creating wrapper script..."
    
    cat > "$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Path to the CLI binary
CLI_BINARY="$SCRIPT_DIR/datagram-cli-x86_64-linux"

# Path to the key file
KEY_FILE="$HOME/.datagram_key"

# Check if key file exists
if [ ! -f "$KEY_FILE" ]; then
    echo "Error: Key file not found at $KEY_FILE"
    exit 1
fi

# Read the license key from the file
LICENSE_KEY="$(cat "$KEY_FILE")"

# Check if the key is empty
if [ -z "$LICENSE_KEY" ]; then
    echo "Error: Empty license key in $KEY_FILE"
    exit 1
fi

# Execute the CLI with the key
exec "$CLI_BINARY" run -- -key "$LICENSE_KEY"
EOF

    # Make the wrapper script executable
    chmod 700 "$WRAPPER_SCRIPT"
    echo "Wrapper script created at $WRAPPER_SCRIPT"
}

# Change to user's home directory
cd ~

# Download Datagram CLI if it doesn't exist
if [ ! -f "./$CLI_BINARY" ]; then
    echo "Downloading Datagram CLI..."
    wget -q "https://github.com/Datagram-Group/datagram-cli-release/releases/latest/download/$CLI_BINARY"
    chmod +x "./$CLI_BINARY"
    echo "Download complete."
else
    echo "Datagram CLI already exists, skipping download."
fi

# Check for existing key file
if [ -f "$KEY_FILE" ]; then
    read -p "A license key already exists. Do you want to update it? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Using existing license key."
    else
        read -p "Please enter your Datagram License key: " LICENSE_KEY
        if [ -n "$LICENSE_KEY" ]; then
            # Store just the plain key value
            echo "$LICENSE_KEY" > "$KEY_FILE"
            chmod 600 "$KEY_FILE"
            echo "License key updated."
        else
            echo "No key provided, using existing key."
        fi
    fi
else
    # Prompt for license key if not found
read -p "Please enter your Datagram License key (find it at https://dashboard.datagram.network/wallet?tab=licenses): " LICENSE_KEY
    if [ -n "$LICENSE_KEY" ]; then
        # Store just the plain key value
        echo "$LICENSE_KEY" > "$KEY_FILE"
        chmod 600 "$KEY_FILE"
        echo "License key saved to $KEY_FILE"
    else
        echo "Error: No license key provided. Exiting."
        exit 1
    fi
fi

# Create log directory if it doesn't exist
if [ ! -d "$(dirname $LOG_FILE)" ]; then
    sudo mkdir -p "$(dirname $LOG_FILE)"
    sudo touch "$LOG_FILE"
    sudo chown $(whoami) "$LOG_FILE"
fi

# Create wrapper script
if [ -f "$WRAPPER_SCRIPT" ]; then
    read -p "Wrapper script already exists. Do you want to recreate it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_wrapper_script
    fi
else
    create_wrapper_script
fi

# Create or update systemd service
if [ -f "$SERVICE_FILE" ]; then
    read -p "Systemd service already exists. Do you want to recreate it? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_systemd_service
    fi
else
    create_systemd_service
fi

# Start or restart the service
echo "Starting Datagram CLI service..."
sudo systemctl restart $SERVICE_NAME

# Show service status
echo -e "\nService status:"
systemctl status $SERVICE_NAME --no-pager

echo -e "\nInstallation complete!"
echo "- Logs are being written to: $LOG_FILE"
echo "- Service name: $SERVICE_NAME"
echo "- To view logs: sudo journalctl -u $SERVICE_NAME -f"
echo "- To stop service: sudo systemctl stop $SERVICE_NAME"
echo "- To start service: sudo systemctl start $SERVICE_NAME"
echo "- To view status: systemctl status $SERVICE_NAME"