#!/system/bin/sh
# PicoClaw Magisk Module 管理脚本
# 版本: 1.0

MODDIR=${0%/*}
MODULE_DIR="/data/adb/modules/picoclaw"
PICOCLAW_DIR="${MODULE_DIR}"
PICOCLAW_HOME="/sdcard/picoclaw"
CONFIG_FILE="${PICOCLAW_HOME}/config.json"
LOG_DIR="${PICOCLAW_HOME}/logs"
LOG_FILE="${LOG_DIR}/action.log"
PICOCLAW="${PICOCLAW_DIR}/picoclaw"
PICOCLAW_WEB="${PICOCLAW_DIR}/picoclaw-web"
PID_FILE="${MODULE_DIR}/picoclaw.pid"
WEB_PID_FILE="${MODULE_DIR}/picoclaw-web.pid"
WEB_PORT=12088

mkdir -p "${LOG_DIR}"
touch "${LOG_FILE}"

log() {
    local message="$(date "+%Y-%m-%d %H:%M:%S") $1"
    echo "$message"
    echo "$message" >> "${LOG_FILE}"
}

update_status() {
    local status=$1
    local prop_file="$MODULE_DIR/module.prop"
    if [ -f "$prop_file" ]; then
        sed -i "s/^description=.*/description=PicoClaw AI助手 | $status/" "$prop_file"
    fi
}

get_pid() {
    if [ -f "$PID_FILE" ]; then
        cat "$PID_FILE"
    fi
}

get_web_pid() {
    if [ -f "$WEB_PID_FILE" ]; then
        cat "$WEB_PID_FILE"
    fi
}

is_running() {
    local pid=$1
    if [ -n "$pid" ] && kill -0 $pid 2>/dev/null; then
        return 0
    fi
    return 1
}

start() {
    mkdir -p "${LOG_DIR}"
    mkdir -p "${PICOCLAW_HOME}/workspace"
    mkdir -p "${PICOCLAW_HOME}/workspace/skills"
    mkdir -p "${PICOCLAW_HOME}/workspace/memory"
    touch "${LOG_FILE}"
    
    log "执行 start 命令"
    echo "执行 start 命令"
    
    # 检查 picoclaw
    local pid=$(get_pid)
    if is_running $pid; then
        echo "PicoClaw 已在运行 (PID: $pid)"
        log "PicoClaw 已在运行 (PID: $pid)"
    else
        echo "正在启动 PicoClaw..."
        log "正在启动 PicoClaw..."
        
        cd "${PICOCLAW_DIR}"
        export PICOCLAW_HOME="${PICOCLAW_HOME}"
        
        nohup ${PICOCLAW} gateway > "${LOG_DIR}/picoclaw.log" 2>&1 &
        echo $! > "$PID_FILE"
        log "PicoClaw 已启动 (PID: $(get_pid))"
        echo "PicoClaw 已启动 (PID: $(get_pid))"
        
        sleep 3
    fi
    
    # 检查 picoclaw-web
    local web_pid=$(get_web_pid)
    if is_running $web_pid; then
        echo "PicoClaw Web 已运行 (PID: $web_pid)"
        log "PicoClaw Web 已运行 (PID: $web_pid)"
    else
        echo "正在启动 PicoClaw Web..."
        log "正在启动 PicoClaw Web..."
        
        nohup ${PICOCLAW_WEB} -public -port ${WEB_PORT} > "${LOG_DIR}/picoclaw-web.log" 2>&1 &
        echo $! > "$WEB_PID_FILE"
        log "PicoClaw Web 已启动 (PID: $(get_web_pid))"
        echo "PicoClaw Web 已启动 (PID: $(get_web_pid))"
    fi
    
    update_status "运行中"
}

stop() {
    mkdir -p "${LOG_DIR}"
    touch "${LOG_FILE}"
    
    log "执行 stop 命令"
    echo "执行 stop 命令"
    
    # 停止 picoclaw-web
    local web_pid=$(get_web_pid)
    if is_running $web_pid; then
        echo "正在停止 PicoClaw Web..."
        log "正在停止 PicoClaw Web..."
        kill $web_pid 2>/dev/null
        rm -f "$WEB_PID_FILE"
    fi
    
    # 停止 picoclaw
    local pid=$(get_pid)
    if is_running $pid; then
        echo "正在停止 PicoClaw..."
        log "正在停止 PicoClaw..."
        kill $pid 2>/dev/null
        rm -f "$PID_FILE"
        sleep 1
    fi
    
    # 确保所有进程停止
    pkill -f picoclaw 2>/dev/null
    
    echo "PicoClaw 已停止"
    log "PicoClaw 已停止"
    update_status "已停止"
}

restart() {
    log "执行 restart 命令"
    echo "执行 restart 命令"
    stop
    sleep 2
    start
}

status() {
    mkdir -p "${LOG_DIR}"
    touch "${LOG_FILE}"
    
    log "执行 status 命令"
    echo "执行 status 命令"
    echo ""
    
    local pid=$(get_pid)
    if is_running $pid; then
        echo "PicoClaw: 运行中 (PID: $pid)"
        log "PicoClaw: 运行中 (PID: $pid)"
    else
        echo "PicoClaw: 未运行"
        log "PicoClaw: 未运行"
    fi
    
    local web_pid=$(get_web_pid)
    if is_running $web_pid; then
        echo "PicoClaw Web: 运行中 (PID: $web_pid)"
        log "PicoClaw Web: 运行中 (PID: $web_pid)"
    else
        echo "PicoClaw Web: 未运行"
        log "PicoClaw Web: 未运行"
    fi
    
    echo ""
    echo "进程列表:"
    ps -A | grep picoclaw | grep -v grep
    
    echo ""
    echo "网络端口:"
    netstat -tlnp 2>/dev/null | grep -E "12088|18790" || echo "无监听端口"
}

logs() {
    mkdir -p "${LOG_DIR}"
    echo "执行 log 命令"
    echo ""
    echo "=== PicoClaw 日志 ==="
    tail -30 "${LOG_DIR}/picoclaw.log" 2>/dev/null || echo "无日志"
    echo ""
    echo "=== PicoClaw Web 日志 ==="
    tail -20 "${LOG_DIR}/picoclaw-web.log" 2>/dev/null || echo "无日志"
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    status)
        status
        ;;
    log)
        logs
        ;;
    *)
        echo "用法: $0 {start|stop|restart|status|log}"
        exit 1
        ;;
esac
