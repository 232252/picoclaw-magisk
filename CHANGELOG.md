## v0.4.5 (2026-06-30)

- 🧹 **清理**: 移除冗余 zip（改由 GitHub Actions 自动构建发布）
- 📝 **强化 .gitignore**: 添加 zip / 运行时产物 / 敏感文件规则
- 📦 **重新打包**: 验证所有二进制 + 脚本可用性，确保兼容性
- 🔧 保留上游 picoclaw v0.2.7 + picoclaw-launcher + picoclaw-launcher-tui

# Changelog

## v0.4.4 (2026-06-21)
- 🚀 同步上游 sipeed/picoclaw v0.2.7 (含 picoclaw-launcher-tui)
- 🔒 **安全修复**: config.json 移除明文 API key,改为占位符;新增 .gitignore 排除 /sdcard/picoclaw/config.json
- 🛡️ tool.sh 添加占位符检测,启动时若检测到 PLEASE_FILL_YOUR_API_KEY 等占位符会拒绝启动
- 📦 新增 scripts/release.sh 自动化打包(支持从 .deb 提取二进制)
- 📝 提供 config.example.json 作为配置参考
- 🔧 修复 CI workflow: 上游 v0.2.9 已移除 picoclaw-launcher-tui,改用 v0.2.7 (最后一个含 tui 的版本)

## v0.4.3 (2026-03-28)
- 修复 SSL_CERT_FILE 环境变量传递
- 修复 max_tokens 过大问题
