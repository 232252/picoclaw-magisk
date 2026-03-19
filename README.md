# PicoClaw Magisk Module

在 Android 设备上运行的超轻量级 AI 助手，带 Web Dashboard。

## 功能特性

- 🤖 **AI 助手** - 支持多种 AI 模型 (OpenAI, Claude, DeepSeek 等)
- 🌐 **Web Dashboard** - 局域网访问，无需配置
- 📁 **工作目录** - `/sdcard/picoclaw/workspace`
- 💬 **Pico 协议** - 内置 Pico 协议通道
- 🔧 **工具支持** - 文件读写、命令执行、网页搜索等
- 🛡️ **守护进程** - 自动启动，自动恢复

## 安装

1. 通过 Magisk Manager 安装 `picoclaw-magisk.zip`
2. 重启或执行 `sh /data/adb/modules/picoclaw/action.sh start`

## 配置

编辑 `/sdcard/picoclaw/config.json`：

```json
{
  "providers": {
    "openai": {
      "api_key": "your-api-key",
      "api_base": "http://your-api-server/v1"
    }
  },
  "agents": {
    "defaults": {
      "provider": "openai",
      "model_name": "your-model-name"
    }
  }
}
```

## 管理命令

```bash
# 启动
sh /data/adb/modules/picoclaw/action.sh start

# 停止
sh /data/adb/modules/picoclaw/action.sh stop

# 重启
sh /data/adb/modules/picoclaw/action.sh restart

# 查看状态
sh /data/adb/modules/picoclaw/action.sh status

# 查看日志
sh /data/adb/modules/picoclaw/action.sh log
```

## 访问

- **Web Dashboard**: http://设备IP:12088
- **Gateway API**: http://设备IP:18790

## 端口

- Web Dashboard: `12088`
- Gateway API: `18790`

## 工作目录

智能体执行文件读写操作时使用的基础目录：`/sdcard/picoclaw/workspace`

## 日志位置

- 核心日志: `/sdcard/picoclaw/logs/picoclaw.log`
- Web日志: `/sdcard/picoclaw/logs/picoclaw-web.log`
- 守护日志: `/sdcard/picoclaw/logs/picoclaw_core.log`
- 操作日志: `/sdcard/picoclaw/logs/action.log`

## 项目信息

- **原始项目**: [sipeed/picoclaw](https://github.com/sipeed/picoclaw)
- **License**: MIT
