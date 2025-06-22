#!/bin/bash
# Gaming mode - optimize for performance
# Disables laptop display to reduce GPU overhead

# Get display names
LAPTOP=$(xrandr | grep " connected" | grep "2560x1600" | awk '{print $1}')
EXTERNAL=$(xrandr | grep " connected" | grep "1920x1080" | awk '{print $1}')

# Turn off laptop display for gaming
if [ -n "$LAPTOP" ]; then
    xrandr --output $LAPTOP --off
fi

# Set external as primary at optimal refresh rate
if [ -n "$EXTERNAL" ]; then
    xrandr --output $EXTERNAL --mode 1920x1080 --rate 144 --primary
fi

# Set CPU governor to performance
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor > /dev/null

# Set GPU to maximum performance
nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1" > /dev/null 2>&1

# Disable compositor if using X11
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    # For GNOME
    gsettings set org.gnome.mutter unredirect-fullscreen-windows true 2>/dev/null
fi

# Kill unnecessary processes
pkill -f "dropbox" 2>/dev/null
pkill -f "slack" 2>/dev/null

notify-send "Gaming Mode" "Performance optimizations enabled" -i applications-games