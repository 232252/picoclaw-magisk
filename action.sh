#!/system/bin/sh
# PicoClaw Magisk Module - 管理脚本
# 用于启动、停止、重启服务

MODDIR=${0%/*}

# 引入公共函数
. "$MODDIR/tool.sh"

# 主逻辑
main() {
  # 清理无效 PID
  cleanup_pidfile
  
  if is_picoclaw_running; then
    # 服务正在运行，停止它
    log_info "停止 PicoClaw 服务..."
    stop_all
    update_description stopped
    echo "服务已停止"
  else
    # 服务未运行，启动它
    log_info "启动 PicoClaw 服务..."
    start_all
    sleep 3
    if is_picoclaw_running; then
      update_description running
      echo "服务已启动"
    else
      update_description error
      echo "服务启动失败，请查看日志"
    fi
  fi
}

main
