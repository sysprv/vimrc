set secure nocompatible encoding=utf-8 fileencoding=utf-8 nobomb
scriptencoding utf-8

" Last Modified: 2022-06-29
" Normal mode mapping to paste easily in iVim.
"
" 2022-06-28: Hashtag prefix sequence changed from a single Greek Cross
" (🞣, U+1F7A3) to "_#". The Greek Cross isn't visible and causes rendering
" issues in iVim (iOS.)

"
" Long, somewhat disorganized, too large a file, my bonsai project. Lots of
" barnacles from documentation spelunking and trying various options. Tired now,
" don't want to touch it for the next 10 years, when it'll be safe to move to
" vim9script.
"
" notes:

" wish (x)vile had become popular instead of vim. not going to bother
" splitting this up into separate files. missing features: proper stacktraces,
" loggingat specific levels, the ability to trace (without a debugger) when
" options like t_Co change...

" vim settings like backupskip and spelllang should be sets, instead of
" strings with commas.

" colorschemes should be scoped better, or vim needs a real module system.
" for more control/better isolation.

" Makes use of: dash(1) par(1) GNU date(1) file(1).
" $MYVIMRC, $VIMRUNTIME, $VIM
" termguicolors control env variable: $VIM_SKIP_TGC

" We enable 'syntax' by default, but it's finally controlled by filetype, per
" window. Manual overriding: <F2>, <F3>

" :sball - show all buffers; inverse: :only / C-w o
"   <F11>

" @% - current filename;

" strtrans() (dep 'display'); 0, 10, ^@, ^J, <Nul>, <NL>, doc :key-notation
"   https://unix.stackexchange.com/a/247331

" 8g8, g8

" put line in command line :<C-r><C-l>

" debug log: vim -V12vdbg; block buffered; use echom to add markers.
"   verbosity level 10: autocommands; 12: function calls.
"   verbosity can interfere/leak in various places; when redirecting
"   message output, the command window after system() output in gvim.
"

" standard plugins in $VIMRUNTIME/plugin:
" unimaginable functionality.
" instead of defining g_loaded_<plugin check> = v:true on each startup,
" just chmod 0 /usr/share/vim/vim82/plugin/
"   {tohtml,gzip,rrhelper,spellfile,{getscript,tar,vimball,zip}Plugin}.vim
"   and matchparen.vim - nice, but the autocommands feel yucky.
"

let g:loaded_matchparen = 1

if has('unix') && !empty(exepath('/bin/dash'))
    set shell=/bin/dash
endif
" use ripgrep
if has('unix') && executable('rg')
    set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case
endif


set modeline nomodelineexpr
" predictable time formats and messages
language time C
language messages C
" love/hate relationship with this. can be annoying.
" a plugin that requires these: vimoutliner
filetype plugin off
filetype indent off
" often assumed; and some curious behaviour - vim always
" seems to set filetype for the first buffer, but not other loaded files.
" filetype off ought to exclude setting ft for the first buffer...
filetype on

" by default, syntax highlighting will be enabled for these filetypes
" using :ownsyntax. for other filetypes, syntax highlighting will be hidden.
" can be enabled with <F2>.
" string highlighting - test with:
" :highlight String ctermbg=252
" prominently absent: perl, ruby, sh; for vimoutliner, add votl
let g:user_syn_fts = 'python,text,vim'
lockvar g:user_syn_fts
let g:user_vim_base = expand('~')
lockvar g:user_vim_base
" U+21B3 - downwards arrow with tip rightwards
let g:user_showbreak_char = '↳'
lockvar g:user_showbreak_char
let g:user_has_x11 = exists('$DISPLAY')
lockvar g:user_has_x11
let g:user_mark = nr2char(0x95F2)
if &term == 'linux' | let g:user_mark = 'X' | endif
lockvar g:user_mark

" listchars/lcs: see UserSetListchars()

" Netrw - hide common things from the Netrw Explore list
let g:netrw_list_hide = netrw_gitignore#Hide() .. '.*\.swp$'

if !exists('$PARINIT')
    let $PARINIT = "rTbgqR B=.,?'_A_a_@ Q=_s>|#"
endif

set backup  " http://stackoverflow.com/a/26779916/1183357

" how files should be written - whether to rename, or put the new data
" into the same file. the vi default behaviour is yes, and it's the most
" natural with vim as $EDITOR.
set backupcopy=yes

set backupskip+=NOTES-*.txt

" default swap file locations aren't too great; keep them inside our homedir.
let s:swapdir = g:user_vim_base . '/.vim_swap'
if !isdirectory(s:swapdir)
    call mkdir(s:swapdir, 'p', 0700)
endif
" // to have the full file path included in the swap file name, with %'s.
" long paths, specially on windows, might cause problems.
" actually, let's see if we can live without that. irl, conflicts should be rare.
let &g:directory = s:swapdir
unlet s:swapdir
set updatecount=10
set swapfile
" to see current swap file path: ':sw[apfile]' / swapname('%')

" mapleader is a variable, not a setting; no &-prefix
let g:mapleader = ','
" hide search wrap and file written messages
set shortmess-=s
set shortmess-=W
" abbreviate as much as possible, truncate ruthlessly
set shortmess+=a
set shortmess+=I
set shortmess+=T
set shortmess+=S
set shortmess+=F

" laststatus: 0 = never, 1 = show if multiple splits, 2 = always
set laststatus=2
" allow lots of space for the ruler, and force right-alignment
"set rulerformat=%30(%=%%M\ %l:%v%)
set rulerformat=%=%M
set ruler
set showmode
" never changing tabstop again
set tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
set fileformats=unix,dos
set smarttab
set autoread
set shiftround
set backspace=indent,eol,start
" allow <Left> and <Right> to move to new lines in insert mode
" felt nice, but rarely. i'm used to <left><right> staying on the same line.
"set whichwrap+=[,]
set incsearch ignorecase smartcase hlsearch
set noshowmatch
set noerrorbells
set showcmd
" doc fo-table
set formatoptions=t
" leave only one space after ./?/! when joining
set nojoinspaces
"set textwidth=80
"
" indentation
" cindentation's a bit too intrusive for plaintext. smartindent too can be
" annoying. have seen 'undeletable' (x doesn't work) tabs.
set autoindent
set colorcolumn=+1
set nolinebreak
" showbreak's troublesome in X11 ttys, can't exclude from being copied.
" highlight group: NonText
if has('gui_running')
    let &g:showbreak = g:user_showbreak_char
endif
" for a noisier status line
if g:user_has_x11 || has('gui_running')
    " yes, even for vim in X terminal emulators
    set title
endif
"set display+=uhex
if v:version < 802
    " newer vims set this to 'truncate'
    set display+=lastline
endif
" use number column for wrapped lines, including showbreak char
set cpoptions+=n
set cpoptions-=a
set cpoptions-=A
set scrolloff=0
set cmdheight=1
if v:version >= 802
    set cursorlineopt=number,screenline
    "set cursorline
endif
"set nowrap sidescroll=3
"set confirm
set autowrite autowriteall
set hidden
set lazyredraw
set matchpairs+=<:>,«:»,｢:｣

if v:version >= 900
    " display completion matches in a popup menu
    set wildoptions=pum
else
    set wildmenu wildmode=list:longest,full
endif
set wildignorecase
"set ttymouse=sgr
" viminfo prev: '100,<50,s10,h
" now: don't save registers
set viminfo='100,<0,s0,h

set browsedir=buffer
" for C-x C-f; may break plugins but i don't use many plugins.
" too cumbersome. specially in iVim (no shell.)
set noautochdir
set virtualedit=block
" perhaps the 2nd best thing about vim - the following options are enabled
" by default.
set endofline fixendofline

" helps with navigating to a line of interest with <no>j and <no>k.
"set relativenumber

" use NFA regexp engine
set regexpengine=2

set switchbuf=split splitbelow splitright

" a little like :behave mswin, but not all the way.
" can't deny the memories of DOS EDIT.COM.
set keymodel=startsel
set selectmode=mouse,key

if version >= 801 && has("patch-8.1-360")
    set diffopt+=indent-heuristic
    set diffopt+=algorithm:patience
endif

" initialize persistent undo with some good settings
if has('persistent_undo')
    let s:undodir = g:user_vim_base . '/.vim_undo/' . hostname()

    if !isdirectory(s:undodir)
        call mkdir(s:undodir, 'p', 0700)
    endif

    set undolevels=5000
    let &g:undodir = s:undodir
    set undofile

    unlet s:undodir
