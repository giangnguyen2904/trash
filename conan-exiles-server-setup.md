# Hướng Dẫn Cài Đặt Conan Exiles Dedicated Server trên Ubuntu 24.04

> 📦 **GitHub Repository:** https://github.com/giangnguyen2904/trash.git

## 📋 Yêu Cầu Hệ Thống

### Tối Thiểu
- **CPU:** Quad-core 3.0 GHz+
- **RAM:** 8GB (khuyến nghị 16GB+ nếu dùng mods hoặc nhiều người chơi)
- **Ổ Đĩa:** ~35GB cho game files
- **OS:** Ubuntu 24.04 LTS (64-bit)
- **Băng Thông:** Kết nối ổn định, tối thiểu 10Mbps upload

### Ports Cần Mở
- **7777/UDP** - Game Client Port
- **7778/UDP** - Peer-to-Peer Port  
- **27015/UDP** - Steam Query Port

---

## 🚀 Cài Đặt Tự Động (Khuyến Nghị)

### Bước 1: Tải Script Cài Đặt

```bash
cd ~
wget https://raw.githubusercontent.com/giangnguyen2904/trash/main/conan-server-setup.sh
chmod +x conan-server-setup.sh
```

### Bước 2: Chạy Script

```bash
sudo ./conan-server-setup.sh
```

Script sẽ tự động:
- Cài đặt tất cả dependencies (Wine, SteamCMD, Xvfb)
- Tạo user `conan` chuyên dụng
- Tải xuống Conan Exiles server files
- Cấu hình firewall
- Tạo systemd service để tự động khởi động

---

## 🔧 Cài Đặt Thủ Công

### Bước 1: Cập Nhật Hệ Thống

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install software-properties-common wget curl lib32gcc-s1 lib32stdc++6 -y
```

### Bước 2: Cài Đặt Wine

Conan Exiles không có server Linux native, cần Wine để chạy server Windows.

**Phương pháp 1: WineHQ (Khuyến nghị)**

```bash
sudo mkdir -pm755 /etc/apt/keyrings
sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
sudo apt update
sudo apt install --install-recommends winehq-stable -y
```

**Phương pháp 2: Ubuntu Repository (Nếu WineHQ gặp lỗi dependencies)**

```bash
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine64 wine32 winetricks -y
```

### Bước 3: Cài Đặt Xvfb (Virtual Display)

```bash
sudo apt install xvfb -y
```

### Bước 4: Tạo User Chuyên Dụng

```bash
sudo adduser --disabled-password --gecos "" conan
sudo su - conan
```

### Bước 5: Cài Đặt SteamCMD

```bash
mkdir ~/steamcmd && cd ~/steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
```

### Bước 6: Tải Conan Exiles Server

```bash
./steamcmd.sh +force_install_dir ~/conan_server +login anonymous +app_update 443030 validate +quit
```

> ⏱️ **Lưu ý:** Quá trình tải xuống mất khoảng 20-40 phút tùy vào tốc độ mạng (file ~30GB).

### Bước 7: Khởi Tạo Wine Prefix

```bash
export WINEPREFIX=~/wineconan
export WINEARCH=win64
winecfg
```

Một cửa sổ cấu hình Wine sẽ xuất hiện, bạn có thể đóng nó lại.

### Bước 8: Cấu Hình Firewall

Thoát khỏi user `conan` và chạy với quyền sudo:

```bash
exit  # Thoát khỏi user conan
sudo ufw allow 7777/udp
sudo ufw allow 7778/udp
sudo ufw allow 27015/udp
sudo ufw enable
```

### Bước 9: Tạo Script Khởi Động

Quay lại user `conan`:

```bash
sudo su - conan
nano ~/start_conan.sh
```

Dán nội dung sau:

```bash
#!/bin/bash
export WINEPREFIX=~/wineconan
export WINEARCH=win64

# Sử dụng xvfb-run để mô phỏng display cho Wine
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' \
wine ~/conan_server/ConanSandboxServer.exe -log
```

Lưu file (Ctrl+O, Enter, Ctrl+X) và cấp quyền thực thi:

```bash
chmod +x ~/start_conan.sh
```

### Bước 10: Chạy Server Lần Đầu

```bash
./start_conan.sh
```

Server sẽ chạy và tạo các file cấu hình. Đợi khoảng 2-3 phút cho server khởi động hoàn toàn, sau đó nhấn `Ctrl+C` để dừng.

---

## ⚙️ Cấu Hình Server

### File Cấu Hình Chính

Sau khi chạy lần đầu, các file cấu hình được tạo tại:

```
~/conan_server/ConanSandbox/Saved/Config/WindowsServer/
```

### Chỉnh Sửa ServerSettings.ini

```bash
nano ~/conan_server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini
```

**Các thiết lập quan trọng:**

```ini
[ServerSettings]
# Tên server (hiển thị trong danh sách server)
ServerName=My Conan Exiles Server

# Mật khẩu server (để trống nếu public)
ServerPassword=

# Mật khẩu admin
AdminPassword=YourStrongAdminPassword123

# Số người chơi tối đa
MaxPlayers=40

# Khu vực (EU, US, Asia, etc.)
ServerRegion=3

# PvP hoặc PvE
ServerCommunity=0

