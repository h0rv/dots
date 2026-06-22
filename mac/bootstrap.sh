#!/usr/bin/env sh

set -eu

MAC_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DOTS_DIR=$(CDPATH= cd -- "$MAC_DIR/.." && pwd)

if ! command -v brew >/dev/null 2>&1; then
	echo "Homebrew is not installed."
	echo "Install it from https://brew.sh, then rerun: $MAC_DIR/bootstrap.sh"
	exit 1
fi

brew bundle --file "$MAC_DIR/Brewfile"

"$DOTS_DIR/link.sh"

if [ -x "$MAC_DIR/macos-defaults.sh" ]; then
	"$MAC_DIR/macos-defaults.sh" || true
fi

if command -v sketchybar >/dev/null 2>&1; then
	env -u TMUX brew services restart sketchybar || env -u TMUX brew services start sketchybar || true
fi

if [ -x "$DOTS_DIR/tmux/bootstrap.sh" ]; then
	"$DOTS_DIR/tmux/bootstrap.sh" || true
fi

if command -v make >/dev/null 2>&1; then
	make -C "$DOTS_DIR/nvim" nvim || true
fi

echo "Mac bootstrap complete. Restart the terminal so zsh picks up Homebrew paths and completions."
echo "Launch AeroSpace once and grant Accessibility permission if macOS prompts for it."
