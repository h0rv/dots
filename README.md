# dotfiles

Neovim + tmux config. Designed to feel like one unified tool.

## tmux

Prefix is `C-Space` (Ctrl+Space).

| Key | Action |
|-----|--------|
| `C-Space r` | Reload tmux config |
| `C-Space \|` | Split horizontal |
| `C-Space -` | Split vertical |
| `C-Space t` | New window |
| `C-Space n/p` | Next/prev window |
| `C-Space H/J/K/L` | Resize pane |
| `C-Space b` | Toggle status bar |
| `C-Space Escape` | Enter copy mode (vi keys, `v` select, `y` yank) |
| `C-Space C-l` | Clear terminal (since Ctrl+L is navigation) |
| `C-Space Space` | Cycle through layouts |
| `C-Space z` | Zoom/unzoom current pane |
| `C-Space =` | Balance panes (tiled) |
| `C-Space M-1` | Main-vertical (big left, stacked right) |
| `C-Space M-2` | Main-horizontal (big top, stacked bottom) |
| `C-Space M-3` | Tiled (equal grid) |
| `C-Space M-4` | Equal columns |
| `C-Space M-5` | Equal rows |

## Navigation (tmux + neovim)

`Ctrl+h/j/k/l` moves seamlessly between neovim splits and tmux panes. No prefix needed. If you're in neovim with two splits and a tmux pane to the right, `Ctrl+l` goes from neovim split -> neovim split -> tmux pane automatically.

Since `Ctrl+L` is taken by navigation, use `C-Space C-l` to clear the terminal instead.

## Neovim

Leader is `Space`.

### Files & Search

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Resume last picker |
| `<leader>fp` | Find files (current package - auto-detected) |
| `<leader>fP` | Grep (current package) |
| `<leader>fd` | Find files in subdirectory (prompts for path) |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |

### Explorer

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file explorer |
| `<leader>o` | Reveal current file in explorer |

### Buffers

| Key | Action |
|-----|--------|
| `Tab` / `S-Tab` | Next / previous buffer |
| `<leader>1-9` | Jump to buffer N |
| `<leader>bd` | Delete buffer |
| `<leader>bD` | Delete all buffers |

### Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Lazygit |
| `<leader>gd` | Diff open (working changes) |
| `<leader>gm` | Diff vs main |
| `<leader>gc` | Close diff |
| `<leader>gB` | Open file on GitHub |

### Session

| Key | Action |
|-----|--------|
| `<leader>qs` | Restore session (current dir) |
| `<leader>qS` | Select session |
| `<leader>qd` | Stop auto-saving session |

Sessions auto-save on exit and auto-restore when you open `nvim` with no arguments.

### LSP Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to definition (snacks picker) |
| `gr` | References (snacks picker) |
| `gi` | Implementation (snacks picker) |
| `gy` | Type definition (snacks picker) |
| `gD` | Declaration |
| `K` | Hover docs |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Prev / next diagnostic |
| `<leader>dd` | All diagnostics (snacks picker) |

### Flash (in-file teleport)

| Key | Action |
|-----|--------|
| `s` | Flash jump - type 2 chars, pick a label, teleport |
| `S` | Flash treesitter - select treesitter nodes |

### General

| Key | Action |
|-----|--------|
| `jk` or `kj` | Escape (insert mode) |
| `<leader>w` | Write file |
| `<leader>f` | Format file |
| `<leader>;` | Floating terminal |

## Monorepo Tips

- `<leader>fp` auto-detects the nearest package (by `package.json`, `Cargo.toml`, `pyproject.toml`, `go.mod`, `mix.exs`) and scopes file search there
- `<leader>fP` does the same but for grep
- `<leader>fd` lets you manually type a subdir path for one-off searches
- `<leader>ff` / `<leader>fg` always search from the git root

## Plugins

snacks.nvim, persistence.nvim, nvim-tmux-navigation, diffview.nvim, which-key.nvim, tokyonight.nvim, nvim-treesitter, nvim-lint, nvim-web-devicons, flash.nvim
