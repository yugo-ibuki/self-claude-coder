# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## tmux pane information

Result of `tmux list-panes -F "#{pane_index}: #{pane_id} #{pane_current_command} #{pane_active}"`:

```
0: %25 volta-shim 1    # 親Pane - プロジェクト司令塔
1: %31 fish 0          # 開発Pane - コード実装担当
2: %32 fish 0          # レビューPane - コードレビュー担当
3: %33 fish 0          # テストPane - 品質保証担当
4: %34 fish 0          # ドキュメントPane - ドキュメント管理担当
5: %35 fish 0          # デプロイPane - 運用・デプロイ担当
```

**Pane作成コマンド例:**
```bash
# 必要に応じてPaneを追加作成
tmux split-window -h    # レビューPane用
tmux split-window -h    # テストPane用
tmux split-window -h    # ドキュメントPane用
tmux split-window -h    # デプロイPane用
```

## tmux自動実行システム

### Paneの役割

#### 1. 親Pane (%25) - プロジェクト司令塔
**責務:**
- 全体的なタスク管理と分岐処理
- 各PaneからのStatus報告受信
- タスクの優先度管理と割り当て
- プロジェクト全体の進捗監視
- 緊急時の指示とエラーハンドリング

**主な処理:**
- タスク分析と適切なPaneへの割り当て
- `.task`ディレクトリの管理
- 各Paneのトークン数監視
- 品質ゲートの管理

#### 2. 開発Pane (%31) - コード実装担当
**責務:**
- 機能の実装とコーディング
- バグ修正とリファクタリング
- 単体テストの作成
- 技術仕様の実装

**作業フロー:**
1. 親Paneからタスクを受信
2. 要件分析と技術設計
3. コード実装
4. 単体テスト実行
5. 親Paneに実装完了を報告

**報告形式:**
```
あなたは%31です。[機能名]の実装完了。実装内容: [詳細説明]。テスト結果: [成功/失敗]。
```

#### 3. レビューPane (%32) - コードレビュー担当
**責務:**
- コード品質の審査
- セキュリティチェック
- パフォーマンス評価
- ベストプラクティス確認
- アーキテクチャ適合性検証

**レビュー項目:**
- コードの可読性と保守性
- セキュリティ脆弱性
- パフォーマンスの問題
- テストカバレッジ
- ドキュメントの整合性

**報告形式:**
```
あなたは%32です。[機能名]のレビュー完了。結果: [承認/要修正]。指摘事項: [具体的な指摘]。
```

#### 4. テストPane (%33) - 品質保証担当
**責務:**
- 統合テストの実行
- E2Eテストの実行
- パフォーマンステスト
- 回帰テストの管理
- テスト自動化の推進

**テスト種類:**
- 機能テスト
- 統合テスト
- パフォーマンステスト
- セキュリティテスト
- ユーザビリティテスト

**報告形式:**
```
あなたは%33です。[機能名]のテスト完了。結果: [成功/失敗]。テストケース: [実行数/成功数]。問題: [詳細]。
```

#### 5. ドキュメントPane (%34) - ドキュメント管理担当
**責務:**
- API仕様書の作成・更新
- ユーザーマニュアルの作成
- 技術仕様書の管理
- README・CHANGELOG更新
- コードコメントの品質確認

**ドキュメント種類:**
- API仕様書 (OpenAPI/Swagger)
- ユーザーマニュアル
- 開発者ガイド
- デプロイ手順書
- トラブルシューティングガイド

**報告形式:**
```
あなたは%34です。[ドキュメント名]の作成/更新完了。内容: [更新内容]。対象バージョン: [version]。
```

#### 6. デプロイPane (%35) - 運用・デプロイ担当
**責務:**
- CI/CDパイプラインの管理
- 環境設定とデプロイ
- 監視・ログ管理
- パフォーマンス監視
- 障害対応とロールバック

**主な作業:**
- ビルドとデプロイの自動化
- 環境間の設定管理
- 監視ダッシュボードの管理
- バックアップとリストア
- セキュリティパッチ適用

**報告形式:**
```
あなたは%35です。[環境名]へのデプロイ完了。バージョン: [version]。ステータス: [成功/失敗]。監視結果: [正常/異常]。
```

### 実行ルール

