#!/system/bin/sh
# PicoClaw Magisk Module - 管理脚本
# 用于启动、停止、重启服务

MODDIR=${0%/*}

# 引入公共函数
. "$MODDIR/tool.sh"

# 主逻辑
main() {
  local cmd="${1:-}"
  
  # 清理无效 PID
  cleanup_pidfile
  
  case "$cmd" in
    start|"")
      if is_picoclaw_running; then
        echo "PicoClaw 服务已在运行 (PID: $(get_pid))"
      else
        log_info "启动 PicoClaw 服务..."
        start_all
        sleep 3
        if is_picoclaw_running; then
          update_description running
          echo "服务已启动 (PID: $(get_pid))"
        else
          update_description error
          echo "服务启动失败，请查看日志"
        fi
      fi
      ;;
    stop)
      if is_picoclaw_running; then
        log_info "停止 PicoClaw 服务..."
        stop_all
        update_description stopped
        echo "服务已停止"
      else
        echo "服务未在运行"
      fi
      ;;
    restart)
      log_info "重启 PicoClaw 服务..."
      stop_all
      sleep 2
      start_all
      sleep 3
      if is_picoclaw_running; then
        update_description running
        echo "服务已重启 (PID: $(get_pid))"
      else
        update_description error
        echo "服务重启失败，请查看日志"
      fi
      ;;
    status)
      cleanup_pidfile
      if is_picoclaw_running; then
        echo "运行中 (PID: $(get_pid))"
      else
        echo "未运行"
      fi
      ;;
    log)
      [ -f "$LOGFILE" ] && tail -50 "$LOGFILE" || echo "日志文件不存在"
      ;;
    dns)
      echo "DNS1: $DNS1, DNS2: $DNS2, DNS3: $DNS3, TZ: $TZ"
      ;;
    *)
      echo "用法: $0 {start|stop|restart|status|log|dns}"
      echo ""
      echo "  start   - 启动服务 (默认)"
      echo "  stop    - 停止服务"
      echo "  restart - 重启服务"
      echo "  status  - 查看状态"
      echo "  log     - 查看最近日志"
      echo "  dns     - 查看 DNS 配置"
      ;;
  esac
}

main "$@"
