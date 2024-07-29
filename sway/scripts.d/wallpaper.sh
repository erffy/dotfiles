#!/bin/bash

WALLPAPER_DIR="$HOME/.config/sway/wallpapers"
INTERVAL=60
TRANSITION_TIME=1
PID_FILE="/tmp/swaybg.pid"
USED_WALLPAPERS=()

# Function to start swaybg with the given wallpaper
start_swaybg() {
  swaybg -m fill -i $1 &
  echo $! > "$PID_FILE"
}

# Function to stop swaybg
stop_swaybg() {
  if [ -f "$PID_FILE" ]; then
    kill $(cat $PID_FILE)
    rm $PID_FILE
  fi
}

# Function to check if a wallpaper is already used
contains() {
  local e
  for e in "${USED_WALLPAPERS[@]}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

# Get list of all wallpapers
all_wallpapers=($(find $WALLPAPER_DIR -type f))

while true; do
  # Refresh list of used wallpapers if all wallpapers have been used
  if [[ ${#USED_WALLPAPERS[@]} -ge ${#all_wallpapers[@]} ]]; then
    USED_WALLPAPERS=()
  fi

  # Select a random wallpaper that hasn't been used
  while true; do
    WALLPAPER="${all_wallpapers[RANDOM % ${#all_wallpapers[@]}]}"
    if [[ "$WALLPAPER" != "$PREV_WALLPAPER" ]] && ! contains "$WALLPAPER"; then
      break
    fi
  done

  # Start new wallpaper and transition
  start_swaybg $WALLPAPER
  sleep $TRANSITION_TIME

  stop_swaybg

  USED_WALLPAPERS+=("$WALLPAPER")
  PREV_WALLPAPER=$WALLPAPER

  sleep $INTERVAL
done