- 各Paneでclaudeを起動する：`claude --dangerously-skip-permissions`
- タスクを各Paneに送信する(右のtmuxのコマンドを叩いて実行してください。[タスク内容]にやってもらう内容で置換してください。)：`tmux send-keys -t [pane_id] "タスク内容。完了後は必ず親Pane(%25)に報告してください。"`
- タスク送信後、必ずもう一度Enterで実行する：`tmux send-keys -t [pane_id] Enter`
- 子Paneは、タスクが終わったら必ず親Paneに報告する：
  1. 親が今動いてるかどうかを右のコマンドを利用して確認してください。pane idは親のIDを指定してください。(参考: tmux capture-pane -t %25 -p | tail -10)
  2. 動いていれば、10秒待って再度 1 を行い確認
  3. 動いてなければ、`tmux send-keys -t %{親PaneId}`でメッセージを送信
  4. 内容: `あなたは[pane番号]です。[タスク完了内容]。`
  5. 最後に`Enter`で実行
- 親Paneは、タスクの報告を受けたら以下を行ってください。
  1. 内容を確認し、それをレビュー担当のPaneにレビュー依頼をしてください。
     1. 確認した内容で問題なければ、`.task` ディレクトリの該当のタスクのステータスをレビューに変えてください。
  2. 次のタスクをコードを書く担当のPaneに依頼してください。
     1. タスク内容は、`.task` ディレクトリにあるタスクからまだ未着手のものから手をつけてください
  3. **具体的な分岐処理フロー**:
     
     **A. 報告内容の分析と完了処理**
     ```bash
     # 報告メッセージから担当Paneとタスク内容を抽出
     # 例: "あなたは%31です。login機能の実装完了。"
     
     # 1. 報告したPaneのステータスをidleに変更
     echo "idle" > .task/panes/${reporting_pane}_status
     
     # 2. 完了したタスクのフェーズを更新
     echo "completed" > .task/${task_id}/phases/${completed_phase}
     echo "$(date): ${completed_phase} 完了 by ${reporting_pane}" >> .task/${task_id}/log
     
     # 3. current_assignmentsから該当エントリを削除
     grep -v "^${reporting_pane}:" .task/panes/current_assignments > temp 2>/dev/null || touch temp
     mv temp .task/panes/current_assignments
     ```
     
     **B. 全Paneの状況確認と次タスクの割り振り**
     ```bash
     # 1. 全Paneの現在の状況を確認
     function check_all_panes() {
       for pane in %31 %32 %33 %34 %35; do
         if tmux list-panes | grep -q "$pane"; then
           status=$(cat .task/panes/${pane}_status 2>/dev/null || echo "offline")
           echo "$pane: $status"
         else
           echo "offline" > .task/panes/${pane}_status
           echo "$pane: offline"
         fi
       done
     }
     
     # 2. 待機中のPaneを特定
     idle_panes=($(for pane in %31 %32 %33 %34 %35; do
       if [ "$(cat .task/panes/${pane}_status 2>/dev/null)" = "idle" ] && tmux list-panes | grep -q "$pane"; then
         echo $pane
       fi
     done))
     
     # 3. 各Paneの役割に応じたタスクを検索・割り当て
     function assign_tasks_to_idle_panes() {
       for pane in "${idle_panes[@]}"; do
         case "$pane" in
           "%31") # 開発Pane
             # development フェーズが pending のタスクを検索
             next_task=$(find .task/task-* -name "phases" -type d -exec sh -c '
               if [ "$(cat "$1/../current_phase")" = "development" ] && [ "$(cat "$1/development")" = "pending" ]; then
                 echo "$(basename $(dirname $1))"
               fi
             ' _ {} \; | head -1)
             ;;
           "%32") # レビューPane
             # review フェーズが pending のタスクを検索
             next_task=$(find .task/task-* -name "phases" -type d -exec sh -c '
               if [ "$(cat "$1/../current_phase")" = "review" ] && [ "$(cat "$1/review")" = "pending" ]; then
                 echo "$(basename $(dirname $1))"
               fi
             ' _ {} \; | head -1)
             ;;
           "%33") # テストPane
             # testing フェーズが pending のタスクを検索
             next_task=$(find .task/task-* -name "phases" -type d -exec sh -c '
               if [ "$(cat "$1/../current_phase")" = "testing" ] && [ "$(cat "$1/testing")" = "pending" ]; then
                 echo "$(basename $(dirname $1))"
               fi
             ' _ {} \; | head -1)
             ;;
           "%34") # ドキュメントPane
             # documentation フェーズが pending のタスクを検索
             next_task=$(find .task/task-* -name "phases" -type d -exec sh -c '
               if [ "$(cat "$1/../current_phase")" = "documentation" ] && [ "$(cat "$1/documentation")" = "pending" ]; then
                 echo "$(basename $(dirname $1))"
               fi
             ' _ {} \; | head -1)
             ;;
           "%35") # デプロイPane
             # deployment フェーズが pending のタスクを検索
             next_task=$(find .task/task-* -name "phases" -type d -exec sh -c '
               if [ "$(cat "$1/../current_phase")" = "deployment" ] && [ "$(cat "$1/deployment")" = "pending" ]; then
                 echo "$(basename $(dirname $1))"
               fi
             ' _ {} \; | head -1)
             ;;
         esac
         
         # タスクが見つかった場合、割り当てを実行
         if [ -n "$next_task" ]; then
           assign_task_to_pane "$pane" "$next_task"
         fi
       done
     }
     
     # 4. タスク割り当て実行
     function assign_task_to_pane() {
       local pane=$1
       local task=$2
       local phase=$(cat .task/$task/current_phase)
       local description=$(cat .task/$task/description)
       
       # Paneステータスを busy に変更
       echo "busy" > .task/panes/${pane}_status
       
       # フェーズステータスを running に変更
       echo "running" > .task/$task/phases/$phase
       
       # 割り当て履歴を記録
       echo "$pane:$task:$phase" >> .task/panes/current_assignments
       
       # Paneにタスクを送信
       tmux send-keys -t $pane "$description (フェーズ: $phase)。完了後は必ず親Pane(%25)に報告してください。" Enter
       
       # ログ記録
       echo "$(date): $task の $phase フェーズを $pane に割り当て" >> .task/$task/log
       echo "$(date): $task:$phase を $pane に割り当て" >> .task/system.log
     }
     
     # 実行
     assign_tasks_to_idle_panes
     ```
     
     **C. フェーズ進行とタスク完了判定**
     ```bash
     # 1. 完了したフェーズに基づいて次フェーズに進む
     function advance_to_next_phase() {
       local task=$1
       local current_phase=$(cat .task/$task/current_phase)
       
       case "$current_phase" in
         "development")
           if [ "$(cat .task/$task/phases/development)" = "completed" ]; then
             echo "review" > .task/$task/current_phase
             echo "$(date): $task が review フェーズに進行" >> .task/$task/log
           fi
           ;;
         "review")
           if [ "$(cat .task/$task/phases/review)" = "completed" ]; then
             echo "testing" > .task/$task/current_phase
             echo "$(date): $task が testing フェーズに進行" >> .task/$task/log
           fi
           ;;
         "testing")
           if [ "$(cat .task/$task/phases/testing)" = "completed" ]; then
             echo "documentation" > .task/$task/current_phase
             echo "$(date): $task が documentation フェーズに進行" >> .task/$task/log
           fi
           ;;
         "documentation")
           if [ "$(cat .task/$task/phases/documentation)" = "completed" ]; then
             echo "deployment" > .task/$task/current_phase
             echo "$(date): $task が deployment フェーズに進行" >> .task/$task/log
           fi
           ;;
         "deployment")
           if [ "$(cat .task/$task/phases/deployment)" = "completed" ]; then
             echo "completed" > .task/$task/overall_status
             echo "$(date): $task 全工程完了" >> .task/$task/log
             echo "$(date): タスク $task 完全終了" >> .task/system.log
           fi
           ;;
       esac
     }
     
     # 2. 重複実行防止チェック
     function prevent_duplicate_execution() {
       local task=$1
       local phase=$2
       local status=$(cat .task/$task/phases/$phase 2>/dev/null || echo "pending")
       
       if [ "$status" = "running" ]; then
         echo "$(date): 警告: $task の $phase フェーズは既に実行中です" >> .task/system.log
         return 1
       elif [ "$status" = "completed" ]; then
         echo "$(date): 警告: $task の $phase フェーズは既に完了済みです" >> .task/system.log  
         return 1
       fi
       return 0
     }
     ```
     
     **D. 次のタスクの割り当て**
     ```bash
     # 未着手タスクの検索
     next_task=$(find .task -name "status" -exec grep -l "pending" {} \; | head -1)
     
     # 次のタスクをコード担当Pane(%31)に送信
     if [ -n "$next_task" ]; then
       task_dir=$(dirname "$next_task")
       task_content=$(cat "$task_dir/description")
       tmux send-keys -t %31 "$task_content。完了後は必ず親Pane(%25)に報告してください。"
       tmux send-keys -t %31 Enter
       echo "assigned" > "$task_dir/status"
       echo "$(date): タスク割り当て完了 -> %31" >> "$task_dir/log"
     else
       tmux send-keys -t %31 "すべてのタスクが完了または処理中です。待機してください。"
       tmux send-keys -t %31 Enter
     fi
     ```
     
     **E. エラーハンドリングと監視**
     ```bash
     # 1. Pane応答性チェック
     function check_pane_responsiveness() {
       for pane in %31 %32 %33 %34 %35; do
         if [ "$(cat .task/panes/${pane}_status)" = "busy" ]; then
           # 最後の活動から一定時間経過をチェック
           last_activity=$(tmux capture-pane -t $pane -p | tail -1 | grep -o '[0-9][0-9]:[0-9][0-9]' | tail -1)
           # 30分以上応答がない場合は警告
           echo "$(date): $pane の応答性チェック実行" >> .task/system.log
         fi
       done
     }
     
     # 2. 不正状態の復旧
     function recover_inconsistent_state() {
       # busyだが割り当てられていないPaneを検出
       for pane in %31 %32 %33 %34 %35; do
         if [ "$(cat .task/panes/${pane}_status)" = "busy" ]; then
           if ! grep -q "^$pane:" .task/panes/current_assignments 2>/dev/null; then
             echo "idle" > .task/panes/${pane}_status
             echo "$(date): $pane の不正な busy 状態を修復" >> .task/system.log
           fi
         fi
       done
       
       # runningだが対応するPaneがbusyでないタスクを検出
       for task_dir in .task/task-*; do
         if [ -d "$task_dir" ]; then
           task=$(basename "$task_dir")
           for phase in development review testing documentation deployment; do
             if [ "$(cat $task_dir/phases/$phase 2>/dev/null)" = "running" ]; then
               # 該当するPaneがbusyでない場合はpendingに戻す
               assigned_pane=$(grep ":$task:$phase" .task/panes/current_assignments 2>/dev/null | cut -d: -f1)
               if [ -z "$assigned_pane" ] || [ "$(cat .task/panes/${assigned_pane}_status)" != "busy" ]; then
                 echo "pending" > $task_dir/phases/$phase
                 echo "$(date): $task の $phase フェーズを pending に復旧" >> .task/system.log
               fi
             fi
           done
         fi
       done
     }
     
     # 3. 定期実行
     recover_inconsistent_state
     check_pane_responsiveness
     ```
     
     **F. トークン数監視**
     ```bash
     # 全Paneのトークン数チェック（概算）
     for pane in %31 %32 %33 %34 %35; do
       if tmux list-panes | grep -q "$pane"; then
         word_count=$(tmux capture-pane -t $pane -p | wc -w)
         if [ "$word_count" -gt 10000 ]; then
           tmux send-keys -t $pane "/clear"
           tmux send-keys -t $pane Enter
           echo "$(date): Pane $pane のトークン数をクリア (word_count: $word_count)" >> .task/system.log
         fi
       fi
     done
     ```

