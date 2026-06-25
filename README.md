<div align="center">

# 🦐 PicoClaw Magisk

**把超轻量 AI 助手塞进你的 Android，让它开机就在。**

基于 [sipeed/picoclaw](https://github.com/sipeed/picoclaw) · Magisk 模块 · ARM64 · MIT

[![Release](https://img.shields.io/github/v/release/232252/picoclaw-magisk?style=for-the-badge&logo=github&color=blue)](https://github.com/232252/picoclaw-magisk/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/232252/picoclaw-magisk/total?style=for-the-badge&logo=download&color=brightgreen)](https://github.com/232252/picoclaw-magisk/releases)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Android-8.0%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white)](#-系统要求)
[![Arch](https://img.shields.io/badge/ARM64-AArch64-orange?style=for-the-badge&logo=arm&logoColor=white)](#-系统要求)

<a href="https://github.com/232252/picoclaw-magisk/releases/latest"><img src="https://img.shields.io/badge/⬇_Download_Module-28a745?style=for-the-badge" alt="Download"/></a>
<a href="#-快速开始"><img src="https://img.shields.io/badge/🚀_Quick_Start-1f6feb?style=for-the-badge" alt="Quick Start"/></a>
<a href="#-常见问题"><img src="https://img.shields.io/badge/❓_FAQ-6f42c1?style=for-the-badge" alt="FAQ"/></a>

</div>

---

## ✨ 这是什么？

**PicoClaw Magisk** 是把 [PicoClaw](https://github.com/sipeed/picoclaw)（矽速科技用 Go 从零写的超轻量 AI 助手）打包成 Magisk 模块，**刷一次、永久在后台**。插上手机电源就有一个本地 AI 网关，浏览器打开就能聊天，也能接飞书、QQ。

> 🦐 PicoClaw 跑在 10 美元的硬件上，内存占用 < 10MB。  
> 📦 本模块打成一个 zip，安装到 Magisk 里就完事。

### 🌟 它适合谁？

| 🎯 场景 | 💡 怎么用 |
|---------|----------|
| 🤖 **随身 AI 助理** | 后台跑着，浏览器随时调 API |
| 💬 **IM 机器人** | 接飞书/QQ 群，个人 AI 网关 |
| 🧪 **折腾玩家的玩具** | 10 美元开发板 + 这个模块 = 7×24 AI 节点 |
| 🔌 **内网服务** | 反向代理 / HomeLab 自动化调度 |
| 🛠️ **Android 命令面板** | 配合 Termux 触发设备操作 |

---

## 🎯 核心特性

<table>
<tr>
<td width="50%">

### 🤖 真正的 AI
- **多模型支持** — 兼容 OpenAI 协议的 LLM（MiniMax / OpenAI / Claude / DeepSeek…）
- **200K tokens 上下文** — 长会话不爆
- **Tool Calling** — 网页搜索、文件读写、命令执行
- **MCP 协议** — 工具可插拔扩展
- **会话记忆** — 跨 session 持久化

</td>
<td width="50%">

### 📱 Android 化
- **开机自启** — post-fs-data 阶段注入环境
- **守护进程** — 崩溃自动拉起
- **Web Dashboard** — 局域网浏览器访问 `:18800`
- **Gateway API** — OpenAI 兼容协议 `:18790`
- **零 root 滥用** — 走 Magisk 正规接口

</td>
</tr>
<tr>
<td>

### 🛡️ 稳如老狗
- **DNS 智能注入** — 8.8.8.8 + 阿里 + 114，三重备份
- **TLS 证书自动配置** — 解决 Android cacerts 问题
- **时区修正** — TZ=Asia/Shanghai，日志时间准
- **健康检查 + 重试** — 启动失败自动重试 3 次
- **日志滚动** — 10MB × 5 份自动归档

</td>
<td>

### 🔐 安全可控
- **占位符检测** — 默认配置拒绝启动，强制填真 key
- **用户配置隔离** — 你的 API key 不会进 git
- **白名单访问** — IM 渠道可限制允许的用户
- **工作区沙箱** — 默认限制在 `/sdcard/picoclaw`
- **MIT 开源** — 每一行代码都看得见

</td>
</tr>
</table>

---

## 🏗️ 架构一览

```
┌─────────────────────────────────────────────────────────────┐
│  📱 Android Device (ARM64, Magisk Root)                      │
│                                                              │
│  ┌──────────────────┐    ┌──────────────────────────────┐   │
│  │  Magisk Module   │    │   /sdcard/picoclaw/          │   │
│  │  ┌────────────┐  │    │   ├─ config.json  (用户配置)  │   │
│  │  │ service.sh │──┼───▶│   ├─ workspace/   (工作区)   │   │
│  │  │ post-fs    │  │    │   ├─ log/         (日志)     │   │
│  │  └─────┬──────┘  │    │   ├─ memory/      (记忆)     │   │
│  │        │         │    │   ├─ sessions/    (会话)     │   │
│  │  ┌─────▼──────┐  │    │   └─ .picoclaw/   (内部配置) │   │
│  │  │ picoclaw   │  │    └──────────────────────────────┘   │
│  │  │ launcher   │  │                                       │
│  │  │ (Go binary)│  │   Env: TZ=Asia/Shanghai              │
│  │  └─────┬──────┘  │        DNS=8.8.8.8,223.5.5.5,114     │
│  └────────┼─────────┘        SSL_CERT_FILE=cacerts         │
│           │                                                  │
│  ┌────────▼─────────┐   :18800  ┌──────────────────┐        │
│  │  Web Dashboard   │◀──────────│   🌐 Browser     │        │
│  └──────────────────┘           └──────────────────┘        │
│  ┌──────────────────┐   :18790  ┌──────────────────┐        │
│  │  Gateway API     │◀──────────│  💬 Feishu / QQ  │        │
│  │  (OpenAI 兼容)   │           │  🔌 Custom Client│        │
│  └──────────────────┘           └──────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 系统要求

| 项目 | 要求 |
|------|------|
| 🏗️ **架构** | ARM64 (AArch64) |
| 🤖 **系统** | Android 8.0 (API 26) 及以上 |
| 🛠️ **Root** | Magisk v20.4+ / KernelSU / APatch |
| 💾 **空间** | ~40MB（模块 + 工作目录） |
| 🧠 **内存** | 空闲 ≥ 50MB（AI 模型在云端，本地几乎不吃） |
| 🌐 **网络** | 联网访问 LLM API |

---

## 🚀 快速开始

### 方式一：Magisk Manager 安装（推荐）

<div align="center">

**下载 → 推送 → 刷入 → 重启** —— 4 步搞定

</div>

```bash
# 1. 在 Releases 下载最新 zip
#    https://github.com/232252/picoclaw-magisk/releases/latest

# 2. 推到手机
adb push picoclaw-magisk-v0.4.4.zip /sdcard/Download/

# 3. 打开 Magisk → 模块 → 从本地安装 → 选择 zip

# 4. 重启
adb reboot
```

### 方式二：ADB 一行命令

```bash
adb push picoclaw-magisk-v0.4.4.zip /sdcard/ && \
adb shell "su -c 'magisk --install-module /sdcard/picoclaw-magisk-v0.4.4.zip'" && \
adb reboot
```

### ✅ 验证安装

重启后等 30 秒，浏览器打开：

```
http://<手机IP>:18800    ← Web Dashboard
http://<手机IP>:18790    ← Gateway API (OpenAI 兼容)
```

> 💡 不知道手机 IP？进 Wi-Fi 设置看，或者 `adb shell ip addr show wlan0`

---

## ⚙️ 配置

### 1️⃣ 填入 API Key

编辑 `/sdcard/picoclaw/config.json`：

```json
{
  "agents": {
    "defaults": {
      "provider": "minimax",
      "model_name": "MiniMax-M2.7",
      "max_tokens": 200000,
      "workspace": "/sdcard/picoclaw/workspace"
    }
  },
  "model_list": [
    {
      "name": "minimax",
      "model_name": "MiniMax-M2.7",
      "model": "MiniMax-M2.7",
      "api_base": "https://api.minimaxi.com/v1",
      "api_key": "👈 填这里"
    }
  ],
  "channels": {
    "feishu": {
      "enabled": true,
      "app_id": "cli_xxx",
      "app_secret": "👈 填这里",
      "allow_from": ["user_id_1"]
    }
  }
}
```

> 🔒 完整示例见 [`config.example.json`](config.example.json)

### 2️⃣ 重启服务

```bash
sh /data/adb/modules/picoclaw/action.sh restart
```

### 3️⃣ 查看日志确认

```bash
sh /data/adb/modules/picoclaw/action.sh log
```

---

## 🎮 服务管理

```bash
sh /data/adb/modules/picoclaw/action.sh start     # 启动
sh /data/adb/modules/picoclaw/action.sh stop      # 停止
sh /data/adb/modules/picoclaw/action.sh restart   # 重启
sh /data/adb/modules/picoclaw/action.sh status    # 状态
sh /data/adb/modules/picoclaw/action.sh log       # 实时日志（最近 50 行）
```

> 💡 `action.sh` 不带参数执行 = 切换状态（运行中则停，未运行则启）

---

## 📁 目录结构

```
/sdcard/picoclaw/
├── config.json           # ⚙️  你的真实配置（含 API key）
├── .picoclaw/
│   └── config.json       # 🔧  PicoClaw 内部配置（自动同步）
├── workspace/            # 📂  AI 工作目录（默认沙箱根）
│   └── skills/           # 🧩  工具/技能扩展
├── memory/               # 🧠  长期记忆数据
├── sessions/             # 💬  会话历史
├── log/
│   └── picoclaw.log      # 📜  主日志（10MB × 5 自动滚动）
└── state/                # 📊  运行时状态
```

---

## 🔧 环境注入

模块在 `post-fs-data` 阶段就注入好环境变量，解决 Android 上跑 Go 二进制的三大坑：

| 变量 | 默认值 | 作用 |
|------|--------|------|
| `TZ` | `Asia/Shanghai` | 修日志时间 |
| `DNS1` / `DNS2` / `DNS3` | `8.8.8.8` / `223.5.5.5` / `114.114.114.114` | 解决 DNS 解析失败 |
| `SSL_CERT_FILE` | `/system/etc/security/cacerts` | 修 TLS 证书错误 |
| `HOME` | `/sdcard/picoclaw` | 让 Go 找得到用户目录 |
| `PICOCLAW_HOME` | `/sdcard/picoclaw` | 显式指定家目录 |

> 自定义：在 `service.sh` 顶部改 `export DNS1=...`，然后 `restart`

---

## ❓ 常见问题

<details>
<summary><b>Q: 浏览器打不开 :18800？</b></summary>

```bash
# 1. 检查服务状态
sh /data/adb/modules/picoclaw/action.sh status

# 2. 没在跑就启
sh /data/adb/modules/picoclaw/action.sh start

# 3. 启不起来查日志
sh /data/adb/modules/picoclaw/action.sh log
```
</details>

<details>
<summary><b>Q: TLS / x509 证书错误？</b></summary>

模块已自动配 `SSL_CERT_FILE=/system/etc/security/cacerts`。还报错：

1. 确认系统 CA 证书目录存在
2. 检查 `service.sh` 顶部环境变量
3. 重启服务
</details>

<details>
<summary><b>Q: AI 不回复 / 一直转圈？</b></summary>

1. 打开 `/sdcard/picoclaw/config.json` 检查 `api_key` / `api_base` / `model_name`
2. 默认配置含 `PLEASE_FILL_YOUR_API_KEY` 占位符，服务**会拒绝启动**直到你填入真 key
3. 看 `picoclaw.log` 里的 HTTP 错误码
</details>

<details>
<summary><b>Q: 占用空间越来越大？</b></summary>

`/sdcard/picoclaw/log` 和 `/sdcard/picoclaw/sessions` 可能膨胀。模块默认日志只保留 5 份 × 10MB。手动清理：

```bash
adb shell "rm -rf /sdcard/picoclaw/sessions/*"
```
</details>

<details>
<summary><b>Q: 怎么升级？</b></summary>

在 Magisk Manager 里：
1. 模块列表找到 PicoClaw
2. 点 **更新**（如果 GitHub release 更新了 updateJson）
3. 重启

或者手动下载新版本 zip 刷入。
</details>

<details>
<summary><b>Q: 卸载？</b></summary>

```bash
sh /data/adb/modules/picoclaw/uninstall.sh
```

或者 Magisk Manager → 模块 → 卸载 → 重启。`/sdcard/picoclaw/` 默认保留，可手动删除。
</details>

---

## 🛠️ 从源码构建

```bash
# 克隆
git clone https://github.com/232252/picoclaw-magisk.git
cd picoclaw-magisk

# 从上游拉新版本
./scripts/release.sh v0.2.7       # 使用上游 v0.2.7 重新打包
./scripts/release.sh v0.2.7 v0.5.0  # 指定新模块版本号
```

构建产物：`picoclaw-magisk-v0.X.Y.zip`

---

## 🗺️ 路线图

- [x] ✅ v0.4.x — 基础模块化、安全加固、自动化构建
- [ ] 🔜 下一版 — Web Dashboard UI 优化
- [ ] 💡 计划中 — Termux 联动、Tasker 触发器
- [ ] 💡 计划中 — 离线小模型支持（GGUF）
- [ ] 💡 计划中 — 模块化工具市场

---

## 🤝 贡献

Issues / PRs 欢迎。

```bash
1. Fork 本仓库
2. 创建 feature 分支 (git checkout -b feature/amazing-thing)
3. 提交 (git commit -m 'Add amazing thing')
4. 推送 (git push origin feature/amazing-thing)
5. 提 PR
```

---

## 📜 许可证

本项目基于 **MIT License** 开源 — 详见 [LICENSE](LICENSE)

### 🙏 致谢

| 项目 | 角色 |
|------|------|
| [sipeed/picoclaw](https://github.com/sipeed/picoclaw) | 上游核心，Go 编写的超轻量 AI 助手 |
| [Sipeed 矽速科技](https://sipeed.com) | PicoClaw 发起方 |
| [Magisk](https://github.com/topjohnwu/Magisk) | 强大的 root 方案 |
| [openp2p-magisk](https://github.com/232252/openp2p-magisk) | DNS/TZ 环境配置参考 |

---

## 📊 Star History

<div align="center">

如果这个项目对你有帮助，欢迎 ⭐ Star 支持一下！

<sub>Made with ❤️ by [@232252](https://github.com/232252)</sub>

</div>

---

<div align="center">

**🦐 PicoClaw · 10 美元硬件 + 一个 Magisk 模块 = 永远在线的私人 AI**

</div>
