#!/usr/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
LOCATION="$HOME/Pictures"

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <area>"
  echo "area: 'specific' or 'full'"
  exit 1
fi

if [ "$1" != "specific" ] && [ "$1" != "full" ]; then
  echo "Invalid argument: $1"
  echo "area: 'specific' or 'full'"
  exit 1
fi

if [ "$1" == "specific" ]; then
  # Capture a specific area
  grim -g "$(slurp)" - | wl-copy >"$LOCATION/Screenshot_${DATE}.png"
  echo "Specific area screenshot taken and copied."
elif [ "$1" == "full" ]; then
  # Capture full screen
  grim - | wl-copy >"$LOCATION/Screenshot_${DATE}.png"
  echo "Full screen screenshot taken and copied."
fi