#!/bin/bash
# Audio device quick switcher
# Supports laptop speakers, HDMI, USB, and Bluetooth devices

case "$1" in
    laptop)
        SINK=$(pactl list short sinks | grep -i "pci.*analog-stereo" | head -1 | awk '{print $2}')
        DEVICE="Laptop Speakers"
        ;;
    hdmi)
        SINK=$(pactl list short sinks | grep -i "hdmi" | head -1 | awk '{print $2}')
        DEVICE="HDMI/DisplayPort Audio"
        ;;
    usb)
        SINK=$(pactl list short sinks | grep -i "usb" | head -1 | awk '{print $2}')
        DEVICE="USB Audio"
        ;;
    bluetooth)
        SINK=$(pactl list short sinks | grep -i "bluez" | head -1 | awk '{print $2}')
        DEVICE="Bluetooth Audio"
        ;;
    list)
        echo "Available audio sinks:"
        pactl list short sinks
        exit 0
        ;;
    *)
        echo "Usage: $0 {laptop|hdmi|usb|bluetooth|list}"
        echo ""
        echo "Quick audio output switcher"
        echo "  laptop    - Internal speakers/headphone jack"
        echo "  hdmi      - HDMI or DisplayPort audio"
        echo "  usb       - USB headset or DAC"
        echo "  bluetooth - Bluetooth audio device"
        echo "  list      - Show all available sinks"
        exit 1
        ;;
esac

if [ -n "$SINK" ]; then
    pactl set-default-sink "$SINK"
    # Move all playing streams to new sink
    pactl list short sink-inputs | while read stream; do
        stream_id=$(echo $stream | cut -f1)
        pactl move-sink-input "$stream_id" "$SINK" 2>/dev/null
    done
    notify-send "Audio Output" "Switched to $DEVICE" -i audio-volume-high
else
    notify-send "Audio Error" "Could not find $DEVICE" -i dialog-error
    echo "Error: Could not find $DEVICE"
    echo "Available sinks:"
    pactl list short sinks
fi