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

# nvim
backup_and_link "$DOTS_DIR/nvim" ~/.config/nvim

# tmux
backup_and_link "$DOTS_DIR/tmux" ~/.config/tmux

# ghostty
backup_and_link "$DOTS_DIR/ghostty" ~/.config/ghostty

# kitty
backup_and_link "$DOTS_DIR/kitty" ~/.config/kitty

# zsh
backup_and_link "$DOTS_DIR/zsh/.zshrc" ~/.zshrc
backup_and_link "$DOTS_DIR/zsh/.zprofile" ~/.zprofile
