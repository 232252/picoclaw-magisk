#!/system/bin/sh
# PicoClaw Magisk Module - 安装脚本
#
# 版本: v0.4.0
# 更新内容:
#   - 添加 DNS 配置支持 (解决网络解析问题)
#   - 添加时区配置 (解决日志时间问题)
#   - 参考 openp2p-magisk 的环境配置方案

MODPATH="${0%/*}"

ui_print "=========================================="
ui_print "  PicoClaw AI 助手模块"
ui_print "  版本: v0.4.3 (配置 Schema v3)"
ui_print "=========================================="

ARCH=$(getprop ro.product.cpu.abi)
ui_print "  架构: $ARCH"

ui_print ""
ui_print "  配置文件:"
ui_print "    /sdcard/picoclaw/config.json"
ui_print "  Gateway: http://127.0.0.1:18790"
ui_print "  Web UI: http://127.0.0.1:18800"
ui_print "  工作目录: /sdcard/picoclaw/workspace"
ui_print ""
ui_print "  安装完成后，请编辑 config.json 设置 API Key"
ui_print "=========================================="
