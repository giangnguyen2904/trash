#!/bin/bash

###############################################################################
# Conan Exiles Server - Uninstall Script
# Gỡ bỏ hoàn toàn server và tất cả dependencies
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}========================================${NC}"
echo -e "${RED}Conan Exiles Server - Uninstall${NC}"
echo -e "${RED}========================================${NC}"
echo ""

# Confirm
read -p "Bạn có chắc muốn gỡ bỏ hoàn toàn Conan Exiles server? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Hủy bỏ."
    exit 0
fi

# Check root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Vui lòng chạy với quyền sudo${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}[1/6] Dừng và xóa systemd service...${NC}"
systemctl stop conan-server 2>/dev/null || true
systemctl disable conan-server 2>/dev/null || true
rm -f /etc/systemd/system/conan-server.service
systemctl daemon-reload
echo -e "${GREEN}Service đã được xóa${NC}"

echo -e "${YELLOW}[2/6] Xóa server files...${NC}"
rm -rf /home/steam/Conan-Server
rm -rf /home/steam/steamcmd
rm -rf /home/steam/.wine
rm -rf /home/steam/backups
echo -e "${GREEN}Server files đã được xóa${NC}"

echo -e "${YELLOW}[3/6] Xóa steam user...${NC}"
userdel -r steam 2>/dev/null || true
echo -e "${GREEN}Steam user đã được xóa${NC}"

echo -e "${YELLOW}[4/6] Gỡ Wine và dependencies...${NC}"
apt remove --purge wine64 wine32 wine xvfb -y
apt autoremove -y
echo -e "${GREEN}Wine và dependencies đã được gỡ${NC}"

echo -e "${YELLOW}[5/6] Xóa firewall rules...${NC}"
ufw delete allow 7777/udp 2>/dev/null || true
ufw delete allow 7778/udp 2>/dev/null || true
ufw delete allow 27015/udp 2>/dev/null || true
echo -e "${GREEN}Firewall rules đã được xóa${NC}"

echo -e "${YELLOW}[6/6] Dọn dẹp...${NC}"
apt clean
echo -e "${GREEN}Hoàn tất dọn dẹp${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Gỡ bỏ hoàn toàn!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Tất cả các thành phần của Conan Exiles server đã được gỡ bỏ."
echo ""
