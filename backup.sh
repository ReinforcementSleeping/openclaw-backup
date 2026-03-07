#!/bin/bash
# OpenClaw 自动备份脚本
# 每天凌晨 3:00 自动执行

BACKUP_DIR="$HOME/.openclaw"
GIT_DIR="$HOME/.openclaw-backup-git"
REPO_URL="git@github.com:ReinforcementSleeping/openclaw-backup.git"

echo "=== $(date) OpenClaw 备份开始 ==="

# 初始化 bare 仓库（如果不存在）
if [ ! -d "$GIT_DIR/.git" ]; then
    echo "初始化备份仓库..."
    mkdir -p "$GIT_DIR"
    git init --bare "$GIT_DIR"
fi

# 同步 .gitignore
cp "$BACKUP_DIR/.gitignore" "$GIT_DIR/" 2>/dev/null

# 添加所有文件（除了忽略的）
cd "$GIT_DIR"
GIT_WORK_TREE="$BACKUP_DIR" git add -A --ignore-errors 2>/dev/null

# 检查是否有更改
if GIT_WORK_TREE="$BACKUP_DIR" git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "没有需要备份的更改"
else
    # 提交更改
    GIT_AUTHOR_NAME="Lynch" GIT_AUTHOR_EMAIL="yuanlynch@gmail.com" \
    GIT_COMMITTER_NAME="Lynch" GIT_COMMITTER_EMAIL="yuanlynch@gmail.com" \
    GIT_WORK_TREE="$BACKUP_DIR" git commit -m "Backup $(date '+%Y-%m-%d %H:%M')" --allow-empty
    
    # 推送到 GitHub
    git push origin main 2>/dev/null || git push origin master 2>/dev/null
    echo "备份已推送到 GitHub"
fi

echo "=== 备份完成 ==="
