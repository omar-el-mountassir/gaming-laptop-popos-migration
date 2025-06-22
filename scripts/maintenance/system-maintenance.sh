#!/bin/bash
# Weekly system maintenance script
# Automatically run via cron or manually

LOG_FILE="$HOME/maintenance.log"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "=== System Maintenance Starting ==="

# Update package database
log "Updating package database..."
sudo apt update 2>&1 | tee -a "$LOG_FILE"

# Clean package cache
log "Cleaning package cache..."
sudo apt autoremove -y 2>&1 | tee -a "$LOG_FILE"
sudo apt autoclean 2>&1 | tee -a "$LOG_FILE"

# Update snap packages
if command -v snap &> /dev/null; then
    log "Updating snap packages..."
    sudo snap refresh 2>&1 | tee -a "$LOG_FILE"
fi

# Update flatpak packages
if command -v flatpak &> /dev/null; then
    log "Updating flatpak packages..."
    flatpak update -y 2>&1 | tee -a "$LOG_FILE"
fi

# Update locate database
log "Updating file database..."
sudo updatedb 2>&1 | tee -a "$LOG_FILE"

# TRIM SSDs
log "Running TRIM on SSDs..."
sudo fstrim -av 2>&1 | tee -a "$LOG_FILE"

# Check NVMe health
log "Checking NVMe drive health..."
for drive in /dev/nvme*n1; do
    if [ -e "$drive" ]; then
        log "Checking $drive..."
        sudo smartctl -a $drive | grep -E "(Critical Warning|Temperature|Available Spare|Percentage Used)" | tee -a "$LOG_FILE"
    fi
done

# Clean old logs
log "Rotating system logs..."
sudo logrotate -f /etc/logrotate.conf 2>&1 | tee -a "$LOG_FILE"

# Clean old kernels (keep current and one previous)
log "Cleaning old kernels..."
DEBIAN_FRONTEND=noninteractive sudo apt autoremove --purge -y 2>&1 | tee -a "$LOG_FILE"

# Update font cache
log "Updating font cache..."
fc-cache -fv 2>&1 | tee -a "$LOG_FILE"

# Check for failed services
log "Checking for failed services..."
failed_services=$(systemctl --failed --no-pager --no-legend)
if [ -n "$failed_services" ]; then
    log "WARNING: Failed services detected:"
    echo "$failed_services" | tee -a "$LOG_FILE"
else
    log "All services running normally"
fi

# Clean thumbnail cache
log "Cleaning thumbnail cache..."
rm -rf ~/.cache/thumbnails/* 2>&1 | tee -a "$LOG_FILE"

# Report disk usage
log "Disk usage report:"
df -h | grep -E "^/dev/" | tee -a "$LOG_FILE"

log "=== Maintenance Complete ==="

# Send notification
if [ -n "$DISPLAY" ]; then
    notify-send "System Maintenance" "Weekly maintenance completed successfully" -i dialog-information
fi