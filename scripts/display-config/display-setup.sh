#!/bin/bash
# Acer Predator mixed resolution display setup
# Laptop: 2560x1600 @ 250Hz | External: 1920x1080 @ 144Hz

# Wait for displays to be ready
sleep 3

# Get display names
LAPTOP=$(xrandr | grep " connected" | grep "2560x1600" | awk '{print $1}')
EXTERNAL=$(xrandr | grep " connected" | grep "1920x1080" | awk '{print $1}')

if [ -n "$LAPTOP" ] && [ -n "$EXTERNAL" ]; then
    # Configure laptop display (2560x1600 @ 250Hz)
    xrandr --output $LAPTOP --mode 2560x1600 --rate 250 --scale 0.75x0.75 --pos 0x0
    
    # Configure external display (1920x1080 @ 144Hz) as primary
    xrandr --output $EXTERNAL --mode 1920x1080 --rate 144 --primary --scale 1x1 --pos 1920x0
    
    notify-send "Display Configuration" "Laptop: 2560x1600@250Hz | External: 1920x1080@144Hz" -i display
else
    notify-send "Display Configuration" "Could not detect both displays" -i dialog-warning
fi

# Log configuration
echo "$(date): Display configuration applied" >> ~/display-config.log
xrandr --current >> ~/display-config.log