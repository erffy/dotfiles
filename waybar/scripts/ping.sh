#!/usr/bin/env bash

# Target for ping
TARGET="google.com"

# Function to perform the ping and extract latency
get_ping_time() {
  local ping_output
  local ping_time

  # Run the ping command and capture the output
  ping_output=$(ping -c 1 "$TARGET" 2>/dev/null)

  # Check if the ping command was successful
  if [[ $? -eq 0 ]]; then
    # Extract the ping time using awk for cleaner processing
    ping_time=$(echo "$ping_output" | awk -F 'time=' '/time=/ {print $2}' | awk '{print $1}')
    echo "${ping_time}ms"
  else
    # If ping fails, return a empty output
    echo ""
  fi
}

# Call the function and output the result
get_ping_time