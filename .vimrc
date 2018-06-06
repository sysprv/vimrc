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
set linebreak
" by default mksession saves too much for my taste
set sessionoptions=tabpages

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

" do not connect to X
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
command Sp  set spell

" enable auto reformatting when writing; gqip or vip, gq to format manually.
command Wr setlocal ff=unix tw=78 fo+=at spell
autocmd BufNewFile,BufReadPost writing*.txt :Wr
autocmd BufNewFile,BufReadPost *.txt        :set spell
autocmd BufNewFile,BufReadPost COMMIT_EDITMSG :set spell
" when editing commit messages, always start from the beginning of the file
autocmd BufNewFile,BufReadPost COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])
autocmd BufNewFile,BufReadPost *music-comments.txt :set nospell
autocmd BufNewFile,BufReadPost *.py         :Lousy

command Nowr setlocal tw=0 fo-=at nospell

if exists('+colorcolumn')
    set colorcolumn=80
    highlight ColorColumn ctermbg=darkred guibg=darkred ctermfg=white guifg=white
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

hi clear MatchParen
" show matching parentheses by underlining.
" t_us, t_ue - underline start, underline end
hi MatchParen cterm=underline ctermbg=none ctermfg=none gui=underline guibg=NONE guifg=NONE

" http://vimdoc.sourceforge.net/htmldoc/spell.html
set spellfile=~/.vimspell.utf-8.add
" http://vimdoc.sourceforge.net/htmldoc/syntax.html#:highlight
hi SpellCap   NONE
hi SpellRare  NONE
hi SpellLocal NONE
hi clear SpellBad
hi SpellBad cterm=underline


" deal with trailing whitespace
" colours - https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
highlight TrailingWhitespace NONE
let s:do_match_trailing_ws=0
if has('gui_running')
    highlight TrailingWhitespace guibg=#f7d6d6
    let s:do_match_trailing_ws=1
elseif &t_Co == 256
    highlight TrailingWhitespace ctermbg=250
    let s:do_match_trailing_ws=1
elseif &t_Co == 88
    " TERM=rxvt
    highlight TrailingWhitespace ctermbg=80
    let s:do_match_trailing_ws=1
elseif &t_Co == 8
    " when TERM is linux, xterm, ansi
    highlight TrailingWhitespace ctermbg=6
    let s:do_match_trailing_ws=1
elseif $TERM == 'vt100'
    highlight TrailingWhitespace term=underline
    let s:do_match_trailing_ws=1
endif

if s:do_match_trailing_ws
    " match is per window, WinEnter does not fire for first window
    autocmd VimEnter,WinEnter * match TrailingWhitespace /\s\+$/
endif

function s:StripTrailingWhitespace()
    let l:win = winsaveview()
    %s/\s\+$//e
    call winrestview(l:win)
endfunction

autocmd BufWritePre * call s:StripTrailingWhitespace()
command Stws call s:StripTrailingWhitespace()

" ergonomics

nnoremap <silent> <C-n> :tabnew<cr>
nnoremap <silent> <C-x>k :bdelete<cr>

if has('gui_running')
    " PRIMARY selection - http://vimdoc.sourceforge.net/htmldoc/gui_x11.html#quoteplus
    inoremap <silent> <S-Insert> <C-r>*
endif

" load ctrlp if available
let s:path_ctrlp = s:home . '/.vim/bundle/ctrlp.vim'
if isdirectory(s:path_ctrlp)
    execute 'set runtimepath+=' . s:path_ctrlp
    if exists(':CtrlPMixed')
        let g:ctrlp_map = '<C-p>'
        let g:ctrlp_cmd = 'CtrlPMixed'
    endif
endif

syntax off
