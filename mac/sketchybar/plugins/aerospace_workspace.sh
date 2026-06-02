#!/usr/bin/env sh

sid="${NAME#space.}"
focused="${FOCUSED_WORKSPACE:-}"

if [ -z "$focused" ] && command -v aerospace >/dev/null 2>&1; then
	focused="$(aerospace list-workspaces --focused 2>/dev/null | sed -n '1p')"
fi

if [ "$sid" = "$focused" ]; then
	sketchybar --set "$NAME" label.color=0xffd8a657
else
	sketchybar --set "$NAME" label.color=0xff7c6f64
fi
