" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
            \| PlugInstall --sync | source $MYVIMRC
            \| endif

call plug#begin()

" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'wadackel/vim-dogrun'
Plug 'connorholyday/vim-snazzy'
Plug 'zeis/vim-kolor'
Plug 'challenger-deep-theme/vim'

" Plugins
Plug 'jiangmiao/auto-pairs'
Plug 'chiel92/vim-autoformat'
Plug 'itchyny/lightline.vim'
Plug 'tpope/vim-markdown'
Plug 'sheerun/vim-polyglot'
Plug 'uiiaoo/java-syntax.vim'
Plug 'vim-syntastic/syntastic'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'preservim/nerdtree'
    nnoremap <C-n> :NERDTreeToggle<CR>
    nnoremap <C-f> :NERDTreeFind<CR>
    " Start NERDTree when Vim is started without file arguments.
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif
    " Exit Vim if NERDTree is the only window left.
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
        \ quit | endif
Plug 'tpope/vim-commentary'
Plug 'vimsence/vimsence'

call plug#end()

colorscheme dracula
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
let g:lightline = { 'colorscheme': 'dracula', }

set encoding=utf-8
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
set fillchars+=vert:\ 
hi NonText guifg=bg 
" Ctrl-c copy in visual mode
map <C-c> "+y<CR> 

function! WinMove(key)
    let t:curwin = winnr()
    exec "wincmd ".a:key
    if (t:curwin == winnr())
        if (match(a:key,'[jk]'))
            wincmd v
        else
            wincmd s
        endif
        exec "wincmd ".a:key
    endif
endfunction

nnoremap <silent> <C-h> :call WinMove('h')<CR>
nnoremap <silent> <C-j> :call WinMove('j')<CR>
nnoremap <silent> <C-k> :call WinMove('k')<CR>
nnoremap <silent> <C-l> :call WinMove('l')<CR>

" Open pdf in vim with :Rpdf
:command! -complete=file -nargs=1 Rpdf :r !pdftotext -nopgbrk <q-args> - 

" Call compile
" Open the PDF from /tmp/"
function! Preview()
    :call Compile()<CR><CR>
    execute "! zathura /tmp/op.pdf &"
endfunction

" [1] Get the extension of the file
" [2] Apply appropriate compilation command
" [3] Save PDF as /tmp/op.pdf
function! Compile()
    let extension = expand('%:e')
    if extension == "ms"
        execute "! groff -ms % -T pdf > /tmp/op.pdf"
    elseif extension == "tex"
        execute "! pandoc -f latex -t latex % -o /tmp/op.pdf"
    elseif extension == "md"
        execute "! pandoc '%:p' -s -o /tmp/op.pdf"
    endif
endfunction

" \ + q: Compile
noremap <leader>p :call Preview()<CR><CR><CR>
" \ + p: Preview
noremap <leader>q :call Compile()<CR><CR>
