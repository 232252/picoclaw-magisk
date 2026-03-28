#!/system/bin/sh
# PicoClaw 启动包装脚本
# 确保环境变量被正确传递给 picoclaw gateway

# 设置关键环境变量
export TZ=Asia/Shanghai
export DNS1=8.8.8.8
export DNS2=223.5.5.5
export DNS3=114.114.114.114
export SSL_CERT_FILE="/system/etc/security/cacerts"
export SSL_CERT_DIR="/system/etc/security/cacerts"
export HOME="/sdcard/picoclaw"
export PICOCLAW_HOME="/sdcard/picoclaw"

MODDIR=${0%/*}
CONFIG="/sdcard/picoclaw/config.json"

# 启动 picoclaw-launcher
exec "$MODDIR/picoclaw-launcher" -public -port 18800 "$CONFIG"
