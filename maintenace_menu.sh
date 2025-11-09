#!/usr/bin/env bash
# maintenance_menu.sh - menu wrapper to run suite scripts
# Usage: ./maintenance_menu.sh
set -euo pipefail

SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MENU_PROMPT=$(cat <<'EOF'
System Maintenance Suite
------------------------
1) Create backup (backup.sh)
2) Update & Cleanup (update_cleanup.sh)  - requires sudo
3) Monitor logs (log_monitor.sh)
4) Run all tasks (backup + update + cleanup)
5) Exit
Choose an option (1-5):
EOF
)

while true; do
  echo "$MENU_PROMPT"
  read -r choice
  case "$choice" in
    1)
      echo "Enter directories to back up (space-separated). Leave empty to use defaults."
      read -r -a dirs
      if [ ${#dirs[@]} -eq 0 ]; then
        "$SCRIPTS_DIR/backup.sh"
      else
        "$SCRIPTS_DIR/backup.sh" "${dirs[@]}"
      fi
      ;;
    2)
      echo "Running update & cleanup (may require sudo)..."
      sudo bash "$SCRIPTS_DIR/update_cleanup.sh"
      ;;
    3)
      echo "Enter keyword (default ERROR) and logfile (default /var/log/syslog). Add --watch for live monitoring."
      read -r kw logfile watch
      kw=${kw:-ERROR}
      logfile=${logfile:-/var/log/syslog}
      "$SCRIPTS_DIR/log_monitor.sh" "$kw" "$logfile" "$watch"
      ;;
    4)
      echo "Running full maintenance: backup then update/cleanup."
      "$SCRIPTS_DIR/backup.sh"
      sudo bash "$SCRIPTS_DIR/update_cleanup.sh"
      ;;
    5)
      echo "Goodbye."
      exit 0
      ;;
    *)
      echo "Invalid choice. Try again."
      ;;
  esac
  echo
  read -r -p "Press Enter to continue..."
done