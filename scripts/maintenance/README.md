# System Maintenance Scripts

Automated maintenance scripts for keeping your Pop!_OS system optimized.

## Available Scripts

### system-maintenance.sh
Weekly maintenance script that:
- Updates package database
- Cleans package cache
- Runs TRIM on SSDs
- Checks NVMe health
- Rotates logs
- Updates locate database

### backup-system.sh
Creates system backups using Timeshift:
- Automated weekly snapshots
- Keeps 3 weekly backups
- Excludes unnecessary files
- Verifies backup integrity

### update-all.sh
Comprehensive update script:
- System packages (apt)
- Snap packages
- Flatpak applications
- Firmware updates
- NVIDIA drivers

## Automation

The maintenance script is automatically scheduled via cron:
```bash
# View scheduled tasks
crontab -l

# Edit schedule
crontab -e
```

Default schedule: Sunday 2 AM

## Manual Execution

```bash
# Run maintenance now
~/Scripts/system-maintenance.sh

# Create backup
~/Scripts/backup-system.sh

# Update everything
~/Scripts/update-all.sh
```

## Customization

### Adding Tasks
1. Edit the script
2. Add your commands
3. Test manually first
4. Update cron if needed

### Changing Schedule
```bash
crontab -e
# Format: minute hour day month dayofweek command
# Example: Daily at 3 AM
0 3 * * * /home/user/Scripts/system-maintenance.sh
```

## Monitoring

Check maintenance logs:
```bash
# View last run
tail -100 ~/maintenance.log

# Check for errors
grep ERROR ~/maintenance.log
```