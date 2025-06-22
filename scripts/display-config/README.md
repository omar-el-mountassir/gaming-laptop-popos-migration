# Display Configuration Scripts

These scripts help manage complex multi-monitor setups, especially for mixed resolution and refresh rate configurations.

## Scripts Included

- `setup-displays.sh` - Main display configuration
- `gaming-mode.sh` - Single display for maximum performance
- `presentation-mode.sh` - Mirror displays for presentations
- `reset-displays.sh` - Reset to default configuration

## Usage

All scripts are installed to `~/Scripts/` by the main installation script.

### Quick Commands

```bash
# Configure dual displays
displays

# Laptop only
laptop-only

# External only
external-only

# Gaming mode (external only, max performance)
gaming-mode
```

## Customization

Edit the scripts to match your specific display configuration. Use `xrandr` to identify your display names:

```bash
xrandr | grep " connected"
```

Then update the display names in the scripts accordingly.