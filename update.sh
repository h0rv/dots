#!/bin/bash

wd=$(pwd)

cp ~/.vimrc $wd/vim/.vimrc

cp ~/.config/alacritty/alacritty.yml $wd/alacritty/alacritty.yml

cp ~/.config/kitty/kitty.conf $wd/kitty/kitty.conf

cp ~/.config/i3/config $wd/i3/config
cp ~/.config/i3/i3blocks.conf $wd/i3/i3blocks.conf

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
