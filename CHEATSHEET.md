# Cheatsheet

Prefix = **`Ctrl+b`**

`Prefix + x` nghĩa là: bấm `Ctrl+b`, **thả tay ra**, rồi bấm `x`.
Khi tmux đang chờ phím tiếp theo, ô bên phải thanh status **đổi sang màu tím**.

Quên phím? Bấm `Prefix + ?` để xem toàn bộ.

---

## Session

| Lệnh / phím | Việc |
|---|---|
| `tmux` | Mở session mới |
| `tmux new -s ten` | Mở session đặt tên |
| `tmux ls` | Liệt kê session |
| `tmux attach` / `tmux a` | Vào lại session gần nhất |
| `tmux attach -t ten` | Vào session cụ thể |
| `tmux kill-session -t ten` | Xoá một session |
| `tmux kill-server` | Xoá **tất cả** session |
| `Prefix + d` | Thoát ra, session vẫn chạy nền |
| `Prefix + s` | Danh sách session để chọn |
| `Prefix + $` | Đổi tên session |
| `Prefix + (` / `)` | Session trước / sau |

> `detach-on-destroy off` đang bật: đóng session cuối cùng sẽ nhảy sang session khác thay vì văng hẳn khỏi tmux.

## Cửa sổ (window)

| Phím | Việc |
|---|---|
| `Prefix + c` | Cửa sổ mới, giữ nguyên thư mục hiện tại |
| **`Alt + 1`** … **`Alt + 9`** | Nhảy thẳng tới cửa sổ 1–9 — **không cần prefix** |
| **`Shift + ←` / `Shift + →`** | Cửa sổ trước / sau — **không cần prefix** |
| `Prefix + Ctrl+Shift + ←` / `→` | **Đổi vị trí** cửa sổ hiện tại (cần prefix) |
| `Prefix + ,` | Đổi tên cửa sổ |
| `Prefix + w` | Danh sách cửa sổ |
| `Prefix + &` | Đóng cửa sổ |
| `Prefix + f` | Tìm cửa sổ theo nội dung |

## Pane

| Phím | Việc |
|---|---|
| `Prefix + \|` | Chia **dọc** (trái / phải) |
| `Prefix + -` | Chia **ngang** (trên / dưới) |
| **`Alt + h/j/k/l`** | Chuyển pane — **không cần prefix** |
| **`Alt + ←/↓/↑/→`** | Chuyển pane — **không cần prefix** |
| `Prefix + h/j/k/l` | Chuyển pane (có prefix) |
| `Prefix + H/J/K/L` | Đổi kích thước, bước 5 ô |
| `Prefix + Ctrl+h/j/k/l` | Đổi kích thước, bước 1 ô |
| **`Prefix + m`** | **Phóng to / thu nhỏ** pane |
| `Prefix + x` | Đóng pane |
| `Prefix + space` | Đổi kiểu bố cục |
| `Prefix + {` / `}` | Đổi chỗ pane |
| `Prefix + q` | Hiện số thứ tự pane (bấm số để nhảy) |
| `Prefix + !` | Tách pane thành cửa sổ riêng |
| `Prefix + z` | Zoom (phím gốc của tmux, vẫn dùng được) |

Kéo viền pane bằng chuột cũng đổi kích thước được.

---

## Copy mode — vim motion

Vào bằng **`Prefix + [`**. Thoát bằng **`q`**.

Cuộn bằng chuột cũng tự vào copy mode.

### Di chuyển

| Phím | Việc |
|---|---|
| `h` `j` `k` `l` | Trái / xuống / lên / phải |
| `w` `b` `e` | Tới / lùi một từ, cuối từ |
| `W` `B` `E` | Như trên, nhưng tính theo khoảng trắng |
| `0` | Đầu dòng |
| `^` | Ký tự đầu tiên khác khoảng trắng |
| `$` | Cuối dòng |
| `{` `}` | Đoạn trước / đoạn sau |
| `g` | Lên đầu lịch sử cuộn |
| `G` | Xuống cuối lịch sử |
| `H` `M` `L` | Đầu / giữa / cuối màn hình |
| `Ctrl+u` `Ctrl+d` | Nửa trang lên / xuống |
| `Ctrl+b` `Ctrl+f` | Một trang lên / xuống |

### Nhảy trong dòng

| Phím | Việc |
|---|---|
| `f<ký tự>` | Nhảy tới ký tự đó |
| `F<ký tự>` | Nhảy ngược lại tới ký tự đó |
| `t<ký tự>` | Nhảy tới **ngay trước** ký tự đó |
| `T<ký tự>` | Nhảy ngược tới ngay sau ký tự đó |
| `;` `,` | Lặp lại lần nhảy vừa rồi, xuôi / ngược |

### Tìm kiếm

| Phím | Việc |
|---|---|
| `/` | Tìm xuôi |
| `?` | Tìm ngược |
| `n` `N` | Kết quả tiếp / trước |

### Chọn và copy

| Phím | Việc |
|---|---|
| `v` | Bắt đầu bôi đen |
| `V` | Chọn **cả dòng** |
| **`Ctrl+v`** | Bôi **khối chữ nhật** |
| `o` | Nhảy sang đầu bên kia của vùng chọn |
| **`y`** | Copy rồi thoát |
| `q` | Thoát, không copy |
| `Prefix + P` | **Dán** |

Kéo chuột để bôi đen — thả tay ra **không** làm mất vùng đã chọn (mặc định tmux làm mất).

### Khác vim ở chỗ nào

Copy mode **chỉ để đọc và copy**. Không có `d`, `c`, `p`, không có chế độ Insert, không sửa được nội dung.

---

## Clipboard hoạt động ra sao

Bấm `y` kích hoạt **hai lớp cùng lúc**:

```
   y  ─┬─►  buffer tmux  ──►  OSC 52  ──►  terminal  ──►  clipboard hệ thống
       │                      (chạy được cả khi SSH sang máy khác)
       │
       └─►  ống dẫn  ──►  pbcopy / wl-copy / xclip / clip.exe
                           (đường trực tiếp, không cần terminal hỗ trợ)
```

Lệnh ở lớp 2 được chọn tự động theo máy:

| Hệ điều hành | Lệnh |
|---|---|
| macOS | `pbcopy` |
| Linux — Wayland | `wl-copy` |
| Linux — X11 | `xclip` |
| WSL | `clip.exe` (đẩy sang clipboard Windows) |

Không có lệnh nào trong số đó thì lớp OSC 52 vẫn chạy.

---

## Khác

| Phím | Việc |
|---|---|
| `Prefix + r` | Nạp lại config |
| `Prefix + ?` | **Xem toàn bộ phím tắt** |
| `Prefix + :` | Dòng lệnh tmux |
| `Prefix + t` | Đồng hồ |
| `Prefix + ~` | Xem log thông báo của tmux |

---

## Đọc thanh status

```
 1: (✓) backend/src   2: nvim                          zsh    lam-viec
 └─────────────────┘  └─────┘                          └───┘  └──────┘
  cửa sổ đang mở:      cửa sổ khác:                    tên     tên
  2 cấp thư mục cuối   tên chương trình                cửa sổ  session
```

- Cửa sổ **đang mở** hiện 2 cấp thư mục cuối, ví dụ `/home/ban/repos/du-an/backend/src` → `backend/src`
- Các cửa sổ khác hiện tên chương trình đang chạy
- Ô bên phải **đổi sang màu tím** khi bạn vừa bấm `Ctrl+b`
