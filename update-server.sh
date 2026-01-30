#!/bin/bash

###############################################################################
# Conan Exiles Server - Update Script
###############################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Conan Exiles Server - Update${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}[1/4] Tạo backup...${NC}"
BACKUP_DIR=/home/steam/backups
BACKUP_FILE="conan_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
sudo mkdir -p $BACKUP_DIR
sudo tar -czf $BACKUP_DIR/$BACKUP_FILE /home/steam/Conan-Server/ConanSandbox/Saved/ 2>/dev/null || true
echo -e "${GREEN}Backup: $BACKUP_DIR/$BACKUP_FILE${NC}"

echo -e "${YELLOW}[2/4] Dừng server...${NC}"
sudo systemctl stop conan-server
sleep 5

echo -e "${YELLOW}[3/4] Cập nhật server...${NC}"
sudo -u steam /home/steam/steamcmd/steamcmd.sh \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir '/home/steam/Conan-Server' \
  +login anonymous \
  +app_update 443030 validate \
  +quit

echo -e "${YELLOW}[4/4] Khởi động lại server...${NC}"
sudo systemctl start conan-server

echo ""
echo -e "${GREEN}Cập nhật hoàn tất!${NC}"
echo ""
echo "Kiểm tra trạng thái: sudo systemctl status conan-server"
echo "Xem logs: sudo journalctl -u conan-server -f"
echo ""
