#!/usr/bin/env bash

updates=$(checkupdates --nocolor)
updates_count=$(echo "$updates" | tr -d '[:space:]' | wc -l)

if [ "$updates_count" -gt 0 ]; then
  pkg_list=$(echo "$updates" | awk '{print $1 ": " $2 " " $3 " " $4}' | paste -sd '\n' -)
  pkg_list=$(echo "$pkg_list" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

  printf '{"text":"   %d","tooltip":"You have %d pending updates.\\n\\n%s"}\n' "$updates_count" "$updates_count" "$pkg_list"
else
  echo '{"text":"","tooltip":"","class":"hidden"}'
fi