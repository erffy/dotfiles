#!/bin/bash

WALLPAPER_DIR="$HOME/.config/sway/wallpapers"
INTERVAL=60
TRANSITION_TIME=1
PID_FILE="/tmp/swaybg.pid"
USED_WALLPAPERS=()
PREV_WALLPAPER=""

# Function to start swaybg with the given wallpaper
start_swaybg() {
  local wallpaper=$1
  swaybg -m fill -i $wallpaper &
  echo $! > $PID_FILE
}

# Function to stop swaybg
stop_swaybg() {
  if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE) 2>/dev/null || true
    rm $PID_FILE
  fi
}

# Function to check if a wallpaper is already used
contains() {
  local wallpaper=$1
  for used in "${USED_WALLPAPERS[@]}"; do
    [[ "$used" == "$wallpaper" ]] && return 0
  done
  return 1
}

# Get list of all wallpapers
all_wallpapers=($(find "$WALLPAPER_DIR" -type f))

if [ ${#all_wallpapers[@]} -eq 0 ]; then
  echo "No wallpapers found in $WALLPAPER_DIR"
  exit 1
fi

while true; do
  # Refresh list of used wallpapers if all wallpapers have been used
  if [ ${#USED_WALLPAPERS[@]} -ge ${#all_wallpapers[@]} ]; then
    USED_WALLPAPERS=()
  fi

  # Select a random wallpaper that hasn't been used
  local WALLPAPER
  while true; do
    WALLPAPER="${all_wallpapers[RANDOM % ${#all_wallpapers[@]}]}"
    if [[ "$WALLPAPER" != "$PREV_WALLPAPER" ]] && ! contains "$WALLPAPER"; then
      break
    fi
  done

  # Stop the previous wallpaper
  stop_swaybg

  # Start new wallpaper
  start_swaybg $WALLPAPER

  # Ensure there's enough time for the new wallpaper to be fully applied
  sleep $TRANSITION_TIME
  
  # Update the list of used wallpapers
  USED_WALLPAPERS+=("$WALLPAPER")
  PREV_WALLPAPER="$WALLPAPER"

  sleep $INTERVAL
done