#!/bin/sh
# ==============================================================================
#  Cài đặt tmux config — macOS / Linux / WSL / MSYS2
#  https://github.com/Gin111191/tmux-config
#
#  Dùng:  ./install.sh            cài bằng symlink (khuyến nghị)
#         ./install.sh --copy     cài bằng cách copy file
#         ./install.sh --dry-run  chỉ xem sẽ làm gì, không thay đổi
# ==============================================================================
set -eu

SRC_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
SRC="$SRC_DIR/tmux.conf"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux"
DEST="$DEST_DIR/tmux.conf"

MODE=symlink
DRY=0
for arg in "$@"; do
    case "$arg" in
        --copy)    MODE=copy ;;
        --dry-run) DRY=1 ;;
        -h|--help)
            sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
            exit 0 ;;
        *) echo "Tham số không hiểu: $arg" >&2; exit 1 ;;
    esac
done

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY" -eq 1 ]; then say "  [dry-run] $*"; else "$@"; fi; }

# ---------- 1. Nhận diện hệ điều hành ----------
OS="$(uname -s 2>/dev/null || echo unknown)"
case "$OS" in
    Darwin)             PLATFORM="macOS";        INSTALL_HINT="brew install tmux" ;;
    Linux)
        if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
            PLATFORM="WSL (${WSL_DISTRO_NAME:-Linux})"
        else
            PLATFORM="Linux"
        fi
        if   command -v apt     >/dev/null 2>&1; then INSTALL_HINT="sudo apt install tmux"
        elif command -v dnf     >/dev/null 2>&1; then INSTALL_HINT="sudo dnf install tmux"
        elif command -v pacman  >/dev/null 2>&1; then INSTALL_HINT="sudo pacman -S tmux"
        elif command -v zypper  >/dev/null 2>&1; then INSTALL_HINT="sudo zypper install tmux"
        elif command -v apk     >/dev/null 2>&1; then INSTALL_HINT="sudo apk add tmux"
        else                                          INSTALL_HINT="cài tmux bằng trình quản lý gói của bạn"
        fi ;;
    MINGW*|MSYS*|CYGWIN*)
        PLATFORM="Windows ($OS)"; INSTALL_HINT="pacman -S tmux  (trong MSYS2)" ;;
    *)  PLATFORM="$OS";           INSTALL_HINT="cài tmux bằng trình quản lý gói của bạn" ;;
esac

say "Hệ điều hành : $PLATFORM"

# ---------- 2. Kiểm tra tmux ----------
if ! command -v tmux >/dev/null 2>&1; then
    say ""
    say "LỖI: chưa cài tmux."
    say "  Cài bằng: $INSTALL_HINT"
    exit 1
fi
say "tmux         : $(tmux -V)"

# ---------- 3. Kiểm tra file nguồn ----------
[ -f "$SRC" ] || { say "LỖI: không tìm thấy $SRC"; exit 1; }

# ---------- 4. Sao lưu config cũ ----------
STAMP="$(date +%Y%m%d-%H%M%S)"
for old in "$DEST" "$HOME/.tmux.conf"; do
    if [ -e "$old" ] || [ -L "$old" ]; then
        # Nếu đã là symlink trỏ đúng vào file này thì bỏ qua
        if [ -L "$old" ] && [ "$(readlink "$old")" = "$SRC" ]; then
            say "Đã cài sẵn   : $old -> $SRC"
            continue
        fi
        say "Sao lưu      : $old -> $old.bak.$STAMP"
        run mv "$old" "$old.bak.$STAMP"
    fi
done

# ---------- 5. Cài ----------
run mkdir -p "$DEST_DIR"
if [ "$MODE" = symlink ]; then
    say "Tạo symlink  : $DEST -> $SRC"
    run ln -sfn "$SRC" "$DEST"
else
    say "Copy file    : $SRC -> $DEST"
    run cp "$SRC" "$DEST"
fi

# ---------- 6. Nạp lại nếu tmux đang chạy ----------
if [ "$DRY" -eq 0 ] && tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$DEST" 2>/dev/null && say "Đã nạp lại config vào server tmux đang chạy."
fi

say ""
say "Xong. Mở tmux và thử:"
say "  Ctrl+b  |     chia pane dọc"
say "  Ctrl+b  -     chia pane ngang"
say "  Alt+1..9      nhảy cửa sổ"
say "  Ctrl+b  ?     xem toàn bộ phím tắt"
