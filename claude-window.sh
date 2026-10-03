#!/bin/sh
# Shift+←/→/↑/↓ and Prefix+d for the Claude popup (see tmux.conf).
#
# Claude Code runs in windows of their own, ·claude:<project>#<n> (window option @claude_stash),
# shown over your working window in a tmux popup by nvim-config's lua/core/claude-popup.lua. A tmux
# popup belongs to the terminal client, not to a window, so each working window records its own
# float in window options, and this script keeps the popup in step with the window on screen:
#   @claude_float       1 while that window's float is open (unset: closed)
#   @claude_float_pane  the Claude pane its float shows
#
#   prev|next  previous / next working window (·claude:… windows skipped): the float on screen
#              closes, and the new window's float opens again if it was left open
#   open       open this window's float (Shift+↑); with none recorded yet, ask the window's Neovim
#              to do it (same as Space a c there)
#   close      close the float and record it closed (Shift+↓ / Prefix+d inside the popup)
#
# Keys pressed inside a popup reach the popup's own client, attached to a throwaway session
# (claude-view-*) that holds just the Claude window; that session records the working session
# (@claude_origin) and the client the popup is drawn on (@claude_client).
#
# Usage: claude-window.sh prev|next|open|close <client_name> <session_id> [<@claude_origin> <@claude_client>]

cmd=$1 client=$2 session=$3 origin=$4 popup=

if [ -n "$origin" ]; then # pressed inside a popup
    popup=$client
    client=$5
    session=$origin
fi

opt() { tmux show-options -w -q -v -t "$1" "$2"; }               # window option, empty when unset
# Pane still exists. (display-message -t <gone pane> exits 0, so it cannot tell.)
alive() { [ -n "$1" ] && tmux list-panes -a -F '#{pane_id}' | grep -qxF "$1"; }

# Close the popup on screen, and wait for it: a client shows only one popup at a time.
hide() {
    [ -n "$popup" ] || return 0
    tmux detach-client -t "$popup"
    i=0
    while tmux list-clients -F '#{client_name}' | grep -qxF "$popup" && [ "$i" -lt 40 ]; do
        sleep 0.05
        i=$((i + 1))
    done
}

# Show Claude pane $2 as the float of working window $1, on $client.
# Keep in step with popup() in nvim-config's lua/core/claude-popup.lua.
show() {
    tmux list-sessions -F '#{session_name} #{session_attached}' | while read -r name attached; do
        case $name in claude-view-*) [ "$attached" = 0 ] && tmux kill-session -t "=$name" ;; esac
    done
    view="claude-view-$$-$(date +%s)"
    tmp=$(tmux new-session -d -s "$view" -P -F '#{window_id}') || return
    tmux link-window -d -s "$(tmux display-message -p -t "$2" '#{window_id}')" -t "$view:"
    tmux kill-window -t "$tmp"
    tmux set-option -t "$view" status off
    tmux set-option -t "$view" detach-on-destroy on # its Claude window gone: close the popup
    tmux set-option -t "$view" @claude_origin "$session"
    tmux set-option -t "$view" @claude_client "$client"
    tmux select-pane -t "$2"
    tmux set-option -w -t "$1" @claude_float 1
    tmux set-option -w -t "$1" @claude_float_pane "$2"
    title=$(tmux display-message -p -t "$2" ' Claude · #{b:@claude_project} ##{@claude_n} ')
    socket=$(tmux display-message -p '#{socket_path}')
    tmux display-popup -c "$client" -E -w 90% -h 90% -b rounded -T "$title" \
        "env -u TMUX tmux -S '$socket' attach-session -t '$view' \\; set-option -t '$view' destroy-unattached on" &
}

# The RPC socket of the Neovim running in window $1, from nvim-config's registry
# (~/.cache/nvim-claude/<pid>.json) and the process tree under the window's panes.
nvim_socket() {
    panes=" $(tmux list-panes -t "$1" -F '#{pane_pid}' | tr '\n' ' ') "
    for file in "${XDG_CACHE_HOME:-$HOME/.cache}"/nvim-claude/*.json; do
        [ -f "$file" ] || continue
        pid=$(basename "$file" .json)
        p=$pid
        while [ -n "$p" ] && [ "$p" -gt 1 ]; do
            case $panes in *" $p "*)
                for s in "${TMPDIR:-/tmp}"/nvim."$USER"/*/nvim."$pid".0 "/run/user/$(id -u)/nvim.$pid.0"; do
                    [ -S "$s" ] && { echo "$s"; return; }
                done
                lsof -nP -U -a -p "$pid" 2>/dev/null | grep -oE "/[^ ]*nvim\.$pid\.0" | head -1
                return ;;
            esac
            p=$(ps -o ppid= -p "$p" | tr -d ' ')
        done
    done
}

window=$(tmux display-message -p -t "$session" '#{window_id}')

case $cmd in
close)
    tmux set-option -w -u -t "$window" @claude_float
    hide
    ;;
open)
    [ -n "$popup" ] && exit 0 # already open
    pane=$(opt "$window" @claude_float_pane)
    if alive "$pane"; then
        show "$window" "$pane"
    elif s=$(nvim_socket "$window") && [ -n "$s" ]; then
        nvim --server "$s" --remote-expr "luaeval('require(\"core.claude-popup\").toggle()')" >/dev/null 2>&1
    else
        tmux display-message -c "$client" 'No Claude for this window yet: Space a c in Neovim starts one'
    fi
    ;;
prev | next)
    hide # the float stays recorded as open for the window being left
    current=$(tmux display-message -p -t "$session" '#{window_index}')
    target=$(tmux list-windows -t "$session" -F '#{window_index} #{@claude_stash}' | awk -v cur="$current" -v dir="$cmd" '
        $2 == "1" { next }
        { idx[n++] = $1 }
        END {
            if (n == 0) exit
            if (dir == "next") { for (i = 0; i < n; i++) if (idx[i] + 0 > cur + 0) { print idx[i]; exit } print idx[0] }
            else               { for (i = n - 1; i >= 0; i--) if (idx[i] + 0 < cur + 0) { print idx[i]; exit } print idx[n - 1] }
        }')
    [ -n "$target" ] || exit 0
    tmux select-window -t "$session:$target"
    window=$(tmux display-message -p -t "$session" '#{window_id}')
    if [ "$(opt "$window" @claude_float)" = 1 ]; then
        pane=$(opt "$window" @claude_float_pane)
        if alive "$pane"; then
            show "$window" "$pane"
        else # its Claude has gone away
            tmux set-option -w -u -t "$window" @claude_float
        fi
    fi
    ;;
esac
exit 0
