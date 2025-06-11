#!/bin/bash

# 現在のウィンドウに3つのペインを作成
# 最初のペインは既に存在するので、2つ追加

# 2つ目のペインを作成（水平分割）
tmux split-window -h

# 3つ目のペインを作成（垂直分割）
tmux split-window -v

# 少し待機してペインが作成されるのを確認
sleep 0.5

# 全てのペインでclaudeを起動
for pane_id in $(tmux list-panes -F "#{pane_id}"); do
    tmux send-keys -t "$pane_id" "claude --dangerously-skip-permissions" Enter
done

echo "3つのペインでclaudeを起動しました"