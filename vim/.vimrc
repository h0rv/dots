" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
            \| PlugInstall --sync | source $MYVIMRC
            \| endif
call plug#begin('~/.vim/plugged')

    Plug 'dracula/vim'
    Plug 'jiangmiao/auto-pairs'
    Plug 'chiel92/vim-autoformat'
    Plug 'preservim/nerdtree'
    Plug 'vim-airline/vim-airline'
    Plug 'tpope/vim-markdown'

call plug#end()

color dracula
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number
set nohlsearch
set noerrorbells
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set signcolumn=yes

