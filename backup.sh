#!/bin/bash

# Directories
SOURCE_DIR="/home/lohit/team2_DCB"
LOG_DIR="./logs"
BACKUP_DIR="./backup"

# Create backup dir if not exists
mkdir -p $BACKUP_DIR

# Archive frontend code (excluding backup and logs to avoid recursion)
zip -r $BACKUP_DIR/frontend_backup_$(date +%F).zip $SOURCE_DIR -x "$BACKUP_DIR/*" "$LOG_DIR/*"

# Archive logs with date
zip -r $BACKUP_DIR/logs_backup_$(date +%F).zip $LOG_DIR

echo "Backup completed successfully on $(date)"
