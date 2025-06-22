#!/bin/bash
# Pop!_OS 22.04 LTS Post-Installation Automation Script
# Version: 1.0 - Acer Predator PTX17-71 Edition
# Description: Fully automated setup for Claude Desktop workstation with gaming support
# Usage: wget -O- https://raw.githubusercontent.com/omar-el-mountassir/gaming-laptop-popos-migration/main/scripts/post-install-setup.sh | bash

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Logging functions
log() { echo -e "${GREEN}[$(date +%T)]${NC} $1" | tee -a ~/popos-setup.log; }
error() { echo -e "${RED}[ERROR]${NC} $1" | tee -a ~/popos-setup.log; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a ~/popos-setup.log; }
info() { echo -e "${BLUE}[INFO]${NC} $1" | tee -a ~/popos-setup.log; }
success() { echo -e "${GREEN}[✓]${NC} $1" | tee -a ~/popos-setup.log; }

# System detection
DISTRO=$(lsb_release -si)
VERSION=$(lsb_release -sr)
KERNEL=$(uname -r)

cat << "EOF"
 ____            _   ___  ____    ____       _               
|  _ \ ___  _ __| | / _ \/ ___|  / ___|  ___| |_ _   _ _ __  
| |_) / _ \| '_ \!| | | \___ \  \___ \ / _ \ __| | | | '_ \ 
|  __/ (_) | |_) |_| |_| |___) |  ___) |  __/ |_| |_| | |_) |
|_|   \___/| .__/  |\___/|____/  |____/ \___|\__|\__,_| .__/ 
           |_|     |_|                                 |_|    
           Acer Predator PTX17-71 Edition
EOF

echo -e "\n${PURPLE}=== Pop!_OS Post-Installation Automation ===${NC}"
echo "System: $DISTRO $VERSION | Kernel: $KERNEL"
echo "This script will configure your system automatically."
echo "Estimated time: 30-45 minutes"
echo -e "\nPress ${GREEN}Enter${NC} to continue or ${RED}Ctrl+C${NC} to cancel..."
read

# Create setup directory
SETUP_DIR="$HOME/.popos-setup"
mkdir -p "$SETUP_DIR"
cd "$SETUP_DIR"

# ============================================================================
# PHASE 1: System Updates & Essential Tools
# ============================================================================
log "Phase 1: System Updates & Essential Tools"

# Update package lists
log "Updating package lists..."
sudo apt update

# Upgrade existing packages
log "Upgrading existing packages..."
sudo apt upgrade -y

# Install essential tools
log "Installing essential system tools..."
sudo apt install -y \
    curl wget git vim neovim \
    build-essential cmake pkg-config \
    htop btop neofetch tree ncdu \
    gnome-tweaks gnome-shell-extensions \
    timeshift gparted synaptic \
    apt-transport-https ca-certificates \
    software-properties-common \
    net-tools traceroute \
    unzip p7zip-full p7zip-rar \
    ffmpeg imagemagick \
    fonts-firacode fonts-cascadia-code

success "Essential tools installed"

# ============================================================================
# PHASE 2: Kernel 6.8+ Upgrade (For 250Hz display & Predator support)
# ============================================================================
log "Phase 2: Kernel Upgrade for Hardware Support"

CURRENT_KERNEL_VERSION=$(uname -r | cut -d. -f1,2)
REQUIRED_KERNEL="6.8"

if (( $(echo "$CURRENT_KERNEL_VERSION < $REQUIRED_KERNEL" | bc -l) )); then
    log "Current kernel $CURRENT_KERNEL_VERSION is older than required $REQUIRED_KERNEL"
    log "Installing mainline kernel tool..."
    
    sudo add-apt-repository -y ppa:cappelikan/ppa
    sudo apt update
    sudo apt install -y mainline
    
    log "Installing kernel 6.8..."
    sudo mainline --install 6.8
    
    warning "Kernel 6.8 installed - REBOOT REQUIRED after script completion"
    REBOOT_REQUIRED=true
