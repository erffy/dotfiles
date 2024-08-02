#!/usr/bin/env bash

TARGET="google.com"
DNS=$(echo $(grep '^nameserver' /etc/resolv.conf | awk '{print $2}') | awk '{print "DNS" NR ": " $1}' | tr '\n' '\n')

ping_output=$(ping -c 1 $TARGET 2>/dev/null)
ping_time=$(echo $ping_output | awk -F 'time=' '/time=/ {print $2}' | awk '{print $1}')

if [[ $? -eq 0 ]]; then
  echo "{\"text\":\"   ${ping_time}ms\", \"tooltip\":\"Target: ${TARGET}\n${DNS}\"}"
else
  echo "{\"text\":\"\", \"tooltip\":\"\", \"class\":\"hidden\"}"
fi