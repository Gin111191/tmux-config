#!/bin/sh
# ==============================================================================
#  Install the tmux config — macOS / Linux / WSL / MSYS2
#  https://github.com/Gin111191/tmux-config
#
#  Usage: ./install.sh            install by symlink (recommended)
#         ./install.sh --copy     install by copying the file
#         ./install.sh --dry-run  only show what it would do, change nothing
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
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY" -eq 1 ]; then say "  [dry-run] $*"; else "$@"; fi; }

# ---------- 1. Identify the operating system ----------
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
        else                                          INSTALL_HINT="install tmux with your package manager"
        fi ;;
    MINGW*|MSYS*|CYGWIN*)
        PLATFORM="Windows ($OS)"; INSTALL_HINT="pacman -S tmux  (inside MSYS2)" ;;
    *)  PLATFORM="$OS";           INSTALL_HINT="install tmux with your package manager" ;;
esac

say "Operating system : $PLATFORM"

# ---------- 2. Check for tmux ----------
if ! command -v tmux >/dev/null 2>&1; then
    say ""
    say "ERROR: tmux is not installed."
    say "  Install it with: $INSTALL_HINT"
    exit 1
fi
say "tmux             : $(tmux -V)"

# ---------- 3. Check the source file ----------
[ -f "$SRC" ] || { say "ERROR: $SRC not found"; exit 1; }

# ---------- 4. Back up the old config ----------
STAMP="$(date +%Y%m%d-%H%M%S)"
for old in "$DEST" "$HOME/.tmux.conf"; do
    if [ -e "$old" ] || [ -L "$old" ]; then
        # Already a symlink pointing at this very file, so skip it
        if [ -L "$old" ] && [ "$(readlink "$old")" = "$SRC" ]; then
            say "Already there    : $old -> $SRC"
            continue
        fi
        say "Backing up       : $old -> $old.bak.$STAMP"
        run mv "$old" "$old.bak.$STAMP"
    fi
done

# ---------- 5. Install ----------
run mkdir -p "$DEST_DIR"
if [ "$MODE" = symlink ]; then
    say "Symlinking       : $DEST -> $SRC"
    run ln -sfn "$SRC" "$DEST"
else
    say "Copying          : $SRC -> $DEST"
    run cp "$SRC" "$DEST"
fi

# ---------- 6. Reload if tmux is already running ----------
if [ "$DRY" -eq 0 ] && tmux list-sessions >/dev/null 2>&1; then
    tmux source-file "$DEST" 2>/dev/null && say "Reloaded the config into the running tmux server."
fi

say ""
say "Done. Open tmux and try:"
say "  Ctrl+Space  |     split the pane vertically"
say "  Ctrl+Space  -     split the pane horizontally"
say "  Alt+1..9      jump to a window"
say "  Ctrl+Space  ?     list every key binding"
