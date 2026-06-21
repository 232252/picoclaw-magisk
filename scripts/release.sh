#!/usr/bin/env bash
# PicoClaw Magisk Module 一键发布脚本
# 用法: ./scripts/release.sh v0.2.7
# 作用:
#   1. 从上游 sipeed/picoclaw 下载指定版本的 Linux arm64 tarball
#   2. 替换仓库内的 picoclaw / picoclaw-launcher / picoclaw-launcher-tui
#   3. 更新 module.prop / updateJson.json / CHANGELOG.md
#   4. 重新打 zip 包
#   5. 清理仓库中可能含敏感信息的 config.json (改用 config.example.json)

set -euo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
    echo "用法: $0 <upstream-version, e.g. v0.2.7>"
    echo "  注意: v0.2.9 之后的版本已移除 picoclaw-launcher-tui,本脚本仅支持 v0.2.7 及之前"
    exit 1
fi

VERSION_NUM="${VERSION#v}"
# 模块版本号(递增): 如果当前是 v0.4.3,下一个 v0.4.4
MODULE_VERSION="${2:-}"
if [ -z "$MODULE_VERSION" ]; then
    # 自动递增 patch 号
    CURRENT_VERSION=$(grep -oE 'version=v[0-9.]+' module.prop | head -1 | cut -d= -f2)
    if [ -n "$CURRENT_VERSION" ]; then
        IFS='.' read -r MAJOR MINOR PATCH <<< "${CURRENT_VERSION#v}"
        PATCH=$((PATCH + 1))
        MODULE_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
    else
        MODULE_VERSION="v0.5.0"
    fi
fi
MODULE_VERSION_CODE=$(echo "${MODULE_VERSION#v}" | awk -F. '{print $1*10000+$2*100+$3}')

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# 镜像源
UPSTREAM_URL_PRIMARY="https://github.com/sipeed/picoclaw/releases/download/${VERSION}/picoclaw_Linux_arm64.tar.gz"
UPSTREAM_URL_MIRROR="https://gh-proxy.com/https://github.com/sipeed/picoclaw/releases/download/${VERSION}/picoclaw_Linux_arm64.tar.gz"

echo "==> 下载上游 ${VERSION} ..."
TARBALL="$TMPDIR/picoclaw.tar.gz"
if curl -sSLf --max-time 120 -o "$TARBALL" "$UPSTREAM_URL_PRIMARY"; then
    echo "    从 GitHub 直连下载成功"
elif curl -sSLf --max-time 180 -o "$TARBALL" "$UPSTREAM_URL_MIRROR"; then
    echo "    通过 gh-proxy 镜像下载成功"
else
    echo "    错误: 下载失败, 请检查版本号是否支持 (v0.2.9+ 已移除 tui)" >&2
    exit 1
fi

echo "==> 解压 ..."
tar -xzf "$TARBALL" -C "$TMPDIR"

REQUIRED_FILES=("picoclaw" "picoclaw-launcher")
# v0.2.9+ 没有 tui,只在有 tui 的版本才强制要求
if [ -f "$TMPDIR/picoclaw-launcher-tui" ]; then
    REQUIRED_FILES+=("picoclaw-launcher-tui")
fi

for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$TMPDIR/$f" ]; then
        echo "    错误: 解压后未找到 $f" >&2
        exit 1
    fi
done

echo "==> 替换二进制 ..."
chmod +x "$TMPDIR"/picoclaw*
cp "$TMPDIR"/picoclaw* "$REPO_ROOT/"

echo "==> 更新 module.prop ..."
sed -i "s|^version=.*|version=${MODULE_VERSION}|" "$REPO_ROOT/module.prop"
sed -i "s|^versionCode=.*|versionCode=${MODULE_VERSION_CODE}|" "$REPO_ROOT/module.prop"
# 用 # 作为分隔符避免 description 里的 | 与 sed 冲突
sed -i "s#^description=.*#description=PicoClaw AI助手 ${MODULE_VERSION} | 上游 ${VERSION} | TZ: Asia/Shanghai | DNS: 8.8.8.8 | SSL: cacerts | Web: http://IP:18800#" "$REPO_ROOT/module.prop"

echo "==> 更新 updateJson.json ..."
cat > "$REPO_ROOT/updateJson.json" <<EOF
{
  "version": "${MODULE_VERSION}",
  "versionCode": ${MODULE_VERSION_CODE},
  "zipUrl": "https://github.com/232252/picoclaw-magisk/releases/download/${MODULE_VERSION}/picoclaw-magisk-${MODULE_VERSION}.zip",
  "changelog": "${MODULE_VERSION}: 同步上游 picoclaw ${VERSION}",
  "size": $(stat -c%s "$REPO_ROOT/picoclaw" 2>/dev/null || stat -f%z "$REPO_ROOT/picoclaw"),
  "date": "$(date +%Y-%m-%d)"
}
EOF

echo "==> 重新打包 ..."
OUTPUT="$REPO_ROOT/picoclaw-magisk-${MODULE_VERSION}.zip"
rm -f "$REPO_ROOT"/picoclaw-magisk-v*.zip
cd "$REPO_ROOT"
zip -r "$OUTPUT" \
    picoclaw \
    picoclaw-launcher \
    picoclaw-launcher-tui \
    picoclaw-wrapper.sh \
    service.sh \
    post-fs-data.sh \
    customize.sh \
    action.sh \
    tool.sh \
    uninstall.sh \
    module.prop \
    updateJson.json \
    config.json \
    config.example.json \
    CHANGELOG.md \
    LICENSE \
    README.md \
    .gitignore \
    -x "*.git*" "picoclaw-magisk-v*.zip" "scripts/*" "*.bak" ".bak-old/*"

echo ""
echo "==> 完毕!"
echo "    二进制: $REPO_ROOT/picoclaw*"
echo "    打包:   $OUTPUT"
echo "    模块版本: ${MODULE_VERSION} (versionCode ${MODULE_VERSION_CODE})"
echo "    上游版本: ${VERSION}"
echo ""
echo "⚠️  安全提醒:"
echo "    1. 请确认 config.json 不含真实 API key (应用占位符 PLEASE_FILL_YOUR_API_KEY)"
echo "    2. 用户的 /sdcard/picoclaw/config.json 不应在 git 中"
echo ""
echo "下一步:"
echo "    git add -A && git commit -m \"release: ${MODULE_VERSION} (upstream ${VERSION})\""
echo "    git tag ${MODULE_VERSION} && git push --tags"
