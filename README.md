# Datagram CLI Installer

A simple bash script to install and run the Datagram CLI in the background on Linux systems.

## Prerequisites

- Linux operating system (x86_64)
- `wget` installed
- `sudo` privileges (for creating log directory)
- Valid Datagram license key

## Installation

1. Clone this repository or download the `datagram_installer.sh` script
2. Make the script executable:
   ```bash
   chmod +x datagram_installer.sh
   ```
3. Run the script:
   ```bash
   ./datagram_installer.sh
   ```

## What the Script Does

1. Changes to the user's home directory
2. Downloads the latest Datagram CLI binary
3. Makes the binary executable
4. Prompts for your Datagram license key
5. Creates necessary log directories
6. Starts the Datagram CLI in the background
7. Writes logs to `/var/tmp/datagram_log`

## Finding Your License Key

You can find your Datagram license key by:
1. Logging into your Datagram dashboard at [https://dashboard.datagram.network/wallet?tab=licenses](https://dashboard.datagram.network)
2. Navigating to Wallet > Licenses
3. Copying your license key

## Logs

Logs are written to: `/var/tmp/datagram_log`

To view the logs:
```bash
sudo tail -f /var/tmp/datagram_log
```

## Stopping the Service

To stop the Datagram CLI, you'll need to find and terminate the process:

```bash
# Find the process ID
pgrep -f "datagram-cli"

# Kill the process (replace PID with the actual process ID)
kill <PID>
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
