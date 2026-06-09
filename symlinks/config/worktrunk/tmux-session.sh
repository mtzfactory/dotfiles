#!/bin/bash
# Worktrunk hook: Create tmux session with four windows if it doesn't exist
# Usage: tmux-session.sh <session_name>

SESSION_NAME="$1"

if [ -z "$SESSION_NAME" ]; then
  echo "Error: session name required"
  exit 1
fi

# Only create session if it doesn't exist
# Use '=' prefix for exact name matching — without it, tmux interprets
# dots in the session name as window.pane separators.
if ! tmux has-session -t "=$SESSION_NAME" 2>/dev/null; then
  tmux new-session -d -s "$SESSION_NAME" -n ai
  tmux new-window -t "=$SESSION_NAME" -n editor
  tmux new-window -t "=$SESSION_NAME" -n metro
  tmux new-window -t "=$SESSION_NAME" -n terminal
  tmux select-window -t "=$SESSION_NAME:ai"
  echo "✓ Tmux session '$SESSION_NAME' created"
else
  echo "✓ Tmux session '$SESSION_NAME' already exists"
fi