endif


" if not gvim, do not connect to X; can slow down startup.
" doesn't seem to be a problem on fedora, vim-enhanced doesn't have +X11
if has('X11') && has('clipboard') && !has('gui_running')
    set clipboard=exclude:.*
endif

" I use 'view' a lot. In Red Hat Linux, view is provided by vim-minimal,
" which evidently does not include folding. This if statement avoids
" errors that view will otherwise print while starting.
if has('folding')
    set foldenable
    set foldmethod=marker
    set foldclose=
endif


" echom's untenable for even print debugging.
function! UserLog(...) abort
    " NB: to not log, just return
    return

    let l:fn = expand('~/.vimlog')

    let l:t = strftime('%FT%T')

    if a:0 > 0 && type(a:1) == 2
        " first arg is a lambda (type 2 == funcref), invoke to get log message
        let l:s = a:1()
    else
        let l:s = a:000
    endif
    " stringify and make any control chars visible
    let l:s = strtrans(string(l:s))
    " get stack trace
    let l:stack = expand('<stack>')
    " remove ourselves from the stack trace
    let l:idx_logfn = match(l:stack, '\.\.UserLog\[\d\+\]$')
    if l:idx_logfn == -1
        " calls from the toplevel, not inside any other function
        let l:idx_logfn = match(l:stack, '\.\.function UserLog\[\d\+\]$')
    endif
    if l:idx_logfn > -1
        let l:stack = strpart(l:stack, 0, l:idx_logfn)
    endif
    let l:logmsg = l:t . ' ' . l:s . "\t" . l:stack

    try
        call writefile([l:logmsg], l:fn, 'a')
    catch /^Vim\%((\a\+)\)\=:E/
        " for read-only filesystems, f.ex.
        " can't do much, don't want to echom
        return
    endtry
endfunction


" function definitions: s: and <SID> - too cumbersome, using prefix User
" instead to namespace. vim9 gets this right anyway.

" If the vim version's recent enough, new colour names can be defined by
" adding to v:colornames (def: $VIMRUNTIME/colors/lists/default.vim).

" To prevent background dark/light detection
" doc 'background'
" set t_RB= t_BG=

" My syntax rules are in UserSyntax(), with highlights in UserColours().

" Re-implementing the mode message by decoding mode() seemed fun at one time
" but it was slow.

"-- doc 'statusline'
" should allow three vertical splits.
" verbose info should go into UserGetInfoLines().
"
" %f - filename - expand('%')
" %< - truncate from here when needed
" %n - buffer number
" then turn window id to window number; trailing comma gets some cleanup
" %M - modified? ,+ or ,-
" %R - read only? ,RO
" %W - preview - ,PRV
" %Y - filetype - f.ex. ,VIM
" %q - "[Quickfix List]", "[Location List]" or empty
"   buf in such buffers %f turns into the same thing.
" %= - separation point, start right-aligned
" %l - line number
" %v - screen column number
" adding conditionals on &l:buftype etc. can be confusing because this function
" gets evaluated for all windows with some settings from the current buffer.
"

" like %M, but always return at least one char to prevent status line
" expansion and contraction.
function! UserBufModStatus()
    let l:result = "'"      " default, no unsaved changes
    if !&modifiable
        let l:result = '-'
    endif
    if &modified
        let l:result = '+'
    endif
    return l:result
endfunction

" default statusline, without window number
" to reduce the jerk in the ux.
" likewise, mode message next to some free space - to reduce jerk.
" use of the Normal highlight group - so StatusLine and StatusLineNC will apply
" to the important info, and the rest will use the Normal hl. best with
" suitable fillchars stl stlnc.
"
" in paste mode, &textwidth returns 0. we combine &paste and &textwidth
" so that textwidth is displayed when paste is off.
" when paste is on, that's indicated, without displaying textwidth.
" caveat - paste is global (status in all windows will change.)
"
"set stl=%f%<\ %n\ %{UserBufModStatus()},%{&paste?'!P':&tw}%R%W%Y%#Normal#%#ModeMsg#%{UserModeMsg()}%#Normal#%=%{g:user_mark}\ %l:%v
" declaring defeat - the above worked, though noticeably slower than
" native 'showmode'. but - though it worked, there's no getting around the fact
" that there's always only one command window.
"
" note, a space before the ma.
set stl=%f%<\ %n\ %{UserBufModStatus()},%{&paste?'!P':&tw}%R%W%Y%#Normal#%=\ %{g:user_mark}\ %l:%v

" if g:statusline_winid available, include window number in statusline.
" this has to be done with a function.

" doc patches-8
if has('patch-8.1.1372')
    " run once on startup:
    if !exists('g:user_stl_nofunc')
        let g:user_stl_nofunc = &stl
        " split, keeping the separator in the first part
        let s:stl_parts = split(g:user_stl_nofunc, '%n\zs')
        let g:user_stl_head = s:stl_parts[0]
        let g:user_stl_tail = s:stl_parts[1]
        unlet s:stl_parts
        lockvar g:user_stl_nofunc g:user_stl_head g:user_stl_tail
    endif   " !exists('g:user_stl_nofunc')

    " on each invocation: join the parts made above at startup with more info.
    " head (ending with buffer number) ++ / window number ++ tail
    function! UserStatusLn()
        return g:user_stl_head
            \. '/' . win_id2win(g:statusline_winid)
            \. g:user_stl_tail
    endfunction

    set stl=%!UserStatusLn()
endif   " has('patch-8.1.1372')

"set tabline=%{hostname()} showtabline=2

" this sucks; a confusion of concerns.
function! UserFixupUI()
    " default - just ordinary everyday underscores; U+005F LOW LINE
    let l:fcs = ['stl:_', 'stlnc:_']

    if has('gui_running') || g:user_has_x11 || &term =~ 'putty'
        " U+2504 - BOX DRAWINGS LIGHT TRIPLE DASH HORIZONTAL
        " U+2502 - BOX DRAWINGS LIGHT VERTICAL
        "   (vert default: U+007C    VERTICAL LINE)
        call extend(l:fcs, ['fold:'.nr2char(0x2504), 'vert:'.nr2char(0x2502)])
        highlight clear VertSplit

        " for the statuslines:
        " U+23BD HORIZONTAL SCAN LINE-9 is nice, but not quite low enough.
        " Being a multibyte character, causes issues with rxvt-unicode.
        "
        " vim patch-8.2.2569 is also required.
        "
        " ref https://www.kernel.org/doc/html/latest/admin-guide/unicode.html
        "   (outdated: F804, DEC VT GRAPHICS HORIZONTAL LINE SCAN 9)
        " https://graphemica.com/blocks/miscellaneous-technical/page/3
        " let l:hrz = nr2char(0x2015)   " HORIZONTAL BAR
        let l:hrz = nr2char(0x2500) " BOX DRAWINGS LIGHT HORIZONTAL
        call extend(l:fcs, ['stlnc:'.l:hrz, 'stl:'.l:hrz])
    endif

    " set fillchars once we're done with all the if's.
    let &fillchars = UserFillChars(l:fcs)
endfunction


function! UserDateTimeComment()
    " month (%b) and day (%a) should be 3 chars each
    return strftime('-- date %F %T%z (%b, %a)', localtime())
endfunction


function! UserDate()
    return strftime('%F')
endfunction


" like 2022-07-05T12:57:18.568367478+00:00
function! UserUtcPython()
    " https://bugs.python.org/issue15443 - datetime doesn't support nanoseconds.
    "
    " 2022-07-05 syntax highlighting can break easily here.
    " if using an endmarker, the ending endmarker should be at col 0 (beginning
    " of line.)
    " if a dot is used to terminate the heredoc, without no endmarkers,
    " the dot being on a col > 0 doesn't seem to break syn.

    " not using the trim option on a whim.

    python3 << EPY
import datetime, decimal, time

def rfc3339ns():
    bln = 1_000_000_000
    tm_ns = decimal.Decimal(time.time_ns())
    tm_s = int(tm_ns / bln)
    tm_frac = int(tm_ns % bln)

    # build datetime with just seconds
    t = datetime.datetime.fromtimestamp(
        tm_s,
        tz=datetime.timezone.utc
    ).isoformat()
    # formatted part, without zone info (which should always be +00:00)
    p = t[0:-6]
    # just the zone info
    z = t[-6:]
    # final value
    return f'{p}.{tm_frac}{z}'

