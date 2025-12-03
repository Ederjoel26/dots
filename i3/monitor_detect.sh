#!/bin/bash

MONITORS=$(xrandr | grep " connected" | awk '{print $1}')
MON_LIST=($MONITORS) 
COUNT=${#MON_LIST[@]}

PRIMARY_MON=""

for m in "${MON_LIST[@]}"; do
    if [[ $m == DP* ]]; then
        PRIMARY_MON=$m
        break
    fi
done

if [ -z "$PRIMARY_MON" ]; then
    for m in "${MON_LIST[@]}"; do
        if [[ $m == HDMI* ]]; then
            PRIMARY_MON=$m
            break
        fi
    done
fi

if [ -z "$PRIMARY_MON" ]; then
    PRIMARY_MON=${MON_LIST[0]}
fi

if [ $COUNT -le 1 ]; then
    echo "Modo: Monitor Único ($PRIMARY_MON)"
    xrandr --output "$PRIMARY_MON" --primary --auto --pos 0x0 --rotate normal

else
    echo "Modo: Multi-Monitor (Principal: $PRIMARY_MON)"
    
    CMD="xrandr --output $PRIMARY_MON --primary --auto --pos 0x0 --rotate normal"
    
    LAST_MON="$PRIMARY_MON"

    for m in "${MON_LIST[@]}"; do
        if [ "$m" != "$PRIMARY_MON" ]; then
            CMD="$CMD --output $m --auto --right-of $LAST_MON --rotate normal"
            LAST_MON="$m"
        fi
    done

    eval $CMD
fi

sleep 1
feh --bg-scale ~/Pictures/wallpapers/current.jpg
~/.config/polybar/launch.sh
