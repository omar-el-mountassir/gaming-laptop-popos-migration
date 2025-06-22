#!/bin/bash
# Comprehensive weekly system maintenance

set -euo pipefail

# Logging
LOG_FILE="/var/log/weekly-maintenance.log"
echo "[$(date)] Starting weekly maintenance" | sudo tee -a "$LOG_FILE"

# Function to log
log() {
    echo "[$(date +%T)] $1" | sudo tee -a "$LOG_FILE"
}

# Check if running as root when needed
if [ "$EUID" -eq 0 ]; then 
   SUDO=""
else
   SUDO="sudo"
fi

log "=== System Maintenance Starting ==="

# Update package database
log "Updating package database..."
$SUDO apt update

# Remove old kernels (keep current and one previous)
log "Cleaning old kernels..."
CURRENT_KERNEL=$(uname -r)
$SUDO apt-get autoremove --purge -y

# Clean package cache
log "Cleaning package cache..."
$SUDO apt-get autoclean -y
$SUDO apt-get clean

# Update mlocate database
log "Updating file database..."
$SUDO updatedb

# TRIM SSDs
log "Running TRIM on SSDs..."
$SUDO fstrim -av

# Check NVMe health
log "Checking NVMe health..."
for drive in /dev/nvme*n1; do
    if [ -e "$drive" ]; then
        log "Checking $drive..."
        $SUDO nvme smart-log "$drive" | grep -E "(critical_warning|temperature|available_spare|percentage_used)" | sudo tee -a "$LOG_FILE"
    fi
done

# Clean systemd journal (keep 2 weeks)
log "Cleaning system logs..."
$SUDO journalctl --vacuum-time=2weeks

# Clean thumbnail cache
log "Cleaning user cache..."
rm -rf ~/.cache/thumbnails/*

# Check for filesystem errors
log "Checking filesystem health..."
$SUDO touch /forcefsck

# Update Flatpak apps if installed
if command -v flatpak &> /dev/null; then
    log "Updating Flatpak applications..."
    flatpak update -y
fi

# Update Snap apps if installed
if command -v snap &> /dev/null; then
    log "Updating Snap applications..."
    $SUDO snap refresh
fi

# Check disk space
log "Disk space report:"
df -h | grep -E "^/dev/" | sudo tee -a "$LOG_FILE"

# Check for system errors
log "Recent system errors:"
$SUDO journalctl -p err -b -n 20 | sudo tee -a "$LOG_FILE"

log "=== Maintenance Complete ==="

# Send notification if in desktop session
if [ -n "${DISPLAY:-}" ]; then
    notify-send "System Maintenance" "Weekly maintenance completed successfully" -i dialog-information
fi

log "Maintenance finished at $(date)"