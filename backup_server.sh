#!/bin/bash

###############################################################################
# Conan Exiles Server - Backup Script
# Tự động backup dữ liệu server
###############################################################################

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Conan Exiles Server - Backup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Backup directory
BACKUP_DIR=~/backups
mkdir -p $BACKUP_DIR

# Create backup filename with timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="conan_full_backup_${TIMESTAMP}.tar.gz"

echo -e "${YELLOW}Đang tạo backup...${NC}"

# Backup saved games and configs
tar -czf $BACKUP_DIR/$BACKUP_FILE \
    ~/conan_server/ConanSandbox/Saved/ \
    ~/conan_server/ConanSandbox/Mods/ 2>/dev/null || true

# Get file size
SIZE=$(du -h $BACKUP_DIR/$BACKUP_FILE | cut -f1)

echo ""
echo -e "${GREEN}Backup hoàn tất!${NC}"
echo "File: $BACKUP_FILE"
echo "Kích thước: $SIZE"
echo "Đường dẫn: $BACKUP_DIR/$BACKUP_FILE"
echo ""

# Clean old backups (keep last 7 days)
echo -e "${YELLOW}Dọn dẹp backup cũ (giữ 7 ngày gần nhất)...${NC}"
find $BACKUP_DIR -name "conan_full_backup_*.tar.gz" -mtime +7 -delete

echo -e "${GREEN}Hoàn tất!${NC}"
