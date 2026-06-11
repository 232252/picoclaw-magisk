#!/system/bin/sh
# PicoClaw Magisk Module - 服务启动脚本
#
# 环境配置:
#   - TZ: Asia/Shanghai (时区)
#   - DNS: 8.8.8.8, 223.5.5.5, 114.114.114.114 (DNS)
#   - SSL_CERT_FILE: /system/etc/security/cacerts (TLS 证书)
#
# 参考: openp2p-magisk 的环境配置方案

MODDIR=${0%/*}

# ============================================
# 核心环境变量 - 必须在加载 tool.sh 之前设置
# ============================================

export TZ=Asia/Shanghai
export DNS1="${DNS1:-8.8.8.8}"
export DNS2="${DNS2:-223.5.5.5}"
export DNS3="${DNS3:-114.114.114.114}"
export SSL_CERT_FILE="/system/etc/security/cacerts"
export SSL_CERT_DIR="/system/etc/security/cacerts"
export HOME="/sdcard/picoclaw"
export PICOCLAW_HOME="/sdcard/picoclaw"

log() {
  echo "[$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
  log "[INFO] $1"
}

log_error() {
  log "[ERROR] $1"
}

# DNS 配置
setup_dns() {
  log_info "配置 DNS: $DNS1, $DNS2, $DNS3"
  setprop net.dns1 "$DNS1" 2>/dev/null
  setprop net.dns2 "$DNS2" 2>/dev/null
  setprop net.dns3 "$DNS3" 2>/dev/null

  # Android 8+ 使用 settings put global
  if [ "$(getprop ro.build.version.sdk)" -ge 26 ]; then
    settings put global dns1 "$DNS1" 2>/dev/null
    settings put global dns2 "$DNS2" 2>/dev/null
  fi
  log_info "DNS 配置完成"
}

# 等待系统就绪
wait_for_system() {
  local timeout=120
  local count=0

  log_info "等待系统启动..."

  while [ ! -d "/system/bin" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done

  count=0
  while [ "$(getprop sys.boot_completed)" != "1" ] && [ $count -lt $timeout ]; do
    sleep 2
    count=$((count + 2))
  done

  count=0
  while [ ! -d "/sdcard" ] && [ $count -lt $timeout ]; do
    sleep 1
    count=$((count + 1))
  done

  # 等待网络就绪 (通过 connectivity check)
  count=0
  while [ $count -lt 30 ]; do
    if getprop sys.boot_completed | grep -q "1" && [ -d "/sdcard" ]; then
      # 网络检测: 尝试解析域名
      if getprop net.dns1 > /dev/null 2>&1 || [ -f "/system/etc/security/cacerts" ]; then
        log_info "系统就绪"
        return 0
      fi
    fi
    sleep 2
    count=$((count + 2))
  done

  log_info "系统就绪 (基础检查完成)"
}

# 引入公共函数
. "$MODDIR/tool.sh"

# 启动服务（带重试）
start_service() {
  local max_retries=3
  local retry=0
  
  while [ $retry -lt $max_retries ]; do
    log_info "启动 PicoClaw 服务 (尝试 $((retry + 1))/$max_retries)..."
    
    chmod 755 "$MODDIR/picoclaw" "$MODDIR/picoclaw-launcher" "$MODDIR/picoclaw-wrapper.sh" 2>/dev/null
    
    init_dirs
    
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
log_info "TZ=$TZ DNS=$DNS1,$DNS2 SSL_CERT_FILE=$SSL_CERT_FILE"

setup_dns
wait_for_system
start_service

log_info "=== 启动流程完成 ==="
