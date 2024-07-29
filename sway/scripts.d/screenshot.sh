#!/usr/bin/env bash

cursor="yes"
showEditor="yes"
TARGET="$HOME/Pictures"
DATE=$(date +%Y%m%d_%H%M%S)

# Take screenshot for each output
takeScreenshot() {
  [[ -n $1 ]] && sleep "$1"

  local outputs
  outputs=$(swaymsg -t get_outputs | jq -r ".[].name")

  for a in $outputs; do
    local tmp_file="/tmp/$a.png"
    [[ -e $tmp_file ]] && rm $tmp_file
    grim -l 1 ${cursor:+-c} -o "$a" "$tmp_file"
    swaymsg for_window "[title=\"imv(.*)$a.png\"]" move to output "$a"
    swaymsg for_window "[title=\"imv(.*)$a.png\"]" fullscreen true
    imv-wayland "$tmp_file" &
  done
}

# Merge all screenshots into one
mergePhotos() {
  local files=$(swaymsg -t get_outputs | jq -r ".[].name" | xargs -I{} echo /tmp/{}.png | tr '\n' ' ')
  pushd /tmp &>/dev/null
  magick +append $files ss.png
  popd &>/dev/null
}

# Process screenshots based on mode
processScreenshot() {
  local mode=$1
  local action=$2
  local timeout=$3
  local tempfile
  tempfile=$(mktemp)

  case $mode in
    Rectangular)
      takeScreenshot "$timeout"
      grim -g "$(slurp)" - > "$tempfile"
      killall imv-wayland
      cat "$tempfile" | swappy -f - | wl-copy
      rm "$tempfile"
      ;;
    Full)
      takeScreenshot "$timeout"
      killall imv-wayland
      local focused
      focused=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
      cat "/tmp/$focused.png" | swappy -f - | wl-copy
      ;;
    Active)
      [[ -n $timeout ]] && sleep "$timeout"
      grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" - > "$tempfile"
      cat "$tempfile" | swappy -f - | wl-copy
      rm "$tempfile"
      ;;
  esac
}

# Main function handling modes
main() {
  local mode=$1
  local action=$2
  local timeout=$3
  local saved_file="$TARGET/${DATE}"

  processScreenshot "$mode" "$action" "$timeout"

  if [[ "$action" == "2" ]] || [[ "$action" == "4" ]]; then
    local output_file="${saved_file}-edited.png"
    case $mode in
      Rectangular)
        grim -g "$(slurp)" - > "${saved_file}.png"
        ;;
      Full)
        local focused
        focused=$(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | .name')
        cat "/tmp/$focused.png" > "${saved_file}.png"
        ;;
      Active)
        grim -g "$(swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')" - > "${saved_file}.png"
        ;;
    esac
    cat "${saved_file}.png" | swappy -f - -o "$output_file"
  fi
}

# Handle command-line arguments
case $1 in
  -r | --rec) main Rectangular 1 ;;
  -f | --full) main Full 2 ;;
  -a | --active) main Active 1 ;;
  *)
    local mode1
    mode1=$(swaynag -t wpgtheme -m Screenshot -Z Full 'echo Full' -Z Rectangular 'echo Rectangular')
    [[ -z $mode1 ]] && exit

    local mode2
    mode2=$(swaynag -t wpgtheme -m "$mode1 Screenshot" -Z 'Copy' 'echo 1' -Z 'Save' 'echo 2' -Z 'Timeout and Copy' 'echo 3' -Z 'Timeout and Save' 'echo 4')

    if [[ "$mode2" == "3" ]] || [[ "$mode2" == "4" ]]; then
      local timeout
      timeout=$(swaynag -t wpgtheme -m Timeout -Z 2 'echo 2' -Z 3 'echo 3' -Z 5 'echo 5' -Z 10 'echo 10' -Z 15 'echo 15' -Z 30 'echo 30')
      [[ -z $timeout ]] && exit
    elif [[ -z $mode2 ]]; then
      exit
    fi

    main "$mode1" "$mode2" "$timeout"
    ;;
esac