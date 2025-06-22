#!/bin/bash
# System health check script

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== System Health Check ===${NC}"
echo "Date: $(date)"
echo

# System information
echo -e "${BLUE}System Information:${NC}"
echo "OS: $(lsb_release -ds)"
echo "Kernel: $(uname -r)"
echo "Uptime: $(uptime -p)"
echo

# CPU Temperature
echo -e "${BLUE}CPU Temperature:${NC}"
if command -v sensors &> /dev/null; then
    sensors | grep -E "(Core|Package)" | while read line; do
        temp=$(echo "$line" | grep -oP '\+\d+\.\d+°C' | head -1)
        if [ -n "$temp" ]; then
            temp_val=$(echo "$temp" | grep -oP '\d+' | head -1)
            if [ "$temp_val" -gt 80 ]; then
                echo -e "${RED}$line${NC}"
            elif [ "$temp_val" -gt 70 ]; then
                echo -e "${YELLOW}$line${NC}"
            else
                echo -e "${GREEN}$line${NC}"
            fi
        fi
    done
else
    echo "sensors not installed"
fi
echo

# GPU Status
echo -e "${BLUE}GPU Status:${NC}"
if command -v nvidia-smi &> /dev/null; then
    nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader
else
    echo "NVIDIA driver not installed"
fi
echo

# Memory Usage
echo -e "${BLUE}Memory Usage:${NC}"
free -h | grep -E "^(Mem|Swap)"
echo

# Disk Usage
echo -e "${BLUE}Disk Usage:${NC}"
df -h | grep -E "^/dev/" | while read line; do
    usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    if [ "$usage" -gt 90 ]; then
        echo -e "${RED}$line${NC}"
    elif [ "$usage" -gt 80 ]; then
        echo -e "${YELLOW}$line${NC}"
    else
        echo -e "${GREEN}$line${NC}"
    fi
done
echo

# NVMe Health
echo -e "${BLUE}NVMe Health:${NC}"
for drive in /dev/nvme*n1; do
    if [ -e "$drive" ]; then
        echo "Drive: $drive"
        sudo nvme smart-log "$drive" 2>/dev/null | grep -E "(critical_warning|temperature|available_spare|percentage_used)" || echo "  Unable to read SMART data"
        echo
    fi
done

# System Load
echo -e "${BLUE}System Load:${NC}"
uptime
echo

# Top Processes
echo -e "${BLUE}Top CPU Processes:${NC}"
ps aux --sort=-%cpu | head -6
echo

echo -e "${BLUE}Top Memory Processes:${NC}"
ps aux --sort=-%mem | head -6
echo

# Recent Errors
echo -e "${BLUE}Recent System Errors (last 10):${NC}"
sudo journalctl -p err -b -n 10 --no-pager

echo -e "\n${GREEN}Health check complete!${NC}"