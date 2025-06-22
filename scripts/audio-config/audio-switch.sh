#!/bin/bash
# Advanced audio device switcher with profiles

set -euo pipefail

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to list audio sinks
list_sinks() {
    echo -e "${BLUE}Available audio devices:${NC}"
    pactl list short sinks | nl -v 0
    echo
    echo -e "${BLUE}Current default:${NC}"
    pactl info | grep "Default Sink"
}

# Function to set audio device
set_audio_device() {
    local device_type=$1
    local sink=""
    
    case "$device_type" in
        laptop|internal)
            sink=$(pactl list short sinks | grep -E "pci.*analog-stereo|alsa.*analog-stereo" | grep -v hdmi | head -1 | awk '{print $2}')
            ;;
        hdmi|external)
            sink=$(pactl list short sinks | grep -i hdmi | head -1 | awk '{print $2}')
            ;;
        usb)
            sink=$(pactl list short sinks | grep -i usb | head -1 | awk '{print $2}')
            ;;
        bluetooth|bt)
            sink=$(pactl list short sinks | grep -i bluez | head -1 | awk '{print $2}')
            ;;
        [0-9])
            # Direct selection by number
            sink=$(pactl list short sinks | sed -n "$((device_type + 1))p" | awk '{print $2}')
            ;;
        *)
            echo -e "${RED}Unknown device type: $device_type${NC}"
            echo "Usage: $0 {laptop|hdmi|usb|bluetooth|list|<number>}"
            exit 1
            ;;
    esac
    
    if [ -z "$sink" ]; then
        echo -e "${RED}Device type '$device_type' not found${NC}"
        echo "Available devices:"
        list_sinks
        exit 1
    fi
    
    # Set the default sink
    pactl set-default-sink "$sink"
    
    # Move all playing streams to new sink
    pactl list short sink-inputs | while read stream; do
        stream_id=$(echo "$stream" | awk '{print $1}')
        pactl move-sink-input "$stream_id" "$sink" 2>/dev/null || true
    done
    
    echo -e "${GREEN}Switched to $device_type audio${NC}"
    notify-send "Audio Output" "Switched to $device_type" -i audio-volume-high
}

# Main script
case "${1:-list}" in
    list)
        list_sinks
        ;;
    laptop|internal|hdmi|external|usb|bluetooth|bt|[0-9])
        set_audio_device "$1"
        ;;
    *)
        echo "Usage: $0 {laptop|hdmi|usb|bluetooth|list|<number>}"
        echo "  laptop    - Internal laptop speakers"
        echo "  hdmi      - HDMI/DisplayPort audio"
        echo "  usb       - USB headset/speakers"
        echo "  bluetooth - Bluetooth audio device"
        echo "  list      - Show all available devices"
        echo "  <number>  - Select device by number from list"
        exit 1
        ;;
esac