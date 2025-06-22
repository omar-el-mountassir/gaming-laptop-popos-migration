# Audio Configuration Scripts

Scripts for managing complex audio setups with multiple devices.

## Features

- Quick switching between audio devices
- Bluetooth audio optimization
- Gaming audio profiles
- Microphone management

## Usage

```bash
# Switch to laptop speakers
audio laptop

# Switch to HDMI/DisplayPort audio
audio hdmi

# Switch to USB headset
audio usb

# Switch to Bluetooth device
audio bluetooth

# List all audio devices
audio list
```

## Audio Profiles

The scripts automatically configure:
- Sample rates
- Latency settings
- Volume levels
- Default devices

## Troubleshooting

If audio device not found:
1. Run `audio list` to see available devices
2. Check device is connected and powered
3. Run `pavucontrol` for GUI control
4. Restart PulseAudio: `pulseaudio -k`