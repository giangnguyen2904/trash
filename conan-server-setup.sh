#!/bin/bash

###############################################################################
# Conan Exiles Dedicated Server - Auto Setup Script
# Hỗ trợ: Ubuntu 24.04 LTS
# Tác giả: Auto-generated
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Conan Exiles Server - Auto Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Vui lòng chạy script với quyền sudo${NC}"
    exit 1
fi

# Step 1: Update system
echo -e "${YELLOW}[1/10] Cập nhật hệ thống...${NC}"
apt update && apt upgrade -y
apt install software-properties-common wget curl lib32gcc-s1 lib32stdc++6 -y

# Step 2: Install Wine
echo -e "${YELLOW}[2/10] Cài đặt Wine...${NC}"

# Try WineHQ first
echo "Thử cài đặt Wine từ WineHQ..."
mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key 2>/dev/null || true
wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources 2>/dev/null || true
apt update

if apt install --install-recommends winehq-stable -y 2>/dev/null; then
    echo -e "${GREEN}Wine từ WineHQ đã được cài đặt thành công${NC}"
else
    echo -e "${YELLOW}WineHQ gặp vấn đề, chuyển sang cài Wine từ Ubuntu repository...${NC}"
    # Remove WineHQ sources if they exist
    rm -f /etc/apt/sources.list.d/winehq-noble.sources
    rm -f /etc/apt/keyrings/winehq-archive.key
    
    # Install Wine from Ubuntu repository
    dpkg --add-architecture i386
    apt update
    apt install wine64 wine32 winetricks -y
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Wine từ Ubuntu repository đã được cài đặt thành công${NC}"
    else
        echo -e "${RED}Không thể cài đặt Wine. Vui lòng cài thủ công.${NC}"
        exit 1
    fi
fi

# Step 3: Install Xvfb
echo -e "${YELLOW}[3/10] Cài đặt Xvfb (Virtual Display)...${NC}"
apt install xvfb screen -y

# Step 4: Create dedicated user
echo -e "${YELLOW}[4/10] Tạo user 'conan'...${NC}"
if id "conan" &>/dev/null; then
    echo -e "${GREEN}User 'conan' đã tồn tại, bỏ qua...${NC}"
else
    adduser --disabled-password --gecos "" conan
    echo -e "${GREEN}User 'conan' đã được tạo${NC}"
fi

# Step 5: Install SteamCMD as conan user
echo -e "${YELLOW}[5/10] Cài đặt SteamCMD...${NC}"
su - conan -c "
    mkdir -p ~/steamcmd
    cd ~/steamcmd
    curl -sqL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxvf -
"

# Step 6: Download Conan Exiles Server
echo -e "${YELLOW}[6/10] Tải Conan Exiles Server (có thể mất 20-40 phút)...${NC}"
su - conan -c "
    cd ~/steamcmd
    ./steamcmd.sh +force_install_dir ~/conan_server +login anonymous +app_update 443030 validate +quit
"

# Step 7: Initialize Wine prefix
echo -e "${YELLOW}[7/10] Khởi tạo Wine prefix...${NC}"
su - conan -c "
    export WINEPREFIX=~/wineconan
    export WINEARCH=win64
    wineboot -i
"

# Step 8: Create startup script
echo -e "${YELLOW}[8/10] Tạo script khởi động...${NC}"
su - conan -c "cat > ~/start_conan.sh << 'EOF'
#!/bin/bash
export WINEPREFIX=~/wineconan
export WINEARCH=win64

# Sử dụng xvfb-run để mô phỏng display cho Wine
xvfb-run --auto-servernum --server-args='-screen 0 640x480x24:32' \\
wine ~/conan_server/ConanSandboxServer.exe -log
EOF
chmod +x ~/start_conan.sh
"

# Step 9: Configure firewall
echo -e "${YELLOW}[9/10] Cấu hình firewall...${NC}"
ufw allow 7777/udp
ufw allow 7778/udp
ufw allow 27015/udp
ufw --force enable

# Step 10: Create systemd service
echo -e "${YELLOW}[10/10] Tạo systemd service...${NC}"
cat > /etc/systemd/system/conan-server.service << 'EOF'
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
EOF

systemctl daemon-reload
systemctl enable conan-server

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cài đặt hoàn tất!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Các bước tiếp theo:${NC}"
echo ""
echo "1. Chỉnh sửa cấu hình server:"
echo "   sudo nano /home/conan/conan_server/ConanSandbox/Saved/Config/WindowsServer/ServerSettings.ini"
echo ""
echo "2. Khởi động server:"
echo "   sudo systemctl start conan-server"
echo ""
echo "3. Kiểm tra trạng thái:"
echo "   sudo systemctl status conan-server"
echo ""
echo "4. Xem logs:"
echo "   sudo journalctl -u conan-server -f"
echo ""
echo -e "${YELLOW}Lưu ý:${NC} Server cần chạy lần đầu để tạo file cấu hình."
echo "Sau khi khởi động lần đầu, hãy dừng server, chỉnh sửa cấu hình, rồi khởi động lại."
echo ""
