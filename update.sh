#!/bin/bash

wd=$(pwd)

cp ~/.vimrc $wd/vim/.vimrc

cp ~/.config/alacritty/alacritty.yml $wd/alacritty/alacritty.yml

cp ~/.config/kitty/kitty.conf $wd/kitty/kitty.conf

cp ~/.config/i3/config $wd/i3/config
cp ~/.config/i3/scripts/* $wd/i3/scripts/

cp ~/.config/gtk-3.0/settings.ini $wd/gtk/settings.ini

cp ~/.config/dunst/dunstrc $wd/dunst/dunstrc

cp ~/.config/polybar/* $wd/polybar

cp ~/.mozilla/firefox/*/chrome/userChrome.css $wd/firefox

cp -r ~/.config/nvim/* $wd/nvim/

cp ~/.config/lvim/config.lua $wd/lvim

cp ~/.config/picom/picom.conf $wd/picom

cp ~/.config/wal/colorschemes/dark/* $wd/pywal/colorschemes/dark

cp ~/.config/wal/templates/* $wd/pywal/templates
cp ~/.config/wpg/templates/* $wd/pywal/wpgtk-templates

cp ~/.config/flashfocus/* $wd/flashfocus

cp ~/.config/libinput-gestures.conf $wd/.config/

cp ~/.tmux.conf $wd/tmux/.tmux.conf

cp ~/.config/zellij/config.yaml $wd/zellij/
