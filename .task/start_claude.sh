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

# 3. 新しいセッションで1つのウィンドウに3個のPaneを作成
echo "📺 新しいセッション 'claude-dev' で3個のPaneを作成中..."

SESSION_NAME="claude-dev"

# 既存セッションがあれば削除
tmux kill-session -t $SESSION_NAME 2>/dev/null || true

# 新しいセッションを作成（デタッチ状態で）
tmux new-session -d -s $SESSION_NAME -c $(pwd)

# セッション作成の確認
sleep 2
echo "   ✅ セッション '$SESSION_NAME' を作成しました"

# ウィンドウ名を設定
tmux rename-window -t "$SESSION_NAME:0" "Claude-開発チーム"

# 1つのウィンドウ内で3個のPaneに分割（左1個、右2個）
echo "🔧 3個のPaneに分割中..."

# ステップ1: 左右に分割（親Pane | 右側）
echo "   📌 ステップ1: 左右分割 (2個)"
tmux split-window -t "$SESSION_NAME:0" -h
STEP1_COUNT=$(tmux list-panes -t "$SESSION_NAME:0" | wc -l | tr -d ' ')
echo "     → 現在のPane数: $STEP1_COUNT個"

# レイアウト調整（左側を50%に固定）
echo "   📌 左側を50%に調整"
tmux select-pane -t "$SESSION_NAME:0.0"
tmux resize-pane -t "$SESSION_NAME:0.0" -x 50

# ステップ2: 右側（Pane1）を上下に分割（右上 | 右下）
echo "   📌 ステップ2: 右側を上下分割 (3個)"
tmux select-pane -t "$SESSION_NAME:0.1"
tmux split-window -t "$SESSION_NAME:0" -v
STEP2_COUNT=$(tmux list-panes -t "$SESSION_NAME:0" | wc -l | tr -d ' ')
echo "     → 現在のPane数: $STEP2_COUNT個"

# 分割確認
echo "   📊 分割結果確認:"
tmux list-panes -t "$SESSION_NAME:0" -F "#{pane_index}: #{pane_id}"

echo "✅ 3個のPaneを作成完了"

# 4. Pane構成の確認
echo "🔍 Pane構成を確認中..."

# Pane一覧を表示
echo "   Pane一覧:"
tmux list-panes -t "$SESSION_NAME:0" -F "#{pane_index}: #{pane_id} (#{pane_width}x#{pane_height})"

# Pane総数を確認
PANE_COUNT=$(tmux list-panes -t "$SESSION_NAME:0" | wc -l | tr -d ' ')
echo "   📊 作成されたPane数: $PANE_COUNT個"

if [ "$PANE_COUNT" -ne 3 ]; then
    echo "⚠️  警告: 期待される3個と異なります（実際: $PANE_COUNT個）"
    echo "   📋 現在のPane一覧:"
    tmux list-panes -t "$SESSION_NAME:0" -F "     #{pane_index}: #{pane_id}"
    echo "   🔄 このまま続行します..."
fi

