#!/usr/bin/sh

DATE=$(date +%Y%m%d_%H%M%S)
LOCATION="$HOME/Pictures"
SAVE_TYPE="$LOCATION/Screenshot_${DATE}.png"

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

notify_user() {
  notify-send -i $SAVE_TYPE "📸 Screenshot Taken!" "<b>Type:</b> $1<br><b>Saved to:</b> $SAVE_TYPE"
}

if [ "$1" == "specific" ]; then
  # Capture a specific area
  grim -g "$(slurp)" $SAVE_TYPE
  wl-copy < $SAVE_TYPE
  notify_user "Specific area"
elif [ "$1" == "full" ]; then
  # Capture full screen
  grim $SAVE_TYPE
  wl-copy < $SAVE_TYPE
  notify_user "Full screen"
fi

echo "Screenshot saved to $SAVE_TYPE"