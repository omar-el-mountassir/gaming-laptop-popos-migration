#!/bin/bash
# Gaming mode - Single display for maximum performance

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Enabling Gaming Mode...${NC}"

# Get display names
LAPTOP=$(xrandr | grep " connected" | grep -E "eDP|LVDS" | awk '{print $1}' || true)
EXTERNAL=$(xrandr | grep " connected" | grep -v -E "eDP|LVDS" | awk '{print $1}' | head -1 || true)

# Disable laptop display if external is connected
if [ -n "$EXTERNAL" ] && [ -n "$LAPTOP" ]; then
    xrandr --output "$LAPTOP" --off
    # Set external to maximum refresh rate
    if xrandr | grep -A1 "^$EXTERNAL" | grep -q "144"; then
        xrandr --output "$EXTERNAL" --mode 1920x1080 --rate 144 --primary
    else
        xrandr --output "$EXTERNAL" --auto --primary
    fi
    echo -e "${GREEN}Gaming mode enabled - External display only${NC}"
else
    echo "Gaming mode requires external display"
    exit 1
fi

# CPU Performance Mode
if command -v cpupower &> /dev/null; then
    sudo cpupower frequency-set -g performance 2>/dev/null || true
else
    echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null 2>&1 || true
fi

# GPU Performance Mode
if command -v nvidia-settings &> /dev/null; then
    nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" > /dev/null 2>&1 || true
fi

# Disable compositor if possible
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    if command -v xfconf-query &> /dev/null; then
        xfconf-query -c xfwm4 -p /general/use_compositing -s false 2>/dev/null || true
    fi
fi

notify-send "Gaming Mode" "Performance optimizations enabled" -i applications-games
echo -e "${GREEN}Gaming mode fully activated!${NC}"