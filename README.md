# Datagram CLI Installer

A bash script to install and run the Datagram CLI as a systemd service on Linux systems, with automatic restarts and secure key storage.

## Features

- Automatic download and installation of the latest Datagram CLI
- Secure storage of license key in `~/.datagram_key` with restricted permissions (600)
- Secure wrapper script that reads the key from the key file at runtime
- Systemd service for automatic startup and process management
- Automatic log rotation via systemd-journald
- Graceful error handling and user feedback
- No key exposure in systemd service files

## Prerequisites

- Linux operating system (x86_64)
- `wget` installed
- `systemd` init system
- `sudo` privileges (for service installation)
- Valid Datagram license key

## Installation

1. Clone this repository or download the `datagram_installer.sh` script
2. Make the script executable:
   ```bash
   chmod +x datagram_installer.sh
   ```
3. Run the script (as a regular user with sudo privileges):
   ```bash
   ./datagram_installer.sh
   ```
4. Follow the prompts to enter your Datagram license key

## What the Script Does

1. Downloads the latest Datagram CLI binary (if not already present)
2. Securely stores your license key in `~/.datagram_key`
3. Creates a wrapper script (`~/datagram-cli-wrapper.sh`) that reads the key at runtime
4. Creates a systemd service file at `/etc/systemd/system/datagram-cli.service`
5. Sets up log rotation via systemd-journald
6. Enables and starts the service

## Service Management

### Start the service
```bash
sudo systemctl start datagram-cli
```

### Stop the service
```bash
sudo systemctl stop datagram-cli
```

### Check service status
```bash
systemctl status datagram-cli
```

### View logs
```bash
# Follow logs in real-time
sudo journalctl -u datagram-cli -f

# View full log history
sudo journalctl -u datagram-cli
```

### Enable/disable automatic startup
```bash
# Enable automatic startup on boot
sudo systemctl enable datagram-cli

# Disable automatic startup
sudo systemctl disable datagram-cli
```

## Updating the License Key

1. Edit the key file:
   ```bash
   nano ~/.datagram_key
   ```
2. Update the `DATAGRAM_KEY` value with your new key (e.g., `DATAGRAM_KEY=your-new-key-here`)
3. Save the file
4. Restart the service to apply changes:
   ```bash
   sudo systemctl restart datagram-cli
   ```
5. Verify the service is running with the new key:
   ```bash
   systemctl status datagram-cli
   ```

## Finding Your License Key

You can find your Datagram license key by:
1. [Signing up](https://dashboard.datagram.network?ref=535715481) for a Datagram account
2. Logging into your Datagram dashboard at [https://dashboard.datagram.network/wallet?tab=licenses](https://dashboard.datagram.network)
3. Navigating to Wallet > Licenses
4. Copying your license key
![Datagram Network Dashboard Licenses tab, with an arrow pointing to where to click to copy your license key](https://azure-adequate-krill-31.mypinata.cloud/ipfs/bafkreic66kkj4pqt7orgijy2rx5676sk4gyfrmhpxtl4wgbewytd3delh4)

## Security Considerations

- The license key is stored in `~/.datagram_key` with 600 permissions (read/write only for the owner)
- A secure wrapper script (`~/datagram-cli-wrapper.sh`) with 700 permissions reads the key at runtime
- The key is never stored in the systemd service file
- The key file is owned by the current user and not accessible by other users
- The service runs under your user account, not root
- The wrapper script ensures the key is not visible in process listings
- Logs are accessible only to privileged users

## Troubleshooting

If the service fails to start, check the logs:
```bash
journalctl -u datagram-cli -n 50 --no-pager
```

Common issues:
- Missing dependencies: Ensure `wget` is installed
- Permission issues: The script should be run as a regular user with sudo privileges
- Invalid license key: Verify the key is correct and hasn't expired

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
