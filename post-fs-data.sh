#!/system/bin/sh
# PicoClaw Magisk Module - 权限修复脚本
# 在模块挂载后立即执行，修复 unzip 解压后的权限问题

MODDIR=${0%/*}

# 修复所有可执行文件和脚本的权限
chmod 755 "${MODDIR}"/*.sh "${MODDIR}/picoclaw" "${MODDIR}/picoclaw-web" 2>/dev/null

# 创建必要的目录
mkdir -p /sdcard/picoclaw/workspace
mkdir -p /sdcard/picoclaw/workspace/skills
mkdir -p /sdcard/picoclaw/workspace/memory
mkdir -p /sdcard/picoclaw/logs
