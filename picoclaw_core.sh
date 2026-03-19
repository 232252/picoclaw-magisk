#!/data/adb/magisk/busybox sh
# PicoClaw Magisk Module - 核心守护进程
# 负责启动和监控 picoclaw 及 picoclaw-web 进程

MODDIR=${0%/*}
PICOCLAW_DIR="${MODDIR}"
PICOCLAW_HOME="/sdcard/picoclaw"
CONFIG_FILE="${PICOCLAW_HOME}/config.json"
LOG_DIR="${PICOCLAW_HOME}/logs"
LOG_FILE="${LOG_DIR}/picoclaw_core.log"
PICOCLAW="${PICOCLAW_DIR}/picoclaw"
PICOCLAW_WEB="${PICOCLAW_DIR}/picoclaw-web"
PID_FILE="${MODDIR}/picoclaw.pid"
WEB_PID_FILE="${MODDIR}/picoclaw-web.pid"
WEB_PORT=12088
CHECK_INTERVAL=30

mkdir -p "${LOG_DIR}"
mkdir -p "${PICOCLAW_HOME}/workspace"
mkdir -p "${PICOCLAW_HOME}/workspace/skills"
mkdir -p "${PICOCLAW_HOME}/workspace/memory"

log() {
    local message="$(date "+%Y-%m-%d %H:%M:%S") $1"
    echo "$message"
    echo "$message" >> "${LOG_FILE}"
}

update_module_status() {
    sed -i "/^description=/c\description=PicoClaw AI助手 | $1" "${MODDIR}/module.prop"
}

get_pid() {
    [ -f "$PID_FILE" ] && cat "$PID_FILE"
}

get_web_pid() {
    [ -f "$WEB_PID_FILE" ] && cat "$WEB_PID_FILE"
}

is_running() {
    local pid=$1
    [ -n "$pid" ] && kill -0 $pid 2>/dev/null
}

# 停止所有 picoclaw 进程
kill_all() {
    log "停止所有 PicoClaw 进程..."
    pkill -f picoclaw 2>/dev/null
    rm -f "$PID_FILE" "$WEB_PID_FILE"
    sleep 2
}

# 检查并创建配置
check_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        if [ -f "${MODDIR}/config.json" ]; then
            cp "${MODDIR}/config.json" "$CONFIG_FILE"
            log "默认配置已复制到 ${CONFIG_FILE}"
        fi
    fi
}

# 启动 picoclaw
start_picoclaw() {
    if is_running $(get_pid); then
        return 0
    fi
    
    log "启动 PicoClaw..."
    cd "${PICOCLAW_DIR}"
    export PICOCLAW_HOME="${PICOCLAW_HOME}"
    
    nohup ${PICOCLAW} gateway > "${LOG_DIR}/picoclaw.log" 2>&1 &
    local new_pid=$!
    echo $new_pid > "$PID_FILE"
    log "PicoClaw 已启动 (PID: $new_pid)"
    
    sleep 3
    
    if is_running $new_pid; then
        log "PicoClaw 启动成功"
        return 0
    else
        log "PicoClaw 启动失败"
        return 1
    fi
}

# 启动 picoclaw-web
start_picoclaw_web() {
    if is_running $(get_web_pid); then
        return 0
    fi
    
    log "启动 PicoClaw Web..."
    
    nohup ${PICOCLAW_WEB} -public -port ${WEB_PORT} > "${LOG_DIR}/picoclaw-web.log" 2>&1 &
    local new_pid=$!
    echo $new_pid > "$WEB_PID_FILE"
    log "PicoClaw Web 已启动 (PID: $new_pid)"
    
    sleep 2
    
    if is_running $new_pid; then
        log "PicoClaw Web 启动成功"
        return 0
    else
        log "PicoClaw Web 启动失败"
        return 1
    fi
}

# 停止 picoclaw
stop_picoclaw() {
    local pid=$(get_pid)
    if is_running $pid; then
        log "停止 PicoClaw (PID: $pid)..."
        kill $pid 2>/dev/null
        sleep 1
    fi
    rm -f "$PID_FILE"
}

# 停止 picoclaw-web
stop_picoclaw_web() {
    local pid=$(get_web_pid)
    if is_running $pid; then
        log "停止 PicoClaw Web (PID: $pid)..."
        kill $pid 2>/dev/null
        sleep 1
    fi
    rm -f "$WEB_PID_FILE"
}

# 守护循环
log "PicoClaw 守护进程启动"
update_module_status "[状态]检查中..."

while true; do
    # 检查是否被禁用
    if ls ${MODDIR} 2>/dev/null | grep -q "disable"; then
        log "模块已被禁用"
        update_module_status "[状态]已禁用"
        kill_all
    else
        check_config
        
        # 检查 picoclaw
        if ! is_running $(get_pid); then
            log "检测到 PicoClaw 未运行，正在启动..."
            start_picoclaw
        fi
        
        # 检查 picoclaw-web
        if ! is_running $(get_web_pid); then
            log "检测到 PicoClaw Web 未运行，正在启动..."
            start_picoclaw_web
        fi
        
        # 更新状态
        if is_running $(get_pid) && is_running $(get_web_pid); then
            update_module_status "[状态]运行中 | Web: http://IP:${WEB_PORT}"
        fi
    fi
    
    sleep ${CHECK_INTERVAL}
done
