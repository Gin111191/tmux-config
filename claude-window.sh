#!/bin/sh
# Shift+← / Shift+→ (see tmux.conf): previous / next window, skipping Claude's windows.
#
# Claude Code runs in windows of their own named ·claude:<project>#<n>, marked with the window
# option @claude_stash (made by nvim-config's lua/core/claude-popup.lua, which shows them in a
# popup). Cycling through them with Shift+arrows is noise, so they are skipped.
#
# Pressed inside such a popup, the keys reach the popup's own client, attached to a throwaway
# session holding only that one window — so there is nowhere to go. Then the popup is closed
# (Claude keeps running) and the move happens in the session the popup was opened from, which the
# popup session records in @claude_origin.
#
# Usage (from tmux.conf): claude-window.sh prev|next <client_name> <session_id> [<@claude_origin>]

dir=$1 client=$2 session=$3 origin=$4

if [ -n "$origin" ]; then
    tmux detach-client -t "$client" # closes the popup
    session=$origin
fi

current=$(tmux display-message -p -t "$session" '#{window_index}')
target=$(tmux list-windows -t "$session" -F '#{window_index} #{@claude_stash}' | awk -v cur="$current" -v dir="$dir" '
    $2 == "1" { next }
    { idx[n++] = $1 }
    END {
        if (n == 0) exit
        if (dir == "next") { for (i = 0; i < n; i++) if (idx[i] + 0 > cur + 0) { print idx[i]; exit } print idx[0] }
        else               { for (i = n - 1; i >= 0; i--) if (idx[i] + 0 < cur + 0) { print idx[i]; exit } print idx[n - 1] }
    }')

[ -n "$target" ] && tmux select-window -t "$session:$target"
exit 0
