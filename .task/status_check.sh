#!/bin/bash

# システム全体の状況を確認するスクリプト

echo "🚀 タスク管理システム状況確認"
echo "=================================="
echo

# Paneの状況確認
echo "📱 Pane状況:"
echo "----------"
for pane in %31 %32 %33 %34 %35; do
    status_file=".task/panes/${pane}_status"
    if [ -f "$status_file" ]; then
        status=$(cat "$status_file")
        # 現在の割り当てを確認
        assignment=$(jq -r ".\"$pane\" // \"none\"" .task/panes/current_assignments 2>/dev/null || echo "none")
        
        # Paneの役割を表示
        case "$pane" in
            "%31") role="開発" ;;
            "%32") role="レビュー" ;;
            "%33") role="テスト" ;;
            "%34") role="ドキュメント" ;;
            "%35") role="デプロイ" ;;
        esac
        
        echo "$pane ($role): $status ($assignment)"
    else
        echo "$pane: ファイルなし"
    fi
done

echo
echo "📋 タスク状況:"
echo "----------"

# 全タスクの状況を表示
if [ -d ".task" ]; then
    for task_dir in .task/task-*; do
        if [ -d "$task_dir" ]; then
            task=$(basename "$task_dir")
            description=$(cat "$task_dir/description" 2>/dev/null || echo "説明なし")
            current_phase=$(cat "$task_dir/current_phase" 2>/dev/null || echo "unknown")
            overall_status=$(cat "$task_dir/overall_status" 2>/dev/null || echo "unknown")
            
            echo "📝 $task: $description"
            echo "   現在フェーズ: $current_phase"
            echo "   全体ステータス: $overall_status"
            
            # 各フェーズの状況
            echo "   フェーズ詳細:"
            for phase in development review testing documentation deployment; do
                phase_status=$(cat "$task_dir/phases/$phase" 2>/dev/null || echo "unknown")
                case "$phase_status" in
                    "pending") icon="⏳" ;;
                    "running") icon="🔄" ;;
                    "completed") icon="✅" ;;
                    "skipped") icon="⏭️" ;;
                    *) icon="❓" ;;
                esac
                echo "     $icon $phase: $phase_status"
            done
            echo
        fi
    done
else
    echo "タスクディレクトリが見つかりません"
fi

echo "📊 システム統計:"
echo "----------"
total_tasks=$(find .task -maxdepth 1 -name "task-*" -type d | wc -l)
pending_tasks=$(find .task -name "overall_status" -exec grep -l "pending" {} \; | wc -l)
in_progress_tasks=$(find .task -name "overall_status" -exec grep -l "in_progress" {} \; | wc -l)
completed_tasks=$(find .task -name "overall_status" -exec grep -l "completed" {} \; | wc -l)

echo "総タスク数: $total_tasks"
echo "未着手: $pending_tasks"
echo "進行中: $in_progress_tasks"
echo "完了: $completed_tasks"

echo
echo "📜 最新のシステムログ (最新5件):"
echo "----------"
if [ -f ".task/system.log" ]; then
    tail -5 .task/system.log
else
    echo "システムログが見つかりません"
fi 