else
    success "Kernel $CURRENT_KERNEL_VERSION meets requirements"
    REBOOT_REQUIRED=false
fi

# ============================================================================
# PHASE 3: NVIDIA Drivers & Graphics Configuration
# ============================================================================
log "Phase 3: NVIDIA Drivers & Graphics Configuration"

# Install NVIDIA drivers if not already installed
if ! command -v nvidia-smi &> /dev/null; then
    log "Installing NVIDIA drivers..."
    sudo apt install -y system76-driver-nvidia
else
    success "NVIDIA drivers already installed"
fi

# Configure NVIDIA settings
log "Configuring NVIDIA for optimal performance..."
sudo nvidia-xconfig --cool-bits=28 --allow-empty-initial-configuration 2>/dev/null || true

# Install GPU monitoring tools
sudo apt install -y nvtop nvidia-settings

success "NVIDIA configuration complete"

# ============================================================================
# PHASE 4: Display Configuration (2560x1600@250Hz + 1920x1080@144Hz)
# ============================================================================
log "Phase 4: Multi-Monitor Display Configuration"

# Create display setup scripts directory
mkdir -p ~/Scripts

# Create display configuration script
cat > ~/Scripts/display-setup.sh << 'DISPLAY_SCRIPT'
#!/bin/bash
# Acer Predator mixed resolution display setup
# Laptop: 2560x1600 @ 250Hz | ASUS: 1920x1080 @ 144Hz

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
DISPLAY_SCRIPT

chmod +x ~/Scripts/display-setup.sh

# Create autostart entry
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/display-setup.desktop << 'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Display Configuration
Exec=/home/$USER/Scripts/display-setup.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Comment=Configure mixed resolution displays
AUTOSTART

# Create display profile switching scripts
cat > ~/Scripts/laptop-only.sh << 'EOF'
#!/bin/bash
xrandr --output $(xrandr | grep " connected" | grep "1920x1080" | awk '{print $1}') --off
xrandr --output $(xrandr | grep " connected" | grep "2560x1600" | awk '{print $1}') --mode 2560x1600 --rate 250 --scale 1x1
notify-send "Display Mode" "Laptop only (2560x1600@250Hz)"
EOF

cat > ~/Scripts/external-only.sh << 'EOF'
#!/bin/bash
xrandr --output $(xrandr | grep " connected" | grep "2560x1600" | awk '{print $1}') --off
xrandr --output $(xrandr | grep " connected" | grep "1920x1080" | awk '{print $1}') --mode 1920x1080 --rate 144 --scale 1x1
notify-send "Display Mode" "External only (1920x1080@144Hz)"
EOF

