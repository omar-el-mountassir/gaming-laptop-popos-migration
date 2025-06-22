# Pop!_OS Migration Framework - Complete Guide

**Version**: 2.3.1 "NVMe-Aware Edition"  
**Date**: June 22, 2025  
**Compatible**: Pop!_OS 22.04 LTS, Kernel 6.8+  
**Hardware**: Acer Predator PTX17-71 (Intel Report Verified)  
**Displays**: Laptop 2560x1600@250Hz + ASUS VG279Q1R 1920x1080@144Hz  

This comprehensive guide documents a successful migration from Windows 11 to Pop!_OS on a high-end gaming laptop. Follow this framework for a smooth transition that preserves your gaming capabilities while gaining the benefits of Linux.

## Table of Contents

1. [Critical Context](#critical-context)
2. [Hardware Specifications](#hardware-specifications)
3. [Pre-Migration Checklist](#pre-migration-checklist)
4. [Installation Process](#installation-process)
5. [Post-Installation Configuration](#post-installation-configuration)
6. [Display Configuration](#display-configuration)
7. [Audio Setup](#audio-setup)
8. [Gaming Configuration](#gaming-configuration)
9. [Development Environment](#development-environment)
10. [Troubleshooting](#troubleshooting)
11. [Performance Optimization](#performance-optimization)
12. [Maintenance](#maintenance)

## Critical Context

### Why Pop!_OS 22.04 LTS?
- **Stability**: LTS release with long-term support
- **NVIDIA Support**: Excellent out-of-box support with dedicated ISO
- **Gaming Ready**: Steam and Proton work flawlessly
- **Developer Friendly**: Great for development workflows

### Important Notes
- ❌ **Pop!_OS 24.04 is in ALPHA** - not production ready
- ✅ **Pop!_OS 22.04 LTS is the stable choice**
- ✅ **Solution**: Install 22.04 LTS, then upgrade to kernel 6.8 for hardware support

## Hardware Specifications

### Verified Configuration
Based on Intel Driver & Support Assistant report (June 21, 2025):

- **CPU**: Intel Core i9-13900HX (24 cores / 32 threads)
- **GPU**: NVIDIA RTX 4090 Laptop + Intel Integrated
- **RAM**: 32GB DDR5
- **Display**: 2560x1600 @ 250Hz (laptop) + 1920x1080 @ 144Hz (external)
- **Storage**: 2x 2TB NVMe (Samsung + Micron)
- **Network**: Intel WiFi + Killer E3000 Ethernet
- **Audio**: 6 devices (Realtek, Intel, NVIDIA)
- **BIOS**: V1.09 (December 2024)

## Pre-Migration Checklist

### Essential Backups
- [ ] Create full disk image (Macrium Reflect recommended)
- [ ] Backup critical documents to external drive
- [ ] Export browser bookmarks and passwords
- [ ] Save game saves (check Documents/My Games)
- [ ] Note down WiFi passwords
- [ ] Export any certificates or VPN configs

### System Preparation
- [ ] Disable BitLocker (if enabled)
- [ ] Disable Fast Startup in Windows
- [ ] Free up 400GB on target drive
- [ ] Update BIOS to latest version
- [ ] Run the pre-flight check script

### Mental Preparation
- [ ] Budget a full day (though it takes ~2 hours)
- [ ] Have ethernet cable ready (backup for WiFi)
- [ ] Prepare USB drives (2x 8GB minimum)
- [ ] Download Pop!_OS 22.04 LTS NVIDIA ISO

## Installation Process

### Creating Installation Media

1. Download Pop!_OS 22.04 LTS NVIDIA ISO from https://pop.system76.com/
2. Use Rufus (Windows) or Etcher to create bootable USB
3. Rufus settings:
   - Partition scheme: GPT
   - Target system: UEFI
   - File system: FAT32

### BIOS Configuration

Access BIOS (F2 during boot) and verify:
- **Secure Boot**: Temporarily disabled
- **Fast Boot**: Disabled
- **SATA Mode**: AHCI (not RAID)
- **Virtualization**: Enabled

### Installation Steps

1. Boot from USB (F12 for boot menu)
2. Select "Try or Install Pop!_OS"
3. Choose language and keyboard layout
4. Select "Custom Install" for dual boot
5. Partition the 683GB F: drive:
   - 512MB EFI (if not sharing Windows EFI)
   - 395GB ext4 mount on /
   - 4GB swap (optional with 32GB RAM)
6. Install and wait ~15 minutes
7. Reboot and remove USB

## Post-Installation Configuration

### First Boot Essential

Run the automated setup script:
```bash
wget -O- https://raw.githubusercontent.com/omar-el-mountassir/gaming-laptop-popos-migration/main/scripts/post-install-setup.sh | bash
```

This handles:
- System updates
- Kernel 6.8 upgrade
- NVIDIA drivers
- Essential software
- Display configuration
- Audio setup

### Manual Steps After Script

1. **Configure Claude Desktop**
   - Launch Claude Desktop
   - Sign in with your API key
   - Configure MCP servers if needed

2. **Sign into browsers**
   - Microsoft Edge: Sync your profile
   - Set as default if preferred

3. **Steam Configuration**
   - Enable Steam Play for all titles
   - Download your games

## Display Configuration

### Mixed Resolution Setup

Your setup requires special attention:
- Laptop: 2560x1600 @ 250Hz (177 PPI)
- External: 1920x1080 @ 144Hz (82 PPI)

The automated script creates display profiles:
- `displays` - Reset to dual configuration
- `laptop-only` - Laptop screen only
- `external-only` - External monitor only

### Manual Display Adjustment

If scaling looks wrong:
```bash
# Enable fractional scaling
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"

# Then use Settings → Displays to adjust
```

## Audio Setup

### Managing 6 Audio Devices

Your system has:
1. Realtek (main audio)
2. Intel Bluetooth Audio
3. NVIDIA HDMI Audio
4. Intel USB Audio
5. NVIDIA Virtual Audio
6. Intel Digital Microphone

Use the audio switcher:
```bash
audio laptop    # Switch to laptop speakers
audio hdmi      # Switch to HDMI/DisplayPort
audio usb       # Switch to USB headset
```

Or use `pavucontrol` for GUI control.

## Gaming Configuration

### Steam Setup
- Steam is installed automatically
- Enable Proton Experimental for latest compatibility
- Right-click games → Properties → Compatibility
- Force specific Proton version if needed

### Game Performance
- Native Linux games: 100% performance
- Proton games: 90-95% performance
- Add to launch options: `gamemoderun %command%`

### Lutris for Other Launchers
- Installed by automation script
- Supports Epic, GOG, Battle.net, etc.
- Check lutris.net for installation scripts

## Development Environment

### Pre-Installed Tools
- Git (configure with your credentials)
- Node.js LTS (for JavaScript/MCP)
- Python 3 with pip
- VS Code
- Docker (optional during setup)

### Additional Setup
```bash
# Generate SSH key for Git
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub/GitLab
cat ~/.ssh/id_ed25519.pub
```

## Troubleshooting

### Common Issues

**Black screen after install**
- Boot with `nomodeset` parameter
- Install NVIDIA drivers properly
- Switch between integrated/dedicated GPU

**WiFi not working**
```bash
# Check if detected
ip link
# Restart NetworkManager
sudo systemctl restart NetworkManager
```

**250Hz not available**
- Ensure kernel 6.8+ is installed
- Check with: `uname -r`
- Verify in display settings

**Audio device missing**
```bash
# Restart PulseAudio
pulseaudio -k
pulseaudio --start
```

## Performance Optimization

### CPU Performance
```bash
# Already set to performance mode by script
# Verify with:
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### GPU Performance
- NVIDIA drivers handle this automatically
- Use `nvidia-smi` to monitor
- Force performance mode for gaming:
  ```bash
  sudo nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1"
  ```

### Storage Optimization
- TRIM is enabled automatically
- NVMe optimization applied
- No need for manual defrag

## Maintenance

### Weekly Tasks
The automation script sets up weekly maintenance:
- Package updates check
- Clean package cache
- TRIM SSDs
- Check NVMe health

### Manual Health Checks
```bash
# Check NVMe health
nvme-health

# Check temperatures
temps

# System information
sysinfo
```

## Success Metrics

You'll know the migration succeeded when:
- ✅ Both displays work at native resolution/refresh
- ✅ All 6 audio devices are manageable
- ✅ Games run smoothly
- ✅ Development tools work perfectly
- ✅ System boots in 15 seconds
- ✅ You haven't booted Windows in a week!

## Getting Help

- **Pop!_OS Chat**: https://chat.pop-os.org/
- **This Repository**: Open an issue
- **Pop!_OS Subreddit**: r/pop_os
- **Linux Gaming**: r/linux_gaming

---

Remember: This is a journey, not a destination. Take your time, enjoy learning, and welcome to the Linux community! 🐧