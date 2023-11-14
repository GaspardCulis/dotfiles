#!/bin/bash
ACTIVE_ICON='󰍹'
SUSPENDED_ICON='󰶐'
RESUMING_ICON='󱄄'

icon=$ACTIVE_ICON
status=$(cat /sys/bus/pci/devices/0000:01:00.0/power/runtime_status)

if [ "$status" == "suspended" ]; then
  icon=$SUSPENDED_ICON
elif [ "$status" == "resuming" ]; then
  icon=$RESUMING_ICON
fi

echo "{\"text\": \"$icon\", \"class\": \"$status\"}"