### 実行例

```bash
# システム初期化
mkdir -p .task/panes
for pane in %31 %32 %33 %34 %35; do
  echo "idle" > .task/panes/${pane}_status
done
> .task/panes/current_assignments

# 新タスク作成
mkdir -p .task/task-001/phases
echo "ログイン機能の実装" > .task/task-001/description
echo "development" > .task/task-001/current_phase
echo "pending" > .task/task-001/overall_status
for phase in development review testing documentation deployment; do
  echo "pending" > .task/task-001/phases/$phase
done

# 例1: 開発Paneからの完了報告受信（親Paneでの処理）
# 報告: "あなたは%31です。task-001のdevelopment完了。"
echo "idle" > .task/panes/%31_status
echo "completed" > .task/task-001/phases/development
echo "review" > .task/task-001/current_phase
     grep -v "^%31:" .task/panes/current_assignments > temp 2>/dev/null || touch temp
     mv temp .task/panes/current_assignments

# 例2: 自動的な次フェーズ割り当て（レビューPaneが空いている場合）
if [ "$(cat .task/panes/%32_status)" = "idle" ]; then
  echo "busy" > .task/panes/%32_status
  echo "running" > .task/task-001/phases/review
       echo "%32:task-001:review" >> .task/panes/current_assignments
  tmux send-keys -t %32 "ログイン機能の実装 (フェーズ: review)。完了後は必ず親Pane(%25)に報告してください。" Enter
fi

# 例3: 現在の状況確認
echo "=== 現在の状況 ==="
for pane in %31 %32 %33 %34 %35; do
  status=$(cat .task/panes/${pane}_status 2>/dev/null || echo "unknown")
       assignment=$(grep "^$pane:" .task/panes/current_assignments 2>/dev/null | cut -d: -f2- || echo "none")
  echo "$pane: $status ($assignment)"
done

# 例4: 全Paneの一括起動
for pane in %25 %31 %32 %33 %34 %35; do
  if tmux list-panes | grep -q "$pane"; then
    tmux send-keys -t $pane "claude --dangerously-skip-permissions" Enter
  fi
done

# 例5: システム状態復旧
# 不正な状態のPaneを修復
for pane in %31 %32 %33 %34 %35; do
  if [ "$(cat .task/panes/${pane}_status)" = "busy" ]; then
           if ! grep -q "^$pane:" .task/panes/current_assignments 2>/dev/null; then
      echo "idle" > .task/panes/${pane}_status
      echo "$(date): $pane の不正な busy 状態を修復"
    fi
  fi
done
```

