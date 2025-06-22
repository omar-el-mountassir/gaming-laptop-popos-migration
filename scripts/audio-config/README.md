# Audio Configuration Scripts

Scripts for managing complex audio setups with multiple devices.

## Available Scripts

### audio-switch.sh
Quick audio device switcher supporting:
- `laptop` - Internal speakers/headphone jack
- `hdmi` - HDMI/DisplayPort audio
- `usb` - USB headsets/DACs
- `bluetooth` - Bluetooth audio devices

## Usage

```bash
# Switch to laptop speakers
audio laptop

# Switch to HDMI audio
audio hdmi

# Switch to USB headset
audio usb

# List available devices
audio list
```

## PulseAudio Configuration

The setup script configures PulseAudio for low-latency gaming:
- Sample rate: 48000 Hz
- Fragment size: 5ms
- Optimized for real-time audio

## GUI Alternative

For more control, use `pavucontrol`:
```bash
pavucontrol
```

This provides:
- Per-application volume control
- Input/output device selection
- Advanced routing options

## Troubleshooting

### No Sound
1. Check mute status: `amixer sset Master unmute`
2. Restart PulseAudio: `pulseaudio -k`
3. Check active sink: `pactl info | grep "Default Sink"`

### Audio Lag
1. Verify low-latency settings in `~/.config/pulse/daemon.conf`
2. Disable audio effects
3. Use wired connection for gaming

### Device Not Found
1. List all sinks: `pactl list sinks short`
2. Update device names in script
3. Check device connection