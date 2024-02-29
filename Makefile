# https://dericpang.com/blog/managing-your-dotfiles-with-git-and-make
dots := bash git nvim tmux fish i3 picom polybar kitty alacritty vscode firefox
pwd  := $(shell pwd -LP)

.PHONY: $(dots)
all: 	$(dots)

bash:
		@ln -nfs "${pwd}/.bashrc" ~/.bashrc

git:
		@ln -nfs "${pwd}/.gitconfig" ~/.gitconfig

nvim:
		@ln -nfs "${pwd}/nvim" ~/.config

tmux:
		@ln -nfs "${pwd}/tmux" ~/.config

fish:
		@ln -nfs "${pwd}/fish" ~/.config

i3:
		@ln -nfs "${pwd}/i3" ~/.config

picom:
		@ln -nfs "${pwd}/picom" ~/.config

polybar:
		@ln -nfs "${pwd}/polybar" ~/.config

kitty:
		@ln -nfs "${pwd}/kitty" ~/.config

alacritty:
		@ln -nfs "${pwd}/alacritty" ~/.config

vscode:
		@ln -nfs "$(pwd)/vscode/settings.json" 	  ~/.config/VSCodium/User/settings.json
		@ln -nfs "$(pwd)/vscode/keybindings.json" ~/.config/VSCodium/User/keybindings.json
		@ln -nfs "$(pwd)/vscode/settings.json" 	  ~/.config/Code/User/settings.json
		@ln -nfs "$(pwd)/vscode/keybindings.json" ~/.config/Code/User/keybindings.json

firefox:
		@ln -nfs "${pwd}/firefox/chrome" ~/.mozilla/firefox/*-release/

