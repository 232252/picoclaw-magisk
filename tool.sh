#!/system/bin/sh
# PicoClaw Magisk Module - 公共函数库
#
# DNS 和时区配置:
#   - TZ: Asia/Shanghai (解决日志时间问题)
#   - DNS: 8.8.8.8, 223.5.5.5, 114.114.114.114 (解决网络解析问题)
#   - SSL_CERT_FILE: /system/etc/security/cacerts (解决 TLS 证书问题)

MODDIR=${0%/*}
MODNAME="picoclaw"
PICOCLAW="$MODDIR/picoclaw"
PICOCLAW_HOME="/sdcard/picoclaw"
WORKSPACE="$PICOCLAW_HOME/workspace"
CONFIG="$PICOCLAW_HOME/config.json"
LOGDIR="$PICOCLAW_HOME/log"
LOGFILE="$LOGDIR/picoclaw.log"
PIDFILE="$MODDIR/picoclaw.pid"
PICOCLAW_CONFIG_DIR="$PICOCLAW_HOME/.picoclaw"
PICOCLAW_CONFIG="$PICOCLAW_CONFIG_DIR/config.json"

MAX_LOG_SIZE=10485760
MAX_LOG_FILES=5

# 关键环境变量
export TZ=Asia/Shanghai
export DNS1="${DNS1:-8.8.8.8}"
export DNS2="${DNS2:-223.5.5.5}"
export DNS3="${DNS3:-114.114.114.114}"
export SSL_CERT_FILE="/system/etc/security/cacerts"
export SSL_CERT_DIR="/system/etc/security/cacerts"
export HOME="$PICOCLAW_HOME"
export PICOCLAW_HOME

apply_dns_config() {
    setprop net.dns1 "$DNS1" 2>/dev/null
    setprop net.dns2 "$DNS2" 2>/dev/null
    setprop net.dns3 "$DNS3" 2>/dev/null
}

log() {
  echo "[$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_info() {
  log "[INFO] $1"
}

log_error() {
  log "[ERROR] $1"
}

init_dirs() {
  mkdir -p "$LOGDIR" "$WORKSPACE" "$WORKSPACE/skills" "$WORKSPACE/memory" "$PICOCLAW_CONFIG_DIR"
  touch "$LOGFILE"
  apply_dns_config
}

get_pid() {
  [ -f "$PIDFILE" ] && cat "$PIDFILE" 2>/dev/null
}

is_running() {
  local pid=$1
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

is_picoclaw_running() {
  is_running "$(get_pid)"
}

cleanup_pidfile() {
  if [ -f "$PIDFILE" ]; then
    local pid=$(get_pid)
    if [ -n "$pid" ] && ! is_running "$pid"; then
      rm -f "$PIDFILE"
    fi
  fi
}

update_description() {
  local status="$1"
  case "$status" in
    running)
      sed -i "s|^description=.*|description=PicoClaw v0.4.3 | TZ: Asia/Shanghai | DNS: $DNS1 | SSL: cacerts|" "$MODDIR/module.prop" 2>/dev/null
      ;;
    stopped)
      sed -i "s|^description=.*|description=PicoClaw AI助手 | [状态]已停止|" "$MODDIR/module.prop" 2>/dev/null
      ;;
    error)
      sed -i "s|^description=.*|description=PicoClaw AI助手 | [状态]启动失败|" "$MODDIR/module.prop" 2>/dev/null
      ;;
  esac
}

check_config() {
  if [ -f "$MODDIR/config.json" ] && [ ! -f "$CONFIG" ]; then
    cp "$MODDIR/config.json" "$CONFIG"
    log_info "配置已复制到 $CONFIG"
  fi
  if [ -f "$CONFIG" ] && [ ! -f "$PICOCLAW_CONFIG" ]; then
    mkdir -p "$PICOCLAW_CONFIG_DIR"
    cp "$CONFIG" "$PICOCLAW_CONFIG"
    log_info "配置已复制到 $PICOCLAW_CONFIG"
  fi
}

start_picoclaw() {
  if is_picoclaw_running; then
    echo "PicoClaw 已在运行 (PID: $(get_pid))"
    return 0
  fi
  
  log_info "启动 PicoClaw Gateway + Web UI..."
  log_info "SSL_CERT_FILE=$SSL_CERT_FILE"
  
  cd "$MODDIR"
  chmod 755 "$MODDIR/picoclaw" "$MODDIR/picoclaw-launcher" "$MODDIR/picoclaw-wrapper.sh" 2>/dev/null
  
  # 使用包装脚本启动，确保环境变量被传递
  (
    while true; do
      # 设置所有环境变量并启动
      env \
        TZ="$TZ" \
        DNS1="$DNS1" DNS2="$DNS2" DNS3="$DNS3" \
        SSL_CERT_FILE="$SSL_CERT_FILE" \
        SSL_CERT_DIR="$SSL_CERT_DIR" \
        HOME="$HOME" \
        PICOCLAW_HOME="$PICOCLAW_HOME" \
        "$MODDIR/picoclaw-launcher" -public -port 18800 "$CONFIG" >> "$LOGFILE" 2>&1
      log_info "Launcher 退出，5秒后重启..."
      sleep 5
    done
  ) &
  local pid=$!
  
  sleep 3
  
  if is_running "$pid"; then
    echo "$pid" > "$PIDFILE"
    log_info "PicoClaw Gateway 启动成功 (PID: $pid)"
    return 0
  else
    log_error "PicoClaw Gateway 启动失败"
    return 1
  fi
}

stop_picoclaw() {
  cleanup_pidfile
  if [ -f "$PIDFILE" ]; then
    local pid=$(get_pid)
    if [ -n "$pid" ]; then
      log_info "停止 PicoClaw (PID: $pid)..."
      kill "$pid" 2>/dev/null
      local count=0
      while is_running "$pid" && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
      done
      [ is_running "$pid" ] && kill -9 "$pid" 2>/dev/null
    fi
    rm -f "$PIDFILE"
  fi
}

stop_all() {
  stop_picoclaw
}

start_all() {
  init_dirs
  check_config
  start_picoclaw
}

run_cmd() {
  case "$1" in
    1|start)
      cleanup_pidfile
      start_all
      if is_picoclaw_running; then
        update_description running
        echo "服务已启动"
      else
        update_description error
        echo "服务启动失败"
      fi
      ;;
    2|stop)
      stop_all
      update_description stopped
      echo "服务已停止"
      ;;
    3|restart)
      stop_all
      sleep 2
      start_all
      if is_picoclaw_running; then
        update_description running
        echo "服务已重启"
      else
        update_description error
        echo "服务重启失败"
      fi
      ;;
    4|status)
      cleanup_pidfile
      if is_picoclaw_running; then
        echo "✓ PicoClaw 运行中 (PID: $(get_pid))"
      else
        echo "✗ PicoClaw 未运行"
      fi
      ;;
    5|log)
      [ -f "$LOGFILE" ] && tail -50 "$LOGFILE" || echo "日志文件不存在"
      ;;
    6|dns)
      echo "DNS1: $DNS1, DNS2: $DNS2, DNS3: $DNS3, TZ: $TZ"
      ;;
    *)
      echo "未知命令: $1"
      ;;
  esac
}

if [ "${0##*/}" != "tool.sh" ]; then
  return 0 2>/dev/null || true
fi

if [ -z "$1" ]; then
  echo "PicoClaw 控制面板 (start/stop/restart/status/log/dns)"
else
  run_cmd "$@"
fi
