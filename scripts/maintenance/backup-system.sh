#!/bin/bash
# System backup script using Timeshift
# Creates automated backups of system files

set -e

# Check if Timeshift is installed
if ! command -v timeshift &> /dev/null; then
    echo "Error: Timeshift is not installed"
    echo "Install with: sudo apt install timeshift"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run with sudo"
    exit 1
fi

# Configuration
BACKUP_DEVICE="/dev/nvme0n1p4"  # Adjust to your backup partition
BACKUP_TYPE="RSYNC"
SNAPSHOT_COMMENT="Automated weekly backup"

echo "=== Timeshift System Backup ==="
echo "Backup device: $BACKUP_DEVICE"
echo "Backup type: $BACKUP_TYPE"
echo ""

# Create backup
echo "Creating system snapshot..."
timeshift --create --comments "$SNAPSHOT_COMMENT" --tags W

# List snapshots
echo -e "\nCurrent snapshots:"
timeshift --list

# Cleanup old snapshots (keep last 3 weekly)
echo -e "\nCleaning old snapshots..."
# Timeshift will automatically manage this based on settings

# Verify backup
latest_snapshot=$(timeshift --list | grep -E "^[0-9]" | tail -1 | awk '{print $3}')
if [ -n "$latest_snapshot" ]; then
    echo -e "\nLatest snapshot created: $latest_snapshot"
    echo "Backup completed successfully!"
else
    echo "Error: Could not verify backup creation"
    exit 1
fi

# Send notification
if [ -n "$SUDO_USER" ] && [ -n "$DISPLAY" ]; then
    su - $SUDO_USER -c "notify-send 'System Backup' 'Weekly backup completed successfully' -i drive-harddisk"
fi