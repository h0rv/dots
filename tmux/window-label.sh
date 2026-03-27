#!/usr/bin/env sh

path="$1"

if [ -z "$path" ] || [ ! -d "$path" ]; then
	echo "shell"
	exit 0
fi

name=$(basename "$path")
branch=$(git -C "$path" symbolic-ref --quiet --short HEAD 2>/dev/null || git -C "$path" rev-parse --short HEAD 2>/dev/null || true)

if [ -n "$branch" ]; then
	printf '%s · %s\n' "$name" "$branch"
else
	printf '%s\n' "$name"
fi
