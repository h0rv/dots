" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
		\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif
" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
    \| PlugInstall --sync | source $MYVIMRC
    \| endif

call plug#begin('~/.local/share/nvim/plugged')

	Plug 'metakirby5/codi.vim'
    Plug 'vim-python/python-syntax'
    Plug 'morhetz/gruvbox'
    Plug 'arcticicestudio/nord-vim'
    Plug 'dylanaraps/wal.vim'

call plug#end()

"Faster ESC.
inoremap jk <ESC>
inoremap kj <ESC>

colorscheme nord
set termguicolors
set background=dark

set encoding=UTF-8
set tabstop=4 softtabstop=4
set encoding=utf-8
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set number

