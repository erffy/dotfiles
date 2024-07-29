#!/usr/bin/env bash

case "$@" in
  "launcher") rofi -show drun -show-icons -theme $HOME/.config/rofi/$@/style.rasi ;;
  "powermenu") $HOME/.config/rofi/$@/run.sh ;;
  *) echo "Invalid option: $@" ;;
esac