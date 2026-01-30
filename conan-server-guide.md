# Hướng Dẫn Cài Đặt Conan Exiles Server trên Ubuntu 24.04

> 📦 **GitHub Repository:** https://github.com/giangnguyen2904/trash.git  
> 📚 **Dựa trên:** [ZAP-Hosting Official Guide](https://zap-hosting.com/guides/docs/dedicated-linux-conan/)

---

## 📋 Yêu Cầu Hệ Thống

### Tối Thiểu
- **CPU:** 4 cores @ 3.0 GHz+
- **RAM:** 8GB (khuyến nghị 16GB+)
- **Ổ Đĩa:** 40GB trống
- **OS:** Ubuntu 24.04 LTS (64-bit)
- **Băng Thông:** 10Mbps+ upload

### Ports Cần Mở
- **7777/UDP** - Game Port
- **7778/UDP** - Query Port
- **27015/UDP** - Steam Port

---

## 🚀 Cài Đặt Nhanh (Tự Động)

### Bước 1: Tải Script

```bash
wget https://raw.githubusercontent.com/giangnguyen2904/trash/main/install-conan-server.sh
chmod +x install-conan-server.sh
```

### Bước 2: Chạy Script

```bash
sudo ./install-conan-server.sh
```

Script sẽ tự động:
- ✅ Cài Wine và dependencies
- ✅ Cài SteamCMD
- ✅ Tạo user `steam`
- ✅ Tải Conan Exiles server (~30GB)
- ✅ Cấu hình firewall
- ✅ Tạo systemd service

---

## 🔧 Cài Đặt Thủ Công

### Bước 1: Cài Đặt Dependencies

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install wine64 xvfb lib32gcc-s1 curl wget -y
```

> **Lưu ý:** Dùng Wine từ Ubuntu repository, **không** dùng WineHQ để tránh lỗi dependencies.

### Bước 2: Tạo Steam User

```bash
sudo useradd -m steam
sudo -u steam -s
cd ~
```

### Bước 3: Cài Đặt SteamCMD

```bash
mkdir ~/steamcmd && cd ~/steamcmd
curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
```

### Bước 4: Tải Conan Exiles Server

**Quan trọng:** Phải force Windows binaries!

```bash
./steamcmd.sh +@sSteamCmdForcePlatformType windows \
  +force_install_dir '/home/steam/Conan-Server' \
  +login anonymous \
  +app_update 443030 validate \
  +quit
```

> ⏱️ **Thời gian:** 20-40 phút (tải ~30GB)

### Bước 5: Cấu Hình Firewall

Thoát khỏi steam user và chạy:

```bash
exit  # Thoát steam user
sudo ufw allow 7777/udp
sudo ufw allow 7778/udp
sudo ufw allow 27015/udp
sudo ufw enable
```

### Bước 6: Chạy Server Lần Đầu

Quay lại steam user:

```bash
sudo -u steam -s
cd ~
xvfb-run wine64 /home/steam/Conan-Server/ConanSandboxServer.exe
```

Đợi server khởi động (2-3 phút), sau đó nhấn `Ctrl+C` để dừng.

---

## ⚙️ Cấu Hình Server

### File Cấu Hình

```bash
nano /home/steam/Conan-Server/Engine/Config/Windows/WindowsServerEngine.ini
```

### Cấu Hình Cơ Bản

Thêm vào cuối file:

```ini
[OnlineSubsystem]
ServerName=My Conan Server
ServerPassword=

[ServerSettings]
AdminPassword=YourStrongPassword123
MaxPlayers=40
ServerRegion=3
PVPEnabled=True
```

### Các Tham Số Quan Trọng

| Tham số | Mô tả | Giá trị |
|---------|-------|---------|
| `ServerName` | Tên server | Text |
| `ServerPassword` | Mật khẩu server | Text (để trống = public) |
| `AdminPassword` | Mật khẩu admin | Text |
| `MaxPlayers` | Số người tối đa | 1-70 |
| `ServerRegion` | Khu vực | 0=EU, 1=NA, 2=Asia, 3=Oceania |
| `PVPEnabled` | Bật PvP | True/False |

📚 **Tham khảo:** [Conan Exiles Wiki - Server Settings](https://conanexiles.fandom.com/wiki/Dedicated_Server)

---

## 🔄 Quản Lý Server

### Tạo Systemd Service

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
User=steam
WorkingDirectory=/home/steam
ExecStart=/usr/bin/xvfb-run /usr/bin/wine64 /home/steam/Conan-Server/ConanSandboxServer.exe
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

### Lệnh Quản Lý

```bash
# Khởi động
sudo systemctl start conan-server

# Dừng
sudo systemctl stop conan-server

# Khởi động lại
sudo systemctl restart conan-server

# Xem trạng thái
sudo systemctl status conan-server

# Xem logs
sudo journalctl -u conan-server -f
```

---

## 🔄 Cập Nhật Server

### Cách 1: Script Tự Động

```bash
sudo -u steam -s
cd ~/steamcmd
./steamcmd.sh +@sSteamCmdForcePlatformType windows \
  +force_install_dir '/home/steam/Conan-Server' \
  +login anonymous \
  +app_update 443030 validate \
  +quit
```

### Cách 2: Sử Dụng Script

Tạo file `update-server.sh`:

```bash
#!/bin/bash
echo "Dừng server..."
sudo systemctl stop conan-server

echo "Cập nhật..."
sudo -u steam /home/steam/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir '/home/steam/Conan-Server' \
  +login anonymous \
  +app_update 443030 validate \
  +quit

echo "Khởi động lại..."
sudo systemctl start conan-server
echo "Hoàn tất!"
```

Cấp quyền và chạy:

```bash
chmod +x update-server.sh
./update-server.sh
```

---

## 💾 Backup

### Backup Thủ Công

```bash
tar -czf conan_backup_$(date +%Y%m%d).tar.gz \
  /home/steam/Conan-Server/ConanSandbox/Saved/
```

### Backup Tự Động (Cron)

```bash
sudo crontab -e
```

Thêm dòng (backup lúc 3h sáng hàng ngày):

```
0 3 * * * tar -czf /home/steam/backups/conan_$(date +\%Y\%m\%d).tar.gz /home/steam/Conan-Server/ConanSandbox/Saved/
```

---

## 🐛 Xử Lý Sự Cố

### Server Không Khởi Động

**Kiểm tra logs:**
```bash
sudo journalctl -u conan-server -n 100
```

**Kiểm tra Wine:**
```bash
wine64 --version
```

**Kiểm tra files:**
```bash
ls -la /home/steam/Conan-Server/ConanSandboxServer.exe
```

### Lỗi "Cannot find Windows binaries"

Bạn quên force Windows binaries. Chạy lại:

```bash
steamcmd +@sSteamCmdForcePlatformType windows \
  +force_install_dir '/home/steam/Conan-Server' \
  +login anonymous \
  +app_update 443030 validate \
  +quit
```

### Server Không Hiển Thị Trong Danh Sách

1. Kiểm tra firewall đã mở ports
2. Đợi 5-10 phút sau khi khởi động
3. Thử direct connect: `IP:7777`

### RAM Không Đủ

Thêm swap:

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## 🎮 Kết Nối Vào Server

### Từ Game Client

1. Mở Conan Exiles
2. Chọn **Play Online**
3. **Server Browser** → Tìm tên server
4. Hoặc **Direct Connect** → Nhập `IP:7777`

### Admin Commands

Trong game:
- Nhấn `Insert` hoặc `Home`
- Nhập admin password
- Sử dụng admin panel

---

## 📊 Giám Sát

### Kiểm Tra Tài Nguyên

```bash
# CPU và RAM
htop

# Disk
df -h

# Network
sudo netstat -tulpn | grep -E '7777|7778|27015'
```

### Xem Logs Real-time

```bash
sudo journalctl -u conan-server -f
```

---

## ✅ Checklist

- [ ] Wine và xvfb đã cài
- [ ] SteamCMD đã cài
- [ ] Server files đã tải (với Windows binaries)
- [ ] Firewall đã mở ports
- [ ] Config đã chỉnh sửa
- [ ] Systemd service hoạt động
- [ ] Server hiển thị trong danh sách
- [ ] Có thể kết nối vào server
- [ ] Admin password hoạt động
- [ ] Đã setup backup

---

## 📚 Tài Liệu Tham Khảo

- [ZAP-Hosting Guide](https://zap-hosting.com/guides/docs/dedicated-linux-conan/)
- [Conan Exiles Wiki](https://conanexiles.fandom.com/wiki/Dedicated_Server)
- [Steam Community](https://steamcommunity.com/app/440900/guides/)

---

**Chúc bạn chơi game vui vẻ! 🎮**
