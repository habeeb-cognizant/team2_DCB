#!/bin/bash

# =================================================================
# GrievanceConnect Log Management Script (.sh version for Bash)
# =================================================================

# --- 1. CONFIGURATION ---
# Note: In Bash, it's better to use forward slashes for paths.
# This path should point to the root of your Java project folder.
PROJECT_ROOT_PATH="/d/Cognizant/Sprint 2/Grievance Connect"

LOG_FILE_PATH="$PROJECT_ROOT_PATH/logs/app.log"
BACKUP_ROOT_PATH="$PROJECT_ROOT_PATH/backup"

# How many days of backups to keep.
DAYS_TO_KEEP=28

# --- 2. SCRIPT LOGIC ---

echo "--- Starting log management process... ---"

# First, check if the log file exists.
if [ ! -f "$LOG_FILE_PATH" ]; then
    echo "Log file not found at '$LOG_FILE_PATH'. Exiting."
    exit 1
fi

# --- A. ROTATE THE CURRENT LOG ---
# Create a timestamp for the archived log file name (e.g., app.log.2025-06-27.gz)
TIMESTAMP=$(date +%Y-%m-%d)
ROTATED_LOG_FILE_NAME="app.log.$TIMESTAMP.gz"
ROTATED_LOG_FULL_PATH="$(dirname "$LOG_FILE_PATH")/$ROTATED_LOG_FILE_NAME"

echo "Archiving log file to '$ROTATED_LOG_FULL_PATH'..."
# Use gzip to compress the file, which is the standard for .sh scripts.
# The 'cp' command copies the file content before gzip compresses it.
cp "$LOG_FILE_PATH" "$ROTATED_LOG_FULL_PATH.tmp" && gzip "$ROTATED_LOG_FULL_PATH.tmp" && mv "$ROTATED_LOG_FULL_PATH.tmp.gz" "$ROTATED_LOG_FULL_PATH"

# After archiving, empty the original log file.
echo "Original log file has been cleared."
> "$LOG_FILE_PATH"

# --- B. BACKUP THE ROTATED LOG ---
# Move the new .gz archive we just created into the backup folder.
mv "$ROTATED_LOG_FULL_PATH" "$BACKUP_ROOT_PATH/"
echo "Moved archive to backup folder: '$BACKUP_ROOT_PATH'"

# --- C. CLEAN UP OLD BACKUPS ---
echo "Deleting backups older than $DAYS_TO_KEEP days..."
# Use the 'find' command, which is a powerful Linux tool for finding files.
# -mtime +$DAYS_TO_KEEP finds files modified more than $DAYS_TO_KEEP days ago.
find "$BACKUP_ROOT_PATH" -name "*.gz" -mtime +$DAYS_TO_KEEP -exec rm {} \;

echo "--- Log management process completed successfully. ---"
