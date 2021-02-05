call plug#begin('~/.vim/plugged')

    Plug 'preservim/nerdtree' |
        \ Plug 'Xuyuanp/nerdtree-git-plugin'
    
    Plug 'dracula/vim'

    Plug 'Valloric/YouCompleteMe'

    Plug 'scrooloose/syntastic'

    Plug 'jiangmiao/auto-pairs'

    Plug 'chiel92/vim-autoformat'

    Plug 'itchyny/lightline.vim'

call plug#end()

color dracula
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:lightline = {
            \ 'colorscheme': 'dracula',
            \ }

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

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
set laststatus=2
set noshowmode
