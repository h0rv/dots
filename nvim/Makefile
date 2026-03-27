.PHONY: nvim
nvim:
	git submodule update --init --recursive
	@if command -v difft >/dev/null 2>&1; then \
		echo "difftastic already installed"; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install difftastic; \
	else \
		echo "Install difftastic manually so the Neovim plugin can work (missing 'difft' binary)"; \
		exit 1; \
	fi
	cd pack/core/start/cursortab.nvim/server && go build -o cursortab .
