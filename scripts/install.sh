#!/bin/bash

#================================================#
#  PicoClaw Magisk Module Installer
#================================================#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Device IP (default, can be changed)
DEVICE_IP=${1:-"10.126.126.5:5555"}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PicoClaw Magisk Module Installer${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check ADB connection
echo -e "${YELLOW}[*] Checking ADB connection...${NC}"
adb connect $DEVICE_IP 2>/dev/null || true

if ! adb -s $DEVICE_IP shell echo "Connected" > /dev/null 2>&1; then
    echo -e "${RED}[✗] Cannot connect to device${NC}"
    echo -e "${RED}    Please check IP address and ADB connection${NC}"
    exit 1
fi

echo -e "${GREEN}[✓] Connected to device${NC}"
echo ""

# Get device info
echo -e "${YELLOW}[*] Device Info:${NC}"
DEVICE_MODEL=$(adb -s $DEVICE_IP shell getprop ro.product.model 2>/dev/null)
DEVICE_ARCH=$(adb -s $DEVICE_IP shell getprop ro.product.cpu.abi 2>/dev/null)
echo "    Model: $DEVICE_MODEL"
echo "    Arch: $DEVICE_ARCH"
echo ""

# Check root
echo -e "${YELLOW}[*] Checking root access...${NC}"
if ! adb -s $DEVICE_IP shell su -c "echo Root" > /dev/null 2>&1; then
    echo -e "${RED}[✗] Root access denied${NC}"
    echo -e "${RED}    Please grant root permission${NC}"
    exit 1
fi
echo -e "${GREEN}[✓] Root access granted${NC}"
echo ""

# Stop existing services
echo -e "${YELLOW}[*] Stopping existing services...${NC}"
adb -s $DEVICE_IP shell su -c "pkill picoclaw 2>/dev/null || true"
adb -s $DEVICE_IP shell su -c "pkill picoclaw-web 2>/dev/null || true"
echo ""

# Create module directory
echo -e "${YELLOW}[*] Creating module directory...${NC}"
adb -s $DEVICE_IP shell su -c "mkdir -p /data/adb/modules/picoclaw"
adb -s $DEVICE_IP shell su -c "mkdir -p /data/adb/picoclaw"
echo ""

# Push files
echo -e "${YELLOW}[*] Pushing module files...${NC}"
adb -s $DEVICE_IP push module.prop /data/local/tmp/module.prop
adb -s $DEVICE_IP push service.sh /data/local/tmp/service.sh
adb -s $DEVICE_IP push picoclaw /data/local/tmp/picoclaw
adb -s $DEVICE_IP push picoclaw-web /data/local/tmp/picoclaw-web
echo ""

# Copy to module directory
echo -e "${YELLOW}[*] Installing module...${NC}"
adb -s $DEVICE_IP shell su -c "cp /data/local/tmp/module.prop /data/adb/modules/picoclaw/"
adb -s $DEVICE_IP shell su -c "cp /data/local/tmp/service.sh /data/adb/modules/picoclaw/"
adb -s $DEVICE_IP shell su -c "cp /data/local/tmp/picoclaw /data/adb/modules/picoclaw/"
adb -s $DEVICE_IP shell su -c "cp /data/local/tmp/picoclaw-web /data/adb/modules/picoclaw/"
echo ""

# Set permissions
echo -e "${YELLOW}[*] Setting permissions...${NC}"
adb -s $DEVICE_IP shell su -c "chmod 755 /data/adb/modules/picoclaw/*"
echo ""

# Copy binaries to data directory
echo -e "${YELLOW}[*] Copying binaries to data directory...${NC}"
adb -s $DEVICE_IP shell su -c "cp /data/adb/modules/picoclaw/picoclaw /data/adb/picoclaw/"
adb -s $DEVICE_IP shell su -c "cp /data/adb/modules/picoclaw/picoclaw-web /data/adb/picoclaw/"
adb -s $DEVICE_IP shell su -c "chmod 755 /data/adb/picoclaw/picoclaw /data/adb/picoclaw/picoclaw-web"
echo ""

# Create auto_mount marker
adb -s $DEVICE_IP shell su -c "touch /data/adb/modules/picoclaw/auto_mount"
echo ""

# Get device IP for web access
DEVICE_WLAN_IP=$(adb -s $DEVICE_IP shell su -c "ip route get 1 | head -1" 2>/dev/null | grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1)

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Complete! 🎉${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Module Location:${NC}"
echo "    /data/adb/modules/picoclaw/"
echo ""
echo -e "${YELLOW}Data Location:${NC}"
echo "    /data/adb/picoclaw/"
echo ""
echo -e "${YELLOW}Web Dashboard:${NC}"
echo "    http://$DEVICE_WLAN_IP:12088"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "    1. Reboot device: adb reboot"
echo "    2. Or start manually:"
echo "       adb shell su -c 'PICOCLAW_HOME=/data/adb/picoclaw /data/adb/picoclaw/picoclaw-web -public -port 12088 &'"
echo ""
echo -e "${GREEN}Happy chatting! 🦐${NC}"
echo ""
