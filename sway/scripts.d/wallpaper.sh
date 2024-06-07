#!/bin/bash

WALLPAPER_DIR="$HOME/.config/sway/wallpapers"
INTERVAL=60
TRANSITION_TIME=2
PREV_WALLPAPER=""
USED_WALLPAPERS=()

start_swaybg() {
  swaybg -m fill -i "$1" &
  echo $! >"/tmp/swaybg_$2.pid"
}

stop_swaybg() {
  if [ -f "/tmp/swaybg_$1.pid" ]; then
    kill $(cat "/tmp/swaybg_$1.pid")
    rm "/tmp/swaybg_$1.pid"
  fi
}

contains() {
  local e

  for e in "${USED_WALLPAPERS[@]}"; do
    [[ "$e" == "$1" ]] && return 0
  done

  return 1
}

while true; do
  WALLPAPER=""

  if [[ ${#USED_WALLPAPERS[@]} -ge $(find "$WALLPAPER_DIR" -type f | wc -l) ]]; then
    USED_WALLPAPERS=()
  fi

  while true; do
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)
    if [[ "$WALLPAPER" != "$PREV_WALLPAPER" ]] && ! contains "$WALLPAPER"; then
      break
    fi
  done

  start_swaybg "$WALLPAPER" 1
  sleep $TRANSITION_TIME

  stop_swaybg 0

  mv /tmp/swaybg_1.pid /tmp/swaybg_0.pid

  USED_WALLPAPERS+=("$WALLPAPER")

  PREV_WALLPAPER="$WALLPAPER"
  sleep $INTERVAL
done