# Pane IDを取得（実際に存在する分だけ）
ALL_PANES=($(tmux list-panes -t "$SESSION_NAME:0" -F "#{pane_id}"))
PANE_COUNT=${#ALL_PANES[@]}

echo "   📊 実際に取得されたPane数: $PANE_COUNT個"

# 各Pane IDを割り当て（3個のPaneのみ）
PANE_0=${ALL_PANES[0]:-""}
PANE_1=${ALL_PANES[1]:-""}
PANE_2=${ALL_PANES[2]:-""}

# 最低限必要なPane（親Paneと子Pane1つ）があるかチェック
if [ -z "$PANE_0" ] || [ -z "$PANE_1" ]; then
    echo "❌ エラー: 最低限のPane（親と子1個）が取得できませんでした"
    echo "   取得できたPane: $PANE_0 $PANE_1 $PANE_2"
    exit 1
fi

echo "   ✅ Pane取得成功（最低$PANE_COUNT個）"

echo "✅ 3個のPaneを確認:"
echo "   Pane 0 (親): $PANE_0 (左側・司令塔)"
echo "   Pane 1 (開発): $PANE_1 (右上・実装)" 
echo "   Pane 2 (レビュー): $PANE_2 (右下・レビュー)"

echo "✅ Pane役割:"
echo "   $PANE_0: 親Pane (プロジェクト司令塔)"
echo "   $PANE_1: 開発Pane (コード実装)"
echo "   $PANE_2: レビューPane (コードレビュー)"

# 5. 各PaneでClaude CLIを起動
echo "🤖 各PaneでClaude CLIを起動中..."

# 存在するPaneのみでClaude起動
if [ -n "$PANE_0" ]; then
    echo "   🚀 親Pane ($PANE_0) を起動中..."
    tmux send-keys -t "$PANE_0" "claude --dangerously-skip-permissions" Enter
    sleep 3
fi

if [ -n "$PANE_1" ]; then
    echo "   🚀 開発Pane ($PANE_1) を起動中..."
    tmux send-keys -t "$PANE_1" "claude --dangerously-skip-permissions" Enter
    sleep 3
fi

if [ -n "$PANE_2" ]; then
    echo "   🚀 レビューPane ($PANE_2) を起動中..."
    tmux send-keys -t "$PANE_2" "claude --dangerously-skip-permissions" Enter
    sleep 3
fi



# 6. 各PaneにCLAUDE.mdを読み込ませて役割を設定
echo "📖 各Paneに役割を設定中..."

sleep 5  # Claude完全起動を待つ

# 存在するPaneのみに役割設定
if [ -n "$PANE_0" ]; then
    echo "   📖 親Pane ($PANE_0) に役割を設定中..."
    tmux send-keys -t "$PANE_0" "CLAUDE.mdファイルを読み込んで、あなたは親Pane ($PANE_0) として動作してください。プロジェクト司令塔として全体を管理し、各子Paneからの報告を受けて適切なタスク割り当てを行ってください。" Enter
    sleep 2
fi

if [ -n "$PANE_1" ]; then
    echo "   📖 開発Pane ($PANE_1) に役割を設定中..."
    tmux send-keys -t "$PANE_1" "CLAUDE.mdファイルを読み込んで、あなたは開発Pane ($PANE_1) として動作してください。コード実装を担当し、完了後は必ず親Pane ($PANE_0) に報告してください。" Enter
    sleep 2
fi

if [ -n "$PANE_2" ]; then
    echo "   📖 レビューPane ($PANE_2) に役割を設定中..."
    tmux send-keys -t "$PANE_2" "CLAUDE.mdファイルを読み込んで、あなたはレビューPane ($PANE_2) として動作してください。コードレビューを担当し、完了後は必ず親Pane ($PANE_0) に報告してください。" Enter
    sleep 2
fi



# 7. Pane状態ファイルを実際のIDで更新
echo "📝 Pane状態ファイルを更新中..."

mkdir -p .task/panes

# 子Paneの状態ファイルを作成（親Pane以外）
if [ -n "$PANE_1" ]; then
    echo "idle" > ".task/panes/${PANE_1}_status"
fi
if [ -n "$PANE_2" ]; then
    echo "idle" > ".task/panes/${PANE_2}_status"
fi

# current_assignmentsファイルも初期化
> .task/panes/current_assignments

# システムログに記録
echo "$(date): システム起動完了。セッション: $SESSION_NAME, Pane IDs: $PANE_0 $PANE_1 $PANE_2" >> .task/system.log

# 7.5. 親PaneにCLAUDE.mdの更新を指示
echo "📝 親PaneにCLAUDE.mdの更新を指示中..."
sleep 3

# Pane ID一覧を作成
PANE_INFO="
0: $PANE_0 volta-shim 1    # 親Pane - プロジェクト司令塔（左側）
1: $PANE_1 fish 0          # 開発Pane - コード実装担当（右上）
2: $PANE_2 fish 0          # レビューPane - コードレビュー担当（右下）
"

# 親Paneに更新指示を送信
echo "   📝 親Paneに情報更新と通信機能を指示中..."
tmux send-keys -t "$PANE_0" "CLAUDE.mdファイルの「## tmux pane information」セクションを以下の内容で更新してください：

Result of \\\`tmux list-panes -F \\\"#{pane_index}: #{pane_id} #{pane_current_command} #{pane_active}\\\"\\\`:

\\\`\\\`\\\`
$PANE_INFO
\\\`\\\`\\\`

更新後、以下の子Pane通信機能を使用してください：

**子Paneへのプロンプト送信方法:**
- 開発Pane ($PANE_1) へ: \\\`tmux send-keys -t $PANE_1 \\\"プロンプト内容\\\" Enter\\\`
- レビューPane ($PANE_2) へ: \\\`tmux send-keys -t $PANE_2 \\\"プロンプト内容\\\" Enter\\\`

これで子Paneに指示を送信できます。" Enter

# 8. 親Paneから子Paneへのプロンプト送信テスト
echo "🔄 親Paneから子Paneへの通信テストを開始中..."
sleep 3  # Claude完全起動を待つ

# 親Paneから各子Paneにテストプロンプトを送信
echo "   📤 親Pane ($PANE_0) から子Paneへプロンプト送信中..."

# 存在する子Paneのみにテストプロンプト送信
if [ -n "$PANE_1" ]; then
    echo "     → 開発Pane ($PANE_1) にプロンプト送信中..."
    tmux send-keys -t "$PANE_1" "こんにちは！あなたは開発Paneです。簡単な挨拶と、あなたの役割を教えてください。" Enter
    sleep 3
fi

if [ -n "$PANE_2" ]; then
    echo "     → レビューPane ($PANE_2) にプロンプト送信中..."
    tmux send-keys -t "$PANE_2" "こんにちは！あなたはレビューPaneです。簡単な挨拶と、あなたの役割を教えてください。" Enter
    sleep 3
fi



echo "   ✅ 全子Paneへのプロンプト送信完了"

# 各子Paneの応答を待つ
echo "   ⏳ 子Paneの応答を待機中..."
sleep 10

# 各子Paneの応答確認
echo "   📄 子Paneの応答確認中..."
echo ""
echo "=== 開発Pane ($PANE_1) の応答 ==="
tmux capture-pane -t "$PANE_1" -p | tail -5
echo ""
echo "=== レビューPane ($PANE_2) の応答 ==="
tmux capture-pane -t "$PANE_2" -p | tail -5
echo ""


echo ""
echo "🎉 Claude tmux自動実行システム（3個Pane版）の起動が完了しました！"
echo "=================================================================="
echo ""
echo "📋 Pane情報:"
echo "   セッション: $SESSION_NAME"
echo "   ウィンドウ: Claude-開発チーム"
echo "   親Pane ID: $PANE_0 （左側・司令塔）"
echo "   開発Pane ID: $PANE_1 （右上・実装）"
echo "   レビューPane ID: $PANE_2 （右下・レビュー）"
echo ""
echo "🔧 次のステップ:"
echo "   1. tmux attach -t $SESSION_NAME でセッションに接続"
echo "   2. Ctrl+B → 0-2 でPane切り替え"
echo "   3. Ctrl+B → Q でPane番号表示"
echo "   4. 各子Paneの応答を確認"
echo "   5. システム状況確認: ./.task/status_check.sh"
echo "   6. 新しいタスク作成: ./.task/create_task.sh task-XXX \"説明\""
echo ""
echo "📚 詳細な使用方法は README_CLAUDE.md を参照してください"
echo ""
echo "🚀 準備完了！親Paneから子Paneに指示を送信できます！" 