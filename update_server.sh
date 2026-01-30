#!/bin/bash

###############################################################################
# Conan Exiles Server - Update Script
# Tự động cập nhật server lên phiên bản mới nhất
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Conan Exiles Server - Update${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running as conan user
if [ "$USER" != "conan" ]; then
    echo -e "${RED}Script này phải chạy với user 'conan'${NC}"
    echo "Sử dụng: sudo su - conan"
    echo "Sau đó chạy: ./update_server.sh"
    exit 1
fi

# Backup current server
echo -e "${YELLOW}[1/4] Tạo backup...${NC}"
BACKUP_DIR=~/backups
BACKUP_FILE="conan_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
mkdir -p $BACKUP_DIR

tar -czf $BACKUP_DIR/$BACKUP_FILE ~/conan_server/ConanSandbox/Saved/ 2>/dev/null || true
echo -e "${GREEN}Backup đã lưu tại: $BACKUP_DIR/$BACKUP_FILE${NC}"

# Stop server
echo -e "${YELLOW}[2/4] Dừng server...${NC}"
sudo systemctl stop conan-server
sleep 5

# Update server
echo -e "${YELLOW}[3/4] Cập nhật server files...${NC}"
cd ~/steamcmd
./steamcmd.sh +force_install_dir ~/conan_server +login anonymous +app_update 443030 validate +quit

# Start server
echo -e "${YELLOW}[4/4] Khởi động lại server...${NC}"
sudo systemctl start conan-server

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Cập nhật hoàn tất!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Kiểm tra trạng thái server:"
echo "  sudo systemctl status conan-server"
echo ""
echo "Xem logs:"
echo "  sudo journalctl -u conan-server -f"
echo ""
