<p align="center">
  <img src="https://raw.githubusercontent.com/sipeed/picoclaw/main/assets/logo.webp" alt="PicoClaw" width="200"/>
</p>

<h1 align="center">PicoClaw Magisk Module</h1>

<p align="center">
  <a href="https://github.com/232252/picoclaw-magisk/releases/latest">
    <img src="https://img.shields.io/github/v/release/232252/picoclaw-magisk?style=flat-square" alt="Release">
  </a>
  <img src="https://img.shields.io/badge/Platform-Android%20ARM64-green?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-orange?style=flat-square" alt="License">
</p>

> 🦐 在你的 Android 设备上运行 ultra-lightweight AI 助手

---

## 📥 下载安装

### 方法一：直接下载 ZIP（推荐）

点击下载最新版本：
**[📦 picoclaw-magisk.zip](https://github.com/232252/picoclaw-magisk/releases/latest/download/picoclaw-magisk.zip)**

然后：
1. 打开 **Magisk Manager** → **模块** → **从存储安装**
2. 选择下载的 `picoclaw-magisk.zip`

### 方法二：ADB 安装

```bash
adb push picoclaw-magisk.zip /sdcard/Download/
adb shell "su -c 'cp /sdcard/Download/picoclaw-magisk.zip /data/adb/modules/'"
adb reboot
```

---

## ✨ 功能特性

| 功能 | 描述 |
|------|------|
| 🌐 Web Dashboard | 可视化配置界面 |
| 🤖 AI 模型 | OpenAI、Claude、Gemini、MiniMax 等 |
| 💬 多渠道 | 飞书、Telegram、Discord、Slack |
| 🔄 自动更新 | GitHub Actions 自动编译 |
| ⚡ 即插即用 | Magisk 模块化，一键安装 |

---

## 🔧 配置

### 1. 访问 Web Dashboard

重启后访问：
```
http://<设备IP>:12088
```

查找设备 IP：
```bash
adb shell "ip route get 1"
```

### 2. 配置 AI 模型

1. 打开 Web Dashboard
2. 进入 **模型** 页面
3. 添加 API Key

### 3. 启用消息渠道

支持：
- ✅ 飞书
- ✅ Telegram  
- ✅ Discord
- ✅ Slack

---

## 🔄 自动更新

新版本会通过 GitHub Actions 自动编译。

检查更新：
```bash
adb shell "su -c 'sh /data/adb/picoclaw/check-update.sh'"
```

---

## ❓ 常见问题

**端口被占用？**
```bash
# 查看端口
adb shell "su -c 'ss -tlnp | grep 12088'"

# 修改 service.sh 中的 WEB_PORT
```

**卸载**
```bash
adb shell "su -c 'rm -rf /data/adb/modules/picoclaw /data/adb/picoclaw'"
adb reboot
```

---

## 📚 相关链接

- [🦐 PicoClaw 官方](https://github.com/sipeed/picoclaw)
- [📖 文档](https://docs.picoclaw.io)
- [🔧 GitHub Actions](https://github.com/232252/picoclaw-magisk/actions)

---

<p align="center">
  MIT License | Made with ❤️
</p>
