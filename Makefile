pwd  := $(shell pwd -LP)
dots := bash git nvim tmux i3 kitty vscode

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

i3:
		@ln -nfs "${pwd}/i3" ~/.config

kitty:
		@ln -nfs "${pwd}/kitty" ~/.config

vscode:
		@ln -nfs "$(pwd)/vscode/settings.json" 	  ~/.config/VSCodium/User/settings.json
		@ln -nfs "$(pwd)/vscode/keybindings.json" ~/.config/VSCodium/User/keybindings.json
		@ln -nfs "$(pwd)/vscode/settings.json" ~/.config/Code/User/settings.json
		@ln -nfs "$(pwd)/vscode/keybindings.json" ~/.config/Code/User/keybindings.json

