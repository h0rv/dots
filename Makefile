pwd := $(shell pwd -LP)
.PHONY: bash
all: bash git

bash:
		@ln -nfs "${pwd}/.bashrc" ~/.bashrc

git:
		@ln -nfs "${pwd}/.gitconfig" ~/.gitconfig

nvim:
		@ln -nfs "${pwd}/nvim" ~/.config/nvim
