#!/system/bin/sh
# PicoClaw Magisk Module - post-fs-data 脚本
# 在模块挂载后立即执行，修复权限和配置 DNS/时区

MODDIR=${0%/*}

# 设置时区 (解决时区问题)
export TZ=Asia/Shanghai

# 配置 DNS (解决网络解析问题)
setup_dns_early() {
    # 在早期就设置 DNS，确保网络服务能正确解析
    setprop net.dns1 "8.8.8.8" 2>/dev/null
    setprop net.dns2 "223.5.5.5" 2>/dev/null
    setprop net.dns3 "114.114.114.114" 2>/dev/null
}

# 修复二进制文件权限
chmod 755 "$MODDIR/picoclaw" 2>/dev/null
chmod 755 "$MODDIR/tool.sh" "$MODDIR/service.sh" "$MODDIR/action.sh" 2>/dev/null

# 早期配置 DNS
setup_dns_early

# 确保目录存在
mkdir -p /sdcard/picoclaw/workspace
mkdir -p /sdcard/picoclaw/log
