#!/bin/bash
# Display configuration for mixed resolution setup
# Laptop: 2560x1600 @ 250Hz
# External: 1920x1080 @ 144Hz

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Configuring displays..."

# Get display names
LAPTOP=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | awk '{print $1}' || true)
EXTERNAL=$(xrandr | grep " connected" | grep -v -E "eDP|LVDS" | awk '{print $1}' | head -1 || true)

if [ -z "$LAPTOP" ] && [ -z "$EXTERNAL" ]; then
    echo -e "${RED}No displays detected!${NC}"
    exit 1
fi

# Configure based on what's connected
if [ -n "$LAPTOP" ] && [ -n "$EXTERNAL" ]; then
    echo "Configuring dual display setup..."
    # Check available modes
    if xrandr | grep -A1 "^$LAPTOP" | grep -q "2560x1600"; then
        # High-res laptop display
        xrandr --output "$LAPTOP" --mode 2560x1600 --rate 250 --scale 0.75x0.75 --pos 0x0 || \
        xrandr --output "$LAPTOP" --mode 2560x1600 --rate 165 --scale 0.75x0.75 --pos 0x0 || \
        xrandr --output "$LAPTOP" --auto --scale 0.75x0.75 --pos 0x0
    else
        xrandr --output "$LAPTOP" --auto --pos 0x0
    fi
    
    # Configure external
    if xrandr | grep -A1 "^$EXTERNAL" | grep -q "1920x1080.*144"; then
        xrandr --output "$EXTERNAL" --mode 1920x1080 --rate 144 --primary --pos 1920x0
    else
        xrandr --output "$EXTERNAL" --mode 1920x1080 --rate 60 --primary --pos 1920x0 || \
        xrandr --output "$EXTERNAL" --auto --primary --pos 1920x0
    fi
    
    echo -e "${GREEN}Dual display configured successfully!${NC}"
    notify-send "Display Configuration" "Dual displays configured" -i display
elif [ -n "$LAPTOP" ]; then
    echo "Only laptop display detected"
    xrandr --output "$LAPTOP" --auto --primary
    echo -e "${GREEN}Laptop display configured${NC}"
elif [ -n "$EXTERNAL" ]; then
    echo "Only external display detected"
    xrandr --output "$EXTERNAL" --auto --primary
    echo -e "${GREEN}External display configured${NC}"
fi

# Log configuration
echo "$(date): Display configuration applied" >> ~/display-config.log
xrandr --current >> ~/display-config.log