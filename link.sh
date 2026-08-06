#!/usr/bin/env sh

set -e

DOTS_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

backup_and_link() {
	src="$1"
	dest="$2"

	if [ -e "$dest" ] && [ ! -L "$dest" ]; then
		mv "$dest" "$dest.bak"
	else
		rm -f "$dest"
	fi

	ln -s "$src" "$dest"
}

sync_pi_extension() {
	src="$1"
	dest="$2"
	tmp="${dest}.next.$$"

	rm -rf "$tmp"
	cp -R "$src" "$tmp"
	rm -rf "$dest"
	mv "$tmp" "$dest"
	echo "Synced Pi extension: $src -> $dest"
}

# nvim
backup_and_link "$DOTS_DIR/nvim" ~/.config/nvim

# tmux
backup_and_link "$DOTS_DIR/tmux" ~/.config/tmux

# ghostty
backup_and_link "$DOTS_DIR/ghostty" ~/.config/ghostty

# kitty
backup_and_link "$DOTS_DIR/kitty" ~/.config/kitty

# git
mkdir -p ~/.config/git
backup_and_link "$DOTS_DIR/git/config" ~/.config/git/config

# aerospace
mkdir -p ~/.config/aerospace
backup_and_link "$DOTS_DIR/mac/aerospace/aerospace.toml" ~/.config/aerospace/aerospace.toml

# sketchybar
backup_and_link "$DOTS_DIR/mac/sketchybar" ~/.config/sketchybar

# zsh
backup_and_link "$DOTS_DIR/zsh/.zshrc" ~/.zshrc
backup_and_link "$DOTS_DIR/zsh/.zprofile" ~/.zprofile

# pi
sh "$DOTS_DIR/pi/validate.sh"
mkdir -p ~/.pi/agent ~/.pi/agent/extensions
backup_and_link "$DOTS_DIR/pi/agent/settings.json" ~/.pi/agent/settings.json
sync_pi_extension "$DOTS_DIR/pi/agent/extensions/gondolin" ~/.pi/agent/extensions/gondolin

if [ -x "$DOTS_DIR/pi/bootstrap.sh" ] && command -v pi >/dev/null 2>&1 && command -v node >/dev/null 2>&1; then
	echo "Syncing pi packages"
	"$DOTS_DIR/pi/bootstrap.sh"
else
	echo "Skipping pi bootstrap (requires pi, node, and $DOTS_DIR/pi/bootstrap.sh)"
fi
