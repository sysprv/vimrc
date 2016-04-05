" vim:set ts=8 sw=4 sts=4 et:
" oft-used variables - $MYVIMRC
set nocp
set tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab fileformat=unix
set enc=utf-8 fenc=utf-8 nobomb
set shiftround
set backspace=indent,eol,start
set nohlsearch incsearch
set noshowmatch
set noerrorbells
set laststatus=2
set showcmd
set formatoptions=

" leave only one space after ./?/! when joining
set nojoinspaces

""""" mappings
map <Up> gk
map <Down> gj
nnoremap Q gq
" rot13
map <F12> ggVGg?
nnoremap , :
map <F9> :exe 'f' getline(1)<CR>
"""""

set statusline=%f%m%r%h%w\ %{&ff}\ sw%{&sw}\ ts%{&ts}\ sts%{&sts}\ et%{&et}\
\ wm%{&wm}\ tw%{&tw}\ fo%{&fo}\ enc%{&enc}\ fenc%{&fenc}\ l%l\ c%v\ o%o\ B%B

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
command Fmt :%!fmt --width=78
command Pst set paste
command Nop set nopaste

" enable auto reformatting when writing; gqip or vip, gq to format manually.
command Wr setlocal ff=unix tw=78 fo+=at spell
autocmd BufNewFile,BufReadPost writing*.txt :Wr
autocmd BufNewFile,BufReadPost *.txt        :set spell
autocmd BufNewFile,BufReadPost *.py         :Lousy

command Nowr setlocal fo-=at

if exists('+colorcolumn')
    set colorcolumn=80
    highlight ColorColumn ctermbg=LightGrey guibg=LightGrey
endif

set backup  " http://stackoverflow.com/a/26779916/1183357

" some constants related to backups
let s:home = expand('~')
let s:hostname = hostname()
let s:backup_root = s:home . '/.backup/' . s:hostname
lockvar s:home s:hostname s:backup_root
if !isdirectory(s:backup_root)
    call mkdir(s:backup_root, 'p')
endif

function s:UpdateBackupOptions()
    "
    " update vim's backup-related options so that
    " a full backup of each file will be kept
    " under ~/.backup/<hostname>/ including
    " the absolute path to the file.
    "
    let l:dir = s:backup_root . expand('%:p:h')
    if !isdirectory(l:dir)
        call mkdir(l:dir, 'p')
    endif
    let &bex = '~' . strftime('%Y%m%d.%H%M%S') . '~'
    let &backupdir = l:dir
    " echo &bex &backupdir
endfunction

autocmd BufWritePre * call s:UpdateBackupOptions()

if has("gui_running")
    " Acme background colour
    highlight Normal guifg=#000000 guibg=#ffffd8
endif

if has("gui_running") && has("win32")
    set guifont=PragmataPro:h10
    set guicursor+=a:blinkon0
endif

if has("gui_running") && !has("win32")
    " assuming Linux
    set guifont=PragmataPro\ 11
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

set spellfile=~/.vimspell.utf-8.add

syntax off

" underline possible spelling errors, instead of highlighting
hi clear SpellBad
hi SpellBad cterm=underline
