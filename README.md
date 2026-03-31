# dotfiles

Neovim + tmux config. Designed to feel like one unified tool.

## tmux

Prefix is `C-Space` (Ctrl+Space).

### Bootstrap

Install tmux plugins (including TPM + tmux-resurrect):

```sh
~/.config/tmux/bootstrap.sh
```

### Session restore

| Key | Action |
|-----|--------|
| `C-Space s` or `C-Space S` | Save tmux session with tmux-resurrect |
| `C-Space r` or `C-Space R` | Restore tmux session with tmux-resurrect |

`tmux-continuum` is also enabled, so tmux auto-saves every 5 minutes and restores the last saved session when tmux starts.

| Key | Action |
|-----|--------|
| `C-Space r` | Reload tmux config |
| `C-Space \|` | Split horizontal |
| `C-Space -` | Split vertical |
| `C-Space t` | New window |
| `C-Space h/l` | Prev / next window (repeatable: `C-Space l l l`) |
| `C-Space n/p` | Next/prev window |
| `C-Space 1-9` | Jump directly to window number |
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

Window labels in the tmux status bar are centered and show:
- window number
- current directory basename

The current pane's git branch is shown separately on the bottom right when available.

## Neovim

Leader is `Space`.

Run `make -C ~/.dots/nvim nvim` after linking/bootstrap. That now also ensures the `difft` CLI from `difftastic` is installed via Homebrew when available.

Useful review commands:
- `:PRReview` — GitHub-style review against the detected base branch
- `:PRReview main` — GitHub-style review against `main`/`origin/main`
- `:PRReviewDifftastic` — structural review via `difft`
- `:PRReviewClose` — close the current diff/review

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
| `<leader>gm` | Review current branch vs `main`/`origin/main` |
| `<leader>gp` | Review current branch like a PR (auto-detect base branch) |
| `<leader>gt` | Structural PR review with difftastic |
| `<leader>gf` | Toggle changed files in review |
| `<leader>gr` | Refresh review |
| `<leader>gc` | Close diff/review |
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

snacks.nvim, persistence.nvim, nvim-tmux-navigation, diffview.nvim, difftastic.nvim, which-key.nvim, tokyonight.nvim, nvim-treesitter, nvim-lint, nvim-web-devicons, plenary.nvim, flash.nvim

## Pi

Tracked Pi files live under `pi/agent/` and only include non-sensitive bootstrap/config files:

- `pi/agent/settings.json`
- `pi/agent/pi-permissions.jsonc`

Excluded from the repo:

- `~/.pi/agent/auth.json`
- `~/.pi/agent/mcp-oauth/`
- `~/.pi/agent/sessions/`

### Bootstrap

Install the Pi packages declared in `pi/agent/settings.json`:

```sh
~/.dots/pi/bootstrap.sh
```

This also applies a local patch to `pi-permission-system` so skill loads do not get blocked when Pi has no active agent context.

### Link config

`./link.sh` links the tracked Pi config files into `~/.pi/agent/` and, when `pi` + `node` are available, also runs `pi/bootstrap.sh` so package installs and the local `pi-permission-system` patch stay in sync automatically.