EPY

    " end of python block

    return py3eval('rfc3339ns()')
endfunction


" like 2022-07-05T12:21:09.900981612+00:00
function! UserUtcGnuDate()
    let l:s = systemlist('/usr/bin/date --utc --rfc-3339=ns')[0]
    " todo fix before year 10000 or other major calendar changes
    return l:s[0:9] . 'T' . l:s[11:]
endfunction

function! UserUtcNow()
    let l:ts = "\<Ignore>"
    " iVim ships with python3, and it's trivial to get vim and python3
    " to work together on windows.
    if has('python3')
        let l:ts = UserUtcPython()
    elseif has('linux')
        let l:ts = UserUtcGnuDate()
    endif
    return l:ts
endfunction


" Run a vim command with output redireced to a variable.
" Compatible with vim versions that don't have the execute() function.
"
" Modifies verbosity temporarily - otherwise the verbose log messages
" leak into the redirection.
" prepending 0verbose to cmd or setting verbosefile doesn't seem to prevent
" verbose messages ending up in l:val.
" running commands like 'verbose map' still works.
function! UserRun(cmd)
    let l:verbosity = &verbose
    if l:verbosity != 0
        set verbose=0
    endif
    try
        redir => l:val
        silent execute a:cmd
    finally     " ensure closure; otherwise l:val isn't usable
        redir END
        if l:verbosity != 0
            let &g:verbose = l:verbosity
        endif
    endtry
    lockvar l:val
    return l:val
endfunction


" doc popup-usage
function! UserPopupNotfOpts()
    return { 'moved': 'WORD', 'time': 7000, 'close': 'click'
        \, 'highlight': 'Comment'
        \, 'pos': 'botleft', 'posinvert': 1, 'fixed': 0, 'wrap': 0 }
endfunction


function! UserAlert(lines)
    if has('popupwin')
        let l:opts = UserPopupNotfOpts()
        call popup_notification(a:lines, l:opts)
    else
        " print just the first line. the full joined array is annoying,
        " requiring another key to dismiss.
        echom a:lines[0]
        " U+2502 - box drawings, light vertical
        " echom join(a:lines, nr2char(0x2502))
    endif
endfunction


" turn a dict into a string like "k=v k'=v'"
function! UserDictToStr(dct)
    let l:l = []
    for [l:k, l:v] in items(a:dct)
        call add(l:l, l:k . '=' . string(l:v))
    endfor
    let l:sl = sort(copy(l:l))
    return join(l:sl)
endfunction


function! UserBufferInfo()
    let l:bufp = { 'ai': &ai, 'et': &et, 'fo': &fo, 'sts': &sts, 'sw': &sw,
        \ 'ts': &ts, 'tw': &tw, 'wm': &wm }
    return UserDictToStr(l:bufp)
endfunction


" list all the syntax groups in effect under the cursor.
function! UserSyntaxNamesAtCursor() abort
    let l:syn_names = []

    for l:synid in synstack(line('.'), col('.'))
        let l:syn_name = synIDattr(l:synid, 'name')
        call add(l:syn_names, l:syn_name)
    endfor

    return l:syn_names
endfunction


function! UserGetInfoLines()
    let l:lines = []

    " buffer/file properties
    let l:enc = { 'enc': &enc, 'fenc': &fenc }
    let l:bufp_misc = { 'filetype': &ft, 'syntax': &syn }

    " window id and size
    let l:win = 'wnd: ' . winnr()
    if exists('*win_getid')
        let l:win .= ', id ' . win_getid()
    endif
    " &lines and &columns are something else
    let l:win .= ': ' . winwidth(0) . 'x' . winheight(0)
    let l:t_co = 't_Co=' . &t_Co
    let l:syn_cur = 'syn: ' . join(UserSyntaxNamesAtCursor(), ' ')

    call add(l:lines, UserBufferInfo())
    call add(l:lines, UserDictToStr(l:enc))
    call add(l:lines, UserDictToStr(l:bufp_misc))
    call add(l:lines, l:t_co)
    call add(l:lines, l:win)
    call add(l:lines, l:syn_cur)

    " print some info about the char under cursor.
    " with chrisbra/unicode.vim if found.
    " unicode#GetUniChar() doesn't return the longed for value, it echoes.
    " so we must capture that output. GetUniChar() in turn executes `ga'.
    " all this seems to make this function only safe for normal mode.
    if mode() == 'n'
        let l:cmd = ':ascii'
        if UserRuntimeHas('plugin/unicode.vim')
            let l:cmd = ':UnicodeName'
        endif
        let l:char_info = UserRun(l:cmd)
        if l:char_info[0] == "\n"
            let l:char_info = strpart(l:char_info, 1)
        endif

        call add(l:lines, '--')
        call add(l:lines, l:char_info)
    endif

    " reminders, which have to be manually maintained for now
    " damian conway has his own documented mappings; not yet worth the trouble.
    call add(l:lines, '--')
    call add(l:lines, '<F2><F3> syn onoff <F4><F5> tty/colo')
    return l:lines
endfunction


" NB: return value ("\<Ignore>") - important for using in insert mode.
" otherwise, function return value will be appended to the buffer.
" doc :map-expression
function! UserShowHelp()
    let l:lines = UserGetInfoLines()
    call UserAlert(l:lines)
    return "\<Ignore>"
endfunction


"
" update vim's backup-related options so that a full backup of each file will
" be kept under ~/.backup/<hostname>/ including the absolute path to the file.
"
" i like this approach better than patch-8.1.0251.
"
" credit:
" https://www.vim.org/scripts/script.php?script_id=89
" https://www.vim.org/scripts/script.php?script_id=563
"
function! UserUpdateBackupOptions()
    let l:filepath = expand('%:p:h')
    " for microsoft windows
    if has('win32')
        let l:filepath = tr(l:filepath, ':', '_')
    endif

    " maybe getftime(); but there's no way to get the modified time
    " of an unwritten buffer.
    let l:tm = localtime()

    " like: ~/.backup/hostname/yyyy-mm-dd/path.../file~hhmmss~
    " keep related changes within a day together
    let l:dir = g:user_vim_base
        \ . '/.backup'
        \ . '/' . hostname()
        \ . '/' . strftime('%F', l:tm)
        \ . '/' . l:filepath

    if !isdirectory(l:dir)
        call mkdir(l:dir, 'p', 0700)
    endif
    let &l:backupext = '~' . strftime('%H%M%S', l:tm) . '~'
    let &l:backupdir = l:dir
    " echom 'backup-options' &bex &bdir
endfunction


function! UserStripTrailingWhitespace()
    if !&l:modifiable || &l:readonly || &l:binary
        return
    endif

    " ah well, only handles ascii whitespaces
    let l:regexp = '\s\+$'
    if search(l:regexp, 'cnw')
        let l:win = winsaveview()
        execute '%substitute/' .. l:regexp .. '//e'
        call winrestview(l:win)
    endif
endfunction


" if a file named 'index' exists, load it; don't create it.
" living without command-t, CtrlP etc.
function! UserOpenIndexFile()
    if filereadable('index')
        edit index
        setlocal readonly
    else
        echom 'no index'
    endif
endfunction

" ---- highlight (colour) definitions
" Overrides for builtin highlights:
" doc highlight-default
" color lists:
" https://upload.wikimedia.org/wikipedia/commons/1/15/Xterm_256color_chart.svg
" https://www.calmar.ws/vim/256-xterm-24bit-rgb-color-chart.html
" https://www.astrouw.edu.pl/~jskowron/colors-x11/rgb.html
"
" 256 colors to rgb codes and x11 color names:
" https://jonasjacek.github.io/colors/

" define the highlight groups used by our own syntax rules.
" kept apart from the UserColours() colour-overriding hierarchy because
" this method can be called more often (f.ex., per new window or even
" per each window switch.)
function! UserCustomSyntaxHighlights()
    highlight UserDateComment term=NONE cterm=italic gui=italic
    highlight UserTrailingWhitespace term=standout cterm=NONE gui=NONE
    highlight UserHashTag term=NONE cterm=NONE gui=NONE

    if &background == 'light'
        highlight UserDateComment ctermfg=8 ctermbg=12 guifg=grey40 guibg=azure2
        highlight UserHashTag ctermbg=194 guifg=fg guibg=palegreen2
        highlight UserTrailingWhitespace ctermbg=7 guibg=lightgrey
    else
        highlight UserDateComment ctermfg=240 guifg=fg guibg=grey40
        highlight UserHashTag ctermbg=240 guifg=fg guibg=grey40
        highlight UserTrailingWhitespace ctermbg=238 guibg=grey27
    endif

    " for URIs at top level
    highlight! default link UserHttpURI Normal
