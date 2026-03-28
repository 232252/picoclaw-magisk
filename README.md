# PicoClaw Magisk Module

<div align="center">

**PicoClaw Magisk 模块** - 在 Android 设备上运行的超轻量级 AI 助手

基于 [sipeed/picoclaw](https://github.com/sipeed/picoclaw) | 支持 ARM64

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Go Version](https://img.shields.io/badge/Go-1.25+-00ADD8?style=flat&logo=go)](https://golang.org)

</div>

---

## 📖 项目说明

本项目是 **[PicoClaw](https://github.com/sipeed/picoclaw)** 的 Magisk 模块移植版本。

### 什么是 PicoClaw？

**PicoClaw** 是由 [矽速科技 (Sipeed)](https://sipeed.com) 发起的开源项目，使用 **Go 语言**从零编写——不是 OpenClaw、NanoBot 或其他项目的分支。

> 🦐 **PicoClaw** 是一个超轻量级个人 AI 助手。它可在 **10 美元** 的硬件上运行，内存占用 **<10MB**。

### 本模块做了什么？

- ✅ 将 PicoClaw 二进制适配为 Magisk 模块格式
- ✅ 添加 DNS/时区/TLS 环境变量配置，解决 Android 环境兼容问题
- ✅ 配置自动启动守护进程
- ✅ 提供 Web Dashboard 访问界面

---

## ✨ 功能特性

| 功能 | 说明 |
|------|------|
| 🤖 **AI 助手** | 支持 MiniMax、OpenAI、Claude、DeepSeek 等多种 LLM 模型 |
| 🌐 **Web Dashboard** | 浏览器访问 AI 助手界面，无需命令行 |
| 💬 **多渠道支持** | Pico 协议、飞书、QQ 等即时通讯渠道 |
| 🔍 **网页搜索** | 内置 DuckDuckGo 搜索工具 |
| 📁 **文件操作** | 支持文件读写、命令执行等工具 |
| 🧠 **记忆系统** | 会话记忆和上下文管理 |
| 🔌 **MCP 协议** | 支持 Model Context Protocol 扩展 |
| 🛡️ **守护进程** | 自动启动、自动恢复 |

---

## 📋 系统要求

- **设备**: ARM64 架构 (AArch64)
- **系统**: Android 8.0+
- **Magisk**: v20.4+ (或 KernelSU 等兼容模块系统)
- **存储**: ~40MB 空间

---

## 🚀 安装

### 方式一：Magisk Manager 安装（推荐）

1. 下载 `picoclaw-magisk-v0.4.3.zip`
2. 在 Magisk Manager 中从本地选择安装
3. 重启设备

### 方式二：ADB 安装

```bash
adb push picoclaw-magisk-v0.4.3.zip /sdcard/
adb shell "su -c 'magisk --install-module /sdcard/picoclaw-magisk-v0.4.3.zip'"
adb shell "su -c 'reboot'"
```

---

## 🛠️ 管理命令

```bash
# 启动服务
sh /data/adb/modules/picoclaw/action.sh start

# 停止服务
sh /data/adb/modules/picoclaw/action.sh stop

# 重启服务
sh /data/adb/modules/picoclaw/action.sh restart

# 查看状态
sh /data/adb/modules/picoclaw/action.sh status

# 查看日志
sh /data/adb/modules/picoclaw/action.sh log
```

---

## 🌐 访问地址

| 服务 | 地址 |
|------|------|
| **Web Dashboard** | http://设备IP:18800 |
| **Gateway API** | http://设备IP:18790 |

---

## 📁 目录结构

```
/sdcard/picoclaw/
├── config.json          # 主配置文件
├── .picoclaw/
│   └── config.json      # PicoClaw 内部配置
├── workspace/           # 工作目录
├── log/                 # 日志目录
│   └── picoclaw.log     # 主日志
├── memory/              # 记忆数据
├── sessions/            # 会话数据
└── state/               # 状态数据
```

---

## ⚙️ 配置

编辑 `/sdcard/picoclaw/config.json`：

```json
{
  "agents": {
    "defaults": {
      "provider": "minimax",
      "model_name": "MiniMax-M2.7",
      "max_tokens": 16384,
      "workspace": "/sdcard/picoclaw/workspace"
    }
  },
  "model_list": [
    {
      "model_name": "你的模型名",
      "model": "模型名",
      "api_base": "https://api.minimaxi.com/v1",
      "api_key": "your-api-key"
    }
  ]
}
```

---

## 🔧 环境配置

本模块自动配置以下环境变量：

| 变量 | 值 | 说明 |
|------|-----|------|
| `TZ` | `Asia/Shanghai` | 时区 |
| `DNS1` | `8.8.8.8` | Google DNS |
| `DNS2` | `223.5.5.5` | 阿里 DNS |
| `SSL_CERT_FILE` | `/system/etc/security/cacerts` | TLS 证书 |

---

## ❓ 常见问题

### Q: TLS/x509 证书错误
A: 已自动配置 SSL_CERT_FILE，如仍有问题请检查系统 CA 证书目录。

### Q: Web UI 无法访问
A: 检查服务状态：`sh /data/adb/modules/picoclaw/action.sh status`

### Q: AI 不回复
A: 检查 config.json 中的 api_key 和 model 配置是否正确。

---

## 📜 卸载

```bash
sh /data/adb/modules/picoclaw/uninstall.sh
# 或在 Magisk Manager 中禁用/删除模块后重启
```

---

## 🔗 相关链接

| 链接 | 说明 |
|------|------|
| [PicoClaw 官网](https://picoclaw.io) | 官方项目网站 |
| [PicoClaw 文档](https://docs.picoclaw.io) | 官方文档 |
| [sipeed/picoclaw](https://github.com/sipeed/picoclaw) | 官方源码仓库 |
| [Sipeed 矽速科技](https://sipeed.com) | 发起公司 |

---

## 📄 License

本 Magisk 模块基于 MIT License开源。

- **PicoClaw**: [MIT License](https://github.com/sipeed/picoclaw/blob/main/LICENSE)
- **本模块**: [MIT License](LICENSE)

---

**版本**: v0.4.3 | **基于**: sipeed/picoclaw v0.2.3 | **构建**: Go 1.25.7
