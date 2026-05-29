.PHONY: nvim
nvim:
	@if command -v difft >/dev/null 2>&1; then \
		echo "difftastic already installed"; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install difftastic; \
	else \
		echo "Install difftastic manually so the Neovim plugin can work (missing 'difft' binary)"; \
		exit 1; \
	fi
	nvim --headless "+qall"