endfunction


" bring some sanity to vim UI element colours
function! UserColoursFailsafe()
    highlight ErrorMsg      term=standout
    highlight Ignore        NONE
    highlight MatchParen    NONE
    highlight ModeMsg       NONE
    "highlight Normal        ctermbg=NONE guibg=NONE
    highlight SpellBad      NONE
    highlight SpellBad      term=reverse
    highlight SpellCap      NONE
    highlight SpellLocal    NONE
    highlight SpellRare     NONE    " decriminalise rare words
    " we want to be safe for monochrome ttys, and at the same time
    " clear cterm and gui attributes that can be bad in 256 color and gui modes.
    " since the attributes here are initial values and get inherited later.
    highlight StatusLine    ctermfg=black   ctermbg=green   cterm=NONE  gui=NONE
    highlight StatusLineNC  ctermfg=black   ctermbg=grey    cterm=NONE  gui=NONE
endfunction

" meant for use when testing colorschemes, to see if a colorscheme has better
" status line colours than my choices, for example. so far this has not been the
" case, including both iceberg and lucius.
function! UserOverrideUiColours()
    return v:true
endfunction

"
" Tip: set tty (xterm, rxvt-unicode, VTE) colour 12 to azure2/#e0eeee.
" For mlterm: ~/.mlterm/color, 12 = #e0eeee;
"       manpage section "Color Configuration File"
" For ROXTerm: ~/.config/roxterm.sourceforge.net/Colours/<custom profile>:
"   [roxterm colour scheme]
"       12=#e0e0eeeeeeee
"
" There are no close soft blues within the common 16 colours, and it's
" not straightforward to override a blue within the 88/256 colours.
"
function! UserColours256Light()
    if UserOverrideUiColours()
        highlight ColorColumn                       ctermbg=12
        highlight StatusLine        ctermfg=0       ctermbg=152
        highlight StatusLineNC      ctermfg=15      ctermbg=237
    endif
    " no point clearing 'Normal' here, vim doesn't seem to reset the background
    " colour to the tty background color. probably mentioned somewhere in
    " `help :hi-normal-cterm'.
    " instead - either choose a colorscheme that can work without modifying
    " Normal-ctermbg like lucius, or wrap it like our own iceberg-wrapper.vim.
endfunction

" dark backgrounds are quite common even if not desired.
" must support.
" things can look wrong if a colorscheme forces background to dark,
" as when trying desert in a bright tty. the following function
" will get run because bg's now dark, and the result can look wrong.
function! UserColours256Dark()
    if UserOverrideUiColours()
        highlight ColorColumn                       ctermbg=237
        highlight StatusLine        ctermfg=NONE    ctermbg=238
        highlight StatusLineNC      ctermfg=NONE    ctermbg=243
    endif
endfunction

function! UserColours256()
    "highlight ErrorMsg          ctermfg=yellow  ctermbg=brown   cterm=bold
    highlight MatchParen                        ctermbg=202

    " high visibility - works well everywhere
    highlight ModeMsg term=reverse ctermfg=0 ctermbg=214 guifg=#000000 guibg=#ffaf00

    if UserOverrideUiColours()
        highlight NonText       ctermfg=14
        highlight SpecialKey    ctermfg=1
    endif
    highlight SpellBad                          ctermbg=252

    if &background == 'light'
        call UserColours256Light()
    else
        call UserColours256Dark()
    endif
endfunction

" 'light' only
function! UserColoursGui()
    " sea green ?
    "
    if UserOverrideUiColours()
        highlight ColorColumn                       guibg=azure2
        highlight MatchParen                        guibg=#ff8c00
        highlight ModeMsg           guifg=#000000   guibg=#ffaf00
        highlight NonText           guifg=grey60
        highlight SpecialKey        guifg=grey70
        " statusline colours a little like this gameboy theme:
        " https://lospec.com/palette-list/grue: stl #b8c7bf, stlnc #4d5964
        " and the Diana F+ camera body.
        " guibg=#grey82 (typo) produced a nice colour, probably #efdf82
        " also dark turquoise
        highlight StatusLine        guifg=black     guibg=#b0e0e6   gui=NONE
        highlight StatusLineNC      guifg=black     guibg=#d0d0d0   gui=NONE
    endif
    "
    " don't like undercurls. most themes use undercurls.
    highlight clear SpellBad
    " a non-annoying grey to go well with the Normal guibg
    highlight SpellBad          guibg=#e3e3e3
    "
    if !has('gui_running')
        return
    endif
    " for gvim only
    highlight clear Cursor
    highlight Cursor gui=reverse
    " was: whitesmoke; current - anti-flash white; see also #f2f3f4
    if exists('g:colors_name') && g:colors_name == 'lucius'
        " lucius is pretty nice in gui mode, no need to override.
        return
    endif
    " default gui forground/background, including for iceberg.
    highlight Normal            guifg=black     guibg=#f3f3f3
endfunction

" t_Co can be ambiguous.
" mlterm starts with t_Co 8, later changes to 256.
"
" NB: this is usually meant to run after a colorscheme we largely like.
" so this function should _not_ call UserSafeHighlights().
"
function! UserColours()
    call UserLog('UserColours enter win', winnr())
    " clean up UI colours
    call UserColoursFailsafe()

    " orange
    highlight clear UserHighVis
    highlight! default link ModeMsg UserHighVis

    if &term =~ '256color'
        call UserColours256()
    endif

    let l:gui = has('gui_running') || &termguicolors
    if l:gui
        call UserColoursGui()
    endif

    " since we're handling a colorscheme change: we should in our custom colour and
    " syntax definitions.
    call UserHS()
    " and our misc. fixups
    call UserFixupUI()
endfunction


function! UserCanLoadColorscheme()
    if has('gui_running')
        return v:true
    endif
    return exists('&t_Co') && &t_Co >= 256
endfunction


" turn off most highlights; 'highlight clear' defaults are awful,
" set highlights to NONE to silence.
function! UserSafeHighlights()
    " source: syntax/syncolor.vim
    " not clearing Error, and SpellBad.
    let l:groups = [ 'Comment', 'Constant', 'Special', 'Identifier', 'Statement'
        \, 'PreProc', 'Type', 'Underlined', 'Ignore', 'Todo' ]
    for l:group in l:groups
        silent execute 'highlight' l:group 'NONE'
    endfor
    " is this universally safe?
    highlight String term=bold cterm=bold gui=bold
endfunction


" define some custom highlighting. alternative: matchadd() - but, these seem to
" override syntax matches. probably can't be used to hide spelling errors as
" we've done with URLs.
" maybe someday - try text properties
"
" damien conway: \S\@<=\s\+\%#\ze\s*$
" https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc#L213
function! UserSyntax()
call UserLog('UserSyntax enter win', winnr())

" without clear, match will happily add the same def to the hl group name
syntax clear UserTrailingWhitespace
syntax match UserTrailingWhitespace /\s\+$/
\ display oneline
\ containedin=ALLBUT,UserTrailingWhitespace

" Faded date comments; regular expression must match the dt mappings
" NB: \a is alphabetic here, not bell
syntax clear UserDateComment
syntax match UserDateComment
\ /\v-- date \d+-..-.. ..:..:..[+-]\d{4} \(\a+, \a+\)/
\ display oneline
\ containedin=ALLBUT,UserDateComment

" doc perl-patterns
" vim \w is ASCII-only.
" word boundaries: \< and \>
"
" doc /[] (https://vimhelp.org/pattern.txt.html#%2F%5B%5D)
" \k etc. doesn't work within [], instead use [:keyword:]
"
" ref Smalltalk syntax file syntax/st.vim, stSymbol
"
" doc /\zs (https://vimhelp.org/pattern.txt.html#%2F%5Czs)
"
" pretty far out stuff!: doc /\] (pattern.txt.html#%2F%5C%5D)
"
syntax clear UserHashTag
" simple tag
syntax match UserHashTag /\v-\#[_[:lower:][:upper:][:digit:]]+/
\ display oneline containedin=ALLBUT,UserHashTag

