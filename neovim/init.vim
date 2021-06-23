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

" Themes
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'wadackel/vim-dogrun'
Plug 'connorholyday/vim-snazzy'
Plug 'zeis/vim-kolor'
Plug 'challenger-deep-theme/vim'
Plug 'dylanaraps/wal.vim'
Plug 'folke/lsp-colors.nvim'
Plug 'savq/melange'
" Plugin
Plug 'itchyny/lightline.vim'
Plug 'davidhalter/jedi-vim'
Plug 'kyazdani42/nvim-tree.lua'
    nnoremap <C-n> :NvimTreeToggle<CR>
    nnoremap <leader>r :NvimTreeRefresh<CR>
    nnoremap <leader>n :NvimTreeFindFile<CR>
    " Exit Vim if NERDTree is the only window left.
    autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NvimTree') && b:NvimTree.isTabTree() |
    \ quit | endif
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'sheerun/vim-polyglot'
Plug 'w0rp/ale'
Plug 'yggdroot/indentline'
" Plug 'uiiaoo/java-syntax.vim'
Plug 'glepnir/dashboard-nvim'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'jiangmiao/auto-pairs'
Plug 'luochen1990/rainbow'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'folke/trouble.nvim'
Plug 'romgrk/barbar.nvim'
    " Move to previous/next
    nnoremap <silent>    <A-h> :BufferPrevious<CR>
    nnoremap <silent>    <A-l> :BufferNext<CR>
    " Re-order to previous/next
    nnoremap <silent>    <A-,> :BufferMovePrevious<CR>
    nnoremap <silent>    <A-.> :BufferMoveNext<CR>
    " Goto buffer in position...
    nnoremap <silent>    <A-1> :BufferGoto 1<CR>
    nnoremap <silent>    <A-2> :BufferGoto 2<CR>
    nnoremap <silent>    <A-3> :BufferGoto 3<CR>
    nnoremap <silent>    <A-4> :BufferGoto 4<CR>
    nnoremap <silent>    <A-5> :BufferGoto 5<CR>
    nnoremap <silent>    <A-6> :BufferGoto 6<CR>
    nnoremap <silent>    <A-7> :BufferGoto 7<CR>
    nnoremap <silent>    <A-8> :BufferGoto 8<CR>
    nnoremap <silent>    <A-9> :BufferLast<CR>
    " Close buffer
    nnoremap <silent>    <A-c> :BufferClose<CR>
    " Wipeout buffer
    "                          :BufferWipeout<CR>
    " Close commands
    "                          :BufferCloseAllButCurrent<CR>
    "                          :BufferCloseBuffersLeft<CR>
    "                          :BufferCloseBuffersRight<CR>
    " Magic buffer-picking mode
    nnoremap <silent> <C-s>    :BufferPick<CR>
    " Sort automatically by...
    nnoremap <silent> <Space>bd :BufferOrderByDirectory<CR>
    nnoremap <silent> <Space>bl :BufferOrderByLanguage<CR>
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
Plug 'uiiaoo/java-syntax.vim'
Plug 'iamcco/markdown-preview.vim'

call plug#end()

colorscheme wal
if g:colors_name !=# 'wal'
    set termguicolors
endif
let g:lightline = { 'colorscheme': 'wal', }
highlight link javaDelimiter NONE

let bufferline = get(g:, 'bufferline', {})
" Configure icons on the bufferline.
highlight buffer_current guibg=red
let bufferline.icon_separator_active = ''
let bufferline.icon_separator_inactive = ''
let bufferline.icon_close_tab = ''
let bufferline.icon_close_tab_modified = ''

set encoding=UTF-8
set tabstop=4 softtabstop=4
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
" Ctrl-c copy in visual mode
map <C-c> "+y<CR>

" Ctrl+h,j,k,l window navigation
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
    if extension == "tex"
        execute "! pandoc -f latex -t latex % -o /tmp/op.pdf"
    elseif extension == "md"
        execute "! pandoc '%:p' -s -o /tmp/op.pdf"
    endif
