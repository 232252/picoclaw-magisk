#!/system/bin/sh
# PicoClaw Magisk Module - 服务启动脚本

MODDIR=${0%/*}

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

# 等待系统就绪
wait_for_system

# 启动服务
start_service

log_info "=== 启动流程完成 ==="