chmod +x ~/Scripts/*.sh

success "Display configuration scripts created"

# ============================================================================
# PHASE 5: Audio Configuration (6 Device Setup)
# ============================================================================
log "Phase 5: Audio System Configuration"

# Install audio management tools
sudo apt install -y \
    pavucontrol \
    pulseaudio-module-bluetooth \
    alsa-utils \
    playerctl

# Create audio profile switcher
cat > ~/Scripts/audio-switch.sh << 'AUDIO_SCRIPT'
#!/bin/bash
# Audio device quick switcher

case "$1" in
    laptop)
        SINK=$(pactl list short sinks | grep -i "pci.*analog-stereo" | head -1 | awk '{print $2}')
        ;;
    hdmi)
        SINK=$(pactl list short sinks | grep -i "hdmi" | head -1 | awk '{print $2}')
        ;;
    usb)
        SINK=$(pactl list short sinks | grep -i "usb" | head -1 | awk '{print $2}')
        ;;
    *)
        echo "Usage: $0 {laptop|hdmi|usb}"
        echo "Available sinks:"
        pactl list short sinks
        exit 1
        ;;
esac

if [ -n "$SINK" ]; then
    pactl set-default-sink "$SINK"
    notify-send "Audio Output" "Switched to $1" -i audio-volume-high
else
    notify-send "Audio Error" "Could not find $1 audio device" -i dialog-error
fi
AUDIO_SCRIPT

chmod +x ~/Scripts/audio-switch.sh

# Configure PulseAudio for gaming (low latency)
mkdir -p ~/.config/pulse
cat >> ~/.config/pulse/daemon.conf << 'PULSE_CONFIG'
default-sample-rate = 48000
alternate-sample-rate = 44100
default-fragments = 3
default-fragment-size-msec = 5
PULSE_CONFIG

success "Audio configuration complete"

# ============================================================================
# PHASE 6: Development Environment
# ============================================================================
log "Phase 6: Development Environment Setup"

# Node.js LTS (for MCP servers)
if ! command -v node &> /dev/null; then
    log "Installing Node.js LTS..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    success "Node.js already installed: $(node --version)"
fi

# Python development tools
log "Installing Python development tools..."
sudo apt install -y \
    python3-pip \
    python3-venv \
    python3-dev \
    ipython3

# Docker (optional - ask user)
read -p "Install Docker? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Installing Docker..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker $USER
    warning "Docker installed - logout required for group membership"
fi

# Git configuration
log "Configuring Git..."
read -p "Enter your Git name: " git_name
read -p "Enter your Git email: " git_email
git config --global user.name "$git_name"
git config --global user.email "$git_email"
git config --global init.defaultBranch main
git config --global core.editor "vim"

success "Development environment configured"

# ============================================================================
# PHASE 7: Claude Desktop Installation
# ============================================================================
log "Phase 7: Claude Desktop Installation"

if ! command -v claude-desktop &> /dev/null; then
    log "Installing Claude Desktop..."
    wget -O- https://raw.githubusercontent.com/emsi/claude-desktop/refs/heads/main/install-claude-desktop.sh | bash
    
    # Create optimized launcher
    sudo sed -i 's/Exec=claude-desktop/Exec=claude-desktop --enable-features=VaapiVideoDecoder --enable-gpu-rasterization --enable-zero-copy/g' \
        /usr/share/applications/claude-desktop.desktop 2>/dev/null || true
else
    success "Claude Desktop already installed"
fi

# Create MCP server directory
mkdir -p ~/mcp-servers
cd ~/mcp-servers
npm init -y 2>/dev/null || true

info "Claude Desktop installed - Configure MCP servers manually after setup"

# ============================================================================
# PHASE 8: Productivity Applications
# ============================================================================
log "Phase 8: Installing Productivity Applications"

# Microsoft Edge
if ! command -v microsoft-edge &> /dev/null; then
    log "Installing Microsoft Edge..."
    curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
    sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
    sudo apt update
    sudo apt install -y microsoft-edge-stable
else
    success "Microsoft Edge already installed"
fi

# Other productivity tools
log "Installing productivity applications..."
sudo apt install -y \
    thunderbird \
    libreoffice \
    flameshot \
    ulauncher \
    copyq \
    obs-studio \
    vlc \
    gimp

# VS Code
if ! command -v code &> /dev/null; then
    log "Installing Visual Studio Code..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
    sudo apt update
    sudo apt install -y code
fi

success "Productivity applications installed"

# ============================================================================
# PHASE 9: Gaming Setup
# ============================================================================
log "Phase 9: Gaming Environment Setup"

read -p "Install gaming tools? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log "Installing gaming tools..."
    
    # Steam
    sudo apt install -y steam-installer gamemode mangohud
    
    # GameMode configuration
    sudo usermod -a -G gamemode $USER
    
    # Lutris for additional game launchers
    sudo add-apt-repository -y ppa:lutris-team/lutris
    sudo apt update
    sudo apt install -y lutris
    
    # Create gaming mode script
    cat > ~/Scripts/gaming-mode.sh << 'GAMING_SCRIPT'
#!/bin/bash
# Optimize system for gaming

# CPU Governor
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# GPU Performance Mode
nvidia-settings -a "[gpu:0]/GPUPowerMizerMode=1"

# Disable compositor (if using X11)
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
    kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
    qdbus org.kde.KWin /KWin reconfigure
fi

notify-send "Gaming Mode" "Performance optimizations enabled" -i applications-games
GAMING_SCRIPT
    
    chmod +x ~/Scripts/gaming-mode.sh
    
    success "Gaming environment configured"
fi

# ============================================================================
# PHASE 10: System Optimizations
# ============================================================================
log "Phase 10: System Performance Optimizations"

# TLP for power management
log "Installing TLP for power management..."
sudo apt install -y tlp tlp-rdw
sudo tlp start

# Preload for faster application launches
sudo apt install -y preload

# CPU frequency utilities
sudo apt install -y cpufrequtils
echo 'GOVERNOR="performance"' | sudo tee /etc/default/cpufrequtils

# NVMe optimization
log "Optimizing NVMe drives..."
# Enable TRIM
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer

# I/O Scheduler optimization
echo 'ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"' | \
    sudo tee /etc/udev/rules.d/60-nvme-scheduler.rules

# Swappiness for 32GB RAM
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure=50" | sudo tee -a /etc/sysctl.conf

# Network optimizations for Killer Ethernet
echo "net.core.default_qdisc=fq" | sudo tee -a /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a /etc/sysctl.conf

sudo sysctl -p

success "System optimizations applied"

# ============================================================================
# PHASE 11: GNOME Customization
# ============================================================================
log "Phase 11: GNOME Desktop Customization"

# Dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'

# Show battery percentage
gsettings set org.gnome.desktop.interface show-battery-percentage true

# Enable fractional scaling for mixed DPI
gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"

# Keyboard shortcuts
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
    "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', \
      '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

# Terminal shortcut
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-terminal'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Control><Alt>t'

# Claude Desktop shortcut
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name 'Claude Desktop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command 'claude-desktop'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding '<Super>c'

# Dock customization
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 48
gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false

success "GNOME customization complete"

# ============================================================================
# PHASE 12: Terminal Enhancement
# ============================================================================
log "Phase 12: Terminal Environment Enhancement"

# Bash aliases and functions
cat >> ~/.bashrc << 'BASHRC_ADDITIONS'

# Custom aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gd='git diff'
alias update='sudo apt update && sudo apt upgrade'
alias search='apt search'
alias install='sudo apt install'
alias ..='cd ..'
alias ...='cd ../..'
alias displays='~/Scripts/display-setup.sh'
alias laptop-only='~/Scripts/laptop-only.sh'
alias external-only='~/Scripts/external-only.sh'
alias audio='~/Scripts/audio-switch.sh'
alias temps='watch -n 1 "sensors | grep -E \"(Core|Package|fan|GPU)\""'

# Useful functions
extract() {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick system info
sysinfo() {
    echo "=== System Information ==="
    echo "OS: $(lsb_release -ds)"
    echo "Kernel: $(uname -r)"
    echo "CPU: $(lscpu | grep "Model name" | sed 's/Model name:[ ]*//')"
    echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null || echo "Not detected")"
    echo "RAM: $(free -h | awk '/^Mem:/ {print $2}')"
    echo "Uptime: $(uptime -p)"
}