endfunction

" \ + q: Compile
noremap <leader>p :call Preview()<CR><CR><CR>
" \ + p: Preview
noremap <leader>q :call Compile()<CR><CR>

" Coc Settings
" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
if has("nvim-0.5.0") || has("patch-8.1.1564")
  " Recently vim can merge signcolumn and number column into one
  set signcolumn=number
else
  set signcolumn=yes
endif

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif


" Start Dashboard when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | Dashboard | endif
let g:mapleader="\<Space>"
let g:dashboard_default_executive = 'telescope'
nmap <Leader>ss :<C-u>SessionSave<CR>
nmap <Leader>sl :<C-u>SessionLoad<CR>
nnoremap <silent> <Leader>fh :DashboardFindHistory<CR>
nnoremap <silent> <Leader>ff :DashboardFindFile<CR>
nnoremap <silent> <Leader>tc :DashboardChangeColorscheme<CR>
nnoremap <silent> <Leader>fa :DashboardFindWord<CR>
nnoremap <silent> <Leader>fb :DashboardJumpMark<CR>
nnoremap <silent> <Leader>cn :DashboardNewFile<CR>
let g:indentLine_fileTypeExclude = ['dashboard']

" let g:dashboard_custom_header = [
" \ '',
" \ '',
" \ '',
" \ '',
" \ '',
" \ '',
" \ ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
" \ ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
" \ ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
" \ ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
" \ ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
" \ ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
" \ '',
" \ '',
" \]

" let g:dashboard_custom_header = [
" \ ' . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .,---,. . . . . . . . . . . . . . . . . . . . . . .',
" \ ' . . . . . . . . . . . . . . . . . . . . . . . . . ,,,-- - - - - -‘`::::::|. . . . . . . . . . . . . . . . . . . . . .',
" \ ' . . . . . . . . . . . . . . . . . . . |`¯¯¯¯-`:::::::::::::::::::::::,,| . . . . . . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . . . . . \::::::::::::::::::::::::::::::,--,:`, . . . . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . . . . . .\,-:::::, , ,:::::::::::::: ./¯) `)\ . . . . . . . . . . . . . . . . . . . . .',
" \ ' . . . . . . . . . . . . . . . . . . . . /::::,/¯) .\::::::::::::::|¯. ,/`’:/’. . . . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . . . . . .’,::::( ¯’__|::::::::::::::¯¯:,-` . . . . . . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . . . . . . `-,:::¯¯::::::::::::::::::::,’-`. . . . . . . . . . . . . . . . . . . . . . .',
" \ ' . . . . . . . . . . . . . . . . . . . . . . `’ ‘ -,- - -- ,, ::::,,-`. . . . . . . . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . . . . . . . . . . . |’::::::::::¯:\,, . . . . . . . . . . . . . .,--,--,. . . . . . . .',
" \ ' . . . ,--`’::,`,’::` ‘ -,,. . . . . . . . . . . ./::::`-,`-¯\`-::`\. . . . . . . . . . . . . .,/`:::/`:/). . . . . ..',
" \ ' . .,-`::,-`’ . . `.`’ - ,:`’-, . . . . . . . . .|::-,::|::’`:’::|:::,\,. . ,,- - ,, . . . . . ./`:::::::`-‘`. . . . .',
" \ ' . ,/::/`. . . . . . . . . `’-,:`’-,. . . . . . .|:::::`|::::::::|,-,’::`’`-,,:::::`’,. . . .,/`:::::::,/`. . . . . ..',
" \ ' . |::|. . . . . . . . . . . . .`-,:`’-, . . . . .\::::,-\::::,,::\`’-,::::::::`-,:::::\. .,/:,-‘`/:/`. . . . . . . ..',
" \ ' . \:::|. . . . . . . . . . . . . .`’-,:`’-,, . . .\::,`::\:::\.\::\:::`,:::::::::):::::\./:::/,/`/` . . . . . . . . .',
" \ ' . `\::\. . . . . . . . . . . . . . . .`’-,:::` ’- -\,|::::\:::\,|::\::::`::::::::/::::-`:::::,-` . . . . . . . . . ..',
" \ ' . . \:::\. . . . . . . . . . . . . . . . . .`’’- -,,:`\:::::\::::::::\:::::::::,/:::::::::,-` . . . . . . . . . . . .',
" \ ' . . .`,::\, . . . . . . . . . . . . . . . . . . . . . ¯’`-,:::\:::::::\::::,-`¯¯`-,_,-`. . . . . . . . . . . . . . ..',
" \ ' . . . .`\::`\ . . . . . . . . . . . . . . . . . . . . . . . .`’’\.:::::|``’ . . . . . . . . . . . . . . . . . . . . .',
" \ ' . . . . . `-,:`-,. . . . . . . . . . . . . . . . . . . . . . . . .`’--‘ . . . . . . . . . . . . . . . . . . . . . . .',
" \ ' . . . . . . .`’-,:`’-, . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . .`’-,:`’-,, . . . . . . . . . . . . . . . . . . . . . . . . . . . , , - - - - ,,. . . . . . . . . . .',
" \ ' . . . . . . . . . . . .`’--,`:`--, . . . . . . . . . . . . . . . . .,,-- ` ’¯ ::::::::::::::,-`. . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . ` ’--,`:’ ‘---, , . . . . . . . . ,-‘`:::::::::::::::::::,,-‘’` . . . . . . . . . . . .',
" \ ' . . . . . . . . . . . . . . . . . . . .` ’ ‘--- ,`, ¯¯ ¯ ¯¯:::::::::::, , --- -‘`’ . . . . . . . . . . . . . . . . ..',
" \ ' . . . . . . . . . . . . . . . . . . . . . . . . . . ¯ ¯¯ ¯ ¯ ¯ . . . . . . . . . . . . . . . . . . . . . . . . . . ..',
" \]

