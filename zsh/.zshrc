PROMPT='%1~%f ❯ '

export KEYTIMEOUT=1
setopt NO_NOTIFY

HISTFILE="$HOME/.zsh_history"
HISTSIZE=200000
SAVEHIST=200000
setopt HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS HIST_IGNORE_SPACE INC_APPEND_HISTORY EXTENDED_HISTORY

export EDITOR='nvim'
export GOPATH="$HOME/.go"
export CLAUDE_CODE_MAX_OUTPUT_TOKENS=16284
export GONDOLIN_COMMAND_PREFIXES='[["jira"]]'

is_macos=0
if [[ "$OSTYPE" == darwin* ]]; then
  is_macos=1
fi

# secrets
source ~/.secrets

# uv / python
export UV_KEYRING_PROVIDER=subprocess
export UV_INDEX_ANATOMY_PYTHON_USERNAME=oauth2accesstoken

export FZF_DEFAULT_OPTS='
  --style=minimal
  --height=40%
  --reverse
  --border=none
  --pointer="▶"
  --marker="✓"
  --prompt="❯ "
  --no-separator
'
export FZF_CTRL_R_OPTS='--border-label=" history " --border=rounded --preview-window=hidden'

typeset -U path PATH fpath

if [[ "$OSTYPE" == darwin* ]] && [[ -d /opt/homebrew/share/zsh/site-functions ]]; then
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
fi

add_path() {
  [[ -d "$1" ]] && path=("$1" $path)
}

add_path "$HOME/.bun/bin"
add_path "$GOPATH/bin"
add_path "/usr/local/bin"
add_path "$HOME/.local/bin"
add_path "$HOME/bin"

if (( is_macos )); then
  add_path "/opt/homebrew/opt/postgresql@17/bin"
fi

if [[ -o interactive ]] && [[ -z "$TMUX" ]] && [[ -z "$HERDR_ENV" ]] && [[ -z ${ZSH_EXECUTION_STRING-} ]] && command -v tmux >/dev/null 2>&1; then
  tmux_start_dir="$PWD"
  if [[ -z "$tmux_start_dir" || "$tmux_start_dir" == / ]]; then
    tmux_start_dir="$HOME"
  fi
  if tmux has-session -t base 2>/dev/null; then
    tmux attach-session -t base
  else
    tmux new-session -s base -c "$tmux_start_dir"
  fi
fi

if command -v just >/dev/null 2>&1; then
  just_bin="$(command -v just)"
  just_completion="$HOME/.zfunc/_just"
  mkdir -p "$HOME/.zfunc"
  if [[ ! -s "$just_completion" || "$just_bin" -nt "$just_completion" ]]; then
    just --completions zsh >| "$just_completion" 2>/dev/null
  fi
  fpath=("$HOME/.zfunc" $fpath)
fi

zstyle ':completion:*' menu select
autoload -Uz compinit
compinit -C

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if command -v trash >/dev/null 2>&1; then
  alias rm='trash'
fi
alias g='git'
alias lg='lazygit'
alias vi='nvim'
alias tf='terraform'
alias k='kubectl'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias python='python3'
alias svenv='source .venv/bin/activate'
alias c='claude'
alias cr='claude --resume'
alias j='just'
alias jc='just --choose'

# My open (not Done/Aborted) Jira issues as a tree, with clickable links (OSC 8).
# Usage: jmine [extra `jira issue list` flags, e.g. -p IN]
jmine() {
  local data
  data=$(jira issue list -a"$(jira me)" -s~Done -s~Aborted --raw "$@") || return
  JMINE_DATA="$data" python3 <<'JMINE_PY'
import os, json
BASE = "https://anatomy.atlassian.net/browse"
R = "\033[0m"
def link(k):  # OSC 8 hyperlink on a bold-blue key
    return f"\033]8;;{BASE}/{k}\033\\\033[1;34m{k}\033[0m\033]8;;\033\\"
def col(s):
    s = s.lower()
    if any(x in s for x in ("progress", "build", "review")): return "\033[33m"
    if "backlog" in s: return "\033[90m"
    if "done" in s:    return "\033[32m"
    return "\033[36m"
nodes = {}
for i in json.loads(os.environ["JMINE_DATA"]):
    f = i["fields"]
    nodes[i["key"]] = {"key": i["key"], "summary": f["summary"],
                       "status": f["status"]["name"],
                       "parent": (f.get("parent") or {}).get("key"), "kids": []}
roots = []
for n in nodes.values():
    p = n["parent"]
    (nodes[p]["kids"] if p in nodes else roots).append(n)
def num(n):
    try: return int(n["key"].split("-")[1])
    except Exception: return 0
def render(n, prefix="", last=True, top=False):
    conn = "" if top else ("└─ " if last else "├─ ")
    st = n["status"]
    print(f"{prefix}{conn}{link(n['key'])}  {col(st)}{st:<12}{R} {n['summary']}")
    kids = sorted(n["kids"], key=num)
    cp = prefix + ("" if top else ("   " if last else "│  "))
    for j, k in enumerate(kids):
        render(k, cp, j == len(kids) - 1)
roots.sort(key=num)
for j, r in enumerate(roots):
    render(r, "", j == len(roots) - 1, top=True)
JMINE_PY
}

if (( is_macos )); then
  export CLICOLOR=1
  alias ll='ls -lhG'
  alias la='ls -lhAG'
else
  alias ll='ls -lh --color=auto'
  alias la='ls -lhA --color=auto'
fi

function y() {
  local tmp cwd

  tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return 1
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  if [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

if [[ -o interactive && -z ${ZSH_EXECUTION_STRING-} ]]; then
  bindkey -v

  if (( is_macos )) && [[ -r /opt/homebrew/opt/fzf/shell/completion.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.zsh
  fi

  if (( is_macos )) && [[ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  fi

  autoload -U history-search-end
  zle -N history-beginning-search-backward-end history-search-end
  zle -N history-beginning-search-forward-end history-search-end
  bindkey '^[[A' history-beginning-search-backward-end
  bindkey '^[[B' history-beginning-search-forward-end
  bindkey '^P' history-beginning-search-backward-end
  bindkey '^N' history-beginning-search-forward-end

  if [[ -r "$HOME/.local/share/zinit/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.local/share/zinit/plugins/zsh-users---zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi

  if [[ -r "$HOME/.local/share/zinit/plugins/zsh-users---zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.local/share/zinit/plugins/zsh-users---zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi

  bindkey '^L' clear-screen
fi

source <(mani completion zsh)

mdfmt() { uvx --with mdformat-gfm mdformat --wrap no --number "$@"; }
