# Display Configuration Scripts

Scripts for managing multi-monitor setups with mixed resolutions and refresh rates.

## Available Scripts

### display-setup.sh
Main configuration script that sets up dual monitors:
- Laptop: 2560x1600 @ 250Hz
- External: 1920x1080 @ 144Hz

### laptop-only.sh
Switches to laptop display only (2560x1600 @ 250Hz)

### external-only.sh
Switches to external display only (1920x1080 @ 144Hz)

### gaming-mode.sh
Optimizes display configuration for gaming:
- Disables laptop screen
- Sets external to primary
- Reduces GPU overhead

## Usage

All scripts are automatically copied to `~/Scripts/` during post-installation.

Command line:
```bash
# Configure dual displays
displays

# Switch to single display
laptop-only
external-only

# Gaming optimization
gaming-mode
```

## Customization

Edit the scripts to match your specific display configuration:
1. Run `xrandr` to identify your display names
2. Update the output names in the scripts
3. Adjust resolutions and refresh rates as needed

## Troubleshooting

If displays aren't detected:
1. Check cable connections
2. Verify NVIDIA drivers are loaded
3. Try `xrandr --auto`
4. Check system logs: `journalctl -xe`