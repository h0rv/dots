#!/usr/bin/env sh

label="${INFO:-}"

if [ -z "$label" ] && command -v aerospace >/dev/null 2>&1; then
	label="$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | sed -n '1p')"
fi

if [ -z "$label" ]; then
	label="Desktop"
fi

sketchybar --set "$NAME" label="$label" label.color=0xffd4be98
