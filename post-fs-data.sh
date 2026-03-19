#!/system/bin/sh
# PicoClaw Magisk Module - post-fs-data 脚本
# 在模块挂载后立即执行，修复权限

MODDIR=${0%/*}

# 修复二进制文件权限
chmod 755 "$MODDIR/picoclaw" 2>/dev/null
chmod 755 "$MODDIR/tool.sh" "$MODDIR/service.sh" "$MODDIR/action.sh" 2>/dev/null

# 确保目录存在
mkdir -p /sdcard/picoclaw/workspace
mkdir -p /sdcard/picoclaw/log
