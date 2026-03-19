#!/system/bin/sh
# PicoClaw Magisk Module Service

MODDIR=${0%/*}
PICOCLAW_DIR=/data/adb/picoclaw
PICOCLAW_HOME=/sdcard/picoclaw
WEB_PORT=12088

# Set environment
export PICOCLAW_HOME=/sdcard/picoclaw

# Create workspace
mkdir -p /sdcard/picoclaw/workspace
mkdir -p /sdcard/picoclaw/workspace/skills
mkdir -p /sdcard/picoclaw/workspace/memory

# Kill existing processes
pkill picoclaw 2>/dev/null
pkill picoclaw-web 2>/dev/null
sleep 1

# Start picoclaw core in background
cd /data/adb/picoclaw
nohup /data/adb/picoclaw/picoclaw gateway --allow-empty > /data/adb/picoclaw/picoclaw.log 2>&1 &

# Wait for core to start
sleep 3

# Start web dashboard (bind to 0.0.0.0 for LAN access)
nohup /data/adb/picoclaw/picoclaw-web -public -port 12088 > /data/adb/picoclaw/web.log 2>&1 &

log -t PicoClaw "PicoClaw started on port 12088"