" let g:dashboard_custom_header = [
"     \ '                                                            ,---, ',
"     \ '                                            ,,,-- - - - - -‘`:     | ',
"     \ '                                    |`¯¯¯¯-`                      ,,| ',
"     \ '                                    \                         ,--,:`, ',
"     \ '                                     \,-     ,,,            ./¯¯) `)\ ',
"     \ '                                      /    ,/¯) .\          |¯¯. ,/`’/’ ',
"     \ '                                     ’,    ( ¯’__|           ¯¯¯   ,-` ',
"     \ '                                      `-,   ¯¯                   ,’-` ',
"     \ '                                         `’ ‘ -,- - -- ,,    ,,-` ',
"     \ '          _  _  _                               |’        :¯¯:\,,                               ,--,--, ',
"     \ '    ,--`’ _,`,’__` ‘ -,,                       /    `-,`-¯\`-    `\                          ,/`   /` /) ',
"     \ ' ,-`  ,-`’  `  ` `’ - ,:`’-,                  |  -,  |  ’`:’  |   ,\,. . ,,- -,,            /`       `-‘` ',
"     \ ',/  /`                  `’-,:`’-,             |     `|        |,-,’  `’`-,,     `’,      ,/`       ,/` ',
"     \ '|  |                         `-,:`’-,          \   :,-\   :,,  \`’-,        `-,    \   ,/  ,‘`/   /` ',
"     \ '\   |                           `’-,:`’-,,      \  ,`  \   \.\  \   `,         )    \./   /,/` /` ',
"     \ '`\  \                               `’-,   ` ’- -\,|   :\   \,|  \   :`        /   :-`     ,-` ',
"     \ '  \   \                                   `’’- -,,:`\     \        \         ,/       ,-` ',
"     \ '   `,  \,                                           ¯’`-,   \      :\   :,-`¯¯`-,_,-` ',
"     \ '     `\  `\                                                `’’\.     |``’ ',
"     \ '        `-,:`-,                                                .`’--‘ ',
"     \ '           `’-,:`’-,               ',
"     \ '               `’-,:`’-,,                                           _, , - - - - ,, ',
"     \ '                     `’--,`:`--,                           ,,--` ’¯¯            ,-` ',
"     \ '                            ` ’--,`:’ ‘---, ,          ,-‘`              ,,-‘’` ',
"     \ '                                   ` ’ ‘--- ,`,¯¯¯ ¯ ¯¯     _,, --- -‘`’ ',
"     \]

