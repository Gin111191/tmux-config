# Cheatsheet

Prefix = **`Ctrl+b`**

`Prefix + x` means: press `Ctrl+b`, **let go**, then press `x`.
While tmux is waiting for the next key, the box on the right of the status bar **turns purple**.

Forgotten a key? Press `Prefix + ?` to see them all.

---

## Sessions

| Command / key | What it does |
|---|---|
| `tmux` | Start a new session |
| `tmux new -s name` | Start a named session |
| `tmux ls` | List the sessions |
| `tmux attach` / `tmux a` | Go back into the most recent session |
| `tmux attach -t name` | Go into a particular session |
| `tmux kill-session -t name` | Delete one session |
| `tmux kill-server` | Delete **all** sessions |
| `Prefix + d` | Detach; the session keeps running in the background |
| `Prefix + s` | List the sessions to pick from |
| `Prefix + $` | Rename the session |
| `Prefix + (` / `)` | Previous / next session |

> `detach-on-destroy off` is on: closing the last session jumps to another session instead of throwing you out of tmux entirely.

## Windows

| Key | What it does |
|---|---|
| `Prefix + c` | New window, keeping the current directory |
| **`Alt + 1`** … **`Alt + 9`** | Jump straight to window 1–9 — **no prefix needed** |
| **`Shift + ←` / `Shift + →`** | Previous / next window — **no prefix needed** |
| `Prefix + Ctrl+Shift + ←` / `→` | **Move** the current window in the list (prefix needed) |
| `Prefix + ,` | Rename the window |
| `Prefix + w` | List the windows |
| `Prefix + &` | Close the window |
| `Prefix + f` | Find a window by its content |

## Panes

| Key | What it does |
|---|---|
| `Prefix + \|` | Split **vertically** (left / right) |
| `Prefix + -` | Split **horizontally** (top / bottom) |
| **`Ctrl + h/j/k/l`** | **Switch pane — and straight on into a Neovim window** (see below) |
| `Alt + h/j/k/l` | Switch pane — no prefix needed |
| `Alt + ←/↓/↑/→` | Switch pane — no prefix needed |
| `Prefix + h/j/k/l` | Switch pane (with the prefix) |
| `Prefix + H/J/K/L` | Resize, 5 cells at a time |
| `Prefix + Ctrl+←/↓/↑/→` | Resize, 1 cell at a time |
| `Prefix + Ctrl+l` | **Clear the screen** (because `Ctrl+l` is taken for switching pane) |
| **`Prefix + m`** | **Zoom** the pane in / out |
| `Prefix + x` | Close the pane |
| `Prefix + space` | Cycle the layout |
| `Prefix + {` / `}` | Swap panes around |
| `Prefix + q` | Show the pane numbers (press a number to jump) |
| `Prefix + !` | Break the pane out into its own window |
| `Prefix + z` | Zoom (tmux's own key, still works) |

Dragging a pane border with the mouse resizes it too.

### Seamless navigation with Neovim

`Ctrl + h/j/k/l` jumps to the next box along, **with no distinction** between a tmux pane and a
Neovim window. Sitting in the leftmost nvim window and pressing `Ctrl+h` jumps straight into the
tmux pane beside it — one set of keys for both.

Both sides are needed for it to work:

| Side | What it needs |
|---|---|
| Neovim | the `christoomey/vim-tmux-navigator` plugin — already in [nvim-config](https://github.com/Gin111191/nvim-config) |
| tmux | the "Seamless navigation with Neovim" section in `tmux.conf` |

How it works: tmux inspects the process running in the pane. If it is `vim`/`nvim` it **sends the
key on** and lets it handle it; if not, tmux switches pane itself.

> **The trade-off:** `Ctrl+l` is normally the shell's "clear the screen", and is now used to switch
> pane. Use `Prefix + Ctrl+l` to clear the screen.

The matching keys on the Neovim side:

| Action | tmux | Neovim |
|---|---|---|
| Move between boxes | `Ctrl + h/j/k/l` | `Ctrl + h/j/k/l` (same keys) |
| Split vertically | `Prefix + \|` | `Space + \|` |
| Split horizontally | `Prefix + -` | `Space + -` |
| Resize | `Prefix + H/J/K/L` | `Space + H/J/K/L` |

---

## Copy mode — vim motions

Enter with **`Prefix + [`**. Leave with **`q`**.

Scrolling with the mouse enters copy mode too.

### Moving around

| Key | What it does |
|---|---|
| `h` `j` `k` `l` | Left / down / up / right |
| `w` `b` `e` | Forward a word, back a word, end of word |
| `W` `B` `E` | The same, but counted by whitespace |
| `0` | Start of the line |
| `^` | First non-whitespace character |
| `$` | End of the line |
| `{` `}` | Previous / next paragraph |
| `g` | Top of the scrollback |
| `G` | Bottom of the scrollback |
| `H` `M` `L` | Top / middle / bottom of the screen |
| `Ctrl+u` `Ctrl+d` | Half a page up / down |
| `Ctrl+b` `Ctrl+f` | A full page up / down |

### Jumping within a line

| Key | What it does |
|---|---|
| `f<char>` | Jump to that character |
| `F<char>` | Jump backwards to that character |
| `t<char>` | Jump to **just before** that character |
| `T<char>` | Jump backwards to just after that character |
| `;` `,` | Repeat the last jump, forwards / backwards |

### Searching

| Key | What it does |
|---|---|
| `/` | Search forwards |
| `?` | Search backwards |
| `n` `N` | Next / previous match |

### Selecting and copying

| Key | What it does |
|---|---|
| `v` | Start selecting |
| `V` | Select **whole lines** |
| **`Ctrl+v`** | Select a **rectangular block** |
| `o` | Jump to the other end of the selection |
| **`y`** | Copy and leave |
| `q` | Leave without copying |
| `Prefix + P` | **Paste** |

Drag with the mouse to select — letting go does **not** lose the selection (tmux loses it by default).

### How it differs from vim

Copy mode is **for reading and copying only**. There is no `d`, `c` or `p`, no Insert mode, and no
way to change the content.

---

## How the clipboard works

Pressing `y` sets off **two layers at once**:

```
   y  ─┬─►  tmux buffer  ──►  OSC 52  ──►  terminal  ──►  system clipboard
       │                      (works even over SSH to another machine)
       │
       └─►  pipe  ──►  pbcopy / wl-copy / xclip / clip.exe
                       (the direct route, needs no terminal support)
```

The layer-2 command is chosen automatically per machine:

| Operating system | Command |
|---|---|
| macOS | `pbcopy` |
| Linux — Wayland | `wl-copy` |
| Linux — X11 | `xclip` |
| WSL | `clip.exe` (pushes to the Windows clipboard) |

If none of those exist, the OSC 52 layer still works.

---

## Other

| Key | What it does |
|---|---|
| `Prefix + r` | Reload the config |
| `Prefix + ?` | **List every key binding** |
| `Prefix + :` | The tmux command line |
| `Prefix + t` | A clock |
| `Prefix + ~` | Show tmux's own message log |

---

## Reading the status bar

```
 1: (✓) backend/src   2: nvim                          zsh    lam-viec
 └─────────────────┘  └─────┘                          └───┘  └──────┘
  current window:      other windows:                  window  session
  last 2 dir levels    the program name                name    name
```

- The **current** window shows the last 2 directory levels, e.g. `/home/you/repos/project/backend/src` → `backend/src`
- The other windows show the name of the program running in them
- The box on the right **turns purple** the moment you press `Ctrl+b`
