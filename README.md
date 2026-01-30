# 🎮 Conan Exiles Server - Quick Start

> 📦 **Repository:** https://github.com/giangnguyen2904/trash.git  
> 📚 **Method:** ZAP-Hosting Official Guide

---

## ⚡ Cài Đặt Nhanh (5 Phút)

### Bước 1: Tải và Chạy Script

```bash
wget https://raw.githubusercontent.com/giangnguyen2904/trash/main/install-conan-server.sh
chmod +x install-conan-server.sh
sudo ./install-conan-server.sh
```

⏱️ **Thời gian:** 30-60 phút (tùy tốc độ mạng)

### Bước 2: Cấu Hình Server

```bash
sudo nano /home/steam/Conan-Server/Engine/Config/Windows/WindowsServerEngine.ini
```

**Thay đổi:**
```ini
ServerName=Tên Server Của Bạn
AdminPassword=MatKhauManh123
```

Lưu: `Ctrl+O`, `Enter`, `Ctrl+X`

### Bước 3: Khởi Động

```bash
sudo systemctl start conan-server
```

### Bước 4: Kiểm Tra

```bash
# Xem trạng thái
sudo systemctl status conan-server

# Xem logs
sudo journalctl -u conan-server -f
```

---

## 🔧 Quản Lý Server

```bash
# Khởi động
sudo systemctl start conan-server

# Dừng
sudo systemctl stop conan-server

# Khởi động lại
sudo systemctl restart conan-server

# Xem logs
sudo journalctl -u conan-server -f
```

---

## 🔄 Cập Nhật Server

```bash
wget https://raw.githubusercontent.com/giangnguyen2904/trash/main/update-server.sh
chmod +x update-server.sh
./update-server.sh
```

---

## 🎮 Kết Nối

1. Mở Conan Exiles
2. **Play Online** → **Server Browser**
3. Tìm tên server hoặc **Direct Connect**: `IP:7777`

---

## 🐛 Xử Lý Lỗi Nhanh

### Server không khởi động

```bash
sudo journalctl -u conan-server -n 100
wine64 --version
```

### Server không hiển thị

1. Đợi 5-10 phút
2. Kiểm tra firewall: `sudo ufw status`
3. Thử direct connect: `IP:7777`

### RAM không đủ

```bash
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## 🗑️ Gỡ Bỏ Server

Nếu muốn gỡ bỏ hoàn toàn:

```bash
wget https://raw.githubusercontent.com/giangnguyen2904/trash/main/uninstall-conan-server.sh
chmod +x uninstall-conan-server.sh
sudo ./uninstall-conan-server.sh
```

Script sẽ:
- Dừng và xóa service
- Xóa tất cả server files
- Xóa steam user
- Gỡ Wine và dependencies
- Xóa firewall rules

---

## 📦 Files Trong Repo

- **README.md** - Hướng dẫn này
- **conan-server-guide.md** - Hướng dẫn chi tiết
- **install-conan-server.sh** - Script cài đặt tự động
- **update-server.sh** - Script cập nhật
- **uninstall-conan-server.sh** - Script gỡ bỏ

---

## 📋 Yêu Cầu VPS

- **CPU:** 4 cores @ 3.0 GHz+
- **RAM:** 8GB (khuyến nghị 16GB)
- **Disk:** 40GB
- **OS:** Ubuntu 24.04 LTS
- **Ports:** 7777, 7778, 27015 (UDP)

---

## ✅ Checklist

- [ ] VPS đáp ứng yêu cầu
- [ ] Đã chạy script cài đặt
- [ ] Đã sửa config (ServerName, AdminPassword)
- [ ] Server khởi động không lỗi
- [ ] Ports đã mở
- [ ] Có thể kết nối vào server

---

## 📚 Tài Liệu

- [Hướng dẫn chi tiết](./conan-server-guide.md)
- [ZAP-Hosting Guide](https://zap-hosting.com/guides/docs/dedicated-linux-conan/)
- [Conan Wiki](https://conanexiles.fandom.com/wiki/Dedicated_Server)

---

**Chúc bạn vận hành server thành công! 🎉**
