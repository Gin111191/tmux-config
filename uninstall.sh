#!/bin/sh
# Remove the config and restore the most recent backup, if there is one.
set -eu
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"

if [ -e "$DEST" ] || [ -L "$DEST" ]; then
    rm -f "$DEST"
    echo "Removed: $DEST"
else
    echo "Nothing to remove at $DEST"
fi

# Restore the newest backup (if there is one)
for base in "$DEST" "$HOME/.tmux.conf"; do
    newest="$(ls -1t "$base".bak.* 2>/dev/null | head -1 || true)"
    if [ -n "$newest" ]; then
        mv "$newest" "$base"
        echo "Restored: $newest -> $base"
        break
    fi
done

tmux list-sessions >/dev/null 2>&1 && echo "Remember to restart tmux: tmux kill-server"
exit 0
