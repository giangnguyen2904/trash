# 🎮 Conan Exiles Server - Hướng Dẫn Nhanh

## 📦 Files Đã Tạo

1. **conan-exiles-server-setup.md** - Hướng dẫn chi tiết đầy đủ
2. **conan-server-setup.sh** - Script cài đặt tự động
3. **update_server.sh** - Script cập nhật server
4. **backup_server.sh** - Script backup dữ liệu

---

## ⚡ Cài Đặt Nhanh (Khuyến Nghị)

### Bước 1: Upload Files Lên VPS

Sử dụng SCP hoặc SFTP để upload file `conan-server-setup.sh` lên VPS Ubuntu 24.04 của bạn.

```bash
# Từ máy local (Windows)
scp conan-server-setup.sh user@your-vps-ip:~/
```

### Bước 2: Chạy Script Cài Đặt

SSH vào VPS và chạy:

```bash
chmod +x conan-server-setup.sh
sudo ./conan-server-setup.sh
```

⏱️ **Thời gian:** Khoảng 30-60 phút (tùy tốc độ mạng)

### Bước 3: Chạy Server Lần Đầu

Để tạo file cấu hình:

```bash
sudo systemctl start conan-server
```

Đợi 2-3 phút, sau đó dừng lại:

```bash
sudo systemctl stop conan-server
```

### Bước 4: Cấu Hình Server

Chỉnh sửa cấu hình:

```bash
sudo nano /home/conan/conan_server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini
```

**Thay đổi tối thiểu:**

```ini
ServerName=Tên Server Của Bạn
AdminPassword=MatKhauAdminManh123
MaxPlayers=40
```

Lưu file: `Ctrl+O`, `Enter`, `Ctrl+X`

### Bước 5: Khởi Động Server

```bash
sudo systemctl start conan-server
```

### Bước 6: Kiểm Tra

```bash
# Xem trạng thái
sudo systemctl status conan-server

# Xem logs real-time
sudo journalctl -u conan-server -f
```

---

## 🔧 Quản Lý Server

### Dừng Server
```bash
sudo systemctl stop conan-server
```

### Khởi Động Server
```bash
sudo systemctl start conan-server
```

### Khởi Động Lại Server
```bash
sudo systemctl restart conan-server
```

### Vô Hiệu Hóa Auto-Start
```bash
sudo systemctl disable conan-server
```

---

## 🔄 Cập Nhật Server

### Cách 1: Sử dụng Script

```bash
sudo su - conan
./update_server.sh
```

### Cách 2: Thủ Công

```bash
sudo systemctl stop conan-server
sudo su - conan
cd ~/steamcmd
./steamcmd.sh +force_install_dir ~/conan_server +login anonymous +app_update 443030 validate +quit
exit
sudo systemctl start conan-server
```

---

## 💾 Backup Dữ Liệu

### Backup Thủ Công

```bash
sudo su - conan
./backup_server.sh
```

### Tự Động Backup Hàng Ngày

Thêm vào crontab:

```bash
sudo su - conan
crontab -e
```

Thêm dòng này (backup lúc 3 giờ sáng mỗi ngày):

```
0 3 * * * /home/conan/backup_server.sh
```

---

## 🐛 Xử Lý Sự Cố Nhanh

### Server Không Khởi Động

```bash
# Xem logs chi tiết
sudo journalctl -u conan-server -n 100 --no-pager

# Kiểm tra Wine
wine --version

# Kiểm tra disk space
df -h
```

### Server Không Hiển Thị Trong Danh Sách

1. Đợi 5-10 phút sau khi khởi động
2. Kiểm tra firewall:
```bash
sudo ufw status
```

3. Kiểm tra ports đang lắng nghe:
```bash
sudo netstat -tulpn | grep -E '7777|7778|27015'
```

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

## 📊 Giám Sát

### Kiểm Tra Tài Nguyên

```bash
# CPU và RAM
htop

# Disk
df -h

# Processes
ps aux | grep Conan
```

### Xem Logs

```bash
# Real-time
sudo journalctl -u conan-server -f

# 100 dòng cuối
sudo journalctl -u conan-server -n 100

# Từ thời điểm cụ thể
sudo journalctl -u conan-server --since "2026-01-30 10:00:00"
```

---

## 🎮 Kết Nối Vào Server

### Từ Game Client

1. Mở Conan Exiles
2. Chọn **Play Online**
3. Chọn **Server Browser**
4. Tìm tên server hoặc dùng **Direct Connect**: `IP:7777`

### Admin Panel

Trong game:
- Nhấn `Insert` hoặc `Home`
- Nhập admin password
- Sử dụng admin commands

---

## 📁 Đường Dẫn Quan Trọng

```
/home/conan/conan_server/                          # Thư mục server
/home/conan/conan_server/ConanSandboxServer.exe    # File chạy server
/home/conan/conan_server/ConanSandbox/Saved/       # Dữ liệu game
/home/conan/conan_server/ConanSandbox/Saved/Config/WindowsServer/  # Cấu hình
/home/conan/backups/                               # Backup files
/home/conan/steamcmd/                              # SteamCMD
```

---

## ✅ Checklist

- [ ] VPS đáp ứng yêu cầu tối thiểu (4 CPU, 8GB RAM, 35GB disk)
- [ ] Đã chạy script cài đặt thành công
- [ ] Đã cấu hình ServerSettings.ini
- [ ] Server khởi động không lỗi
- [ ] Ports đã mở trong firewall
- [ ] Có thể thấy server trong danh sách
- [ ] Có thể kết nối vào server
- [ ] Admin password hoạt động
- [ ] Đã setup backup tự động

---

## 📞 Hỗ Trợ

Nếu gặp vấn đề, kiểm tra:

1. **Logs:** `sudo journalctl -u conan-server -f`
2. **Hướng dẫn chi tiết:** `conan-exiles-server-setup.md`
3. **Community:** [Conan Exiles Forums](https://forums.funcom.com/c/conan-exiles/15)

---

**Chúc bạn vận hành server thành công! 🎉**
