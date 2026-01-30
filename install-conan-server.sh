#!/bin/bash

###############################################################################
# Conan Exiles Server - Auto Install Script
# Based on ZAP-Hosting Guide
# Ubuntu 24.04 LTS
###############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Conan Exiles Server - Auto Install${NC}"
echo -e "${GREEN}Based on ZAP-Hosting Guide${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Vui lòng chạy với quyền sudo${NC}"
    exit 1
fi

# Step 1: Install dependencies
echo -e "${YELLOW}[1/7] Cài đặt dependencies...${NC}"
apt update && apt upgrade -y
apt install wine64 xvfb lib32gcc-s1 curl wget -y

echo -e "${GREEN}Wine và xvfb đã được cài đặt${NC}"

# Step 2: Create steam user
echo -e "${YELLOW}[2/7] Tạo user 'steam'...${NC}"
if id "steam" &>/dev/null; then
    echo -e "${GREEN}User 'steam' đã tồn tại${NC}"
else
    useradd -m steam
    echo -e "${GREEN}User 'steam' đã được tạo${NC}"
fi

# Step 3: Install SteamCMD
echo -e "${YELLOW}[3/7] Cài đặt SteamCMD...${NC}"
su - steam -c "
    mkdir -p ~/steamcmd
    cd ~/steamcmd
    curl -sqL 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxvf -
"
echo -e "${GREEN}SteamCMD đã được cài đặt${NC}"

# Step 4: Download Conan Exiles Server
echo -e "${YELLOW}[4/7] Tải Conan Exiles Server (20-40 phút)...${NC}"
echo -e "${YELLOW}Forcing Windows binaries...${NC}"
su - steam -c "
    cd ~/steamcmd
    ./steamcmd.sh +@sSteamCmdForcePlatformType windows \
      +force_install_dir '/home/steam/Conan-Server' \
      +login anonymous \
      +app_update 443030 validate \
      +quit
"
echo -e "${GREEN}Server files đã được tải xuống${NC}"

# Step 5: Configure firewall
echo -e "${YELLOW}[5/7] Cấu hình firewall...${NC}"
ufw allow 7777/udp
ufw allow 7778/udp
ufw allow 27015/udp
ufw --force enable
echo -e "${GREEN}Firewall đã được cấu hình${NC}"

# Step 6: Create systemd service
echo -e "${YELLOW}[6/7] Tạo systemd service...${NC}"
cat > /etc/systemd/system/conan-server.service << 'EOF'
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
EOF

systemctl daemon-reload
systemctl enable conan-server
echo -e "${GREEN}Systemd service đã được tạo${NC}"

# Step 7: Create config template
echo -e "${YELLOW}[7/7] Tạo config template...${NC}"
mkdir -p /home/steam/Conan-Server/Engine/Config/Windows
cat > /home/steam/Conan-Server/Engine/Config/Windows/WindowsServerEngine.ini << 'EOF'
[OnlineSubsystem]
ServerName=My Conan Server
ServerPassword=

[ServerSettings]
AdminPassword=ChangeThisPassword123
MaxPlayers=40
ServerRegion=2
PVPEnabled=True
EOF

chown -R steam:steam /home/steam/Conan-Server

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cài đặt hoàn tất!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Các bước tiếp theo:${NC}"
echo ""
echo "1. Chỉnh sửa cấu hình server:"
echo "   sudo nano /home/steam/Conan-Server/Engine/Config/Windows/WindowsServerEngine.ini"
echo ""
echo "2. Thay đổi AdminPassword và ServerName"
echo ""
echo "3. Khởi động server:"
echo "   sudo systemctl start conan-server"
echo ""
echo "4. Kiểm tra trạng thái:"
echo "   sudo systemctl status conan-server"
echo ""
echo "5. Xem logs:"
echo "   sudo journalctl -u conan-server -f"
echo ""
echo -e "${YELLOW}Lưu ý:${NC} Server cần 2-3 phút để khởi động lần đầu."
echo ""
