#!/usr/bin/env bash

# This file is part of 'custom/updates' module

LOG="/tmp/update.log"
MANAGERS=("yay" "pacman" "paru")
UPDATE_SUCCESS=false

[ -f "$LOG" ] && rm "$LOG"

for manager in "${MANAGERS[@]}"; do
  if command -v $manager &>/dev/null; then
    if $manager -Syu --noconfirm --noprogressbar >"$LOG" 2>&1; then
      UPDATE_SUCCESS=true
      break
    else
      echo "$manager update failed. Check the log for details." >>"$LOG"
    fi
  fi
done

if [ "$UPDATE_SUCCESS" = true ]; then
  echo "System update completed successfully." | tee -a "$LOG"
else
  echo -e "No known package manager found or all updates failed.\nUpdate failed." | tee -a "$LOG"
fi

exit 0