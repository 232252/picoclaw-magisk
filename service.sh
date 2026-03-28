#!/system/bin/sh
# PicoClaw Magisk Module - 服务启动脚本
# 
# DNS 配置说明：
#   - 本模块使用 Google DNS (8.8.8.8, 8.8.4.4) 和国内常用 DNS
#   - DNS 会通过系统属性 net.dns1, net.dns2 设置
#   - 时区默认设置为 Asia/Shanghai
#
# 参考: openp2p-magisk 的环境配置方案

MODDIR=${0%/*}

# ============================================
# 环境配置 - 参考 openp2p-magisk
# ============================================

# 设置时区 (解决时区问题)
export TZ=Asia/Shanghai

# Go TLS 证书配置 (解决 x509 证书验证问题)
export SSL_CERT_FILE="/system/etc/security/cacerts"
export SSL_CERT_DIR="/system/etc/security/cacerts"

# DNS 配置 (解决 DNS 解析问题)
# 使用 Google DNS + 阿里 DNS + 114 DNS 组合
setup_dns() {
    local dns1="${1:-8.8.8.8}"
    local dns2="${2:-223.5.5.5}"
    
    log_info "配置 DNS: $dns1, $dns2"
    
    # 设置 Android 系统 DNS 属性
    setprop net.dns1 "$dns1"
    setprop net.dns2 "$dns2"
    
    # 设置额外的 DNS 属性 (部分设备需要)
    setprop net.dns1.1 "$dns1"
    setprop net.dns2.1 "$dns2"
    
    # 确保 DNS 全局变量
    export DNS1="$dns1"
    export DNS2="$dns2"
    
    # 写入 resolv.conf (部分系统需要)
    if [ -w "/system/etc/resolv.conf" ]; then
        echo "nameserver $dns1" > /system/etc/resolv.conf
        echo "nameserver $dns2" >> /system/etc/resolv.conf
    fi
    
    log_info "DNS 配置完成"
}

# 引入公共函数
. "$MODDIR/tool.sh"

# 等待系统就绪
wait_for_system() {
  local timeout=120
  local count=0
  
  log_info "等待系统启动..."
  
  # 等待 /system 挂载
  while [ ! -d "/system/bin" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done
  
  # 等待 boot 完成
  count=0
  while [ "$(getprop sys.boot_completed)" != "1" ] && [ $count -lt $timeout ]; do
    sleep 2
    count=$((count + 2))
  done
  
  # 等待存储就绪
  count=0
  while [ ! -d "/sdcard" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done
  
  # 等待网络就绪
  count=0
  while [ $count -lt 15 ]; do
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
      log_info "网络就绪"
      break
    fi
    sleep 2
    count=$((count + 2))
  done
  
  log_info "系统就绪"
}

# 启动服务（带重试）
start_service() {
  local max_retries=3
  local retry=0
  
  while [ $retry -lt $max_retries ]; do
    log_info "启动 PicoClaw 服务 (尝试 $((retry + 1))/$max_retries)..."
    
    # 修复权限
    chmod 755 "$MODDIR/picoclaw" 2>/dev/null
    chmod 755 "$MODDIR/tool.sh" 2>/dev/null
    
    # 初始化目录
    init_dirs
    
    # 启动服务
    if start_all; then
      sleep 3
      if is_picoclaw_running; then
        log_info "PicoClaw 服务启动成功"
        update_description running
        return 0
      fi
    fi
    
    retry=$((retry + 1))
    log_error "启动失败，${retry}s 后重试..."
    sleep 5
  done
  
  log_error "PicoClaw 服务启动失败"
  update_description error
  return 1
}

# 主逻辑
log_info "=== PicoClaw 服务启动中 ==="
log_info "时区: $TZ"
log_info "DNS: $DNS1, $DNS2"

# 配置 DNS
setup_dns

# 等待系统就绪
wait_for_system

# 启动服务
start_service

log_info "=== 启动流程完成 ==="
