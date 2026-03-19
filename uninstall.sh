#!/system/bin/sh
# PicoClaw Magisk Module - 卸载脚本

MODDIR=${0%/*}

# 停止服务
if [ -f "$MODDIR/tool.sh" ]; then
  . "$MODDIR/tool.sh"
  stop_all 2>/dev/null
fi

# 清理 PID 文件
rm -f "$MODDIR/picoclaw.pid"
rm -f "$MODDIR/picoclaw-web.pid"

# 注意：保留用户数据目录 /sdcard/picoclaw
# 如需删除，取消下行注释
# rm -rf /sdcard/picoclaw
