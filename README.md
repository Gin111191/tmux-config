# tmux-config

Config tmux **không dùng plugin**, chạy được trên **macOS, Linux, WSL và MSYS2**.

Không cần TPM. Không cần Python. Không có tiến trình nền nào chạy định kỳ.
Chỉ một file `tmux.conf` duy nhất.

```
 1: (✓) backend/src   2: nvim                          zsh    lam-viec
 └─────────────────┘  └─────┘                          └───┘  └──────┘
  cửa sổ đang mở:      cửa sổ khác:                    tên     tên
  2 cấp thư mục cuối   tên chương trình                cửa sổ  session
```

---

## Có gì

- **Prefix vẫn là `Ctrl+b`** — không đổi sang `Ctrl+a` để khỏi đè lên phím "về đầu dòng" của shell
- **`Alt + h/j/k/l`** chuyển pane, **`Alt + 1..9`** nhảy cửa sổ — không cần bấm prefix
- **Copy/paste kiểu vim**, có cả bôi khối chữ nhật (`Ctrl+v`)
- **Clipboard hai lớp chạy song song** — OSC 52 (qua terminal, dùng được cả khi SSH) **và** lệnh native của hệ điều hành (`pbcopy`/`wl-copy`/`xclip`/`clip.exe`) tự nhận diện
- **Cửa sổ đang mở hiện 2 cấp thư mục cuối** thay vì chỉ "zsh"
- **Thanh status đổi màu khi bấm prefix** — biết ngay tmux đang chờ phím
- Giao diện **Tokyo Night Moon**

Xem toàn bộ phím tắt: [CHEATSHEET.md](CHEATSHEET.md)

---

## Cài đặt

### macOS · Linux · WSL

```sh
git clone https://github.com/Gin111191/tmux-config ~/.local/share/tmux-config
cd ~/.local/share/tmux-config
./install.sh
```

Script sẽ tự: nhận diện hệ điều hành → kiểm tra tmux → **sao lưu config cũ** → tạo symlink tới `~/.config/tmux/tmux.conf` → nạp lại nếu tmux đang chạy.

Muốn xem trước mà không thay đổi gì:

```sh
./install.sh --dry-run
```

Muốn copy file thay vì symlink (ví dụ khi cài trên server rồi xoá thư mục repo):

```sh
./install.sh --copy
```

### Windows

**tmux không chạy trực tiếp trên Windows.** Có 2 cách:

**Cách 1 — WSL (khuyến nghị).** Mở PowerShell:

```powershell
wsl --install -d Ubuntu
```

Rồi vào Ubuntu và làm y như phần Linux ở trên.

**Cách 2 — MSYS2.** Cài [MSYS2](https://www.msys2.org/), mở "MSYS2 UCRT64":

```sh
pacman -S tmux git
git clone https://github.com/Gin111191/tmux-config ~/tmux-config
cd ~/tmux-config && ./install.sh
```

> Git Bash **không** có sẵn tmux. Cygwin thì được (chọn gói `tmux` lúc cài).

### Cài thủ công

```sh
mkdir -p ~/.config/tmux
cp tmux.conf ~/.config/tmux/tmux.conf
```

Hoặc dùng đường dẫn cũ `~/.tmux.conf` — config nhận cả hai.

### Dùng thử không cài

```sh
tmux -f /duong/dan/toi/tmux.conf
```

---

## Yêu cầu

| Thứ | Bắt buộc? | Ghi chú |
|---|---|---|
| **tmux ≥ 3.0** | Có | Đã kiểm thử trên 3.6. Cú pháp `%hidden` cần tmux ≥ 3.0 |
| **Nerd Font** | Nên có | Thanh status dùng vài icon. Không có font thì hiện ô vuông — xem mục Tuỳ chỉnh để bỏ |
| Terminal hỗ trợ true color | Nên có | WezTerm, kitty, Alacritty, Ghostty, iTerm2, Windows Terminal |

Cài Nerd Font: [nerdfonts.com](https://www.nerdfonts.com/) — ví dụ JetBrainsMono Nerd Font.

---

## Tuỳ chỉnh

### Đổi màu

Sửa 13 dòng `%hidden thm_*` ở cuối `tmux.conf`. Dán bảng màu khác vào là xong.

### Bỏ icon Nerd Font

Nếu thanh status hiện ô vuông, mở `tmux.conf`, tìm dòng `set -g status-right` và xoá 3 ký tự icon (``, ``, ``).

### Đổi prefix sang `Ctrl+a`

Bỏ chú thích 3 dòng trong mục "Prefix" của `tmux.conf`.

### Đổi số cấp thư mục hiển thị

Tìm dòng `window-status-current-format`, sửa regex:

```tmux
# 2 cấp (mặc định)
#{s|^.*/([^/]+/[^/]+)$|\\1|:pane_current_path}

# 1 cấp
#{b:pane_current_path}

# 3 cấp
#{s|^.*/([^/]+/[^/]+/[^/]+)$|\\1|:pane_current_path}
```

> Phải viết `\\1` (**hai** gạch chéo). Viết một gạch thì tmux báo `invalid octal escape`.

---

## Gỡ cài đặt

```sh
./uninstall.sh
```

Script gỡ symlink và khôi phục bản sao lưu gần nhất.

---

## Nguồn gốc & khác biệt

Dựa trên [tonybanters/tmux-btw](https://github.com/tonybanters/tmux-btw). Những chỗ đã đổi:

| | Bản gốc | Bản này |
|---|---|---|
| Prefix | `Ctrl+a` | **`Ctrl+b`** (mặc định) |
| Biến màu | Rò rỉ 13 biến vào môi trường mọi shell | Dùng `%hidden`, **không rò rỉ** |
| Đường dẫn trên status | `#(echo ... \| rev \| cut \| rev)` — 3 tiến trình mỗi lần vẽ, vỡ khi tên thư mục có dấu `'` | Regex native tmux — **0 tiến trình**, không vỡ |
| Clipboard | Chỉ OSC 52 | OSC 52 **cộng thêm** lệnh native tự nhận diện (`pbcopy`/`wl-copy`/`xclip`/`clip.exe`) — hai lớp chạy song song |
| Đường dẫn reload | Cứng `$HOME/.config/tmux/tmux.conf` | Thử cả `~/.config/tmux/` và `~/.tmux.conf` |
| `default-shell` | — | Không đặt, để tmux tự dùng `$SHELL` (tránh hỏng khi zsh ở `/usr/bin`) |
| `escape-time` | 10 (mặc định) | **0** — bỏ trễ phím ESC trong Neovim |
| `history-limit` | 2000 (mặc định) | **100000** |
| `focus-events` | off | **on** — Neovim tự nạp lại file |
| `allow-passthrough` | off | **on** — xem được ảnh trong terminal |
| `detach-on-destroy` | on | **off** — đóng session cuối không văng khỏi tmux |
| Cài đặt | Tự symlink bằng tay | `install.sh` đa nền tảng, có sao lưu |

## Ghi công

Cấu trúc và bảng màu bắt nguồn từ [tonybanters/tmux-btw](https://github.com/tonybanters/tmux-btw)
(repo gốc không kèm file giấy phép, nên đây chỉ là ghi công, không phải tái cấp phép).
Bảng màu Tokyo Night Moon thuộc về [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim).
