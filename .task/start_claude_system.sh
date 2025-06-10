#!/bin/bash

# Claude tmux自動実行システム 一括起動スクリプト
# 使用方法: ./start_claude_system.sh

echo "🚀 Claude tmux自動実行システムを起動します..."
echo "============================================="

# 1. 前提条件チェック
echo "📋 前提条件をチェック中..."

# tmuxの確認
if ! command -v tmux &> /dev/null; then
    echo "❌ エラー: tmux がインストールされていません"
    exit 1
fi

# claudeの確認
if ! command -v claude &> /dev/null; then
    echo "❌ エラー: claude CLI がインストールされていません"
    exit 1
fi

echo "✅ 前提条件OK"

# 2. タスク管理システムの確認
echo "📁 タスク管理システムをチェック中..."

if [ ! -d ".task" ]; then
    echo "❌ エラー: .taskディレクトリが見つかりません"
    echo "   ./.task/status_check.sh を実行して初期化してください"
    exit 1
fi

echo "✅ タスク管理システムOK"

# 3. 現在のウィンドウでPaneを作成
echo "📺 現在のウィンドウでPaneを準備中..."

# 現在のPane数を確認
CURRENT_PANES=$(tmux list-panes | wc -l | tr -d ' ')
echo "   現在のPane数: $CURRENT_PANES"

if [ "$CURRENT_PANES" -lt 6 ]; then
    echo "🔧 6個のPaneに分割中..."
    
    if [ "$CURRENT_PANES" -eq 1 ]; then
        # 1個から6個に分割
        tmux split-window -h
        tmux split-window -v
        tmux select-pane -t 0
        tmux split-window -v
        tmux select-pane -t 2
        tmux split-window -v
        tmux select-pane -t 4
        tmux split-window -v
    else
        echo "   既存のPane構成をそのまま使用します"
    fi
else
    echo "✅ 十分なPane数があります"
fi

# 4. 現在のPane IDを取得
echo "🔍 Pane IDを確認中..."
PANE_IDS=($(tmux list-panes -F "#{pane_id}"))

if [ ${#PANE_IDS[@]} -lt 6 ]; then
    echo "❌ エラー: 必要なPane数（6個）が不足しています"
    echo "   現在のPane数: ${#PANE_IDS[@]}"
    exit 1
fi

echo "✅ Pane構成:"
for i in "${!PANE_IDS[@]}"; do
    case $i in
        0) role="親Pane (プロジェクト司令塔)" ;;
        1) role="開発Pane (コード実装)" ;;
        2) role="レビューPane (コードレビュー)" ;;
        3) role="テストPane (品質保証)" ;;
        4) role="ドキュメントPane (ドキュメント管理)" ;;
        5) role="デプロイPane (運用・デプロイ)" ;;
    esac
    echo "   ${PANE_IDS[$i]}: $role"
done

# 5. 各PaneでClaude CLIを起動
echo "🤖 各PaneでClaude CLIを起動中..."

for i in "${!PANE_IDS[@]}"; do
    pane_id="${PANE_IDS[$i]}"
    case $i in
        0) role="親Pane" ;;
        1) role="開発Pane" ;;
        2) role="レビューPane" ;;
        3) role="テストPane" ;;
        4) role="ドキュメントPane" ;;
        5) role="デプロイPane" ;;
    esac
    
    echo "   🚀 $role ($pane_id) を起動中..."
    tmux send-keys -t "$pane_id" "claude --dangerously-skip-permissions" Enter
    sleep 3  # Claude起動を待つ
done

# 6. 各PaneにCLAUDE.mdを読み込ませて役割を設定
echo "📖 各Paneに役割を設定中..."

sleep 5  # Claude完全起動を待つ

# 親Pane設定
tmux send-keys -t "${PANE_IDS[0]}" "CLAUDE.mdファイルを読み込んで、あなたは親Pane (${PANE_IDS[0]}) として動作してください。プロジェクト司令塔として全体を管理し、各子Paneからの報告を受けて適切なタスク割り当てを行ってください。" Enter

sleep 2

# 開発Pane設定
tmux send-keys -t "${PANE_IDS[1]}" "CLAUDE.mdファイルを読み込んで、あなたは開発Pane (${PANE_IDS[1]}) として動作してください。コード実装を担当し、完了後は必ず親Pane (${PANE_IDS[0]}) に報告してください。" Enter