" for hashtags with quotes, a region match. this will match too much
" (tab characters, f.ex.), but this is only meant as a casual indication
" anyway. The syntax sure is convenient.
" doc: syn-region
" NB: additive; not clearing UserHashTag before defining the region.
syntax region UserHashTag start=/-\#'/ skip=/\\\'/ end=/'/
\ display oneline containedin=ALLBUT,UserHashTag,UserHttpURI


syntax clear UserHttpURI
" two definitions with the same regexp but different match flags:
" -
" doc :syn-contained
" -
" match for when URIs may be enclosed in other syntax groups.
" transparent - this match definition doesn't need a highlight group.
" prev pattern: vhttps?:\/\/[\-A-Za-z0-9+&@#\/%?=~_|!:,.;]*[\-A-Za-z0-9+&@#\/%=~_|]
" current pattern - more liberal, delimited by word boundaries
syntax match UserHttpURI /\v<https?:\/\/\S+>/
\ transparent contained containedin=ALLBUT,UserHttpURI contains=@NoSpell
" -
" for the top level (URIs outside any other syntax group)
if v:false  " top level test; <F1> syntax display on line below should
" include UserHttpURI. and not be affected by 'setl spell'.
https://web.archive.org/web/20010301154434/http://www.vim.org/
endif
syntax match UserHttpURI /\v<https?:\/\/\S+>/ contains=@NoSpell
endfunction     " UserSyntax()


function! UserHS(...)
    let l:forced = a:0 > 0 && a:1 == v:true

    call UserLog(printf('UserHS winnr=%d forced=%d syn_on=%d'
        \, winnr()
        \, l:forced
        \, exists('g:syntax_on')))

    " don't enable if syntax is globally disabled
    " but do enable if called with arg 1 == 1
    if exists('g:syntax_on') || l:forced
        call UserCustomSyntaxHighlights()
        call UserSyntax()
    endif
endfunction


" Fallback using no colours or text attributes.
" t_Co=0 disables all colours; http://aplawrence.com/Forum/TonyLawrence10.html
" Was useful once under haphazardly setup AIX systems.
" Destructive, can't really restore to normal without restarting vim.
if v:false
function! UserTermBasic()
    syntax off
    highlight clear
    set t_Co=0 t_md= t_Sf= t_Sb= t_us= t_ue= t_ZH= t_ZR=
    set notermguicolors nolist showbreak=NONE colorcolumn=0
endfunction
endif

function! UserRuntimeHas(pathspec)
    return len(globpath(&runtimepath, a:pathspec, 0, 1)) > 0
endfunction


" only need this fancy stuff on home systems, not legacy CentOS or whatever.
if v:version >= 802
" Run a vim command and drop the output into a new window.
"
" Adapted from https://vi.stackexchange.com/a/8379
"
" Maybe "normal! \<C-w>\w"
"
" This function is over-engineered. A simple `close' without window ids and
" wincmd must do the same thing. But tracking window ids makes the control
" flow easier to understand.
"
" On the curious case of `NB q' - what seems to happen is that the latest
" function invocation opens a window and then closes it because execute+redir
" returns nothing.  Then the :q takes effect on the current window and closes
" it.
"
" Same for `NB w' - new window opens and closes, :w tries to act on original
" window, fails since the buffer's unmodifiable.
"" Since the command runs in a new buffer, some things like
" :syntax (listing syntax definitions) won't work.
function! UserSpoolEx(cmd)
    if v:false
        if (&l:readonly || !&l:modifiable)
            echom 'unmodifiable'
            return
        endif
    endif

    new | setlocal filetype=text buftype=nofile noswapfile
    let l:winid = win_getid()
    "echom 'opened' l:winid
    let l:close = v:true
    try
        let l:v = UserRun(a:cmd)
        if empty(l:v)
            "echom 'nothing to put'
        else
            put = l:v

            " can make the buffer readonly nomodifiable here, but it can be
            " nice to play around/test editing commands.

            " everything seems fine, leave window open.
            let l:close = v:false
        endif
    catch /^Vim\%((\a\+)\)\=:E21:/
        echom v:exception
    catch /^Vim\%((\a\+)\)\=:E382:/
        echom 'cannot write -' &buftype
    catch /^Vim\%((\a\+)\)\=:E/
        " echoerr throws; messy.
        echom v:exception
    finally
        if l:close
            " something went wrong before l:close could be set to zero
            "echom 'closing' l:winid
            let l:winnr = win_id2win(l:winid)
            execute l:winnr .. 'wincmd c'
        endif
    endtry

    return "\<Ignore>"
endfunction

" a command to put the output of a vim command into a new scratch buffer
command -nargs=+ -complete=command NB call UserSpoolEx(<q-args>)
endif   " v:version >= 802


" fun little hacks; show things defined by me, from my .vimrc / .gvimrc
" since these functions use currently loaded data, settings defined
" in .gvimrc won't be visible when queried under tty vim.
function! UserShowMaps()
    new | setlocal filetype=text buftype=nofile noswapfile
    " :map doesn't show mappings for all modes; meh
    " doc map-overview
    put= UserRun('verbose map')
    put= UserRun('verbose cmap')
    put= UserRun('verbose imap')
    " get rid of the line breaks in the 'verbose' output
    " conceptually cleaner: :g/^\sLast set from/-1j    [join with line above]
    global/\n\s\+Last set from/s//\t# src =/
    " delete lines that don't refer to our vim configuration files
    global/src =/g!/src = \~\/\.g\?vimrc/d
    " replace <file> line <lineno> with something gF can jump to
    global/ line \(\d\+\)$/s//:\1/

    " delete empty lines
    global/^$/d
    " internal :sort, skipping the first column (mode)
    sort /^.\s\+/

    file Maps
    setlocal readonly nomodifiable
endfunction

command MyMaps      silent call UserShowMaps()


function! UserShowCommands()
    new | setlocal filetype=text buftype=nofile noswapfile
    put= UserRun('verbose command')
    global/\n\s\+Last set from/s//\t# src =/
    " select the lines that have an 'src =' but not our config file.
    " this preserves the header row (that's been generated by ':command'.)
    global/src =/g!/src = \~\/\.g\?vimrc/d
    " enable going to location - replace "<file> line <lineno>" in the
    " 'verbose' output with <file>:<lineno>
    global/ line \(\d\+\)$/s//:\1/

    " ':command' output is already sorted.
    " delete empty lines
    global/^$/d

    file Commands
    setlocal readonly nomodifiable
endfunction

command MyCommands  silent call UserShowCommands()


function! UserShowFunctions()
    new | setlocal filetype=text buftype=nofile noswapfile
    put= UserRun('verbose function')
    global/\n\s\+Last set from/s//\t# src =/
    global/src =/g!/src = \~\/\.g\?vimrc/d
    global/ line \(\d\+\)$/s//:\1/
    global/^$/d
    sort

    file Functions
    setlocal readonly nomodifiable
endfunction

command MyFunctions     silent call UserShowFunctions()


" spelling
"
" en_rare doesn't seem to exist anywhere.
" Lang cjk only prevents checking CJK characters.
" spell files: https://ftp.nluug.nl/vim/runtime/spell/
"
" custom english spellfile:
" http://app.aspell.net/create?max_size=80&spelling=GBs&max_variant=3&diacritic=both&special=hacker&special=roman-numerals&download=wordlist&encoding=utf-8&format=inline
" curl -o f
" then, :mkspell en_gb f
"
function! UserSpellLangs()
    let l:spls = []
    if UserRuntimeHas('spell/enlocal.utf-8.spl')
        call add(l:spls, 'enlocal')
    else
        " should default to 'en'
        call add(l:spls, 'en')
    endif
    if UserRuntimeHas('spell/ru.utf-8.spl') | call add(l:spls, 'ru') | endif
    if UserRuntimeHas('spell/he.utf-8.spl') | call add(l:spls, 'he') | endif
    call add(l:spls, 'cjk')
    return l:spls
endfunction

" &g: doesn't work here.
let &spelllang = join(UserSpellLangs(), ',')
" if spellfile unset, with a word is added (zg/zw) vim will set spellfile
" to somewhere inside ~/.vim/ .
" also - all words from all spell languages go into the same file.
let &spellfile = g:user_vim_base . '/.vimspell.utf-8.add'
set spellcapcheck=


