#!/system/bin/sh
# PicoClaw Magisk Module - 安装脚本

MODPATH="${0%/*}"

ui_print "=========================================="
ui_print "  PicoClaw AI 助手模块"
ui_print "  版本: v0.2.5"
ui_print "=========================================="

ARCH=$(getprop ro.product.cpu.abi)
ui_print "  架构: $ARCH"

ui_print ""
ui_print "  安装完成!"
ui_print "  访问: http://127.0.0.1:12088"
ui_print "  工作目录: /sdcard/picoclaw"
ui_print "=========================================="
