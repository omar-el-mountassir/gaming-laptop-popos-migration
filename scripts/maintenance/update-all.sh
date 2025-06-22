#!/bin/bash
# Comprehensive system update script
# Updates all package managers and firmware

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== System Update Script ===${NC}"
echo "This will update all system packages and firmware"
echo "Press Enter to continue or Ctrl+C to cancel..."
read

# APT packages
echo -e "\n${YELLOW}Updating APT packages...${NC}"
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean

# Snap packages
if command -v snap &> /dev/null; then
    echo -e "\n${YELLOW}Updating Snap packages...${NC}"
    sudo snap refresh
fi

# Flatpak packages
if command -v flatpak &> /dev/null; then
    echo -e "\n${YELLOW}Updating Flatpak packages...${NC}"
    flatpak update -y
    flatpak uninstall --unused -y
fi

# Firmware updates
if command -v fwupdmgr &> /dev/null; then
    echo -e "\n${YELLOW}Checking firmware updates...${NC}"
    sudo fwupdmgr refresh --force
    sudo fwupdmgr update
fi

# NVIDIA driver check
if command -v nvidia-smi &> /dev/null; then
    echo -e "\n${YELLOW}Current NVIDIA driver:${NC}"
    nvidia-smi --query-gpu=driver_version --format=csv,noheader
    echo "To update NVIDIA drivers, use:"
    echo "sudo apt install system76-driver-nvidia"
fi

# Update file database
echo -e "\n${YELLOW}Updating file database...${NC}"
sudo updatedb

# Clean package cache
echo -e "\n${YELLOW}Cleaning package cache...${NC}"
sudo apt clean

# Report
echo -e "\n${GREEN}=== Update Complete ===${NC}"
echo "System packages: Updated"
echo "Snap packages: $(snap list | wc -l) installed"
echo "Flatpak packages: $(flatpak list | wc -l) installed"
echo "Kernel version: $(uname -r)"

echo -e "\n${YELLOW}Reboot recommended if kernel was updated${NC}"