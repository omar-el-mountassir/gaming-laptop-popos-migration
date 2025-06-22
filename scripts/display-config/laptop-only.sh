#!/bin/bash
# Switch to laptop display only

# Get display names
LAPTOP=$(xrandr | grep " connected" | grep "2560x1600" | awk '{print $1}')
EXTERNAL=$(xrandr | grep " connected" | grep "1920x1080" | awk '{print $1}')

# Turn off external display
if [ -n "$EXTERNAL" ]; then
    xrandr --output $EXTERNAL --off
fi

# Configure laptop display at full resolution
if [ -n "$LAPTOP" ]; then
    xrandr --output $LAPTOP --mode 2560x1600 --rate 250 --scale 1x1 --primary
    notify-send "Display Mode" "Laptop only (2560x1600@250Hz)" -i computer
else
    notify-send "Display Error" "Could not find laptop display" -i dialog-error
fi