" 'fillchars' can accumulate items of same type. the last is effective. but
" the accumulated output is a mess and can be confusing. this function
" can be used to remove redundant items.
"
" input should be a list, with items in the same format as that which 'fillchars'
" uses. with no input items, returns current fillchars without duplicates.
"
" the input array may itself contain duplicate item types.
"
" example: UserFillChars(['stl:x', 'stlnc:y'])
"
" could have just used a:000, but it's also nice to be explicit about
" what's expected.
"
function! UserFillChars(...) abort
    let l:fcs = &fillchars
    let l:fcs_items = split(l:fcs, ',')

    if a:0 > 0
        call extend(l:fcs_items, a:1)
    endif

    " keep last of each duplicate type
    let l:kv = {}
    for l:item in l:fcs_items
        let [l:k, l:v] = split(l:item, ':')
        let l:kv[l:k] = l:v
    endfor

    " make new string
    let l:result = ''
    for [l:k, l:v] in items(l:kv)
        let l:result .= ',' . l:k . ':' . l:v
    endfor
    return strpart(l:result, 1)
endfunction


" doc 'listchars'
" By default listchars has eol:$ ; this case and trail: are covered by
" the trailing whitespace highlighting.
" These don't show up on the linux console of course, sometimes
" not even with Windows/PuTTY. But the replacement/fallback characters
" serve well enough.
" Test nbsp with AltGr+Space.
" 'list' can be cumbersome depending on the choice for tabs.
"
" tab: U+00BB and a space; if 2nd char isn't space, cumbersome/ugly.
"   hl: SpecialKey
" precedes: U+2039 single left-pointing angle quotation mark
"   hl: NonText
" extends: U+203A single right-pointing angle quotation mark
"   hl: NonText
" nbsp: ordinary underscore
"   hl: SpecialKey
"   'list' nbsp catches both U+00A0 and U+202F.
"
" not being able to exclude 'tabs' from listchars really seems to
" favour 'expandtabs' ... ?
"
" i'd like special highlighting for nbsp and Normal highlight for tab, but
" both use SpecialKey.
"
" control pictures would be good to use here, but they're not very legible.
"
" U+263A WHITE SMILING FACE / cp437 char 0x1

function! UserSetListchars(incltabs)
    let l:dfl = "nbsp:☺,precedes:‹,extends:›,trail:$"

    if a:incltabs
        let l:result = "tab:>-," . l:dfl
    else
        " default - use spaces to show tabs with 'set list'
        let l:result = "tab:\u20\u20," . l:dfl
    endif

    return l:result
endfunction

let &g:listchars = UserSetListchars(0)


" ---- mappings
nnoremap        <Up>    gk
nnoremap        k       gk
nnoremap        <Down>  gj
nnoremap        j       gj