### 重要な注意事項

- **重複実行防止**: 各タスクの各フェーズは最大1つのPaneでのみ実行される
- **状態同期**: Paneステータスとタスクフェーズの状態は常に同期されている必要がある
- **報告形式統一**: 完了報告は "あなたは[PaneID]です。[TaskID]の[Phase]完了。" の形式で行う
- **自動割り当て**: 親Paneは子Paneから報告を受けるたびに全Paneの状況を確認し、待機中のPaneに適切なタスクを自動割り当て
- **フェーズ順序**: development → review → testing → documentation → deployment の順序で進行
- **エラー復旧**: システムは不正な状態を自動検出・修復する機能を持つ
- **ログ管理**: 全ての操作はタスクログとシステムログに記録される
- **トークン監視**: 全Paneのトークン数を定期的に監視し、必要に応じて自動クリア
- **状態確認**: `current_assignments`ファイルで現在の割り当て状況を常に確認可能
- **一意性保証**: 同じフェーズが複数のPaneで実行されることは絶対にない

## タスク管理システム

### .taskディレクトリ構造

```
.task/
├── panes/                    # Pane状態管理
│   ├── %31_status           # idle/busy/offline
│   ├── %32_status           # idle/busy/offline
│   ├── %33_status           # idle/busy/offline
│   ├── %34_status           # idle/busy/offline
│   ├── %35_status           # idle/busy/offline
│   └── current_assignments  # 現在の割り当て状況
├── task-001/
│   ├── description          # タスクの詳細説明
│   ├── phases/              # フェーズ別実行状況
│   │   ├── development      # pending/running/completed/skipped
│   │   ├── review           # pending/running/completed/skipped
│   │   ├── testing          # pending/running/completed/skipped
│   │   ├── documentation    # pending/running/completed/skipped
│   │   └── deployment       # pending/running/completed/skipped
│   ├── current_phase        # 現在のフェーズ
│   ├── overall_status       # pending/in_progress/completed
│   ├── assignee_history     # 各フェーズの担当者履歴
│   └── log                  # 実行ログ
├── task-002/
│   └── ...
└── system.log               # システム全体のログ
```

### フェーズステータス管理

**各フェーズのステータス:**
- `pending`: 未着手（前フェーズ完了待ち）
- `running`: 実行中（1つのPaneで実行中）
- `completed`: 完了
- `skipped`: スキップ（必要に応じて）

**Paneステータス:**
- `idle`: 待機中（新しいタスクを受け取り可能）
- `busy`: 作業中
- `offline`: オフライン

### タスク作成例

```bash
# 新しいタスクの作成
mkdir -p .task/task-001/phases
echo "ログイン機能の実装" > .task/task-001/description
echo "development" > .task/task-001/current_phase
echo "pending" > .task/task-001/overall_status

# 各フェーズの初期化
echo "pending" > .task/task-001/phases/development
echo "pending" > .task/task-001/phases/review
echo "pending" > .task/task-001/phases/testing
echo "pending" > .task/task-001/phases/documentation
echo "pending" > .task/task-001/phases/deployment

echo "$(date): タスク作成" > .task/task-001/log
> .task/task-001/assignee_history

# Pane状態管理ディレクトリの初期化
mkdir -p .task/panes
for pane in %31 %32 %33 %34 %35; do
  echo "idle" > .task/panes/${pane}_status
done
> .task/panes/current_assignments
```
