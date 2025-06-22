# System Maintenance Scripts

Automated maintenance scripts to keep your Pop!_OS system running smoothly.

## Scripts Included

- `weekly-maintenance.sh` - Comprehensive weekly maintenance
- `update-system.sh` - Safe system updates
- `clean-system.sh` - Disk space cleanup
- `check-health.sh` - System health monitoring

## Automatic Scheduling

The main installation script sets up weekly maintenance via cron:
```
0 2 * * 0 ~/Scripts/maintenance/weekly-maintenance.sh
```

Runs every Sunday at 2 AM.

## Manual Usage

```bash
# Run weekly maintenance
sudo ~/Scripts/maintenance/weekly-maintenance.sh

# Update system safely
~/Scripts/maintenance/update-system.sh

# Clean disk space
~/Scripts/maintenance/clean-system.sh

# Check system health
~/Scripts/maintenance/check-health.sh
```

## What Gets Maintained

- Package updates
- Kernel cleanup
- Log rotation
- Cache cleanup
- TRIM for SSDs
- NVMe health monitoring
- Temperature checks
- Disk space analysis