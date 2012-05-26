set nocp
set tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
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
" I use a Norwegian keyboard, so this mapping is rather useless.
" nnoremap , :
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

" I use view a lot. In Red Hat Linux, view is provided by vim-minimal,
" which evidently does not include folding. This if statement avoids
" errors that view will otherwise print while starting.
if has("folding")
	set foldenable
	set foldmethod=marker
	set foldclose=
endif

command Proper set ts=8 noet sts=8 sw=8 ai
command Lousy set ts=8 et sts=4 sw=4 ai

set backup
set backupdir=.backup,.    " http://news.ycombinator.com/item?id=360748 ??
" set patchmode=.bck
set backupext=~
au BufWritePre * let &bex = '~' . strftime("%Y%m%d.%H%M") . '~'


if has("unix") && (executable("/bin/uname") || executable("/usr/bin/uname"))
	" maybe check for /usr/lib/boot/unix_mp?
	let s:uname = system("uname")
else
	let s:uname = "unknown"
endif

" show matching parentheses by underlining.
if has("gui_running")
	hi MatchParen gui=underline guibg=NONE guifg=NONE
else
	" t_us, t_ue
	hi MatchParen cterm=underline ctermbg=none ctermfg=none
endif

if has("gui_running") && has("win32")
	set guifont=PragmataPro:h10
	set guicursor+=a:blinkon0
endif

if has("gui_running") && s:uname == "Linux"
	set guifont=PragmataPro\ 11
endif

if has("gui_running")
	syntax on
	syntax sync minlines=128
	" https://raw.github.com/altercation/vim-colors-solarized/master/colors/solarized.vim
	try
		colorscheme solarized
	catch /^Vim\%((\a\+)\)\=:E185/
	endtry
endif