" on hitting F1 instead of Esc by accident when sleepy - do something
" unobtrusive instead of opening help. <expr> is brittle. <Cmd>'s robust, but
" very new. the quiet alternative: <Nop>
nnoremap <silent> <F1>      :call UserShowHelp()<CR>
imap              <F1>      <Esc><F1>
" for misconfigured virtual serial lines with putty. better to set
" TERM=putty-256color before starting (above mappings work then), instead of
" working under 'vt220' or whatever.
if &term !~# 'putty' && !g:user_has_x11 && !has('gui_running')
    nnoremap <silent> <Esc>[11~  :call UserShowHelp()<CR>
    inoremap <silent> <Esc>[11~  <Esc>:call UserShowHelp()<CR>
endif

" quickly toggle spellcheck
" used to use F6 to toggle spell, but setl [no]spell is easier to remember.

" show all buffers in windows; was just thinking of fullscreen.
nnoremap <silent> <F11>  :sball<CR>

" lots more modes... doc :noremap and doc xterm-function-keys

" Trying out a mapping to show buffers quickly and unobtrusively.
" https://stackoverflow.com/a/16084326
" https://github.com/Raimondi/vim-buffalo
" The <Space> after :b allows wildmenu to come into play easily.
" NB: can't be a silent mapping.
nnoremap    +           :ls!<CR>:b<Space>

" emacs/readline-like mappings for the command line; doc emacs-keys
cnoremap    <C-a>       <Home>
cnoremap    <C-b>       <Left>
cnoremap    <C-d>       <Del>
cnoremap    <C-e>       <End>
cnoremap    <C-f>       <Right>
cnoremap    <C-n>       <Down>
cnoremap    <C-p>       <Up>

" Switch to alternate file: Ctrl-6
" doc CTRL-^ (https://vimhelp.org/editing.txt.html#CTRL-%5E)

"" a way to turn hlsearch off quickly; from Damian Conway
nnoremap <silent> <BS>   :nohlsearch<CR>

xnoremap    <BS>    x


" 2022-02-14 from defaults.vim - delete to beginning, with undo
inoremap    <C-u>   <C-g>u<C-u>
" same for deleting words; from tpope's vim-sensible
inoremap    <C-w>   <C-g>u<C-w>

"" insert timestamp
"" nnoremap        <silent> <Leader>dt :put=UserDateTimeComment()<CR>
inoremap <expr> <silent> <Leader>dt     UserDateTimeComment()

"" insert date
"" nnoremap        <silent> <Leader>dd :put=UserDate()<CR>
inoremap <expr> <silent> <Leader>dd     UserDate()
" so i can do :e f-<,dd> in the vim command window
cnoremap <expr> <Leader>dd              UserDate()

inoremap <expr> <silent> <Leader>dU     UserUtcNow()

"" see also: insert mode, <C-r>=    doc i_CTRL-R

"" format paragraph with par -  for justify
""      see also: plugin/justify.vim; doesn't seem as good as par.
""
"" mapping deciphered:
"" { - go to beginning of paragraph
"" !}par... - doc ! (https://vimhelp.org/change.txt.html#%21)
""      filter to end of paragraph
"" } - move to end of paragraph
""
"" http://www.softpanorama.org/Editors/Vimorama/vim_piping.shtml#Using_vi_as_a_simple_program_generator
""
"" http://www.nicemice.net/par/par-doc.var
""
nnoremap <silent> <Leader>j     {!}par 78<CR>}
""
"" format paragraph. k's just close to , .
""
nnoremap <silent> <Leader>k     gwip
""
"" join paragraph to single line
""      theres's no {motion}J
""
nnoremap <silent> <Leader>J     vipJ
""

" øæå as brackets, braces, parentheses - done with xmodmap

" A mapping to copy from tty vim, since when list mode is enabled the usual copy
" from the terminal will include listchars. pass visual selection to X11
" CLIPBOARD; doc :write_c
if g:user_has_x11 && has('unix')
    xnoremap <silent> <Leader>y  <Esc>:silent '<,'>:w !xclip -selection clipboard<CR>
endif
if has('gui_running')
    " for iVim on iOS (has gui but no X11, no gtk) - paste with little ceremony
    " and kept in .vimrc instead of .gvimrc
    nnoremap <silent> <Leader>xp    "+p
    inoremap <silent> <Leader>xp    <C-r>+
    cnoremap          <Leader>xp    <C-r>+
else
    nnoremap <silent> <Leader>xp    <nop>
    inoremap <silent> <Leader>xp    <nop>
    cnoremap          <Leader>xp    <nop>
endif

nnoremap <silent>   <Leader>xs      :update<CR>

" set current window (split) width to 80
" for use with multiple vertical splits
"nnoremap <silent> <Leader>wd 80<C-w>\|


" For convenient input of some typographic symbols:

" doc digraphs-default
" see also: digraph_get()

" For Butterick's Pollen; U+24CA Lozenge
" https://docs.racket-lang.org/pollen/third-tutorial.html
" digraph: C-k LZ

" Interpunct/middle dot, U+00B7
" digraph: C-k .M

" Dagger/obelus; U+2020; double dagger: U+2021
" digraph: C-k /- and C-k /=

" If using strings with unicode escape, use UTF-32 format - "\U0001F7A1" etc.
"
" Beautiful fleurons: https://www.unicode.org/charts/PDF/U1F650.pdf
"
" U+FF62, U+FF63 - halfwidth corner brackets; used by raku.
" U+2118 - Weierstrass P https://en.wikipedia.org/wiki/Weierstrass_elliptic_function
let Symbols = {
    \ 'lozenge':        nr2char(0x25CA)
    \ ,'interpunct':    nr2char(0xB7)
    \ ,'dagger':        nr2char(0x2020)
    \ ,'greek cross, medium': nr2char(0x1F7A3)
    \ ,'brkt left corner': nr2char(0xFF62)
    \ ,'brkt right corner': nr2char(0xFF63)
    \ }
lockvar Symbols

inoremap <expr> <Leader>;       Symbols['interpunct']
inoremap <expr> <Leader>lz      Symbols['lozenge']
inoremap <expr> <Leader>dg      Symbols['dagger']

" pound signs used everywhere, lozenge taken by Pollen...
" U+25B8 Black right-pointing small triangle
" U+25BA Black right-pointing pointer
" U+298B, U+298C - brackets with underbar
" U+2991, U+2992 brackets with dot
inoremap <Leader>#       -#
cnoremap <Leader>#       -#

" abbreviations aren't so useful in such cases, they expand after whitespace.

" prevent accidental nbsp entry; using 'execute' for mapping whitespace
execute "inoremap \u00A0 <Space>"

" use 's' for window commands instead of the emacsy C-w
nnoremap    s   <C-w>
" for keys like C-wf (doc CTRL-W_f), there's no option to make the split
" vertical by default. We make do with this:
nnoremap    <Leader>vf  <C-w>f<C-w>L

" WIP mapping to open files; meant to work under just two windows:
" one window with a list of filenames.
nnoremap    <Leader>se  :let f = expand('<cfile>')<CR><C-w>w:execute('edit ' . f)<CR>


if !has('gui_running')
    " tty - Ctrl-Backspace sends Ctrl-H.
    " Usually. xterm, rxvt-unicode, linux console + screen do.
    " pterm sends Ctrl-? by default.
    " https://tartarus.org/~simon/putty-snapshots/htmldoc/Chapter4.html#config-backspace
    "
    " also remember Ctrl-u
    inoremap    <C-h>   <C-w>
endif

" ----

" trying out insert mode autocomplete with C-X C-U
" doc i_CTRL-X_CTRL-U
" doc complete-functions

function! UserSymComplFn(findstart, base)
    if a:findstart == 1
        " completion starts at cursor column
        return -100
    elseif a:findstart == 0
        let l:compl = []
        for [l:name, l:sym] in sort(items(g:Symbols))
            " 'word': Symbol value, 'menu', Symbol key (description)
            let l:entry = { 'menu': l:name, 'word': l:sym }
            call add(l:compl, l:entry)
        endfor
        return l:compl
    else
        " cancel silently and leave completion mode
        return -3
    endif
endfunction

set completefunc=UserSymComplFn


" :ownsyntax wipes buffer-local spell options, breaking the basic global->local
" relation created with :set. this walks and talks like a bug, it's just
" documented. here we save and restore the local spell options manually. it's
" not enough if we set the local options to the globals, the local options may
" have been modified beforehand.
"
" symptoms without this - :setl spell doesn't do anything, z= raises
"   E756: Spell checking is not possible.
"
function! UserOwnSyntax(flag)
    let l:spllng = &l:spelllang
    let l:spell = &l:spell
    let l:spf = &l:spellfile
    " spellcapcheck, don't want.
    try
        execute 'ownsyntax' a:flag
    finally
        let &l:spelllang = l:spllng
        let &l:spell = l:spell
        let &l:spellfile = l:spf
    endtry
endfunction


" no longer in use.
"
" for the expected usecase, this autocmd seems to get called twice.
" 1 - val == <filetype>; probably on filetype change
" 2 - val == on; probably after ownsyntax on
if v:false
function! UserAutoSyn(val)
    call UserLog('autocmd syntax val:', a:val)
    if a:val ==? 'on'       " equal ignore case
        call UserCustomSyntaxHighlights()
        call UserSyntax()
        "echom 'user syntax rules loaded'
    endif
endfunction
endif


" no longer in use.
"
" for some filetypes, initially turn on syntax highlighing.
" caveat - ownsyntax refuses to turn on without a filetype.
"
" one issue - disabling syn, switching away and switching back to
" a window, turns syn on again. working around that with a window var
" and managing that var (f.ex. clearing it in a BufReadPost for
" new file loads etc. isn't worth the trouble.
if v:false
function! UserSetWinSynByFt(...)
    call UserLog('UserSetWinSynByFt for win', winnr())
    " use parameter if provided, or local filetype
    let l:param_filetype = (a:0 > 0 && type(a:1) == v:t_string)
        \? a:1 : &l:filetype
    if empty(l:param_filetype)
        " empty file, probably. can't turn on ownsyntax, just load
        " our syntax rules.
        " alternatively, we could do :silent ownsyntax on.
        " ownsyntax will fail because no filetype, but the Syntax autocmd
        " will be invoked with 'on' anyway, and our syntax rules will get
        " loaded.
        call UserAutoSyn('on')
        return
    endif
    let l:flag = g:user_syn_fts =~? l:param_filetype ? 'on' : 'off'
    call UserLog('autocmd ownsyntax ft:', l:param_filetype, 'fl:', l:flag)
    " it's important to run for both 'on' and 'off' to get our
    " rules to take effect.
    " run ownsyntax + save and restore spell options
    call UserOwnSyntax(l:flag)
    call UserAutoSyn(l:flag)
endfunction
endif


" ----

" doc fo-table
command Nowr    setlocal fo=t nospell ai nosi nocin
command FoText  setl fo=at
command FoCode  setl fo=cjoqr nosi cin
"
" NB: autoindent affects fo-at
" spelling: probably better to switch to native aspell and dict-gcide
"   (GNU Collaborative International Dictionary of English)
command Wr      setlocal tw=78 fo=at nocin nosi noai spell
" for transcribing poetry -
" significant whitespace, auto-indenting, no hard tabs, no auto formatting
" remember - delete to beginning of line: 0d (V), Ctrl-U (I);
"   Ctrl-U is readline unix-line-discard.
" set colorcolumn=16,32,48,64,80,96 might also help.
command Poetry  setlocal tw=0 formatoptions-=ta sts=4 sw=4 sts=4 ai et nospell
command Proper  setlocal softtabstop=8 shiftwidth=8 noexpandtab
" for Python and common scripting languages
command Lousy   setlocal softtabstop=4 shiftwidth=4 expandtab
" for lisps
command Lisp    setlocal softtabstop=2 shiftwidth=2 expandtab
command Retab   %retab
" numbering; use 'windo' (as usual) if necessary.
command NoNumber            set nonumber | set norelativenumber
command RelativeNumber      set nonumber | set relativenumber
command Number              set norelativenumber | set number

command ShowBreak       let &l:showbreak = g:user_showbreak_char
command NoShowBreak     setlocal showbreak=NONE
" turn on our syntax highlighting, without regard for global syntax flags
command Syn             call UserHS(v:true)
" sometimes a mess is useful; load a scheme and force our own style
" command Colour          syn enable | color desert | set bg& | Syn
command -nargs=1 CH     set cmdheight=<args>
command Colortest       runtime syntax/colortest.vim


" enable/disable paste mode - outdated; vim supports bracketed paste now.
command Pst     setlocal paste
command Nopst   setlocal nopaste
command Spell   setlocal spell
command NoSpell setlocal nospell

" to turn the status line on
command St      set laststatus=2
" to turn the status line back off
command Nost    set laststatus=0

command B       echom UserBufferInfo()
command Basic   call UserTermBasic()

command Stws        call UserStripTrailingWhitespace()
command Lst         let &l:list = !&l:list

" useful when testing :NB and opening many scratch windows.
command Die windo q
" new window for scribbling
command Scratch new | setlocal buftype=nofile noswapfile filetype=text

" like :Explore
command Index   call UserOpenIndexFile()

" list default - set listchars to global pref
command ListDef     let &g:listchars = UserSetListchars(0) <bar> windo set list
" list including tabs
command ListTab     let &g:listchars = UserSetListchars(1) <bar> windo set list

command VeDefault   set virtualedit=block,onemore

" search for the nbsps that 'list' also uses
" but vim isn't great for this; use perl5:
"       perl -Mopen=locale -pe 's/[\N{U+202f}\N{U+00a0}]/[X]/g'
command Fnbsp            /[\u202f\ua0]


" use file(1) to determine if fn is a text file
function! UserDetectTextFile(fn)
    if !has('unix') | return -1 | endif
    let l:fnesc = shellescape(a:fn, 1)
    "echom 'passing to file: ' . l:fnesc
    silent let l:out = systemlist('/usr/bin/file -b --mime-type ' . l:fnesc)[0]
    if v:shell_error
        echoerr 'file(1) failed, status ' . v:shell_error
        return -2
    endif
    if l:out == 'text/plain'
        return 0
    endif
    return -3
endfunction


function! UserAutoSetFtText(fn)
    "echom '[userauto ft text]'
    " if a filetype's present, don't mess with it
    if did_filetype() | return | endif
    if exists('&l:filetype') && !empty(&l:filetype) | return | endif
    if &binary | return | endif

    " file names and paths are awkward.
    " if there seems to be an ascii extension but it's neither txt nor text,
    " don't bother.
    if a:fn =~? '\.[a-z]\+$' && a:fn !~? '\.te\?xt$'
        return
    endif
    " 2022-02-07
    " if vim's called with f.ex. -- --f, where --f doesn't exist, this function
    " might get called with it, though the autocmd should not fire in this case.
    if !filereadable(a:fn) | return | endif

    if UserDetectTextFile(a:fn) == 0
        setlocal filetype=text
    endif
endfunction


" mine own -#autogroup
augroup UserVimRc
    autocmd!

    " enable auto reformatting when writing journal entries,
    " not for all text files.
    " format manually: gqip or vip, gq
    autocmd BufNewFile,BufReadPost  writing*.txt,NOTES*.txt     Wr
    " the first line of the commit message should be < 50 chars
    " to allow for git log --oneline
    autocmd BufNewFile,BufReadPost COMMIT_EDITMSG   setl tw=78 spell cc=50,80
    autocmd BufReadPost *music-comments.txt     setl nospell

    " for file names without an extension -
    " if file(1) thinks it's a text file, treat it as such.
    autocmd BufReadPost *   call UserAutoSetFtText(expand('<afile>'))

    autocmd BufNewFile      /etc/*                  Proper
    autocmd BufReadPost     /etc/*                  Proper
    autocmd FileType        c,sh,conf               Proper
    autocmd FileType        perl,python,vim         Lousy
    autocmd FileType        ruby,eruby              Lousy
    autocmd FileType        lisp,scheme,clojure     Lisp

    autocmd BufWritePre *   call UserStripTrailingWhitespace()
    autocmd BufWritePre *   call UserUpdateBackupOptions()

    "autocmd TermResponse * echom 'termresponse:' strtrans(v:termresponse)
augroup end



" autogroup for my weird syntax dealings
augroup UserVimRcSyntax
    autocmd!

    " in and out of the rube goldberg machine. ref - syntax/synload.vim, Syntax
    " autogroup. we start with syntax highlighting globally on. then we make use
    " of 'ownsyntax' to turn it on and off per window. the filetype decides if
    " ownsyntax gets turned on. when the Syntax autocommand fires, we append our
    " own syntax matches. triggered by filetype, decide whether to :ownsyntax on
    " or off. this has the downside of not being able to force syntax off for
    " a window; switching away and back to a window will again turn syntax on
    " for that window, by filetype.

    " this should run for each buffer switch, the FileType event isn't enough.
    " BufWinEnter for the initial window,
    " WinEnter for subsequent splits.
    "autocmd BufWinEnter,WinEnter  * call UserSetWinSynByFt()
    "autocmd BufReadPost  * call UserSetWinSynByFt()
    "
    " this is much simpler than what we built up earlier around ownsyntax,
    " but has the downside the syntax highlighting stays enabled by default
    " for all filetypes.
    autocmd BufWinEnter *  call UserHS()

    " triggered by 'ownsyntax'; if 'on', append our rules
    " 2022-02-20
    " this definitely worked, and then stopped working. The event still fired
    " and the rules seemed to run as expected, they just weren't visible, and
    " took no effect.
    " now UserSetWinSynByFt() calls UserAutoSyn() by itself. this path is more
    " deterministic anyway.
    " autocmd Syntax      *   call UserAutoSyn(expand('<amatch>'))

    " on colourscheme load/change, apply our colours, overriding the scheme.
    autocmd ColorScheme *   call UserColours()
augroup end

if v:false
    augroup UserLogAutoEvents
        autocmd!

        autocmd FileType    *   call UserLog('ae FileType')
        autocmd BufEnter    *   call UserLog('ae BufEnter')
        autocmd BufWinEnter *   call UserLog('ae BufWinEnter')
        autocmd WinEnter    *   call UserLog('ae WinEnter')
        autocmd BufReadPost *   call UserLog('ae BufReadPost')
        autocmd BufCreate   *   call UserLog('ae BufCreate')
        autocmd BufNew      *   call UserLog('ae BufNew')
    augroup end
endif

" ----
" various plumbing/hacks

" Warning: xterm with TERM == xterm-direct doesn't handle 256 colours well.
" Despite issues, it's nice how VTE can handle 256 colours and truecolor at
" the same time.
" NB: disabled - now we use vim in ttys using 256 colours, lucious color scheme
" set to not touch Normal ctermbg.
"call timer_start(150, 'UserCheckEnableTermGuiColors')
"call UserCheckEnableTermGuiColors()

" colour
" mlterm causes an extra reload of the colorscheme.
" Debian vim might start with syntax off.
" That's actually nice to start with, but syn off -> enable is an Upheaval.
"
" Take care when testing with xterm: vim always seems to think bg == light,
" with both -rv (reverse) and -fg white -bg black.
" urxvt and bg detection works as expected.

" syntax handling and redrawing
" lucius needs some time
if &redrawtime > 700
    set redrawtime=700
endif
"syntax sync minlines=50
set synmaxcol=200
set background&     " sometimes even works.
" hack upon hack:
" for terminal emulators, if the $COLORFGBG kludge isn't available...
if v:false && !has('gui_running') && !exists('$COLORFGBG')
    \ && v:version < 900
    \ && &term != 'vt220' && &term !~ 'putty'
    set background=light
endif
syntax on


" turn syntax colours on for window
" :ownsyntax off resets syntax definitions (but not highlight groups);
" need to reload our rules.
nnoremap <silent> <F2>      :call UserOwnSyntax('on') <bar> call UserSyntax()<CR>
" turn syntax colours off for window
nnoremap <silent> <F3>      :call UserOwnSyntax('off')<CR>

" most colorschemes don't pull their own weight. would be great if a colorscheme
" + reload behaviour would take a closure instead of requiring a file on disk.
" And seperate user interface component highlights from text content highlights.
"
" order's significant here; whether bg& before or after depends on what the
" scheme does.
"
" test tip: COLORFGBG='15;0' xterm -tn xterm-vt220 -fg \#ffb000 -bg grey10
" desert for dark, shine for light. with modifications to not touch important
" highlights and not modify 'background'.
"
" start by erasing the default highlights, which are very annoying, specially on
" terminals with few colours.
call UserSafeHighlights()

if UserRuntimeHas('colors/tty.vim')
    " colorscheme tty
    nnoremap <F4>   :colorscheme tty<CR>
endif

" 2022-03-09 lucius light and white modes seem to trigger a bug in gvim on
" Linux. The command window rendering becomes subtly broken, selected text
" almost invisible.
"
" 2022-06-30 gvim command window under lucius looks good now.
"
" in any case, the default vim syntax definitions are maybe 60% good anyway.
" setting non-tty-fg dark colours on "normal" text bothers me a little too.
if UserCanLoadColorscheme() && UserRuntimeHas('colors/lucius.vim')
    let g:lucius_no_term_bg = 1     " perfect, A+; cterm only, not for tgc
    colorscheme lucius
    nnoremap <F5>   :colorscheme lucius<CR>
    if has('gui_running')
        LuciusLight
    endif
endif
" call UserLog('t_Co', &t_Co)
" t_Co might be undefined here for gvim? definitely undefined in iVim (iOS.)
if v:false && UserCanLoadColorscheme() && UserRuntimeHas('colors/iceberg-wrapped.vim')
    colorscheme iceberg-wrapped
    nnoremap <F5>   :colorscheme iceberg-wrapped<CR>
endif

" if no colorscheme found/loaded, the ColorScheme autocmd won't work.
" load our UI colour overrides.
if !exists('g:colors_name') || g:colors_name ==? 'default'
    call UserColours()
endif

" ~ fini ~

" vim:tw=80 fo=croq:
