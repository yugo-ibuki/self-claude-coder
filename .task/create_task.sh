#!/bin/bash

# 新しいタスクを作成するヘルパースクリプト
# 使用方法: ./create_task.sh task-ID "タスク説明"

if [ $# -ne 2 ]; then
    echo "使用方法: $0 <task-id> <description>"
    echo "例: $0 task-003 'API endpoint設計'"
    exit 1
fi

TASK_ID=$1
DESCRIPTION=$2
TASK_DIR=".task/$TASK_ID"

# タスクが既に存在するかチェック
if [ -d "$TASK_DIR" ]; then
    echo "エラー: タスク $TASK_ID は既に存在します"
    exit 1
fi

# タスクディレクトリとフェーズディレクトリを作成
mkdir -p "$TASK_DIR/phases"

# 基本ファイルを作成
echo "$DESCRIPTION" > "$TASK_DIR/description"
echo "development" > "$TASK_DIR/current_phase"
echo "pending" > "$TASK_DIR/overall_status"

# 各フェーズのステータスを初期化
for phase in development review testing documentation deployment; do
    echo "pending" > "$TASK_DIR/phases/$phase"
done

# ログと履歴ファイルを作成
echo "$(date): $TASK_ID ($DESCRIPTION) 作成" > "$TASK_DIR/log"
echo "{}" > "$TASK_DIR/assignee_history"

# システムログに記録
echo "$(date): 新しいタスク $TASK_ID 作成: $DESCRIPTION" >> .task/system.log

echo "✅ タスク $TASK_ID を作成しました"
echo "説明: $DESCRIPTION"
echo "現在のフェーズ: development"
echo "ステータス: pending" 