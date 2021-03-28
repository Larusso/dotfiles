#!/bin/bash

killall -q polybar

bar="${1:-$XDG_SESSION_DESKTOP}"

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar --reload "$bar" &
done
echo "Polybar launched..."