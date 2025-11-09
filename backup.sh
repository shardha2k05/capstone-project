#!/usr/bin/env bash
# backup.sh - create a timestamped tar.gz backup of specified directories
# Usage: ./backup.sh [source_dir1 source_dir2 ...]
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="${HOME}/backups"
SOURCES=("$@")

if [ ${#SOURCES[@]} -eq 0 ]; then
  SOURCES=("${HOME}/Documents" "${HOME}/.config")
fi

mkdir -p "$BACKUP_DIR"

ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"

echo "Creating backup ${ARCHIVE_PATH} for: ${SOURCES[*]}"
tar -czf "$ARCHIVE_PATH" -C / "${SOURCES[@]/#\//}" 2>/dev/null || tar -czf "$ARCHIVE_PATH" "${SOURCES[@]}"

# Rotate: keep last 7 backups
KEEP=7
ls -1t "${BACKUP_DIR}"/backup_*.tar.gz 2>/dev/null | tail -n +$((KEEP+1)) | xargs -r rm --
echo "Backup complete. Kept last ${KEEP} backups in ${BACKUP_DIR}."