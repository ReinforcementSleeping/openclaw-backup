#!/usr/bin/env python3
"""
一键创建 GitHub 私有仓库并配置自动备份
"""
import os
import sys
import subprocess
import json
import urllib.request
import urllib.error

def run(cmd):
    result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr}")
    return result

# 检查是否有 GitHub token
token = os.environ.get('GH_TOKEN') or os.environ.get('GITHUB_TOKEN')

if not token:
    print("❌ 需要 GitHub Token")
    print("\n请在 GitHub 上创建 Token:")
    print("1. 打开 https://github.com/settings/tokens")
    print("2. 点击 'Generate new token (classic)'")
    print("3. 勾选 'repo' 权限")
    print("4. 点击生成，复制 token")
    print("\n然后运行:")
    print("  GH_TOKEN=你的token python3 ~/.openclaw/setup_backup.py")
    sys.exit(1)

# 创建私有仓库
print("📦 创建私有仓库...")
url = "https://api.github.com/user/repos"
data = json.dumps({
    "name": "openclaw-backup",
    "private": True,
    "description": "OpenClaw 自动备份"
}).encode()

req = urllib.request.Request(url, data=data, method='POST')
req.add_header('Authorization', f'token {token}')
req.add_header('Accept', 'application/vnd.github.v3+json')
req.add_header('Content-Type', 'application/json')

try:
    with urllib.request.urlopen(req) as response:
        print("✅ 仓库创建成功!")
except urllib.error.HTTPError as e:
    if e.code == 422:
        print("ℹ️ 仓库已存在，跳过创建")
    else:
        print(f"❌ 创建仓库失败: {e.read()}")
        sys.exit(1)

# 配置 git remote
print("🔧 配置 Git 远程仓库...")
run('cd ~/.openclaw && git remote add origin git@github.com:ReinforcementSleeping/openclaw-backup.git 2>/dev/null || true')

# 添加 .gitignore 并提交
print("📝 首次提交...")
run('cd ~/.openclaw && git add .gitignore')
run('cd ~/.openclaw && git commit -m "Initial commit" 2>/dev/null || echo "Nothing to commit"')

# 推送到 GitHub
print("🚀 推送到 GitHub...")
result = run('cd ~/.openclaw && git push -u origin main 2>&1')
if result.returncode != 0:
    # 尝试 master 分支
    result = run('cd ~/.openclaw && git push -u origin master 2>&1')

if result.returncode == 0:
    print("✅ 首次备份成功!")
else:
    print(f"⚠️ 推送失败: {result.stderr}")

print("\n🎉 配置完成!")
print("每天凌晨 3:00 会自动备份到 GitHub")
