#!/bin/bash

# mute laptop if not muted
MUTED=$(pacmd list-sinks | awk '/muted/ { print $2 }')
if [ $MUTED = no ]
then
    pulseaudio-ctl mute
fi

# get background color from pywal
BG=$(head -n 1 ~/.cache/wal/colors)
# remove # from hex code
BG="${BG:1}

set -e
xset s off dpms 0 10 0"
i3lock-fancy
xset s off -dpms
