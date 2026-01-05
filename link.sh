#!/usr/bin/env sh

set -e

# nvim
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
ln -s "$(pwd)/nvim" ~/.config/nvim 2>/dev/null || true

# tmux
mv ~/.config/tmux ~/.config/tmux.bak 2>/dev/null || true
ln -s "$(pwd)/tmux" ~/.config/tmux 2>/dev/null || true