" let g:dashboard_custom_header = [
"    \'                             ',
"    \'           ░░░░░░░           ',
"    \'      ░░░░░░░░░░░░░░░░░      ',
"    \'    │░░░░░░░░░░░░░░░░░░░│    ',
"    \'    │░░░░░░░░░░░░░░░░░░░│    ',
"    \'   ░└┐░░░░░░░░░░░░░░░░░┌┘░   ',
"    \'   ░░└┐░░░░░░░░░░░░░░░┌┘░░   ',
"    \'   ░░┌┘     ░░░░░     └┐░░   ',
"    \'    ░│       ░░░       │░    ',
"    \'    ░│      ░░ ░░      │░    ',
"    \'    ─┘░░░░░░░   ░░░░░░░└─    ',
"    \'    ░░░    ░░   ░░    ░░░    ',
"    \'      ─┘   ░░░░░░░   └─      ',
"    \'      ░░  ─┬┬┬┬┬┬┬─  ░░      ',
"    \'      ░░░ ┬┼┼┼┼┼┼┼┬ ░░░      ',
"    \'       ░░░└┴┴┴┴┴┴┴┘░░░       ',
"    \'         ░░░░░░░░░░░         ',
"    \'                             ',
"    \ ]

" let g:dashboard_custom_header = [
"     \ '                  ."-,.__ ',
"     \ '                  `.     `.  , ',
"     \ '               .--''  .._,''"-'' `. ',
"     \ '              .    .''         `'' ',
"     \ '              `.   /          ,'' ',
"     \ '                `  ''--.   ,-"'' ',
"     \ '                 `"`   |  \ ',
"     \ '                    -. \, | ',
"     \ '                     `--Y.''      ___. ',
"     \ '                          \     L._, \ ',
"     \ '                _.,        `.   <  <\                _ ',
"     \ '              ,'' ''           `, `.   | \            ( ` ',
"     \ '           ../, `.            `  |    .\`.           \ \_ ',
"     \ '          ,'' ,..  .           _.,''    ||\l            )  ''". ',
"     \ '         , ,''   \           ,''.-.`-._,''  |           .  _._`. ',
"     \ '       ,'' /      \ \        `'' '' `--/   | \          / /   ..\ ',
"     \ '     .''  /        \ .         |\__ - _ ,''` `        / /     `.`. ',
"     \ '     |  ''          ..         `-...-"  |  `-''      / /        . `. ',
"     \ '     | /           |L__           |    |          / /          `. `. ',
"     \ '    , /            .   .          |    |         / /             ` ` ',
"     \ '   / /          ,. ,`._ `-_       |    |  _   ,-'' /               ` \ ',
"     \ '  / .           \"`_/. `-_ \_,.  ,''    +-'' `-''  _,        ..,-.    \`. ',
"     \ ' .  ''         .-f    ,''   `    ''.       \__.---''     _   .''   ''     \ \ ',
"     \ ' '' /          `.''    l     .'' /          \..      ,_|/   `.  ,''`     L` ',
"     \ ' |''      _.-""` `.    \ _,''  `            \ `.___`.''"`-.  , |   |    | \ ',
"     \ ' ||    ,''      `. `.   ''       _,...._        `  |    `/ ''  |   ''     .| ',
"     \ ' ||  ,''          `. ;.,.---'' ,''       `.   `.. `-''  .-'' /_ .''    ;_   || ',
"     \ ' || ''              V      / /           `   | `   ,''   ,'' ''.    !  `. || ',
"     \ ' ||/            _,-------7 ''              . |  `-''    l         /    `|| ',
"     \ ' . |          ,'' .-   ,'' ||               | .-.        `.      .''     || ',
"     \ '  `''        ,''    `".''    |               |    `.        ''. -.''       `'' ',
"     \ '           /      ,''      |               |,''    \-.._,.''/'' ',
"     \ '           .     /        .               .       \    .'''' ',
"     \ '         .`.    |         `.             /         :_,''.'' ',
"     \ '           \ `...\   _     ,''-.        .''         /_.-'' ',
"     \ '            `-.__ `,  `''   .  _.>----''''.  _  __  / ',
"     \ '                 .''        /"''          |  "''   ''_ ',
"     \ '                /_|.-''\ ,".             ''.''`__''-( \ ',
"     \ '                  / ,"''"\,''               `/  `-.|"  ',
"     \]

" let g:dashboard_custom_header = [
"     \'               ...                            ',
"     \'             ;::::;                           ',
"     \'           ;::::; :;                          ',
"     \'         ;:::::''   :;                         ',
"     \'        ;:::::;     ;.                        ',
"     \'       ,:::::''       ;           OOO\         ',
"     \'       ::::::;       ;          OOOOO\        ',
"     \'       ;:::::;       ;         OOOOOOOO       ',
"     \'      ,;::::::;     ;''         / OOOOOOO      ',
"     \'    ;:::::::::`. ,,,;.        /  / DOOOOOO    ',
"     \'  .'';:::::::::::::::::;,     /  /     DOOOO   ',
"     \' ,::::::;::::::;;;;::::;,   /  /        DOOO  ',
"     \';`::::::`''::::::;;;::::: ,#/  /          DOOO ',
"     \':`:::::::`;::::::;;::: ;::#  /            DOOO',
"     \'::`:::::::`;:::::::: ;::::# /              DOO',
"     \'`:`:::::::`;:::::: ;::::::#/               DOO',
"     \' :::`:::::::`;; ;:::::::::##                OO',
"     \' ::::`:::::::`;::::::::;:::#                OO',
"     \' `:::::`::::::::::::;'':;::#                O ',
"     \'  `:::::`::::::::;''/  / `:#                  ',
"     \'   ::::::`:::::;''  /  /   `#                  ',
"     \]


