export SHELL="/usr/bin/fish"
export PATH="/home/horv/.local/bin:$PATH"
export PATH="/home/horv/.cargo/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export BROWSER="firefox"
# Ruby
export GEM_HOME="$(ruby -e 'puts Gem.user_dir')"
export PATH="$PATH:$GEM_HOME/bin"
# Go
export GOPATH="$HOME/.go"
export PATH="$PATH:$GOROOT/bin:$GOPATH/bin"

# Aliases

alias vi="nvim"
alias rm="trash"
alias endash='echo — | xclip -sel clip'
if type -q exa
  alias ls "exa --icons"
  alias lls "ls"
  alias ll "exa -l -g --icons"
  alias la "exa -a"
  alias lla "ll -a"
end
alias cat="bat"
alias g="git"
alias ...="cd ..; cd .."
alias ....="...; cd .."
alias jp="jupyter"

# tmux
if not set -q TMUX
    set -g TMUX tmux new-session -d -s base
    eval $TMUX
    tmux attach-session -d -t base
end

# Zellij
# if status is-interactive
#     eval (zellij setup --generate-auto-start fish | string collect)
# end


function zathura --wraps zathura
    nohup zathura $argv &> /dev/null &
end

function p2e
  set filename (echo (string split -r -m1 . $argv)[1])
  ebook-convert $argv $filename.epub --enable-heuristics
end


# Opens web browser with URL of git remote repository
function gremote
  set remote (git remote -v | head -n 1)
  if string match '*https*' $remote
  	set repoUrl (echo $remote | awk -F " " '{print $2}')
  else
  	set repoUrl (echo $remote | awk -F "@" '{print $2}' | awk -F " " '{print $1}' | sed 's/:/\\//g' | sed 's/.git//g' | awk '{print "https://"$1}')
  end
  echo "Opening $repoUrl"
  open $repoUrl
end

if status is-interactive
    fish_vi_cursor
    fish_vi_key_bindings
end

# Fix fonts for pipes.sh and tree
export LC_ALL="en_US.UTF-8"

starship init fish | source
