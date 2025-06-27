# =================================================================
# GrievanceConnect Log Management Script for Task 600 - FINAL VERSION
# =================================================================

# --- 1. CONFIGURATION ---
# This path should point to the root of your Java project folder.
$ProjectRootPath = "D:\Cognizant\Sprint 2\SPRINT2" # I have updated this based on our previous discussions

# These paths are built based on the root path above.
# This now correctly points to "app.log" as defined in log4j2.xml
$LogFilePath = Join-Path -Path $ProjectRootPath -ChildPath "logs\app.log"
$BackupRootPath = Join-Path -Path $ProjectRootPath -ChildPath "backup"

# How many days of backups to keep. (4 weeks = 28 days)
$DaysToKeep = 28

# --- 2. SCRIPT LOGIC ---

Write-Host "Starting log management process..." -ForegroundColor Green

# First, check if the log file we are supposed to manage actually exists.
if (-not (Test-Path $LogFilePath)) {
    Write-Host "Log file not found at '$LogFilePath'. Creating it for the test." -ForegroundColor Yellow
    New-Item -Path $LogFilePath -ItemType File | Out-Null
    Add-Content -Path $LogFilePath -Value "INFO - Log file created by management script for testing."
}

# --- A. ROTATE THE CURRENT LOG ---
# Create a timestamp for the archived log file name
$timestamp = Get-Date -Format "yyyy-MM-dd"
# This now correctly uses "app.log" for the archive name
$rotatedLogFileName = "app.log.$timestamp.zip"
$rotatedLogFullPath = Join-Path -Path (Split-Path $LogFilePath) -ChildPath $rotatedLogFileName

Write-Host "Archiving log file to '$rotatedLogFullPath'..."
# This command compresses the log file into a .zip archive
Compress-Archive -Path $LogFilePath -DestinationPath $rotatedLogFullPath -Force

# After archiving, empty the original log file so it can start fresh.
Write-Host "Original log file has been cleared."
Clear-Content -Path $LogFilePath

# --- B. BACKUP THE ROTATED LOG ---
# Move the new .zip archive we just created into the backup folder.
Move-Item -Path $rotatedLogFullPath -Destination $BackupRootPath
Write-Host "Moved archive to backup folder: '$BackupRootPath'"

# --- C. CLEAN UP OLD BACKUPS ---
# Get the date from $DaysToKeep days ago. Anything older than this will be deleted.
$cleanupDate = (Get-Date).AddDays(-$DaysToKeep)
Write-Host "Deleting backups older than $cleanupDate..."

# Find .zip files in the backup folder that are older than our cleanup date.
Get-ChildItem -Path $BackupRootPath -Filter "*.zip" | Where-Object { $_.CreationTime -lt $cleanupDate } | ForEach-Object {
    Write-Host "  -> Deleting old backup file: $($_.Name)" -ForegroundColor Yellow
    Remove-Item -Path $_.FullName
}

Write-Host "Log management process completed successfully." -ForegroundColor Green
