# PicoClaw Magisk Module

在 Android 设备上运行的超轻量级 AI 助手，带 Web Dashboard。

## 功能特性

- 🤖 **AI 助手** - 支持多种 AI 模型 (OpenAI, Claude, DeepSeek 等)
- 🌐 **Web Dashboard** - 局域网访问，无需配置
- 📁 **工作目录** - 使用 `/sdcard/picoclaw` 作为工作目录
- 💬 **Pico 协议** - 内置 Pico 协议通道
- 🔧 **工具支持** - 文件读写、命令执行、网页搜索等

## 安装

1. 通过 Magisk Manager 安装 `picoclaw-magisk.zip`
2. 重启或执行 `/data/adb/modules/picoclaw/service.sh`

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
      "model_name": "your-model",
      "workspace": "/sdcard/picoclaw/workspace"
    }
  }
}
```

## 访问

- **Web Dashboard**: http://设备IP:12088
- **Gateway API**: http://设备IP:18790

## 局域网访问

Web Dashboard 默认绑定 `0.0.0.0`，局域网内可直接访问。

## 工作目录

智能体执行文件读写操作时使用的基础目录：`/sdcard/picoclaw/workspace`

## 端口

- Web Dashboard: `12088`
- Gateway API: `18790`

## 构建

```bash
# 编译 ARM64 版本
make build-android

# 构建 Magisk 模块
make package
```

## 项目信息

- **原始项目**: [sipeed/picoclaw](https://github.com/sipeed/picoclaw)
- **License**: MIT
