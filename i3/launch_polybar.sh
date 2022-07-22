#!/usr/bin/env bash

sed -e

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Solution from https://github.com/jaagr/polybar/issues/763 to polybar in
# multiple monitors
for monitor in $(polybar --list-monitors | cut -d ":" -f 1); do
  # Launch bar1 and bar2
  MONITOR=$monitor polybar --reload --config=$HOME/.config/i3/polybar status &
done

echo "Bar status launched."
