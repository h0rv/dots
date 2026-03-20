#!/usr/bin/env sh

set -eu

TPM_DIR="$HOME/.tmux/plugins/tpm"
TMUX_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"
PLUGIN_DIR="$HOME/.tmux/plugins/"

if ! command -v git >/dev/null 2>&1; then
	echo "git is required" >&2
	exit 1
fi

if ! command -v tmux >/dev/null 2>&1; then
	echo "tmux is required" >&2
	exit 1
fi

if [ ! -d "$TPM_DIR" ]; then
	echo "Installing TPM..."
	git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
	echo "TPM already installed"
fi

echo "Loading tmux config..."
tmux start-server
# Make TPM's command-line installer work even when tmux wasn't already running.
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$PLUGIN_DIR"
tmux source-file "$TMUX_CONF"

echo "Installing tmux plugins from $TMUX_CONF..."
"$TPM_DIR/bin/install_plugins"

echo "Done."
echo "tmux-resurrect save:    prefix + S"
echo "tmux-resurrect restore: prefix + R"
