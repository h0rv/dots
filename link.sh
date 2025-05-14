#!/usr/bin/env sh

set -e

if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.bak
fi

ln -s "$(pwd)/nvim" ~/.config