# NVMe health check
nvme-health() {
    echo "=== NVMe Drive Health ==="
    for drive in /dev/nvme*n1; do
        if [ -e "$drive" ]; then
            echo -e "\nDrive: $drive"
            sudo nvme smart-log $drive | grep -E "(critical_warning|temperature|available_spare|percentage_used)"
        fi
    done
}

# Better prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Enable bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
BASHRC_ADDITIONS

success "Terminal environment enhanced"

# ============================================================================
# PHASE 13: Security & Maintenance
# ============================================================================
log "Phase 13: Security & Maintenance Setup"

# Firewall
log "Configuring firewall..."
sudo apt install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw --force enable

# Automatic security updates
sudo apt install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# System monitoring tools
sudo apt install -y \
    lm-sensors \
    fancontrol \
    smartmontools \
    nvme-cli

# Initialize sensors
sudo sensors-detect --auto

# Create system maintenance script
cat > ~/Scripts/system-maintenance.sh << 'MAINTENANCE_SCRIPT'
#!/bin/bash
# Weekly system maintenance

echo "=== System Maintenance Starting ==="

# Update package database
sudo apt update

# Clean package cache
sudo apt autoremove -y
sudo apt autoclean

# Update locate database
sudo updatedb

# TRIM SSDs
sudo fstrim -av

