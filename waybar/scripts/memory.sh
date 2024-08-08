#!/usr/bin/env bash

format_size() {
  local size=$1

  if ((size >= 1024 ** 2)); then
    printf "%.2fG" "$(echo "scale=2; $size / 1024 / 1024" | bc)"
  elif ((size >= 1024)); then
    printf "%.2fM" "$(echo "scale=2; $size / 1024" | bc)"
  else
    printf "%dK" "$size"
  fi
}

convert_to_kb() {
  local value=$1
  if [[ $value == *G ]]; then
    echo "$(echo "scale=0; (${value%G} * 1024 * 1024)/1" | bc)"
  elif [[ $value == *M ]]; then
    echo "$(echo "scale=0; (${value%M} * 1024)/1" | bc)"
  elif [[ $value == *K ]]; then
    echo "${value%K}"
  fi
}

mem_info=$(free -k | awk 'NR==2{printf "{\"total\": \"%s\", \"used\": \"%s\", \"free\": \"%s\", \"shared\": \"%s\", \"buff/cache\": \"%s\", \"available\": \"%s\"}", $2, $3, $4, $5, $6, $7}')
mem_swap_info=$(free -k | awk 'NR==3{printf "{\"total\": \"%s\", \"used\": \"%s\", \"free\": \"%s\"}", $2, $3, $4}')

mem_usage=$(format_size $(echo $mem_info | jq -r '.used'))
mem_total=$(format_size $(echo $mem_info | jq -r '.total'))
mem_free=$(format_size $(echo $mem_info | jq -r '.free'))
mem_shared=$(format_size $(echo $mem_info | jq -r '.shared'))
mem_cache=$(format_size $(echo $mem_info | jq -r '."buff/cache"'))
mem_available=$(format_size $(echo $mem_info | jq -r '.available'))

mem_swap_usage=$(format_size $(echo $mem_swap_info | jq -r '.used'))
mem_swap_total=$(format_size $(echo $mem_swap_info | jq -r '.total'))
mem_swap_free=$(format_size $(echo $mem_swap_info | jq -r '.free'))

total_usage=$(format_size $(echo "$(convert_to_kb $mem_usage) + $(convert_to_kb $mem_swap_usage)" | bc))

echo "{\"text\":\"  ${total_usage}\", \"tooltip\":\"Total: ${mem_total}\nFree: ${mem_free}\nAvailable: ${mem_available}\nShared: ${mem_shared}\nBuffer/Cache: ${mem_cache}\n\nSwap Total: ${mem_swap_total}\nSwap Free: ${mem_swap_free}\nSwap Used: ${mem_swap_usage}\"}"