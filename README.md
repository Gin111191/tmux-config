# tmux-config

A tmux config that runs on **macOS, Linux, WSL and MSYS2**.

No TPM, no plugin manager, no Python — one `tmux.conf`, plus two plugins `install.sh`
clones for [session persistence](#session-persistence). That pair is the only thing on
a timer; delete the block at the end of `tmux.conf` and there is none.

> **Take [nvim-config](https://github.com/Gin111191/nvim-config) with this one.** 24-bit
> colour is arranged across both repos: this one decides whether to tell Neovim the
> terminal has it, and nvim-config carries the 256-colour palette for when it does not.
> Install only one and the colours break in a terminal without 24-bit colour, such as
> macOS Terminal.app.

```
 1: (✓) backend/src   2: nvim                          zsh    lam-viec
 └─────────────────┘  └─────┘                          └───┘  └──────┘
  current window:      other windows:                  window  session
  last 2 dir levels    the program name                name    name
```

---

## What it does

- **The prefix stays `Ctrl+b`** — not moved to `Ctrl+a`, so it does not sit on the shell's "go to start of line"
- **`Ctrl + h/j/k/l` moves seamlessly with Neovim** — one set of keys for both tmux panes and nvim windows
- **`Alt + h/j/k/l`** switches pane, **`Alt + 1..9`** jumps to a window — no prefix needed
- **vim-style copy/paste**, including rectangular selection (`Ctrl+v`)
- **A two-layer clipboard running side by side** — OSC 52 (through the terminal, works over SSH too) **and** the operating system's own command (`pbcopy`/`wl-copy`/`xclip`/`clip.exe`), detected automatically
- **The current window shows the last 2 directory levels** instead of just "zsh"
- **The status bar changes colour when the prefix is pressed** — so you can see tmux waiting for a key
- **Sessions survive a reboot** — windows, panes, directories and the programs in them,
  including Claude Code with its conversation ([details](#session-persistence))
- A **Tokyo Night Moon** theme

Every key binding: [CHEATSHEET.md](CHEATSHEET.md)

---

## Install

### macOS · Linux · WSL

```sh
git clone https://github.com/Gin111191/tmux-config ~/.local/share/tmux-config
cd ~/.local/share/tmux-config
./install.sh
```

The script does it all: identify the operating system → check tmux is installed → **back up the old config** → symlink it to `~/.config/tmux/tmux.conf` → reload if tmux is already running.

To see what it would do without changing anything:

```sh
./install.sh --dry-run
```

To copy the file instead of symlinking (for instance installing on a server and then deleting the repo folder):

```sh
./install.sh --copy
```

### Windows

**tmux does not run on Windows directly.** There are 2 ways round it:

**Option 1 — WSL (recommended).** Open PowerShell:

```powershell
wsl --install -d Ubuntu
```

Then go into Ubuntu and follow the Linux section above exactly.

**Option 2 — MSYS2.** Install [MSYS2](https://www.msys2.org/) and open "MSYS2 UCRT64":

```sh
pacman -S tmux git
git clone https://github.com/Gin111191/tmux-config ~/tmux-config
cd ~/tmux-config && ./install.sh
```

> Git Bash does **not** ship tmux. Cygwin does (pick the `tmux` package during setup).

### Installing by hand

```sh
mkdir -p ~/.config/tmux
cp tmux.conf ~/.config/tmux/tmux.conf
```

Or use the old `~/.tmux.conf` path — the config accepts either.

### Trying it without installing

```sh
tmux -f /path/to/tmux.conf
```

---

## Requirements

| What | Required? | Notes |
|---|---|---|
| **tmux ≥ 3.0** | Yes | Tested on 3.6. The `%hidden` syntax needs tmux ≥ 3.0 |
| **A Nerd Font** | Recommended | The status bar uses a few icons. Without the font they show as empty boxes — see Customising to remove them |
| A true-colour terminal | Recommended | WezTerm, kitty, Alacritty, Ghostty, iTerm2, Windows Terminal |

To install a Nerd Font: [nerdfonts.com](https://www.nerdfonts.com/) — JetBrainsMono Nerd Font, for example.

---

## Customising

### Changing the colours

Edit the 13 `%hidden thm_*` lines at the bottom of `tmux.conf`. Paste in a different palette and you are done.

### Dropping the Nerd Font icons

If the status bar shows empty boxes, open `tmux.conf`, find the `set -g status-right` line and delete the 3 icon characters (``, ``, ``).

### Changing the prefix to `Ctrl+a`

Uncomment the 3 lines in the "Prefix" section of `tmux.conf`.

### Changing how many directory levels are shown

Find the `window-status-current-format` line and edit the regex:

```tmux
# 2 levels (the default)
#{s|^.*/([^/]+/[^/]+)$|\\1|:pane_current_path}

# 1 level
#{b:pane_current_path}

# 3 levels
#{s|^.*/([^/]+/[^/]+/[^/]+)$|\\1|:pane_current_path}
```

> It must be written `\\1` (**two** backslashes). With one, tmux errors with `invalid octal escape`.

---

### Machine-local additions

`tmux.conf` sources `~/.config/tmux/local.conf` if that file exists, just before the
persistence block, so it can override any `@option` the plugins read.
Anything that belongs to one machine goes there: it sits outside this repo, so it is
never committed and never lands on the other machines. Same idea as `local.zsh`.

On a machine without the file the line is a no-op, so it is safe everywhere.

#### Example

Anything machine-specific: a different status bar, a key that only makes sense on one
box, an `@option` you want to override before the plugins load.

---

## Session persistence

Windows, panes, working directories and the programs inside them come back after a
reboot. This ships in `tmux.conf`; `install.sh` clones the two plugins it needs
([resurrect](https://github.com/tmux-plugins/tmux-resurrect) and
[continuum](https://github.com/tmux-plugins/tmux-continuum)) — no TPM.

### What comes back

| | |
|---|---|
| Layout, sizes, window and session names, active pane | exactly |
| Each pane's working directory | exactly |
| What was on screen | as text — a screenshot, not a live program |
| Programs | **restarted, not resumed** — only whitelisted ones |

The whitelist is resurrect's default (`vim nvim emacs man less tail top htop …`) plus
one addition in `tmux.conf`:

```tmux
set -g @resurrect-processes '"~claude->claude --continue"'
```

`~` matches any command starting with `claude`; `->` rewrites what actually runs. The
`--continue` reopens that directory's most recent conversation, so Claude Code comes
back with its context instead of an empty session. Anything not on the list — `btop`,
`lf`, a dev server — returns as a plain shell in the right directory.

### Saving

Automatic every 5 minutes (`@continuum-save-interval`), plus `prefix + Ctrl-s` to save
on the spot. Worth pressing before a deliberate shutdown.

Old saves are pruned by resurrect itself: it always keeps the newest 5 and deletes the
rest once they pass 30 days (`@resurrect-delete-backup-after`). The directory stays in
the tens of kilobytes.

### Getting it back

```sh
tmux
```

`tmux attach` also works: with no server running it starts one, the config loads,
continuum restores, and the attach then finds the session. That is a race — restore
runs in the background — and if it ever loses you get `no sessions`. Run it again.

### Turning it off

A session you deliberately killed can come back, but only in one case: killing the
**last** session exits the server, so no save runs and the file still lists it. Kill
one session out of several and the next autosave drops it within 5 minutes.

```sh
touch ~/tmux_no_auto_restore     # next tmux starts clean; rm to re-enable
```

To remove the feature entirely, delete the persistence block at the end of
`tmux.conf`. The plugins are then dead weight in `~/.config/tmux/plugins/`.

## Uninstalling

```sh
./uninstall.sh
```

The script removes the symlink and restores the most recent backup.

---

## Origin & differences

Based on [tonybanters/tmux-btw](https://github.com/tonybanters/tmux-btw). What was changed:

| | The original | This one |
|---|---|---|
| Prefix | `Ctrl+a` | **`Ctrl+b`** (the default) |
| Colour variables | Leaks 13 variables into every shell's environment | Uses `%hidden`, **no leaking** |
| The path on the status bar | `#(echo ... \| rev \| cut \| rev)` — 3 processes per redraw, breaks on a directory name containing `'` | tmux's native regex — **0 processes**, never breaks |
| Clipboard | OSC 52 only | OSC 52 **plus** an auto-detected native command (`pbcopy`/`wl-copy`/`xclip`/`clip.exe`) — two layers side by side |
| Reload path | Hard-coded `$HOME/.config/tmux/tmux.conf` | Tries both `~/.config/tmux/` and `~/.tmux.conf` |
| `default-shell` | — | Not set, so tmux uses `$SHELL` (avoids breaking when zsh lives in `/usr/bin`) |
| `escape-time` | 10 (the default) | **0** — removes the ESC key delay in Neovim |
| `history-limit` | 2000 (the default) | **100000** |
| `focus-events` | off | **on** — Neovim reloads files by itself |
| `allow-passthrough` | off | **on** — images can be shown in the terminal |
| `detach-on-destroy` | on | **off** — closing the last session does not throw you out of tmux |
| Installing | Symlink it by hand | A cross-platform `install.sh`, with backups |

## Credits

The structure and the palette come from [tonybanters/tmux-btw](https://github.com/tonybanters/tmux-btw)
(the original repo ships no licence file, so this is credit, not a re-licence).
The Tokyo Night Moon palette belongs to [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim).