# Check NVMe health
for drive in /dev/nvme*n1; do
    if [ -e "$drive" ]; then
        echo -e "\nChecking $drive..."
        sudo smartctl -a $drive | grep -E "(Critical Warning|Temperature|Available Spare|Percentage Used)"
    fi
done

# Log rotation
sudo logrotate -f /etc/logrotate.conf

echo "=== Maintenance Complete ==="
notify-send "System Maintenance" "Weekly maintenance completed successfully" -i dialog-information
MAINTENANCE_SCRIPT

chmod +x ~/Scripts/system-maintenance.sh

# Add to crontab (weekly on Sunday at 2 AM)
(crontab -l 2>/dev/null; echo "0 2 * * 0 $HOME/Scripts/system-maintenance.sh") | crontab -

success "Security and maintenance configured"

# ============================================================================
# PHASE 14: Final Cleanup & Summary
# ============================================================================
log "Phase 14: Final Cleanup"

# Clean up
sudo apt autoremove -y
sudo apt autoclean

# Create system info file
cat > ~/Desktop/system-info.txt << EOF
Pop!_OS System Configuration Summary
====================================
Generated: $(date)

Hardware:
- CPU: Intel Core i9-13900HX (24C/32T)
- GPU: NVIDIA RTX 4090 Laptop
- RAM: 32GB
- Displays: 2560x1600@250Hz + 1920x1080@144Hz

Quick Commands:
- Switch displays: displays, laptop-only, external-only
- Switch audio: audio laptop|hdmi|usb
- System info: sysinfo
- NVMe health: nvme-health
- Temperature monitoring: temps

Important Locations:
- Scripts: ~/Scripts/
- MCP Servers: ~/mcp-servers/
- Logs: ~/popos-setup.log

Keyboard Shortcuts:
- Terminal: Ctrl+Alt+T
- Claude Desktop: Super+C

Notes:
- Kernel 6.8 installed: $([[ $REBOOT_REQUIRED == true ]] && echo "REBOOT REQUIRED" || echo "Already running")
- Docker installed: $(command -v docker &> /dev/null && echo "Yes - LOGOUT REQUIRED" || echo "No")
- Firewall: Enabled
- Automatic updates: Configured
- Weekly maintenance: Scheduled

For detailed setup log, see: ~/popos-setup.log
EOF

# ============================================================================
# COMPLETION
# ============================================================================

echo
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN}   Pop!_OS Setup Complete! 🎉${NC}"
echo -e "${GREEN}=============================================${NC}"
echo
echo "Summary:"
success "System updated and optimized"
success "Development environment ready"
success "Display configuration prepared"
success "Audio system configured"
success "Gaming tools installed (if selected)"
success "Security measures in place"
echo
if [[ $REBOOT_REQUIRED == true ]]; then
    echo -e "${YELLOW}IMPORTANT: Reboot required for kernel 6.8${NC}"
    echo -e "${YELLOW}Run: sudo reboot${NC}"
else
    echo -e "${GREEN}No reboot required - kernel already up to date${NC}"
fi
echo
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker installed - logout/login required for group membership${NC}"
fi
echo
echo "Next steps:"
echo "1. Configure Claude Desktop with your API key"
echo "2. Sign into Microsoft Edge and sync your profile"
echo "3. Set up Git SSH keys if needed"
echo "4. Install any additional software via Pop Shop"
echo
echo -e "Setup log saved to: ${BLUE}~/popos-setup.log${NC}"
echo -e "System info saved to: ${BLUE}~/Desktop/system-info.txt${NC}"
echo
echo "Enjoy your new Pop!_OS system! 🚀"
