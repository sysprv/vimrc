" vim:set ts=8 sw=4 sts=4 et:
" oft-used variables - $MYVIMRC
set nocp
set tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab fileformat=unix
set shiftround
set autoindent
set backspace=indent,eol,start
set nohlsearch incsearch
set noshowmatch
set noerrorbells
set laststatus=2
set showcmd

""""" mappings
map <Up> gk
map <Down> gj
nnoremap Q gq
" rot13
map <F12> ggVGg?
nnoremap , :
imap ø [
imap æ ]
imap Ø {
imap Æ }
map <F9> :exe 'f' getline(1)<CR>
"""""

set statusline=%f%m%r%h%w\ %{&ff}\ sw%{&sw}\ ts%{&ts}\ sts%{&sts}\ et%{&et}\
\ wm%{&wm}\ tw%{&tw}\ enc%{&enc}\ fenc%{&fenc}\ l%l\ c%v\ o%o\ B%B

" set modeline
set showmode
set lazyredraw
set wildmenu
set wildmode=list:longest
set ttymouse=xterm2

" show trailing whitespace when list is on
set listchars=trail:^

" do not connect to any X server
set clipboard=exclude:.*

" I use 'view' a lot. In Red Hat Linux, view is provided by vim-minimal,
" which evidently does not include folding. This if statement avoids
" errors that view will otherwise print while starting.
if has("folding")
    set foldenable
    set foldmethod=marker
    set foldclose=
endif

command Proper set ts=8 noet sts=8 sw=8 ai
command Lousy set ts=8 et sts=4 sw=4 ai
command Clj set ts=8 sts=2 sw=2 et ai
" t_Co=0 disables all colours.
" http://aplawrence.com/Forum/TonyLawrence10.html
command Basic set syntax=off t_Co=0 t_md= t_Sf= t_Sb= t_us= t_ue= t_ZH= t_ZR=
command Gd cd $GOOGLE_DRIVE_DIRECTORY/PlainText | set ff=unix tw=78

if exists('+colorcolumn')
    set colorcolumn=80
endif

set backup
set backupdir=.backup,.    " http://news.ycombinator.com/item?id=360748 ??
" set patchmode=.bck
set backupext=~
au BufWritePre * let &bex = '~' . strftime("%Y%m%d.%H%M%S") . '~'

if has("gui_running") && has("win32")
    set guifont=PragmataPro:h10
    set guicursor+=a:blinkon0
endif

if has("gui_running") && !has("win32")
    " assuming Linux
    set guifont=PragmataPro\ 11
endif

if has("gui_running")
    syntax on
    syntax sync minlines=128
    " raw solarized.vim on github - http://goo.gl/Ai3LU
    try
        colorscheme solarized
    catch /^Vim\%((\a\+)\)\=:E185/
    endtry
endif

"filetype plugin indent on - found out that I don't like this.

hi clear MatchParen
" show matching parentheses by underlining.
if has("gui_running")
    hi MatchParen gui=underline guibg=NONE guifg=NONE
else
    " t_us, t_ue - underline start, underline end
    hi MatchParen cterm=underline ctermbg=none ctermfg=none
endif

