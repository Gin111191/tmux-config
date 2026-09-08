# Cheatsheet

Prefix = **`Ctrl+b`** (mặc định của tmux).
Ký hiệu `Prefix + x` nghĩa là: bấm `Ctrl+b`, **thả ra**, rồi bấm `x`.

## Session

| Phím / lệnh | Việc |
|---|---|
| `tmux` | Mở session mới |
| `tmux new -s ten` | Mở session đặt tên |
| `tmux ls` | Liệt kê session |
| `tmux attach -t ten` | Vào lại session |
| `Prefix + d` | Thoát ra (session vẫn chạy nền) |
| `Prefix + s` | Danh sách session để chọn |
| `Prefix + $` | Đổi tên session |

## Cửa sổ (window)

| Phím | Việc |
|---|---|
| `Prefix + c` | Cửa sổ mới (giữ nguyên thư mục) |
| `Alt + 1` … `Alt + 9` | Nhảy thẳng tới cửa sổ 1–9 |
| `Shift + ←` / `Shift + →` | Cửa sổ trước / sau |
| `Ctrl+Shift + ←` / `→` | **Đổi vị trí** cửa sổ hiện tại |
| `Prefix + ,` | Đổi tên cửa sổ |
| `Prefix + w` | Danh sách cửa sổ |
| `Prefix + &` | Đóng cửa sổ |

## Pane

| Phím | Việc |
|---|---|
| `Prefix + \|` | Chia **dọc** (trái/phải) |
| `Prefix + -` | Chia **ngang** (trên/dưới) |
| `Alt + h/j/k/l` | Chuyển pane — **không cần prefix** |
| `Alt + ←/↓/↑/→` | Chuyển pane — không cần prefix |
| `Prefix + h/j/k/l` | Chuyển pane (có prefix) |
| `Prefix + H/J/K/L` | Đổi kích thước 5 ô |
| `Prefix + Ctrl+h/j/k/l` | Đổi kích thước 1 ô |
| `Prefix + m` | **Phóng to / thu nhỏ** pane |
| `Prefix + x` | Đóng pane |
| `Prefix + space` | Đổi kiểu bố cục |

## Copy / Paste (kiểu vim)

| Phím | Việc |
|---|---|
| `Prefix + [` | Vào copy mode |
| `h/j/k/l`, `w`, `b`, `G`, `g` | Di chuyển như vim |
| `/` , `?` | Tìm xuôi / ngược |
| `v` | Bắt đầu bôi đen |
| `Ctrl + v` | Bôi **khối chữ nhật** |
| `y` | Copy (ra clipboard hệ thống) |
| `q` | Thoát copy mode |
| `Prefix + P` | Dán |

Chuột: kéo để bôi đen — thả ra **không** làm mất vùng đã chọn.

## Khác

| Phím | Việc |
|---|---|
| `Prefix + r` | Nạp lại config |
| `Prefix + ?` | Xem **toàn bộ** phím tắt |
| `Prefix + t` | Đồng hồ |
| `Prefix + :` | Dòng lệnh tmux |

## Đọc thanh status

```
 1: (✓) backend/src   2: nvim                          zsh    lam-viec
 └─────────────────┘  └─────┘                          └───┘  └──────┘
  cửa sổ đang mở:      cửa sổ khác:                    tên     tên
  2 cấp thư mục cuối   tên chương trình                cửa sổ  session
```

Ô giữa bên phải **đổi sang màu tím** khi bạn vừa bấm `Ctrl+b` — dấu hiệu tmux đang chờ phím tiếp theo.
