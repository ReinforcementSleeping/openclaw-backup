#!/bin/bash
# OpenClaw 备份初始化脚本
# 需要先安装 GitHub CLI

echo "📡 检查 GitHub CLI..."
if ! command -v gh &> /dev/null; then
    echo "❌ 未安装 GitHub CLI"
    echo "请先运行: brew install gh"
    echo "或者手动创建仓库: https://github.com/new"
    exit 1
fi

echo "🔐 尝试 GitHub 认证..."
gh auth status 2>&1

if [ $? -ne 0 ]; then
    echo "请在浏览器中完成 GitHub 登录认证"
    gh auth login
fi

# 创建仓库
echo "📦 创建私有仓库..."
gh repo create openclaw-backup --private --description "OpenClaw 自动备份" 2>/dev/null || echo "仓库可能已存在"

# 配置 remote
cd ~/.openclaw
git remote add origin git@github.com:ReinforcementSleeping/openclaw-backup.git 2>/dev/null || true

# 首次推送
echo "🚀 首次备份推送..."
git add .gitignore
git commit -m "Initial backup" 2>/dev/null || echo "无需提交"
git push -u origin main 2>&1 || git push -u origin master 2>&1

echo "✅ 完成!"
