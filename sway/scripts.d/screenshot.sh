#!/usr/bin/sh

DATE=$(date +%Y%m%d_%H%M%S)
LOCATION="$HOME/Pictures"
SAVE_TYPE="$LOCATION/Screenshot_${DATE}.png"

show_usage() {
  echo "Usage: $0 [-f|--full] [-s|--specific] [-t|--timeout <seconds>] [-k|--keyboard]"
  echo "Options:"
  echo "  -f, --full            Capture the full screen"
  echo "  -s, --specific        Capture a specific area"
  echo "  -t, --timeout <seconds> Capture after a delay"
  echo "  -k, --keyboard        Capture using keyboard shortcuts"
  exit 1
}

notify_user() {
  notify-send -i $SAVE_TYPE "📸 Screenshot Taken!" "<b>Type:</b> $1<br><b>Saved to:</b> $SAVE_TYPE"
}

if [ "$#" -lt 1 ]; then
  show_usage
fi

case $1 in
  -f|--full)
    grim $SAVE_TYPE
    wl-copy < $SAVE_TYPE
    notify_user "Full screen"
    ;;
  -s|--specific)
    grim -g "$(slurp)" $SAVE_TYPE
    wl-copy < $SAVE_TYPE
    notify_user "Specific area"
    ;;
  -t|--timeout)
    if [ -z "$2" ]; then
      echo "Error: Timeout value required"
      show_usage
    fi
    sleep $2
    grim $SAVE_TYPE
    wl-copy < $SAVE_TYPE
    notify_user "Full screen after $2 seconds"
    ;;
  -k|--keyboard)
    echo "Press 'f' for full screen, 's' for specific area"
    read -n 1 key
    case $key in
      f)
        grim $SAVE_TYPE
        wl-copy < $SAVE_TYPE
        notify_user "Full screen"
        ;;
      s)
        grim -g "$(slurp)" $SAVE_TYPE
        wl-copy < $SAVE_TYPE
        notify_user "Specific area"
        ;;
      *)
        echo "Invalid key: $key"
        show_usage
        ;;
    esac
    ;;
  *)
    echo "Invalid argument: $1"
    show_usage
    ;;
esac

echo "Screenshot saved to $SAVE_TYPE"