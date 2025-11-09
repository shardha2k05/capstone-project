#!/usr/bin/env bash
# update_cleanup.sh - update system packages and clean up package cache and old logs
# Usage: sudo ./update_cleanup.sh
set -euo pipefail

echo "Updating package lists..."
apt update -y

echo "Upgrading packages... (this may take a while)"
apt upgrade -y

echo "Removing unused packages..."
apt autoremove -y
apt autoclean -y

# Optional: remove apt cache older than 30 days (safe)
find /var/cache/apt/archives -type f -mtime +30 -delete || true

# Cleanup old logs (example: compress large logs older than 7 days)
LOG_DIRS=("/var/log")
echo "Compressing and trimming logs in ${LOG_DIRS[*]} ..."
for d in "${LOG_DIRS[@]}"; do
  find "$d" -type f -name "*.log" -mtime +7 -exec gzip -9 {} \; || true
done

# Remove tmp files older than 7 days in /tmp
echo "Removing temporary files older than 7 days from /tmp ..."
find /tmp -type f -mtime +7 -exec rm -f {} \; || true

echo "System update and cleanup finished."