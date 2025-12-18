#!/bin/bash

# 1. Kill previous instances
killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# --- SMART DETECTION START ---

# A. Network Interface Detection (More robust)
# We look for interfaces that are NOT loopback (lo) and exist in /sys/class/net
export WIFI_INTERFACE=$(ls /sys/class/net | grep wl | head -n 1)
export ETH_INTERFACE=$(ls /sys/class/net | grep -E 'en|eth' | head -n 1)

# B. Battery Detection
# Check if a folder starting with BAT exists in /sys/class/power_supply
BATTERY_PATH=$(ls /sys/class/power_supply/ | grep BAT | head -n 1)
ADAPTER_PATH=$(ls /sys/class/power_supply/ | grep -E 'AC|ADP' | head -n 1)

if [ -z "$BATTERY_PATH" ]; then
    # -- DESKTOP MODE --
    echo "No battery detected. Loading Desktop modules..."
    export RIGHT_MODULES="pulseaudio wlan eth powermenu"
else
    # -- LAPTOP MODE --
    echo "Battery $BATTERY_PATH detected. Loading Laptop modules..."
    export RIGHT_MODULES="pulseaudio wlan eth battery powermenu"
    export BATTERY_NAME=$BATTERY_PATH
    export ADAPTER_NAME=$ADAPTER_PATH
fi

# --- SMART DETECTION END ---

# Launch the bar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload mybar &
  done
else
  polybar --reload mybar &
fi

echo "Polybar launched..."
