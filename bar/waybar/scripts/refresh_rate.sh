#!/bin/bash

refresh_rate=$(hyprctl -j monitors | jq '.[0].refreshRate | round')
class="overdrive"
if [ "$refresh_rate" == "60" ]; then
  class=normal
fi

if [ "$1" == "toggle" ]; then
  if [ "$refresh_rate" == "60" ]; then
    hyprctl keyword monitor eDP-1,2560x1440@165,auto,1
  else
    hyprctl keyword monitor eDP-1,2560x1440@60,auto,1
  fi
fi

echo "{\"text\": \"$refresh_rate\", \"class\": \"$class\"}"
