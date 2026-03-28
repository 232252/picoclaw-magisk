# PicoClaw Magisk Module

在 Android 设备上运行的超轻量级 AI 助手，带 Web Dashboard。

## 功能特性

- 🤖 **AI 助手** - 支持 MiniMax、OpenAI、Claude、DeepSeek 等多种模型
- 🌐 **Web Dashboard** - 局域网访问，无需配置
- 💬 **多渠道支持** - Pico 协议、飞书、QQ 等
- 🔧 **工具支持** - 文件读写、命令执行、网页搜索等
- 🛡️ **守护进程** - 自动启动，自动恢复
- 🌍 **DNS/时区适配** - 自动配置 8.8.8.8 DNS 和 Asia/Shanghai 时区

## 安装

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

## 启动

重启后服务会自动启动。也可手动控制：

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

## 访问

- **Web Dashboard**: http://设备IP:18800
- **Gateway API**: http://设备IP:18790

## 端口说明

| 服务 | 端口 | 说明 |
|------|------|------|
| Web Dashboard | 18800 | 浏览器访问的网页界面 |
| Gateway API | 18790 | pico/ws 协议端口 |

## 目录结构

```
/sdcard/picoclaw/
├── config.json          # 主配置文件
├── .picoclaw/
│   └── config.json      # picoclaw 内部配置
├── workspace/          # 工作目录（AI 执行文件操作的基础目录）
├── log/                # 日志目录
│   └── picoclaw.log    # 主日志
├── memory/             # 记忆数据
├── sessions/           # 会话数据
└── state/              # 状态数据
```

## 配置

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
  ],
  "channels": {
    "pico": {
      "enabled": true,
      "token": "your-pico-token"
    }
  }
}
```

## 模型配置示例

### MiniMax

```json
{
  "model_name": "MiniMax-M2.7",
  "model": "MiniMax-M2.7",
  "api_base": "https://api.minimaxi.com/v1",
  "api_key": "your-minimax-api-key"
}
```

### OpenAI 兼容

```json
{
  "model_name": "gpt-4o",
  "model": "gpt-4o",
  "api_base": "https://api.openai.com/v1",
  "api_key": "sk-your-openai-key"
}
```

## 日志查看

```bash
# 实时查看日志
tail -f /sdcard/picoclaw/log/picoclaw.log

# 查看最近 100 行
tail -100 /sdcard/picoclaw/log/picoclaw.log

# 清空日志
> /sdcard/picoclaw/log/picoclaw.log
```

## 常见问题

### Q: TLS/x509 证书错误
A: 确保 SSL_CERT_FILE 环境变量设置为 `/system/etc/security/cacerts`

### Q: Web UI 无法访问
A: 检查 18800 端口是否监听：`adb shell "netstat -tlnp | grep 18800"`

### Q: AI 不回复
A: 检查 config.json 中的 api_key 是否正确配置

## 卸载

```bash
sh /data/adb/modules/picoclaw/uninstall.sh
# 或在 Magisk Manager 中禁用/删除模块
```

## 项目信息

- **原始项目**: [sipeed/picoclaw](https://github.com/sipeed/picoclaw)
- **License**: MIT
- **版本**: v0.4.3
