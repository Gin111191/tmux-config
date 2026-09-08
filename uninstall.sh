#!/bin/sh
# Gỡ config, khôi phục bản sao lưu gần nhất nếu có.
set -eu
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"

if [ -e "$DEST" ] || [ -L "$DEST" ]; then
    rm -f "$DEST"
    echo "Đã gỡ: $DEST"
else
    echo "Không có gì để gỡ tại $DEST"
fi

# Khôi phục bản sao lưu mới nhất (nếu có)
for base in "$DEST" "$HOME/.tmux.conf"; do
    newest="$(ls -1t "$base".bak.* 2>/dev/null | head -1 || true)"
    if [ -n "$newest" ]; then
        mv "$newest" "$base"
        echo "Đã khôi phục: $newest -> $base"
        break
    fi
done

tmux list-sessions >/dev/null 2>&1 && echo "Nhớ khởi động lại tmux: tmux kill-server"
exit 0