let g:dashboard_custom_header = [
    \'                    ▄▄▄▄▄▄▀▄            ',
    \'            ▄▄▄▓▓▓▀▀        ▀█▄         ',
    \'      ▄▄▄▓▀▀▀                 ▀█▄       ',
    \'   ▄█▀▀                         ▀█▄     ',
    \'  ▄█             ▄██▄  ███▄       ▀█▄   ',
    \' ▐█            ▄████▌ ▓█████        █▄  ',
    \' ▐█           ██████▌ ▀██████▄       █▌ ',
    \' ▐█         ▄███████▌ ▐███████▄      ▓█ ',
    \'  █        ██████████ ▐█████████     ▓█ ',
    \'  █      ▄██████████▌ ▐██████████    ▐█ ',
    \'  █▌    ▐███████████   ▐██████▀▀     █▀ ',
    \'  ▐█▌     ▀▀▀▀▀▀▀▀ ▄█▄█▓           ▄▓▀  ',
    \'    ▐▀▓▌▄▄        ███ ███      ▄▄█▀     ',
    \'         ▀██      ▀▀▀ ███▀     █▌       ',
    \'          ▐█             ▄     █▌       ',
    \'          ▐█  ▄█  ▐██   ▓█▌▄█▌▄█▀       ',
    \'          ▐█▓▓███▓███▀▀▀██  █▀          ',
    \'              ▐█▌  ██   ██ ▐█▄          ',
    \'           ▐█▀▀██▀▀██▌▀▀██▀▓█▀██        ',
    \'           ▐█  ▀▀  ▐█▌     ▐▀ ▓▌        ',
    \'            ▓▌                █▌        ',
    \'             █▓▄▄             █         ',
    \'                ▀▀▀▀▀▀▀▀▀▓▀▄▓█▌         ',
    \]
