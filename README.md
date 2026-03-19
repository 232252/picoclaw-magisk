<p align="center">
  <img src="https://raw.githubusercontent.com/sipeed/picoclaw/main/assets/logo.webp" alt="PicoClaw" width="200"/>
</p>

<h1 align="center">PicoClaw Magisk Module</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Version-v0.2.3-blue?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/Platform-Android%20ARM64-green?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-orange?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/PicoClaw-25K%20%E2%AD%90-yellow?style=flat-square" alt="Stars">
</p>

<p align="center">
  🦐 PicoClaw Magisk 模块 — 在你的 Android 设备上运行 ultra-lightweight AI 助手
</p>

---

## ✨ 功能特性

- **🚀 超轻量级** — 仅需 <25MB 内存，<1秒启动
- **🤖 多渠道支持** — 飞书、Telegram、Discord、Slack、QQ 等
- **🌐 Web Dashboard** — 完整的可视化配置界面
- **🧠 多模型支持** — OpenAI、Claude、Gemini、MiniMax 等
- **🔧 Magisk 模块化** — 一键安装，自动启动

---

## 📦 快速开始

### 安装要求

- Android 设备 (ARM64/aarch64)
- 已 root (Magisk)
- 设备 IP 和 ADB 连接

### 安装步骤

**方法一：直接推送（推荐）**

```bash
# 连接设备
adb connect <你的设备IP>:5555

# 克隆本仓库
git clone https://github.com/YOUR_USERNAME/picoclaw-magisk.git
cd picoclaw-magisk

# 一键安装
chmod +x install.sh
./install.sh
```

**方法二：手动安装**

```bash
# 1. 推送模块到设备
adb push picoclaw /data/adb/modules/picoclaw/
adb push picoclaw-web /data/adb/modules/picoclaw/
adb push module.prop /data/adb/modules/picoclaw/
adb push service.sh /data/adb/modules/picoclaw/

# 2. 设置权限
adb shell su -c "chmod 755 /data/adb/modules/picoclaw/*"

# 3. 重启 Magisk 或手动启动
adb shell su -c "touch /data/adb/modules/picoclaw/auto_mount"
```

---

## 🔧 配置

### 1. 启动服务

重启后 PicoClaw 会自动启动，或手动启动：

```bash
adb shell su -c "PICOCLAW_HOME=/data/adb/picoclaw nohup /data/adb/modules/picoclaw/picoclaw-web -public -port 12088 > /data/adb/picoclaw/web.log 2>&1 &"
```

### 2. 访问 Web Dashboard

```
http://<设备IP>:12088
```

### 3. 配置 AI 模型

在 Web Dashboard 中：
1. 进入 **模型** 页面
2. 添加你的 API Key
3. 选择默认模型

支持的模型提供商：

| 提供商 | 状态 |
|--------|------|
| OpenAI (GPT-4) | ✅ |
| Anthropic (Claude) | ✅ |
| Google (Gemini) | ✅ |
| MiniMax | ✅ |
| 智谱 AI | ✅ |
| Kimi | ✅ |
| OpenRouter | ✅ |

### 4. 配置消息渠道

在 Web Dashboard 中：
1. 进入 **频道** 页面
2. 选择要启用的渠道
3. 填入 Bot Token / App credentials

支持的频道：

| 频道 | 状态 |
|------|------|
| 飞书 | ✅ |
| Telegram | ✅ |
| Discord | ✅ |
| Slack | ✅ |
| QQ | 🔜 |
| WhatsApp | 🔜 |

---

## 📁 目录结构

```
picoclaw-magisk/
├── module.prop          # 模块信息
├── service.sh          # 自动启动脚本
├── picoclaw            # 主程序 (ARM64)
├── picoclaw-web        # Web Dashboard (ARM64)
├── scripts/
│   └── install.sh      # 安装脚本
└── README.md
```

---

## 🔄 更新日志

### v0.2.3 (2026-03-19)
- ✨ 初始版本
- 🦐 PicoClaw v0.2.3
- 🌐 Web Dashboard 集成
- 📱 Magisk 模块化

---

## ❓ 常见问题

**Q: 端口被占用怎么办？**
```bash
# 查看占用端口的进程
adb shell su -c "ss -tlnp | grep <端口>"

# 修改 service.sh 中的 WEB_PORT
```

**Q: 如何查看日志？**
```bash
adb shell su -c "cat /data/adb/picoclaw/web.log"
adb shell su -c "cat /data/adb/picoclaw/picoclaw.log"
```

**Q: 如何卸载？**
```bash
adb shell su -c "rm -rf /data/adb/modules/picoclaw"
adb shell su -c "rm -rf /data/adb/picoclaw"
```

---

## 📚 相关链接

- 🦐 [PicoClaw 官方仓库](https://github.com/sipeed/picoclaw)
- 📖 [PicoClaw 文档](https://docs.picoclaw.io)
- 🌐 [PicoClaw 官网](https://picoclaw.io)

---

## 📄 License

MIT License - 详见 [LICENSE](LICENSE) 文件

---

<p align="center">
  Made with ❤️ for the PicoClaw community
</p>
