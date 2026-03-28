#!/system/bin/sh
# PicoClaw Magisk Module - 公共函数库
#
# DNS 和时区配置:
#   - TZ: Asia/Shanghai (解决日志时间问题)
#   - DNS: 8.8.8.8, 223.5.5.5, 114.114.114.114 (解决网络解析问题)
#   - 参考 openp2p-magisk 的环境配置方案

MODDIR=${0%/*}
MODNAME="picoclaw"
PICOCLAW="$MODDIR/picoclaw"
PICOCLAW_HOME="/sdcard/picoclaw"
WORKSPACE="$PICOCLAW_HOME/workspace"
CONFIG="$PICOCLAW_HOME/config.json"
LOGDIR="$PICOCLAW_HOME/log"
LOGFILE="$LOGDIR/picoclaw.log"
PIDFILE="$MODDIR/picoclaw.pid"
WEBPORT=18790

# 日志配置
MAX_LOG_SIZE=10485760  # 10MB
MAX_LOG_FILES=5

# ============================================
# 环境变量配置 (解决 DNS 和时区问题)
# ============================================

# 设置时区
export TZ=Asia/Shanghai

# DNS 配置
# - DNS1: Google DNS (8.8.8.8)
# - DNS2: 阿里 DNS (223.5.5.5)  
# - DNS3: 114 DNS (114.114.114.114)
export DNS1="${DNS1:-8.8.8.8}"
export DNS2="${DNS2:-223.5.5.5}"
export DNS3="${DNS3:-114.114.114.114}"

# 引入环境变量
export PICOCLAW_HOME

# 应用 DNS 配置到系统
apply_dns_config() {
    # 设置 Android 系统 DNS 属性
    if [ -n "$DNS1" ]; then
        setprop net.dns1 "$DNS1" 2>/dev/null
    fi
    if [ -n "$DNS2" ]; then
        setprop net.dns2 "$DNS2" 2>/dev/null
    fi
    if [ -n "$DNS3" ]; then
        setprop net.dns3 "$DNS3" 2>/dev/null
    fi
}

# 日志函数 (带时区信息)
log() {
  echo "[$(TZ=Asia/Shanghai date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
}

log_info() {
  log "[INFO] $1"
}

log_error() {
  log "[ERROR] $1"
}

# 初始化目录
init_dirs() {
  mkdir -p "$LOGDIR"
  mkdir -p "$WORKSPACE"
  mkdir -p "$WORKSPACE/skills"
  mkdir -p "$WORKSPACE/memory"
  touch "$LOGFILE"
  
  # 应用 DNS 配置
  apply_dns_config
}

# 日志轮转
rotate_logs() {
  if [ -f "$LOGFILE" ]; then
    local size
    size=$(stat -c%s "$LOGFILE" 2>/dev/null || echo "0")
    if [ "$size" -gt $MAX_LOG_SIZE ]; then
      for i in $(seq $((MAX_LOG_FILES - 1)) -1 1); do
        [ -f "$LOGFILE.$i" ] && mv "$LOGFILE.$i" "$LOGFILE.$((i + 1))"
      done
      mv "$LOGFILE" "$LOGFILE.1"
      touch "$LOGFILE"
    fi
  fi
}

# 获取 PID
get_pid() {
  [ -f "$PIDFILE" ] && cat "$PIDFILE" 2>/dev/null
}

# 检查进程是否运行
is_running() {
  local pid=$1
  [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

is_picoclaw_running() {
  is_running "$(get_pid)"
}

# 清理无效 PID 文件
cleanup_pidfile() {
  if [ -f "$PIDFILE" ]; then
    local pid
    pid=$(get_pid)
    if [ -n "$pid" ] && ! is_running "$pid"; then
      rm -f "$PIDFILE"
    fi
  fi
}

# 更新 module.prop 状态
update_description() {
  local status="$1"
  case "$status" in
    running)
      sed -i "s|^description=.*|description=PicoClaw AI助手 v0.4.0 | TZ: Asia/Shanghai | DNS: $DNS1 | Web: http://IP:18800 | Gateway: http://IP:18790|" "$MODDIR/module.prop" 2>/dev/null
      ;;
    stopped)
      sed -i "s|^description=.*|description=PicoClaw AI助手 | [状态]已停止|" "$MODDIR/module.prop" 2>/dev/null
      ;;
    starting)
      sed -i "s|^description=.*|description=PicoClaw AI助手 | [状态]启动中...|" "$MODDIR/module.prop" 2>/dev/null
      ;;
    error)
      sed -i "s|^description=.*|description=PicoClaw AI助手 | [状态]启动失败|" "$MODDIR/module.prop" 2>/dev/null
      ;;
  esac
}

# 检查配置文件
check_config() {
  if [ ! -f "$CONFIG" ]; then
    if [ -f "$MODDIR/config.json" ]; then
      cp "$MODDIR/config.json" "$CONFIG"
      log_info "默认配置已复制到 $CONFIG"
    fi
  fi
}

# 启动 PicoClaw Gateway + Web UI
start_picoclaw() {
  if is_picoclaw_running; then
    echo "PicoClaw 已在运行 (PID: $(get_pid))"
    return 0
  fi
  
  log_info "启动 PicoClaw Gateway + Web UI..."
  log_info "环境配置: TZ=$TZ, DNS=$DNS1,$DNS2,$DNS3"
  
  cd "$MODDIR"
  
  # 修复权限
  chmod 755 "$MODDIR/picoclaw" 2>/dev/null
  chmod 755 "$MODDIR/picoclaw-launcher" 2>/dev/null
  
  # picoclaw-launcher 会自动启动 gateway 和 Web UI
  # 使用循环守护，防止 launcher 退出
  (
    while true; do
      HOME="$PICOCLAW_HOME" TZ="$TZ" DNS1="$DNS1" DNS2="$DNS2" DNS3="$DNS3" "$MODDIR/picoclaw-launcher" -public -port 18800 "$CONFIG" >> "$LOGFILE" 2>&1
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

# 停止 PicoClaw
stop_picoclaw() {
  cleanup_pidfile
  if [ -f "$PIDFILE" ]; then
    local pid
    pid=$(get_pid)
    if [ -n "$pid" ]; then
      log_info "停止 PicoClaw (PID: $pid)..."
      kill "$pid" 2>/dev/null
      local count=0
      while is_running "$pid" && [ $count -lt 10 ]; do
        sleep 1
        count=$((count + 1))
      done
      if is_running "$pid"; then
        kill -9 "$pid" 2>/dev/null
      fi
    fi
    rm -f "$PIDFILE"
  fi
}

# 停止所有服务
stop_all() {
  stop_picoclaw
}

# 启动所有服务
start_all() {
  init_dirs
  check_config
  start_picoclaw
}

# 显示帮助
show_help() {
  cat << 'EOF'
PicoClaw 控制面板
==================
  1. start       - 启动服务
  2. stop        - 停止服务
  3. restart     - 重启服务
  4. status      - 查看状态
  5. log         - 查看日志
  6. dns         - 查看 DNS 配置
  0. exit        - 退出
==================
EOF
}

# 显示 DNS 配置
show_dns() {
  echo "当前 DNS 配置:"
  echo "  DNS1: $DNS1"
  echo "  DNS2: $DNS2"
  echo "  DNS3: $DNS3"
  echo "  时区: $TZ"
}

# 运行命令
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
    2|stop      stop_all
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
      if [ -f "$LOGFILE" ]; then
        tail -50 "$LOGFILE"
      else
        echo "日志文件不存在"
      fi
      ;;
    6|dns)
      show_dns
      ;;
    help|h|"")
      show_help
      ;;
    *)
      echo "未知命令: $1"
      return 1
      ;;
  esac
}

# 如果是被 source 引入，直接返回
if [ "${0##*/}" != "tool.sh" ]; then
  return 0 2>/dev/null || true
fi

# 主逻辑 - 交互模式
if [ -z "$1" ]; then
  show_help
  while true; do
    echo -n "picoclaw> "
    read -r cmd || break
    case "$cmd" in
      0|exit|quit)
        echo "再见"
        break
        ;;
      "")
        ;;
      *)
        run_cmd "$cmd"
        ;;
    esac
  done
else
  run_cmd "$@"
fi
