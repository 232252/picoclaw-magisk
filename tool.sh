#!/system/bin/sh
# PicoClaw Magisk Module - 公共函数库

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

# 引入环境变量
export PICOCLAW_HOME

# 日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOGFILE"
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
      sed -i "s|^description=.*|description=PicoClaw AI助手 | [状态]运行中 | Gateway: http://IP:${WEBPORT}|" "$MODDIR/module.prop" 2>/dev/null
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

# 启动 PicoClaw Gateway
start_picoclaw() {
  if is_picoclaw_running; then
    echo "PicoClaw 已在运行 (PID: $(get_pid))"
    return 0
  fi
  
  log_info "启动 PicoClaw Gateway..."
  
  cd "$MODDIR"
  
  # 设置 HOME 环境变量，让 picoclaw 能找到 ~/.picoclaw/config.json
  # 使用 -E 允许无默认模型启动
  HOME="$PICOCLAW_HOME" nohup "$PICOCLAW" gateway -E > "$LOGFILE" 2>&1 &
  local pid=$!
  
  sleep 5
  
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
  0. exit        - 退出
==================
EOF
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
      if [ -f "$LOGFILE" ]; then
        tail -50 "$LOGFILE"
      else
        echo "日志文件不存在"
      fi
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
