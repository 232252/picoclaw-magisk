#!/data/adb/magisk/busybox sh
# PicoClaw Magisk Module - 服务脚本
# 在系统启动后执行，启动守护进程

MODDIR=${0%/*}
PICOCLAW_HOME="/sdcard/picoclaw"
LOG_DIR="${PICOCLAW_HOME}/logs"
LOG_FILE="${LOG_DIR}/service.log"

mkdir -p "${LOG_DIR}"
chmod 755 ${MODDIR}/*

# 日志函数
log() {
    local message="$(date "+%Y-%m-%d %H:%M:%S") $1"
    echo "$message"
    echo "$message" >> "${LOG_FILE}"
}

# 等待系统启动完成
log "开始启动 PicoClaw 服务，等待系统启动完成..."
echo "开始启动 PicoClaw 服务..."

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 5s
done

log "系统启动完成"

# 创建工作目录
mkdir -p "${PICOCLAW_HOME}/workspace"
mkdir -p "${PICOCLAW_HOME}/workspace/skills"
mkdir -p "${PICOCLAW_HOME}/workspace/memory"
mkdir -p "${PICOCLAW_HOME}/logs"

# 获取唤醒锁防止系统休眠
echo "获取唤醒锁"
log "获取唤醒锁"
echo "PowerManagerService.noSuspend" > /sys/power/wake_lock

# 更新模块状态
sed -i 's/^description=.*/description=PicoClaw AI助手 | [状态]启动中.../' "$MODDIR/module.prop"
log "模块状态已更新为启动中"

# 等待网络就绪
log "等待网络就绪..."
sleep 10s
log "网络就绪"

# 启动核心守护进程
log "启动 PicoClaw 守护进程..."
echo "启动 PicoClaw 守护进程..."
"${MODDIR}/picoclaw_core.sh" &

# 释放唤醒锁
sleep 2
echo "释放唤醒锁"
log "释放唤醒锁"
echo "PowerManagerService.noSuspend" > /sys/power/wake_unlock

log "PicoClaw 服务启动完成"
echo "PicoClaw 服务启动完成"