# Mod list (nếu có)
Mods=
```

### Các File Cấu Hình Khác

- **Engine.ini** - Cấu hình engine, performance
- **Game.ini** - Cấu hình gameplay mechanics
- **ServerSettings.ini** - Cấu hình server chính

---

## 🔄 Quản Lý Server

### Chạy Server với Screen

Để server tiếp tục chạy sau khi ngắt kết nối SSH:

```bash
screen -S conan_server
./start_conan.sh
```

**Tách khỏi screen:** Nhấn `Ctrl+A` sau đó `D`

**Kết nối lại:**
```bash
screen -r conan_server
```

**Xem danh sách screen:**
```bash
screen -ls
```

### Tạo Systemd Service (Tự Động Khởi Động)

Tạo file service:

```bash
sudo nano /etc/systemd/system/conan-server.service
```

Nội dung:

```ini
[Unit]
Description=Conan Exiles Dedicated Server
After=network.target

[Service]
Type=simple
User=conan
WorkingDirectory=/home/conan
Environment="WINEPREFIX=/home/conan/wineconan"
Environment="WINEARCH=win64"
ExecStart=/usr/bin/xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' /usr/bin/wine /home/conan/conan_server/ConanSandboxServer.exe -log
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Kích hoạt service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable conan-server
sudo systemctl start conan-server
```

**Kiểm tra trạng thái:**
```bash
sudo systemctl status conan-server
```

**Xem logs:**
```bash
sudo journalctl -u conan-server -f
```

---

## 🔄 Cập Nhật Server

### Cập Nhật Thủ Công

```bash
sudo systemctl stop conan-server  # Dừng server
sudo su - conan
cd ~/steamcmd
./steamcmd.sh +force_install_dir ~/conan_server +login anonymous +app_update 443030 validate +quit
exit
sudo systemctl start conan-server  # Khởi động lại
```

### Script Tự Động Cập Nhật

Tạo file `update_server.sh`:

```bash
nano ~/update_server.sh
```

Nội dung:

```bash
#!/bin/bash
echo "Dừng server..."
sudo systemctl stop conan-server

echo "Cập nhật server..."
cd ~/steamcmd
./steamcmd.sh +force_install_dir ~/conan_server +login anonymous +app_update 443030 validate +quit

echo "Khởi động lại server..."
sudo systemctl start conan-server

echo "Hoàn tất!"
```

Cấp quyền:
```bash
chmod +x ~/update_server.sh
```

---

## 🐛 Xử Lý Sự Cố

### Lỗi Cài Đặt Wine (Dependency Issues)

Nếu gặp lỗi `winehq-stable : Depends: wine-stable` khi cài Wine:

```bash
# Xóa WineHQ repository
sudo rm -f /etc/apt/sources.list.d/winehq-noble.sources
sudo rm -f /etc/apt/keyrings/winehq-archive.key
sudo apt update

# Cài Wine từ Ubuntu repository
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install wine64 wine32 winetricks -y
```

### Server Không Khởi Động

**Kiểm tra logs:**
```bash
sudo journalctl -u conan-server -n 100
```

**Kiểm tra Wine:**
```bash
wine --version
```

### Server Không Hiển Thị Trong Danh Sách

1. Kiểm tra firewall đã mở ports chưa
2. Kiểm tra `ServerSettings.ini` có đúng không
3. Đợi 5-10 phút sau khi khởi động (server cần thời gian đăng ký với Steam)

### RAM Không Đủ

Thêm swap space:

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

### Performance Kém

Chỉnh sửa `Engine.ini`:

```ini
[/Script/Engine.Engine]
bSmoothFrameRate=true
SmoothedFrameRateRange=(LowerBound=(Type=Inclusive,Value=22),UpperBound=(Type=Exclusive,Value=62))
```

---

## 📊 Giám Sát Server

### Kiểm Tra Tài Nguyên

```bash
# CPU và RAM
htop

# Disk usage
df -h

# Network
iftop
```

### Backup Dữ Liệu

Backup thư mục saved games:

```bash
tar -czf conan_backup_$(date +%Y%m%d).tar.gz ~/conan_server/ConanSandbox/Saved/
```

---

## 🎮 Kết Nối Đến Server

### Từ Game Client

1. Mở Conan Exiles
2. Chọn "Play Online"
3. Chọn "Server Browser"
4. Tìm tên server của bạn hoặc sử dụng "Direct Connect" với IP:7777

### Admin Commands

Trong game, nhấn `Insert` hoặc `Home` để mở admin panel (cần nhập admin password).

---

## 📚 Tài Liệu Tham Khảo

- [Official Conan Exiles Wiki](https://conanexiles.fandom.com/wiki/Dedicated_Server)
- [Steam Community Guides](https://steamcommunity.com/app/440900/guides/)
- [WineHQ Documentation](https://www.winehq.org/)

---

## ✅ Checklist Sau Cài Đặt

- [ ] Server khởi động thành công
- [ ] Ports đã được mở trong firewall
- [ ] Có thể thấy server trong danh sách
- [ ] Có thể kết nối vào server
- [ ] Admin password hoạt động
- [ ] Systemd service tự động khởi động
- [ ] Đã backup cấu hình ban đầu
- [ ] Đã test performance và RAM usage

---

**Chúc bạn chơi game vui vẻ! 🎮**
