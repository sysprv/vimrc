set nocp
set tabstop=8
set shiftwidth=8
set softtabstop=8
set noexpandtab
set autoindent
set backspace=indent,eol,start
syntax on
let g:loaded_matchparen=1
" set nohlsearch
set incsearch
set noshowmatch
set noerrorbells
set laststatus=2
set showcmd

""""" mappings
map <Up> gk
map <Down> gj
nnoremap Q gq
" I use a Norwegian keyboard, so this mapping is rather useless.
" nnoremap , :
"""""

" set bg=dark
let g:loaded_matchparen=1
set nohlsearch

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

if &cp == 0
        set foldenable
        set foldmethod=marker
        set foldclose=
        " for editing Go, C, bash, perl, Ruby
        command Proper set ts=8 noet sts=8 sw=8 ai

        " for JavaScript, Java, Python
        command Lousy set ts=8 et sts=4 sw=4 ai

        :Proper
endif

" getting too old to play it dangerous
set backup
set backupdir=.
set backupext=~
:au BufWritePre * let &bex = '-' . strftime("%Y%m%d.%H%M%S") . "~"

highlight LineNr  term=NONE

if has("unix")
	let s:uname = system("uname")
	if s:uname == "AIX"
		" disable bold, underline, italic (no good under aix terminfo/termcap)
		" http://vimdoc.sourceforge.net/htmldoc/term.html
		set t_Co=0 t_md= t_Sf= t_Sb= t_us= t_ue= t_ZH= t_ZR=
		syntax off
	endif
elseif has("win32")
	set guifont=Dina:h9
endif