sleep 2

# レビューPane設定
tmux send-keys -t "${PANE_IDS[2]}" "CLAUDE.mdファイルを読み込んで、あなたはレビューPane (${PANE_IDS[2]}) として動作してください。コードレビューを担当し、完了後は必ず親Pane (${PANE_IDS[0]}) に報告してください。" Enter

sleep 2

# テストPane設定
tmux send-keys -t "${PANE_IDS[3]}" "CLAUDE.mdファイルを読み込んで、あなたはテストPane (${PANE_IDS[3]}) として動作してください。品質保証を担当し、完了後は必ず親Pane (${PANE_IDS[0]}) に報告してください。" Enter

sleep 2

# ドキュメントPane設定
tmux send-keys -t "${PANE_IDS[4]}" "CLAUDE.mdファイルを読み込んで、あなたはドキュメントPane (${PANE_IDS[4]}) として動作してください。ドキュメント管理を担当し、完了後は必ず親Pane (${PANE_IDS[0]}) に報告してください。" Enter

sleep 2

# デプロイPane設定
tmux send-keys -t "${PANE_IDS[5]}" "CLAUDE.mdファイルを読み込んで、あなたはデプロイPane (${PANE_IDS[5]}) として動作してください。運用・デプロイを担当し、完了後は必ず親Pane (${PANE_IDS[0]}) に報告してください。" Enter

# 7. Pane状態ファイルを実際のIDで更新
echo "📝 Pane状態ファイルを更新中..."

mkdir -p .task/panes
for i in "${!PANE_IDS[@]}"; do
    if [ $i -gt 0 ]; then  # 親Pane以外
        echo "idle" > ".task/panes/${PANE_IDS[$i]}_status"
    fi
done

# current_assignmentsファイルも初期化
> .task/panes/current_assignments

# システムログに記録
echo "$(date): システム起動完了。Pane IDs: ${PANE_IDS[*]}" >> .task/system.log

# 7.5. 親PaneにCLAUDE.mdの更新を指示
echo "📝 親PaneにCLAUDE.mdの更新を指示中..."
sleep 3

# Pane ID一覧を作成
PANE_INFO="
0: ${PANE_IDS[0]} volta-shim 1    # 親Pane - プロジェクト司令塔
1: ${PANE_IDS[1]} fish 0          # 開発Pane - コード実装担当
2: ${PANE_IDS[2]} fish 0          # レビューPane - コードレビュー担当
3: ${PANE_IDS[3]} fish 0          # テストPane - 品質保証担当
4: ${PANE_IDS[4]} fish 0          # ドキュメントPane - ドキュメント管理担当
5: ${PANE_IDS[5]} fish 0          # デプロイPane - 運用・デプロイ担当
"

# 親Paneに更新指示を送信
tmux send-keys -t "${PANE_IDS[0]}" "CLAUDE.mdファイルの「## tmux pane information」セクションを以下の内容で更新してください：

Result of \\\`tmux list-panes -F \\\"#{pane_index}: #{pane_id} #{pane_current_command} #{pane_active}\\\"\\\`:

\\\`\\\`\\\`
$PANE_INFO
\\\`\\\`\\\`

その後、更新したCLAUDE.mdを読み込み直して、更新されたPane IDで各Paneとの通信を行ってください。" Enter

# 8. 完了メッセージ
echo ""
echo "🎉 Claude tmux自動実行システムの起動が完了しました！"
echo "============================================="
echo ""
echo "📋 Pane情報:"
echo "   親Pane ID: ${PANE_IDS[0]}"
echo "   開発Pane ID: ${PANE_IDS[1]}"
echo "   レビューPane ID: ${PANE_IDS[2]}"
echo "   テストPane ID: ${PANE_IDS[3]}"
echo "   ドキュメントPane ID: ${PANE_IDS[4]}"
echo "   デプロイPane ID: ${PANE_IDS[5]}"
echo ""
echo "🔧 次のステップ:"
echo "   1. システム状況確認: ./.task/status_check.sh"
echo "   2. 新しいタスク作成: ./.task/create_task.sh task-XXX \"説明\""
echo ""
echo "📚 詳細な使用方法は README_CLAUDE.md を参照してください"
echo ""
echo "�� 準備完了！開発を開始できます！" 