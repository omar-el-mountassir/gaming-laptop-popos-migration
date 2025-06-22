#!/bin/bash
# Switch to external display only

# Get display names
LAPTOP=$(xrandr | grep " connected" | grep "2560x1600" | awk '{print $1}')
EXTERNAL=$(xrandr | grep " connected" | grep "1920x1080" | awk '{print $1}')

# Turn off laptop display
if [ -n "$LAPTOP" ]; then
    xrandr --output $LAPTOP --off
fi

# Configure external display
if [ -n "$EXTERNAL" ]; then
    xrandr --output $EXTERNAL --mode 1920x1080 --rate 144 --scale 1x1 --primary
    notify-send "Display Mode" "External only (1920x1080@144Hz)" -i display
else
    notify-send "Display Error" "Could not find external display" -i dialog-error
fi