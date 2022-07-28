set nocompatible secure encoding=utf-8 fileencoding=utf-8 nobomb nolangremap
scriptencoding utf-8

" Last Modified: 2022-07-28
"
" 2022-07-28 Added colour overrides for dark backgrounds. For using iVim at
" night.
"
" 2022-07-25 Bring back syntax rule-based custom highlights. I missed the
" old URL syntax behaviour.
"
" 2022-07-22 Fixes to the mapping (,1) that joins a paragraph into one line.
" Disabled 'q' (recording, as well as q[:/?]) in normal mode.
"
" 2022-07-21 Fixes to the auto backup behaviour. Check the current buffer
" filename against 'backupskip' to see if the file would be backed up, before
" creating directory hierarchies under ~/.backup. Also keep 'ignorecase' off.
"
" 2022-07-20 Clean up the functions that manage fillchars and listchars.
" Command-line window: always enable line numbers and 'list'.
" vim 8.1 or thereabouts seems to have trouble parsing trimmed heredocs;
" so such code blocks are now left ugly for compatibility.
" 'lazyredraw' also seems to delay the initial screen painting, maybe depending
" on other factors. 'lazyredraw' removed. also went back to strinc concatenation
" with a single dot instead of '..'.
"
" 2022-07-13 went away from trying to extend syntax matching with our own rules
" and struggling to have our rules applied in all desired circumstances.
" Using matchadd() now, in UserMatchAdd().
" Lots of syntax-related functions and comments still left lying around.
"
" On startup, create ~/.vim/syntax/after/text.vim if necessary, to have
" our syntax rules applied in a robust and consistent manner.
"
" Normal mode mapping to paste easily in iVim.
"
" 2022-06-28: Hashtag prefix sequence changed from a single Greek Cross
" (🞣, U+1F7A3) to "-#". The Greek Cross isn't visible and causes rendering
" issues in iVim (iOS.)

" Long, somewhat disorganized, too large a file, my bonsai project. Lots of
" barnacles from documentation spelunking and trying various options. Tired now,
" don't want to touch it for the next 10 years, when it'll be safe to move to
" vim9script.
"
" notes:

" Other vimmers:
" Yasuhiro Matsumoto
" https://web.archive.org/web/20160130063001/http://howivim.com/2015/mattn/
"
" Kana Natsuno
" https://github.com/kana/config/tree/master/vim/personal
" https://whileimautomaton.net/
"
" aereal - https://github.com/aereal/dotfiles/tree/main/.vim
"
" Akkana - https://github.com/akkana/dotfiles/tree/master/.vim

" ! check out $VIMRUNTIME/defaults.vim from time to time.

" wish (x)vile had become popular instead of vim. not going to bother
" splitting this up into separate files. missing features: proper stacktraces,
" loggingat specific levels, the ability to trace (without a debugger) when
" options like t_Co change.

" would be nice if functionality had names like emacs and vile, instead of keys
" that can be remapped. though the vi/vim way is more immediate for the common
" case.

" ---------------------------------------------
" most insidious: :Next (, :wNext, :cNext etc.)
" ---------------------------------------------
" does the same thing as :previous, yet is shaped like the opposite of :prev.
" light dawns when you notice that :Next is :(<shift>n)ext, "inverted" :next.
" looks like a user-defined command, isn't.
" doc: user-cmd-ambiguous

" vim settings like backupskip and spelllang should be sets, instead of
" strings with commas.

" colorschemes should be scoped better, or vim needs a real module system.
" for more control/better isolation.

" Makes use of external commands: dash/bash, par, GNU date, file, xsel.

" $MYVIMRC, $VIMRUNTIME, $VIM

" function definitions: s: and <SID> - too cumbersome, using prefix User
" instead to namespace. vim9 gets this right anyway. But this convention has
" the downside of making function names camel-case.

" Leave out <silent> from mappings that end with <cr>. Errors/missing <cr>s
" can fail without any indication of what went wrong.

" If the vim version's recent enough, new colour names can be defined by
" adding to v:colornames (def: $VIMRUNTIME/colors/lists/default.vim).

" To prevent background dark/light detection
" doc 'background'
" set t_RB= t_BG=

" My syntax rules are in /UserMatchAdd(), with highlights in UserColours().

" Re-implementing the mode message by decoding mode() seemed fun at one time
" but it was slow.


" :sball - show all buffers; inverse: :only / C-w o
"   <F11>

" @% - current filename;

" :0file - remove name from buffer

" strtrans() (dep 'display'); 0, 10, ^@, ^J, <Nul>, <NL>, doc :key-notation
"   https://unix.stackexchange.com/a/247331

" 8g8   g8  g;  g,  gd

" put line in command line :<C-r><C-l>, WORD: :<C-r><C-a>

" list all augroups - :augroup<cr>

" debug log: vim -V16vdbg; block buffered; use echom to add markers.
"   verbosity level 10: autocommands; 12: function calls.
"   verbosity can interfere/leak in various places; when redirecting
"   message output, the command window after system() output in gvim.
"

" standard plugins in $VIMRUNTIME/plugin - disable.
"{{{
" unimaginable functionality. would be nice to chmod 0, but often can't.
" /usr/share/vim/vim*/plugin/
"   {tohtml,gzip,rrhelper,spellfile,{getscript,tar,vimball,zip}Plugin}.vim
"   matchparen.vim - nice, but the autocommands feel yucky.
"   manpager - vim can be a rather nice manpager.
"
let g:did_load_filetypes = 1
let g:loaded_matchparen = 1
let g:loaded_2html_plugin = 1
let g:loaded_gzip = 1
let g:loaded_getscriptPlugin = 1
let g:loaded_tarPlugin = 1
let g:loaded_vimballPlugin = 1
let g:loaded_zipPlugin = 1
" don't need netrw, i do file management in the shell.
let g:loaded_netrwPlugin = 1
" instead try :cexpr system( grep ) ...
let g:loaded_logiPat = 1
"}}}

" 2022-07-28 clear out autocommands of other people.
" {{{

" i.e., redhat/fedora /etc/vimrc duplicates some of defaults.vim, things that
" are meant to be pulled in only when the user has no .vimrc. this seems to
" interfere with jumping to the last location on some files.
"
" at least the worst is in a named augroup. viml parsing is extra picky
" with au/aug. autocmd_delete() isn't available on deathrow rhel boxen.
" distributions use various augroup names. debian doesn't add augroups,
" thankfully. augroup listing is inconvenient.

if exists('#fedora')
    augroup fedora
    autocmd!
    augroup END
    augroup! fedora
endif
if exists('#redhat')
    augroup redhat
    autocmd!
    augroup END
    augroup! redhat
endif
" }}}

if has('unix')
    if !empty(exepath('/bin/dash'))
        set shell=/bin/dash
    elseif !empty(exepath('/bin/bash'))
        set shell=/bin/bash
    endif
    " ripgrep
    if executable('rg')
        let &grepprg = 'rg --vimgrep --no-heading --smart-case'
    endif
endif

" journalled filesystems, SSD/NVMe/SD cards. fsync is complex these days, it's
" not clear that vim does everything that's needed.
" https://www.linusakesson.net/programming/vimsuspend/index.php (old)
" https://twitter.com/marcan42/status/1494213855387734019
" fsync directory? aio_fsync?
set nofsync swapsync=
" how files should be written - whether to rename, or put the new data
" into the same file. the vi default behaviour is yes, and it's the most
" natural with vim as $EDITOR.
set backupcopy=yes

set modeline
" love/hate relationship with this. can be annoying.
" a plugin that requires these: vimoutliner
filetype plugin off
" language-specific auto indenting is about 10% solved.
filetype indent off
" often assumed; and some curious behaviour - vim always
" seems to set filetype for the first buffer, but not other loaded files.
" filetype off ought to exclude setting ft for the first buffer...
filetype on

" 2022-07-16 selective syntax highlighting no longer in use

" U+21B3 - DOWNWARDS ARROW WITH TIP RIGHTWARDS
let g:user_showbreak_char = '↳'
lockvar g:user_showbreak_char

let g:user_has_x11 = exists('$DISPLAY')
lockvar g:user_has_x11

" fence, guard; defend; idle time
let g:user_mark = nr2char(0x95F2)
if &term ==# 'linux' | let g:user_mark = '0' | endif
lockvar g:user_mark

if !exists('$PARINIT')
    let $PARINIT = "rTbgqR B=.,?'_A_a_@ Q=_s>|#"
endif


" it's fine. incsearch can be an unwelcome surprise over ssh.
set noincsearch

" setting 'ignorecase' can be surprising.
" for example, checking filenames against the 'backupskip' patterns uses
" 'ignorecase'.
set noignorecase
set hlsearch
set noshowmatch
set noerrorbells
set showcmd
" doc fo-table
set formatoptions=t
" leave only one space after ./?/! when joining
set nojoinspaces
set linebreak
" wrapmargin adds <EOL>s, never use.

" http://stackoverflow.com/a/26779916/1183357
set backup backupdir=~/.backup
" backupskip is a list of patterns - beware of ignorecase.
set backupskip+=COMMIT_EDITMSG,NOTES-*.txt

" 'directory' - we used to set the swapfile location to a central place, it
" seemed like a good idea, but keeping it near the file being edited is better
" when editing from different hosts.
set directory=. swapfile updatecount=10
" to see current swap file path: ':sw[apfile]' / swapname('%')
if has('persistent_undo')
    " we used to keep all undo files under ~/.vim_undo; fill path with the
    " % thing in filenames.
    " now we keep undo files in the same directory as the file, as .<file>.un~
    set undofile undodir=. undolevels=200
endif

" mapleader is a variable, not a setting; no &-prefix
let g:mapleader = ','
" hide search wrap and file written messages
" shortmess "f", "w" are nice, so not adding "a"
set shortmess+=i
set shortmess+=l
set shortmess+=m
set shortmess+=n
set shortmess+=r
set shortmess+=x
set shortmess+=o    " since we use 'autowriteall'
set shortmess+=W    " don't show "written"/"[w]"
set shortmess+=I    " hide intro
set shortmess+=c    " hide ins-complete-menu messages

" a little like :behave mswin, but not all the way. think DOS EDIT.COM.
" set keymodel=startsel selectmode=mouse,key
" don't use SELECT mode
set selectmode=

" laststatus: 0 = never, 1 = show if multiple splits, 2 = always.
set laststatus=0

" disabling 'ruler' makes 3<C-g> print more info.
set ruler rulerformat=%=%M\ %{g:user_mark}
set showmode
" never changing tabstop again
set tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
set fileformats=unix,dos
set smarttab
set shiftround
set backspace=indent,eol,start

" move, in normal+visual with, <left> and <right>.
" NB regarding the default (b,s) - we map <bs> to disable hlsearch, and i've never
" used <space> to go forward. so, instead of +=, here we do =.
set whichwrap=<,>


" indentation
" cindentation's a bit too intrusive for plaintext. smartindent too can be
" annoying. have seen 'undeletable' (x doesn't work) tabs.
set autoindent
set colorcolumn=+1
set nolinebreak
" showbreak's troublesome in X11 ttys, when selecting purely with the mouse.
" will be fine using visual mode/line numbers and the xsel(1) integration
" mappings and commands further below.
" highlight group: NonText
let &showbreak = g:user_showbreak_char

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

set scrolloff=2
set cmdheight=1
"set cursorlineopt=number,screenline cursorline
"set confirm
set autoread autowriteall
set hidden
set matchpairs+=<:>,«:»,｢:｣

" ttyfast - seems to be about terminal capabilities and less about line speed.
" can disable if exists('$SSH_CONNECTION') && !g:user_has_x11

if v:version >= 900
    " display completion matches in a popup menu
    set wildoptions=pum

    " new-ish options, lumped under '900'.
    set nomodelineexpr
    " use NFA regexp engine?
    set regexpengine=2
    " predictable time formats and messages
    language time C
    language messages C
endif
set wildmenu
" don't complete until unique
set wildmode=list:longest,list
set wildignorecase
" don't complete swap, undo files and others.
set wildignore=.*.swp,.*.un~,*.pyc

" viminfo: don't save registers.
set viminfo='100,<0,s0,h,r/tmp
if exists('$TMPDIR') && $TMPDIR !=# '/tmp'
    execute 'set viminfo+=r' . $TMPDIR
endif

set browsedir=buffer
"set autochdir - too cumbersome
set virtualedit=block
" perhaps the 2nd best thing about vim - the following options are enabled
" by default.
set endofline fixendofline

" helps with navigating to a line of interest with <no>j and <no>k,
" but also takes up a lot of space.
"set number relativenumber

set switchbuf=split splitbelow splitright

if version >= 801 && has('patch-8.1-360')
    set diffopt+=indent-heuristic
    set diffopt+=algorithm:patience
endif

" if not gvim, do not connect to X; can slow down startup.
" doesn't seem to be a problem on fedora, vim-enhanced doesn't have +X11
if has('X11') && has('clipboard') && !has('gui_running')
    set clipboard=exclude:.*
endif
set mouse=

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
    let l:enabled = v:false
    if !l:enabled && (&verbose == 0)
        return
    endif
    let l:verbosity = &verbose
    set verbose=0
    " above to prevent logging of the body of this function
    " at high verbose levels.

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

    if l:enabled
        let l:fn = expand('~/.vimlog')
        try
            call writefile([l:logmsg], l:fn, 'a')
        catch /^Vim\%((\a\+)\)\=:E/
            " for read-only filesystems, f.ex.
            " can't do much, don't want to echom
            return
        endtry
    endif

    " reset verbosity and return everything, which will be included in the
    " vim verbosefile when enabled.
    " the verbosity modification ought to be done in a try/finally block.
    if l:verbosity > 0
        " might put this into a finally block
        let &verbose = l:verbosity
    endif
    return l:logmsg
endfunction


function! UserRuntimeHas(pathspec)
    return !empty(globpath(&runtimepath, a:pathspec, 0, 1))
endfunction


" given a string like a vim setting ("a:b,c:d") where items/pairs are separated
" by commas and each key/value pair is separated by colons, build a dict
" mnemonic: CoCo: ColumnComma or CommaColumn
function! UserCoCoToDict(s) abort
    let l:l1 = split(a:s, ',')
    let l:d = {}
    for l:pair in l:l1
        let [l:k, l:v] = split(l:pair, ':')
        let l:d[l:k] = l:v
    endfor
    return l:d
endfunction

" for sorting dict items by the key (first item of the list).
" a little better than sorting by the stringified list.
" mnemonic: UserListPairKeyComparator
function! ULPCompr(pair_left, pair_right) abort
    let l:key_left = a:pair_left[0]
    let l:key_right = a:pair_right[0]

    return l:key_left == l:key_right ? 0 :
        \       l:key_left > l:key_right ? 1 :
        \           -1
endfunction

" given a dict, build a colon and comma-separated string that vim can accept
" as the value of a setting.
function! UserDictToCoCo(d) abort
    let l:tmp = []
    for l:pair in sort(items(a:d), 'ULPCompr')
        let l:joined_col = join(l:pair, ':')
        call add(l:tmp, l:joined_col)
    endfor
    return join(l:tmp, ',')
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
" U+263A WHITE SMILING FACE / cp437 char 0x1

function! UserListchars(incltabs) abort
    let l:lcs = UserCoCoToDict(&listchars)
    " our defaults
    let l:lcs.nbsp = '☺'
    let l:lcs.precedes = '<'
    let l:lcs.extends = '>'

    " unicode control pictures - never very legible, but enough to indicate
    " that something's there.

    " trail:
    " trailing spaces will be shown by the pattern in UserMatchAdd().
    " U+2420 SYMBOL FOR SPACE
    " let l:lcs.trail = '␠'

    " eol:
    " U+2424 SYMBOL FOR NEWLINE
    " U+21B2 DOWNWARDS ARROW WITH TIP LEFTWARDS - parity with g:user_showbreak_char
    let l:lcs.eol = '↲'

    " tab:
    " by default, show (effectively hide) tabs using plain spaces.
    " the default "^I" is horrendous.
    " highlighting (SpecialKey) is still applied.
    let l:lcs.tab = "\u20\u20"
    if a:incltabs
        " U+2409 SYMBOL FOR HORIZONTAL TABULATION
        " U+2192 RIGHTWARDS ARROW
        let l:lcs.tab = '→·'
    endif

    return UserDictToCoCo(l:lcs)
endfunction


" 'fillchars' can accumulate items of same type. the last is effective. but
" the accumulated output is a mess and can be confusing. this function
" can be used to remove redundant items.
"
" input should be a dict of items that 'fillchars' understands.
" example: UserFillChars({'stl': 'x', 'stlnc': 'y'})
"
" could have just used a:000, but it's also nice to be explicit about
" what's expected.
"
function! UserFillchars(...) abort
    let l:fcs = UserCoCoToDict(&fillchars)
    " start with existing fillchars. if first param is an array, append it.
    if a:0 > 0 && type(a:1) == 4
        call extend(l:fcs, a:1)
    endif

    return UserDictToCoCo(l:fcs)
endfunction


function! UserSetupFillchars()
    " plain underscores don't join, that's ugly. elsewhere, for old
    " vim versions, we use a full, traditional statusline. don't want to use
    " fillchars stl/stlnc then.
    let l:fcs = {}

    if has('gui_running') || g:user_has_x11
       \ || &term =~# 'xterm' || &term =~# 'rxvt' || &term =~# 'putty'
        " U+2504 - BOX DRAWINGS LIGHT TRIPLE DASH HORIZONTAL
        " U+2502 - BOX DRAWINGS LIGHT VERTICAL
        "   (vert default: U+007C    VERTICAL LINE)
        let l:fcs.fold = nr2char(0x2504)
        let l:fcs.vert = nr2char(0x2502)

        " for the statuslines:
        " U+23BD HORIZONTAL SCAN LINE-9 is nice, but not quite low enough.
        " Being a multibyte character, causes issues with rxvt-unicode.
        "
        " vim patch-8.2.2569 is also required.
        "
        " ref https://www.kernel.org/doc/html/latest/admin-guide/unicode.html
        "   (outdated: F804, DEC VT GRAPHICS HORIZONTAL LINE SCAN 9)
        " https://graphemica.com/blocks/miscellaneous-technical/page/3

        " 2022-07-26 using StatusLineNC more instead of fillchars.
        if v:false && has('patch-8.2.2569')
            " BOX DRAWINGS LIGHT HORIZONTAL
            let l:hrz = nr2char(0x2500)
            let l:fcs.stl = l:hrz
            let l:fcs.stlnc = l:hrz
        endif
    endif

    " set fillchars once we're done with all the if's.
    return UserFillchars(l:fcs)
endfunction


" our statusline and highlight groups (VertSplit) depend on what's included in
" fillchars. so, set it early before defining statusline and our highlight
" overrides.
let &fillchars = UserSetupFillchars()

let &listchars = UserListchars(0)

"-- doc 'statusline'
" should allow three vertical splits.
" verbose info should go into UserGetInfoLines().
"
" %f - filename - expand('%')
" %< - truncate from here when needed
" %n - buffer number
" then turn window id to window number; trailing comma gets some cleanup
" %M - modified: +, nomodifiable: -, both: +-
" %R - read only? ,RO
" %W - preview - ,PRV
" %Y - filetype - f.ex. ,VIM
" %H - help buffer flag, redundant, shows up in filetype
" %q - "[Quickfix List]", "[Location List]" or empty
"   in such buffers %f turns into the same thing.
" %= - separation point, start right-aligned
" %l - line number
" %v - screen column number
" %c - column number, byte index
" adding conditionals on &l:buftype etc. can be confusing because this function
" gets evaluated for all windows with some settings from the current buffer.
"

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
" note, a space before and after the ma.
" note, %M right after %R, and not at the end of the buffer attribute list.
" otherwise, with fillchars, for non-modifiable buffers the %M becomes a "-",
" looking like a part of the stl/stlnc fillchars, which looks bad.
"
" trail: %l:%c%V; really, better to enable 'number' and 'relativenumber'
" instead of having line:col flickering all the time.

" %M and %R don't do exactly what i want...
function! UserStLnBufModStatus()
    let l:m = ''
    " NB attribute check order
    if &modified    | let l:m .= '+'    | endif
    if !&modifiable | let l:m .= '-'    | endif
    " if neither modified nor unmodifiable:
    if empty(l:m)   | let l:m .= 'f'    | endif
    if &readonly    | let l:m .= '.ro'  | endif
    return l:m
endfunction

function! UserStLnTextWidth()
    return &paste ? '!P' : &textwidth
endfunction

" tried prev: if fillchars has 'stl', use hl Normal between the buffer
" attrib flags and the right hand side, as:
" %...%#Normal#%=...
"
" %Y is too loud, %y has brackets - use raw &filetype, show always.
"   ! NB non-current (NC) status lines don't update immediately when the
"   filetype changes. %y doesn't help (same behaviour as %{&filetype}).
"   workaround: :redrawstatus, of course. actually, moving to the command line
"   (no need to run redrawstatus) seems to be enough, with nolazyredraw.
"
" %w (Preview) is somewhat special, so it gets to hang around.
"
" would prefer parentheses, but brackets are hardcoded for default buffer names
"   ("[No Name]", "[Scratch]").
"
" aside: Mathematica: brackets - https://mathematica.stackexchange.com/q/72976
"
" d[] for delta -> change -> modified/modifiable status.
"   d[f] == quiescent, no unwritten changes, finalised -> delta? false.
"

" gather up buffer info into one function - to execute in a single %{}.
" Using printf for chit-chat.
function! UserStLnBufFlags()
    return printf('tw%s d[%s] ft[%s]',
        \ UserStLnTextWidth(),
        \ UserStLnBufModStatus(),
        \ &filetype)
endfunction

" use :execute to evaluate g:user_mark once, instead of in another %{}.
execute 'set statusline=%<%f\ b%n%#StatusLineNC#\ %{UserStLnBufFlags()}%w%=\ '.g:user_mark.'\ '

" -- enough now.

" test statusline appearance with:
"   command window: :<C-f>
"   help
"   preview: :pedit <file>
"   :setl modified nomodifiable readonly

" the tabline doesn't update itself in the same way the statusline does.

" old yak-shaving: if g:statusline_winid available (has('patch-8.1.1372')),
" include window number in statusline. this variable's made available only in
" statusline functions.
"
" winnr = win_id2win(g:statusline_winid)
"
" 2022-07-07 drop the window number; never needed it. and, with only one level
" of interpretation (not reinterpreting the return value of the statusline
" function, the statusline should be faster.
"
" doc patches-8


function! UserDateTimeComment()
    " month (%b) and day (%a) should be 3 chars each
    return strftime('-- date %F %T%z (%b, %a)')
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

python3 << PYEOF
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

PYEOF

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
    let l:ts = "(null)"
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
"
" sandbox is too strict, prevents useful commands like 'au'.
" hard to get side effects right with destructive commands. caveat emptor.
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
            let &verbose = l:verbosity
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
        " put all the info into a new scratch buffer that can be dismissed
        " easily
        Scratch
        call append(0, a:lines)
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
        \ 'ts': &ts, 'tw': &tw, 'lbr': &lbr }
    return UserDictToStr(l:bufp)
endfunction


" https://stackoverflow.com/a/23323958
function! UserGetScreenChar()
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

" unicode name lookup.
" previously, lookup via https://ucdapi.org/unicode/10.0.0/codepoint/hex/
" now, python3 has more recent UCD data.
function! UserScreenCharLookup() abort
    let l:screen_char = UserGetScreenChar()
    if l:screen_char ==# ''
        return 'NUL'
    endif

python3 << PYEOF
import unicodedata
import vim

screen_char = vim.eval('screen_char')
u_name = unicodedata.name(screen_char)

PYEOF

    let l:u_name = py3eval('u_name')
    let l:fmt = printf('''%s'' U+%04X %s',
        \ l:screen_char, char2nr(l:screen_char), l:u_name)
    return l:fmt
endfunction

command UC  echom UserScreenCharLookup()


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

    function! s:addl(ln) closure
        call add(l:lines, a:ln)
    endfunction

    " window info
    let l:win = 'wnd: ' . winnr()
    if exists('*win_getid')
        let l:win .= ', id ' . win_getid()
    endif
    " window size: getwininfo(win_getid())

    call s:addl('bufnr: ' . bufnr())
    call s:addl(UserBufferInfo())

    let l:enc = { 'enc': &enc, 'fenc': &fenc }
    call s:addl(UserDictToStr(l:enc))

    " let l:bufp_misc = { 'filetype': &ft, 'syntax': &syn }
    " call s:addl(UserDictToStr(l:bufp_misc))

    " this was nice while debugging colour/term issues
    " let l:t_co = 't_Co=' . &t_Co
    " call s:addl(l:t_co)

    " syntax groups under the cursor, if any
    let l:syn_cur = 'syn: ' . join(UserSyntaxNamesAtCursor(), ' ')
    call s:addl(l:syn_cur)

    call s:addl('matches (pat. hl.): ' . len(getmatches()))

    " include some info about the char under the cursor.
    " don't need chrisbra/unicode.vim any longer.
    if has('python3')
        let l:char_info = UserScreenCharLookup()
    else
        " fallback - the output of the :ascii command. no unicode name.
        let l:cmd = ':ascii'
        let l:char_info = UserRun(l:cmd)
        if l:char_info[0] ==# "\n"
            let l:char_info = strpart(l:char_info, 1)
        endif
    endif
    call s:addl('--')
    call s:addl(l:char_info)

    " reminders, which have to be manually maintained for now.
    " damian conway has his own documented mappings; not yet worth the trouble.
    call s:addl('--')
    call s:addl('g;    g,')

    delfunction s:addl
    return l:lines
endfunction


" return some info about the buffer and the current location,
" a little like 3<C-g>
function! UserLoc()
    let l:name = bufname()
    if l:name == ''
        " don't bother to duplicate "No name", "Scratch" etc.
        let l:name = '[]'
    endif
    let l:lno_cur = line('.')
    let l:lno_end = line('$')
    let l:perc = l:lno_cur * 100 / l:lno_end
    return printf('buf %d: %s %d:%d $ %d --%d%%--',
        \ bufnr(), l:name, l:lno_cur, col('.'), l:lno_end, l:perc)
endfunction


" NB: return value ("\<Ignore>") - important for using in insert mode.
" otherwise, function return value will be appended to the buffer.
" doc :map-expression
function! UserShowHelp()
    let l:lines = UserGetInfoLines()
    call UserAlert(l:lines)
    return "\<Ignore>"
endfunction


" compute backupdir and backupext that should be used for automatic backups.
" $HOME is very long on iOS.
" this function has no side-effects, so doesn't care if the file would be backed
" up or not.
function! UserBufferBackupLoc(fn) abort
    let l:filepath = fnamemodify(a:fn, ':p:h')

    if has('win32')
        " for microsoft windows - replace the ':' after drive letters with '$'
        let l:filepath = l:filepath[0] . '$' . l:filepath[2:]
    endif

    " could start with g:backupdir
    let l:backup_root = expand('~/.backup')
    let l:tm = localtime()

    " like: ~/.backup/example.com/yyyy-mm-dd/path.../file~hhmmss~
    " keeps related changes within a day together.
    "
    " the slash between strftime() and l:filepath makes for two slashes
    " in unix, but windows requires it (no slash before drive letter).
    let l:dir = l:backup_root
        \ . '/' . hostname()
        \ . '/' . strftime('%F', l:tm)
        \ . '/' . l:filepath

    if exists('*simplify')
        let l:dir = simplify(l:dir)
    endif

    " tildes are a bit superfluous here
    let l:ext = strftime('.%H%M', l:tm)

    return [l:dir, l:ext]
endfunction

" run a filename through the 'backupskip' patterns to see if it would be
" backed up. 'ignorecase' is significant, used by match().
" returns 0 if file would be backed up.
function! UserTestBackupskip(fn) abort
    if !&backup
        return -1
    endif

    let l:bsk_pats = split(&backupskip, ',')
    for l:pat in l:bsk_pats
        " left's an absolute filename, right (pattern) might be anything
        if match(a:fn, l:pat) >= 0
            return -2
        endif
    endfor

    " file would be backed up - unless we've missed something
    return 0
endfunction

"
" update options backupdir and backupext so that a full backup of each file will
" be kept under ~/.backup/<hostname>/ including the absolute path to the file.
"
" i like this approach better than patch-8.1.0251 (backupdir//, backups with
" path components separated by %s:
" https://github.com/vim/vim/commit/b782ba475a3f8f2b0be99dda164ba4545347f60f)
"
" credit:
" https://www.vim.org/scripts/script.php?script_id=89
" https://www.vim.org/scripts/script.php?script_id=563
" https://stackoverflow.com/a/38479550
"
function! UserUpdateBackupOptions() abort
    let l:fn = expand('<amatch>')
    if !filereadable(l:fn)
        " file hasn't been written for the first time yet, nothing to backup
        return
    endif
    if UserTestBackupskip(l:fn) != 0
        " writing a new file - no backup will be written by vim,
        " no need to create directories.
        return
    endif

    let [l:dir, l:ext] = UserBufferBackupLoc(l:fn)

    if !isdirectory(l:dir)
        call mkdir(l:dir, 'p', 0700)
    endif

    let &l:backupdir = l:dir
    let &l:backupext = l:ext
    " echom 'backup-options' &bdir &bex
    let b:user_last_backup =  l:dir . '/' . fnamemodify(l:fn, ':t') . l:ext
    " echom 'b' pathshorten(b:user_last_backup)
endfunction


function! UserStripTrailingWhitespace()
    if !&l:modifiable || &l:readonly || &l:binary
        return
    endif

    " ah well, only handles ascii whitespace
    let l:regexp = '\s\+$'
    if search(l:regexp, 'cnw')
        let l:win = winsaveview()
        try
            execute '%substitute/' . l:regexp . '//e'
        finally
            call winrestview(l:win)
        endtry
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


" termguicolors - accept only if turned on.
function! UserCanUseGuiColours()
    return has('gui_running') || (has('termguicolors') && &termguicolors)
endfunction

" t_Co might be undefined sometimes
function! User256()
    return exists('&t_Co') && &t_Co >= 256
endfunction

function! UserCanLoadColorscheme()
    return UserCanUseGuiColours() || User256()
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
    " basically just the definitions
    highlight UserDateComment term=NONE cterm=italic gui=italic
    highlight UserTrailingWhitespace term=standout ctermbg=grey guibg=grey
    highlight UserHashTag term=NONE cterm=NONE gui=NONE
    " for URIs at top level, with syntax highlighting and not matchadd()
    highlight! default link UserHttpURI Normal

    if !UserCanUseGuiColours() && !User256()
        return
    endif

    if &background ==# 'light'
        highlight UserDateComment ctermfg=8 ctermbg=12 guifg=grey40 guibg=azure2
        "highlight UserHashTag ctermbg=194 guibg=#b9ebc4
        " like the status line:
        highlight UserHashTag ctermbg=152 guibg=#b0e0e6
        highlight UserTrailingWhitespace ctermbg=7 guibg=grey88
    else
        highlight UserDateComment   ctermfg=246 guifg=grey58
        highlight UserHashTag       ctermbg=240 guibg=grey35
        highlight UserTrailingWhitespace    ctermbg=238 guibg=grey23
    endif

    " UserHttpURI: if using non-syntax matches (matchadd/UserMatchAdd),
    " define a ctermbg to hide spell errors.
    " f.ex. ctermbg=255 guibg=bg
endfunction


" bring some sanity to vim UI element colours
function! UserSafeUIHighlights()
    "highlight ErrorMsg      term=standout
    highlight Ignore        NONE
    "highlight LineNr        NONE
    highlight MatchParen    NONE
    " in some situations the default bold attribute of ModeMsg caused problems.
    highlight ModeMsg       NONE
    "highlight Normal        ctermbg=NONE guibg=NONE
    highlight EndOfBuffer   NONE
    highlight SpellBad      NONE
    highlight SpellCap      NONE
    highlight SpellLocal    NONE
    " decriminalise rare words
    highlight SpellRare     NONE
    " we want to be safe for monochrome ttys, and at the same time
    " clear cterm and gui attributes that can be bad in 256 color and gui modes.
    " since the attributes here are initial values and get inherited later.
    " and bearable with screen(1) defaults, where t_Co == 8.

    " NonText - by default used, among others, for the end-of-buffer tildes.
    " a none-NONE ctermbg would be ugly here.
    " listchars: eol, extends, precedes
    highlight NonText       term=NONE ctermfg=green ctermbg=NONE cterm=NONE gui=NONE

    " listchars: tab, nbsp, trail (+ space, multispace, lead)
    highlight SpecialKey    term=NONE ctermfg=blue ctermbg=NONE cterm=NONE gui=NONE

    highlight SpellBad      ctermfg=NONE    ctermbg=cyan    cterm=NONE  gui=NONE

    " specifying ctermfg in case of a dark tty background
    highlight StatusLine    ctermfg=black   ctermbg=darkcyan cterm=NONE  gui=NONE
    highlight StatusLineNC  ctermfg=black   ctermbg=grey    cterm=NONE  gui=NONE
endfunction


" turn off most highlights; 'highlight clear' defaults are awful,
" set highlights to NONE to silence.
" these are highlights for text/content, not vim UI elements.
function! UserClearContentHighlights()
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
        "highlight LineNr            ctermbg=253
        " NonText and SpecialKey should match UserTrailingWhitespace
        highlight NonText           ctermbg=7
        highlight SpecialKey        ctermbg=7
        highlight ColorColumn                       ctermbg=12
        highlight StatusLine        ctermfg=NONE    ctermbg=152
        highlight StatusLineNC      ctermfg=NONE    ctermbg=252
    endif

    highlight SpellBad                              ctermbg=253

    " no point clearing 'Normal' here, vim doesn't seem to reset the background
    " colour to the tty background color. probably mentioned somewhere in
    " `help :hi-normal-cterm'.
    " instead - either choose a colorscheme that can work without modifying
    " Normal-ctermbg like lucius, or wrap it like our own iceberg-wrapper.vim.
    " 2022-07-09 lucius can be set to not touch ctermbg, but still sets ctermfg.
    highlight Normal ctermfg=NONE
endfunction

" dark backgrounds are quite common even if not desired.
" must support.
" things can look wrong if a colorscheme forces background to dark,
" as when trying desert in a bright tty. the following function
" will get run because bg's now dark, and the result can look wrong.
function! UserColours256Dark()
    if UserOverrideUiColours()
        "highlight LineNr            ctermbg=237
        highlight NonText           ctermbg=238
        highlight SpecialKey        ctermbg=238
        highlight ColorColumn                       ctermbg=237
        highlight StatusLine        ctermfg=NONE    ctermbg=243
        highlight StatusLineNC      ctermfg=NONE    ctermbg=238
    endif
    highlight SpellBad                              ctermbg=237
endfunction

function! UserColours256()
    "highlight ErrorMsg          ctermfg=yellow  ctermbg=brown   cterm=bold
    highlight MatchParen                        ctermbg=202
    highlight EndOfBuffer       ctermbg=NONE

    " high visibility - works well everywhere
    highlight ModeMsg term=reverse ctermfg=0 ctermbg=214 guifg=#000000 guibg=#ffaf00

    if UserOverrideUiColours()
        highlight NonText       ctermfg=14
        highlight SpecialKey    ctermfg=1
    endif

    if &background ==# 'light'
        call UserColours256Light()
    else
        call UserColours256Dark()
    endif
endfunction

" 'light' only
" sea green ?
"
" statusline colours a little like this gameboy theme:
" https://lospec.com/palette-list/grue: stl #b8c7bf, stlnc #4d5964
" and the Diana F+ camera body.
" guibg=#grey82 (typo) produced a nice colour, probably #efdf82
" also dark turquoise.
"
function! UserColoursGui()
    " passable light: NonText SpecialKey guifg=grey50   guibg=grey88
    " passable dark:  NonText SpecialKey guifg=grey50   guibg=grey25

    " light vs. dark, always overriding any colorschemes. SpellBad -
    " overriding because themes like using only guisp=undercurl, which we do
    " not want, which can leave SpellBad with nothing at all.
    if &background ==# 'light'
        " my precious...
        highlight ColorColumn               guibg=azure2
        highlight NonText                   guibg=grey88
        highlight SpecialKey                guibg=grey88
        highlight SpellBad      guifg=fg    guibg=grey91    gui=NONE
        highlight StatusLine    guifg=fg    guibg=#b0e0e6   gui=NONE
        highlight StatusLineNC  guifg=fg    guibg=#d8d8d8   gui=NONE
    else
        highlight NonText                   guibg=grey25
        highlight SpecialKey                guibg=grey25
        highlight SpellBad      guifg=fg    guibg=grey25    gui=NONE
        highlight StatusLine    guifg=black guibg=#b0e0e6   gui=NONE
        highlight StatusLineNC  guifg=fg    guibg=grey40    gui=NONE
    endif

    " regardless of bg light/dark
    highlight EndOfBuffer       guifg=grey50    guibg=NONE
    highlight ModeMsg           guifg=black     guibg=#ffaf00
    highlight MatchParen                        guibg=#ff8c00

    " cursor - only set for true gui, not under termguicolors
    if has('gui_running')
        highlight clear Cursor
        highlight Cursor gui=reverse
    endif

    " if we're using lucius, let it set the Normal colours and don't override.
    if exists('g:colors_name') && g:colors_name ==# 'lucius'
        return
    endif
    " default gui forground/background
    " was: whitesmoke; current - anti-flash white; see also #f2f3f4
    highlight Normal            guifg=black     guibg=#f3f3f3
endfunction

" t_Co can be ambiguous.
" mlterm starts with t_Co 8, later changes to 256.
"
" NB: this is usually meant to run after a colorscheme we largely like.
" so this function should _not_ call UserClearContentHighlights().
"
function! UserColours()
    call UserLog('UserColours enter win', winnr())
    " clean up UI colours
    call UserSafeUIHighlights()

    " orange
    highlight clear UserHighVis
    highlight! default link ModeMsg UserHighVis

    " NB don't run 256-color code for gui.
    if User256()
        call UserColours256()
    endif

    if UserCanUseGuiColours()
        call UserColoursGui()
    endif

    " if we've defined a 'vert' in fillchars, remove the highlight group
    if &fillchars =~# 'vert:'
        highlight clear VertSplit
    endif

    " since we're handling a colorscheme change: pull in our custom colour and
    " syntax definitions.

    call UserCustomSyntaxHighlights()
endfunction


" cruft warning; not failsafe, depends on vim version.
function! UserIsWinRegular()
    " check for popup/preview/command line etc.
    if v:version >= 802 && win_gettype() != ''
        return 0
    endif

    " check for quickfix/terminal
    let l:wi_lst = getwininfo(win_getid())
    "" info for current window; l:wi_lst should never be empty.
    let l:wi = l:wi_lst[0]
    if get(l:wi, 'loclist') || get(l:wi, 'quickfix') || get(l:wi, 'terminal')
        return 0
    endif

    " nothing more to check
    return 1
endfunction

function! UserHlNames()
    return [
        \ 'UserTrailingWhitespace',
        \ 'UserDateComment',
        \ 'UserHashTag',
        \ 'UserHttpURI'
        \ ]
endfunction

function! UserGetCurWinMatchHls()
    let l:hl_exst = []
    let l:hls = UserHlNames()

    for l:m in getmatches()
        for l:hl in l:hls
            if l:m['group'] ==# l:hl
                if index(l:hl_exst, l:hl) == -1
                    call add(l:hl_exst, l:hl)
                endif
                break
            endif
        endfor
    endfor

    return l:hl_exst
endfunction

" try out matchadd() instead of trying to extend the ft/syntax regime.
" has the advantage of working even with 'syntax off'.
" https://stackoverflow.com/questions/41083829/how-can-i-apply-custom-syntax-highlighting-in-vim-to-all-file-types
"
" disadvantages:
"   - for excluding URIs from spell check, using a highlight group
" linked to Normal doesn't seem to work. However, using a highlight group
" that defines ctermbg and guibg hides the SpellBad highlighting.
" workable, though it may not make URIs perfectly transparent in terminals.
" gvim is fine, with guibg=bg.
" So, not excluded from spell checking, just occluded.
"
" it's a great relief to be free of the filetype/syntax rigmarole, the expected
" way of defining a filetype. non-syntax matchadd() is ultimate freedom.
"
" On WinEnter:
" we don't want to highlight things in special buffer types or
" non-modifiable buffers - but, WinEnter is too early to check anything.
" win_gettype() is nice, but doesn't cover help windows.
" https://stackoverflow.com/questions/68001855/vimscript-reliable-way-of-checking-win-and-buf-type-of-a-new-window-with-autoc
" so this setup will add the matches to many places where it's not necessary.
" should be harmless in the end. it is funny to see trailing spaces in vim help
" files.
"
function! UserMatchAdd() abort
    " if we've defined all the matches we want in this window, no need to act
    if exists('w:user_matches') && w:user_matches == 5
        return
    endif
    let w:user_matches = 0

    " the names of our highlight-groups.
    let [l:hg_utws, l:hg_udtc, l:hg_uht, l:hg_uhuri] = UserHlNames()

    " matches that have already been defined
    let l:hl_exst = UserGetCurWinMatchHls()

    " regular expressions
    let l:re_utws = '\s\+$'

    " this date range should be enough to outlast me.
    " the seconds part should cater for leap seconds.
    let l:re_udtc = '\v-- date 20\d\d+-[0-1]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-6]\d.{,16}'
    " date comment, optional trailing part, after seconds: [+-]\d{4} \(\a+, \a+\)

    let l:re_uht_simple = '\v✚[_[:lower:][:upper:][:digit:]]+'
    " non-greedily ("-1") match anything except
    "   caret, apostrophe, hash
    " (too broad but must include unicode) chars between apostrophes.
    " canary: [✚x] [✚'x'] [✚'x ✚'x](pathological, overlap)
    " if a tag is over 30 chars - could indicate a problem.
    let l:re_uht_liberal = "✚'[^^'✚]\\{-1,30}'"

    let l:re_uhuri = '\v<https?:\/\/\S+>'

    function! s:needs(s) closure
        return index(l:hl_exst, a:s) == -1
    endfunction

    " let hlsearch (priority 0) override our match highlights
    let l:prio = -2
    " trailing whitespace
    if s:needs(l:hg_utws)
        call matchadd(l:hg_utws, l:re_utws, l:prio)
        let w:user_matches += 1
    endif
    if s:needs(l:hg_udtc)
        call matchadd(l:hg_udtc, l:re_udtc, l:prio)
        let w:user_matches += 1
    endif
    if s:needs(l:hg_uht)
        call matchadd(l:hg_uht, l:re_uht_simple, l:prio)
        call matchadd(l:hg_uht, l:re_uht_liberal, l:prio)
        let w:user_matches += 2
    endif
    if s:needs(l:hg_uhuri)
        call matchadd(l:hg_uhuri, l:re_uhuri, l:prio)
        let w:user_matches += 1
    endif

    delfunction s:needs
endfunction

" helper
function! UserMatchReset()
    call clearmatches()
    let w:user_matches = 0
    call UserMatchAdd()
endfunction


" reason for syntax clear - syntax match is additive, and there's no good way
" (short of running :syntax list and capturing the output) to see if syntax
" rules are present. synIDattr() works as long as highlight groups are defined.
function! UserApplySyntaxRules()
    call UserLog('UserApplySyntaxRules enter win', winnr())

    syntax clear UserTrailingWhitespace
    syntax match UserTrailingWhitespace /\s\+$/
        \ display oneline containedin=ALLBUT,UserTrailingWhitespace

    " canary:
    " -- date 2022-07-25 14:42:43+0200 (Jul, Mon)x
    syntax clear UserDateComment
    syntax match UserDateComment
        \ /\v-- date 20\d\d+-[0-1]\d-[0-3]\d [0-2]\d:[0-5]\d:[0-6]\d.{,16}/
        \ display oneline containedin=ALLBUT,UserDateComment

    " canary: [✚x] [✚'x'] [✚'x ✚'x](pathological, overlap)
    syntax clear UserHashTag
    syntax match UserHashTag /\v✚[_[:lower:][:upper:][:digit:]]+/
        \ display oneline containedin=ALLBUT,UserHashTag
    syntax match UserHashTag /\v✚'[^^'✚]{-1,30}'/
        \ display oneline containedin=ALLBUT,UserHashTag

    " make URIs effectively invisible; if contained, highlight like the
    " container. if at toplevel, highlight like the Normal hl group.
    " see hl definition of UserHttpURI.
    " canary:
    "https://web.archive.org/web/20010301154434/http://www.vim.org/"
    if v:false
        https://web.archive.org/web/20010301154434/http://www.vim.org/
    endif
    syntax clear UserHttpURI
    " toplevel:
    syntax match UserHttpURI =\v<https?://\S+= contains=@NoSpell
    " contained:
    syntax match UserHttpURI =\v<https?://\S+=
        \ transparent contained containedin=ALLBUT,UserHttpURI contains=@NoSpell
endfunction


function! UserHS(...)
    let l:forced = a:0 > 0 && a:1 == v:true

    call UserLog(printf('UserHS winnr=%d forced=%d syn_on=%d'
        \, winnr()
        \, l:forced
        \, exists('g:syntax_on')))

    " don't enable if syntax is globally disabled
    " but do enable if called with arg 1 == 1
    "
    " todo - perhaps remove the guard, be independent of syntax highlighting
    if exists('g:syntax_on') || l:forced
        call UserCustomSyntaxHighlights()
        " 2022-07-13 - matches instead of syntax
        " call UserMatchAdd()
        " 2022-07-26 back to syntax items
        call UserApplySyntaxRules()
    endif
endfunction


" Fallback using no colours or text attributes.
" t_Co=0 disables all colours; http://aplawrence.com/Forum/TonyLawrence10.html
" Was useful once under haphazardly setup AIX systems.
" Destructive, can't really restore to normal without restarting vim.
function! UserTermBad()
    syntax off
    highlight clear
    set t_Co=0 t_md= t_Sf= t_Sb= t_us= t_ue= t_ZH= t_ZR=
    set notermguicolors showbreak=NONE colorcolumn=0
endfunction


" do all the ui/content color changes and loading of a color scheme
function! UserLoadColors()

    " most colorschemes don't pull their own weight. would be great if a
    " colorscheme + reload behaviour would take a closure instead of requiring
    " a file on disk.  And seperate user interface component highlights from
    " text content highlights.
    "
    " order's significant here; whether bg& before or after depends on what
    " the scheme does.
    "
    " test tip: COLORFGBG='15;0' xterm -tn xterm-vt220 -fg \#ffb000 -bg grey10
    " desert for dark, shine for light. with modifications to not touch
    " important highlights and not modify 'background'.
    "
    " start by erasing the default highlights, which are very annoying,
    " specially on terminals with few colours.

    if exists('g:syntax_on')
        call UserClearContentHighlights()
    endif

    if UserRuntimeHas('colors/tty.vim')
        " colorscheme tty
        nnoremap <F4>   :colorscheme tty<cr>
    endif

    " 2022-03-09 lucius light and white modes seem to trigger a bug in gvim on
    " Linux. The command window rendering becomes subtly broken, selected text
    " almost invisible.
    "
    " 2022-06-30 gvim command window under lucius looks good again.
    "
    " in any case, the default vim syntax definitions are maybe 60% good
    " anyway. setting non-tty-fg dark colours on "normal" text bothers me a
    " little too.

    if UserCanLoadColorscheme()
        if UserRuntimeHas('colors/lucius.vim')
            " perfect, A+; cterm only, not for tgc
            let g:lucius_no_term_bg = 1
            colorscheme lucius
            nnoremap <F5>   :colorscheme lucius<cr>
            if UserCanUseGuiColours()
                LuciusLight
            endif
        endif
        " other good: iceberg, PaperColor?
        " honorable mention:
        "   monochromenote - https://github.com/koron/vim-monochromenote
    endif

    " if no colorscheme found/loaded, the ColorScheme autocmd won't work. load
    " our UI colour overrides.

    if !exists('g:colors_name') || g:colors_name ==? 'default'
        call UserColours()
    endif
endfunction


function! UserCreateBuf()
    " bufadd with empty name always creates a new buffer
    let l:b = bufadd('')
    " call setbufvar(l:b, '&buftype', 'nofile')
    call setbufvar(l:b, '&filetype', 'text')
    " call setbufvar(l:b, '&swapfile', 0)

    " if the buffer isn't listed, a bare ':b' will switch to the last
    " listed buffer.
    call setbufvar(l:b, '&buflisted', 1)

    return l:b
endfunction

" WIP UI; like :bd, but if there's no alternate file, open a new buffer
" instead of closing the window.
"
" janky alternative: :bprevious | split | bnext | bdelete
"
function! UserBufCloseKeepWin()
    if winnr('$') == 1
        " just one window (I don't use tab pages)
        confirm bdelete
        return
    endif

    " write changes, but autowriteall should do this anyway
    update
    " keep current buffer number, we'll need it later
    let l:bufnr = bufnr()
    let l:bufnr_alt = bufnr('#')

    if l:bufnr_alt != -1
        let l:b = l:bufnr_alt
        execute 'buffer' l:bufnr_alt
    else
        enew
    endif

    " if the previously displayed buffer (now the alternate) is no longer
    " loaded, delete it.
    "
    " to only visibility:
    " getbufinfo(l:bufnr) -> <dict>.windows
    " win_findbuf(l:bufnr)
    "
    if !bufloaded(l:bufnr)
        execute 'confirm bdelete ' l:bufnr
    endif
endfunction

command XB  call UserBufCloseKeepWin()
nnoremap Q :call UserBufCloseKeepWin()<cr>


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
"
" prior: https://github.com/AmaiSaeta/capture.vim/blob/master/plugin/capture.vim
"
function! UserSpoolEx(cmd)
    if v:false
        if (&l:readonly || !&l:modifiable)
            echom 'unmodifiable'
            return
        endif
    endif

    Scratch
    let l:winid = win_getid()
    let l:winnr = win_id2win(l:winid)
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
            execute l:winnr . 'wincmd c'
            " leaves the actual buffer lying around
        endif
    endtry

    return "\<Ignore>"
endfunction

" a command to put the output of a vim command into a new scratch buffer
command -nargs=+ -complete=command Capture call UserSpoolEx(<q-args>)


" fun little hacks; show things defined by me, from my .vimrc / .gvimrc
" since these functions use currently loaded data, settings defined
" in .gvimrc won't be visible when queried under tty vim.
function! UserShowMaps()
    Scratch
    call append(0, ['Maps', ''])
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

    setlocal readonly nomodifiable
endfunction

command MyMaps      silent call UserShowMaps()


function! UserShowCommands()
    Scratch
    call append(0, ['Commands', ''])
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

    setlocal readonly nomodifiable
endfunction

command MyCommands  silent call UserShowCommands()


function! UserShowFunctions()
    Scratch
    call append(0, ['Functions', ''])
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


" list the syntax items in a buffer and put them into a new scratch buffer
" for convenient viewing.
function! UserShowSyntaxItems() abort
    if !exists('*execute')
        echoerr 'need execute()'
        return -1
    endif
    let l:bufnr = bufnr()
    " execute in current buffer
    let l:syn = execute('syntax list')
    Scratch
    " add output to new scratch buffer
    call append(0, ['Syntax items for buffer ' . l:bufnr])
    put =l:syn
    /^--- Syntax items ---$/d
    :0
endfunction

" can't call it "My*" like the other similar commants; there's no good way
" to filter only syntax items defined by me, except by the "User" prefix.
" besides, i generally want to see all defined syn items.
command ShowSyntaxItems   silent call UserShowSyntaxItems()



" this is so ubiquitious as to seem like a native feature, but is defined in
" $VIMRUNTIME/defaults.vim, which isn't included in this vimrc.
"
" doc:last-position-jump
" https://vim.fandom.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
function! UserLastPositionJump()
    " don't restore for vcs commit message files
    if &filetype =~# 'commit'
        return
    endif

    let l:ln = line("'\"")
    if l:ln > 0 && l:ln <= line('$')
        " go to mark " without changing the jumplist
        normal! g`"
        " if we're in a fold, unfold it
        if foldlevel(line('.')) != 0
            normal! zv
        endif
    endif
endfunction


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
    return join(l:spls, ',')
endfunction

" &g: doesn't work here.
let &spelllang = UserSpellLangs()

" if spellfile unset, with a word is added (zg/zw) vim will set spellfile
" to somewhere inside ~/.vim/ .
" also - all words from all spell languages go into the same file.
set spellfile=~/.vimspell.utf-8.add
set spellcapcheck=


" ---- mappings
nnoremap        <Up>    gk
nnoremap        <Down>  gj
nnoremap        k       gk
nnoremap        j       gj
vnoremap        <Up>    gk
vnoremap        <Down>  gj
vnoremap        k       gk
vnoremap        j       gj

" 2022-07-16 - recognition, through vimrc.
" https://github.com/hotchpotch/dotfiles-vim/blob/master/.vimrc
" https://secon.dev/entry/20061225/1167032528/
" for working with gettext code using tpope/vim-surround.
" nnoremap        g'      cs'g
" nnoremap        g"      cs"G

" on hitting F1 instead of Esc by accident when sleepy - do something
" unobtrusive instead of opening help. <expr> is brittle. <Cmd>'s robust, but
" very new. the quiet alternative: <Nop>
nnoremap          <F1>      :call UserShowHelp()<cr>
imap              <F1>      <Esc><F1>

" for misconfigured virtual serial lines with putty. better to set
" TERM=putty-256color before starting (above mappings work then), instead of
" working under 'vt220' or whatever.
if v:false
    if &term !~# 'putty' && !g:user_has_x11 && !has('gui_running')
        nnoremap <silent> <Esc>[11~  :call UserShowHelp()<cr>
        inoremap <silent> <Esc>[11~  <Esc>:call UserShowHelp()<cr>
    endif
endif

" quickly toggle spellcheck
" used to use F6 to toggle spell, but setl [no]spell is easier to remember.

" show all buffers in windows; was just thinking of fullscreen.
nnoremap        <F11>  :sball<cr>

" lots more modes... doc :noremap and doc xterm-function-keys

" Trying out a mapping to show buffers quickly and unobtrusively.
" https://stackoverflow.com/a/16084326
" https://github.com/Raimondi/vim-buffalo
" The <Space> after :b allows wildmenu to come into play easily.
" NB: can't be a silent mapping.
" used to use '+', but turns out it's useful. now using 'K'.
nnoremap    K           :ls!<cr>:b<Space>

" emacs/readline-like mappings for the command line; doc emacs-keys
" don't mess with C-f, the default 'cedit' value.
cnoremap    <C-a>       <Home>
cnoremap    <C-d>       <Del>
cnoremap    <C-e>       <End>

" Switch to alternate file: Ctrl-6
" doc CTRL-^ (https://vimhelp.org/editing.txt.html#CTRL-%5E)

" map backspace to turn hlsearch off; from Damian Conway.
"nnoremap    <BS>   :nohlsearch<cr>
" can also set v:hlsearch = 0
if has('patch-7.4-079')
    nnoremap    <silent>    <BS>    :if v:hlsearch <bar>
                                    \ nohlsearch <bar>
                                    \ endif<cr>
                                    \<BS>
else
    nnoremap    <silent>    :nohlsearch<cr><BS>
endif

xnoremap    <BS>    x


" 2022-02-14 from defaults.vim - delete to beginning, with undo
inoremap    <C-u>   <C-g>u<C-u>
" same for deleting words; from tpope's vim-sensible
inoremap    <C-w>   <C-g>u<C-w>

"" insert timestamp
"" nnoremap        <silent> <Leader>dt :put=UserDateTimeComment()<cr>
inoremap <expr> <silent> <Leader>dt     UserDateTimeComment()

"" insert date
"" nnoremap        <silent> <Leader>dd :put=UserDate()<cr>
inoremap <expr> <silent> <Leader>dd     UserDate()
" so i can do :e f-<,dd> in the vim command window
cnoremap <expr> <Leader>dd              UserDate()

inoremap <expr> <silent> <Leader>dU     UserUtcNow()

"" see also: insert mode, <C-r>=    doc i_CTRL-R

"" format paragraph with par(1) -  for justify
""      see also: plugin/justify.vim; doesn't seem as good as par.
""
"" mapping deciphered:
"" { - go to beginning of paragraph
"" !}par... - doc ! (https://vimhelp.org/change.txt.html#%21)
""      filter to end of paragraph
"" } - move to end of paragraph
"" http://www.softpanorama.org/Editors/Vimorama/vim_piping.shtml#Using_vi_as_a_simple_program_generator
"" http://www.nicemice.net/par/par-doc.var
""
nnoremap        <Leader>j     {!}par 78<cr>}

" join paragraphs to one line, for sharing.
" to join paragraph into one line with tr(1) rather than fmt(1) -
" (tr doesn't have the low line/goal limits of GNU fmt.)
" https://utcc.utoronto.ca/~cks/space/blog/unix/FmtTwoUses
" beware final trailing space.
" nnoremap <silent> <Leader>O     {!}tr "\n\r" "  "<cr>}
" with ex command :join
" nnoremap <silent> <Leader>O     vip:join
" J's work seems to be undone when auto formatting is enabled.
" nnoremap <silent> <Leader>O     vipJ
" the :join ex command isn't undone by autoformatting.
nnoremap        <Leader>1     vip:join<cr>

" format paragraph without formatprg/formatexpr. k's just close to , .
nnoremap <silent> <Leader>k     gwip
vnoremap <silent> <Leader>k     gw


" øæå as brackets, braces, parentheses - done with xmodmap

function! s:xclipbrd_write(txt)
    silent call system('xsel -b -i', a:txt)
    if v:shell_error
        echoerr 'xclip invocation failed, code' v:shell_error
    endif
endfunction

" put the visual selection (line-wise or not) into a register, invoke
" xclip with the register as the input.
" not using get/setreginfo() for compatibility.
"
" https://stackoverflow.com/a/26125513, adapted
function! UserWriteVisualToX11Clipboard() abort
    let l:reg = @u
    " yank to register 'u'
    norma!l gv"uy
    call s:xclipbrd_write(@u)
    " restore 'u' somewhat
    let @u = l:reg
    " normal! gv -- no, leave visual mode
endfunction

" for normal mode
function! UserWriteLinesToX11Clipboard() abort range
    let l:reg = @u
    " yank to register 'u'
    let l:cmd = a:firstline . ',' . a:lastline . 'y u'
    silent execute l:cmd
    call s:xclipbrd_write(@u)
    let @u = l:reg
endfunction

function! UserReadFromX11Clipboard() abort
    silent let l:clp = system('xsel -b -o')
    if v:shell_error
        echoerr 'xclip invocation failed, code' v:shell_error
        return
    endif
    if l:clp ==# ''
        return
    endif
    let l:reg = @u
    let @u = l:clp
    normal! "ugP
    let @u = l:reg
endfunction


" mappings to copy/paste using the X clipboard from tty vim, without resorting
" to +X11 (vim feature).
" doc :write_c
if g:user_has_x11 && has('linux') && !has('gui_running')
    " ttys and bracketed paste cover this well usually
    nnoremap <silent>   <Leader>xp      :call UserReadFromX11Clipboard()<cr>
    " doc i_CTRL-G_u - break undo sequence, start new change
    inoremap <silent>   <Leader>xp      <C-g>u<C-o>:call UserReadFromX11Clipboard()<cr><C-g>u
    " no paste for command-line mode; instead paste into command window and run.
    "   or paste into any regular window and :<C-R><C-L>

    " define an ex command that takes a range and pipes to xclip
    nnoremap <silent>   <Leader>xc      :call UserWriteLinesToX11Clipboard()<cr>
    " for the visual selection (not necessarily linewise):
    vnoremap <silent>   <Leader>xc      :call UserWriteVisualToX11Clipboard()<cr>

    " doc :write_c
    " use: :.,+10WX11
    command -range WX11     silent <line1>,<line2>:w !xsel -i -b
elseif has('gui_running')
    set mouse=inv
    " for iVim on iOS (has gui but no X11, no gtk) - paste with little ceremony.
    " kept in .vimrc instead of .gvimrc
    nnoremap <silent> <Leader>xp    "+gP
    nnoremap <silent> <C-S-v>       "+gP
    " just like the right-click popup menu
    " see menu.vim Edit -> Paste, autoload/paste.vim
    inoremap <silent> <Leader>xp    <C-g>u<C-o>:call paste#Paste()<cr><C-g>u
    inoremap <silent> <C-S-v>       <C-g>u<C-o>:call paste#Paste()<cr><C-g>u
    vnoremap <silent> <Leader>xp    "-c<Esc>:call paste#Paste()<cr>
    vnoremap <silent> <C-S-v>       "-c<Esc>:call paste#Paste()<cr>

    " normal mode, copy current line
    nnoremap <silent> <Leader>xc    "+yy
    " visual mode, copy selection, not linewise; doc: v_zy
    vnoremap <silent> <Leader>xc    "+zy<Esc>

    command -range WX11     <line1>,<line2>y +
endif


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
"
" 0x1F7A3 MEDIUM GREEK CROSS - too many bytes, not widely available in fonts
let Symbols = {
    \ 'lozenge':        nr2char(0x25CA)
    \ ,'interpunct':    nr2char(0xB7)
    \ ,'dagger':        nr2char(0x2020)
    \ ,'greek cross, heavy': nr2char(0x271A)
    \ ,'brkt left corner': nr2char(0xFF62)
    \ ,'brkt right corner': nr2char(0xFF63)
    \ ,'silcrow':       nr2char(0xA7)
    \ }
lockvar Symbols

inoremap <expr> <Leader>ip      Symbols['interpunct']
inoremap <expr> <Leader>lz      Symbols['lozenge']
inoremap <expr> <Leader>dg      Symbols['dagger']
inoremap <expr> <Leader>sc      Symbols['silcrow']
" 2022-07-14
inoremap <expr> <Leader>(       Symbols['brkt left corner']
inoremap <expr> <Leader>)       Symbols['brkt right corner']

" pound signs used everywhere, lozenge taken by Pollen...
" U+25B8 Black right-pointing small triangle
" U+25BA Black right-pointing pointer
" U+298B, U+298C - brackets with underbar
" U+2991, U+2992 brackets with dot
"
" used to use <Leader>#, too cumbersome.
inoremap <expr> <Leader><Leader>   Symbols['greek cross, heavy']
cnoremap <expr> <Leader><Leader>   Symbols['greek cross, heavy']

" abbreviations aren't so useful in such cases, they expand after whitespace.

" prevent accidental nbsp entry; using 'execute' for mapping whitespace
" execute "inoremap \u00A0 <Space>"

" use 's' for window commands instead of the emacsy C-w
nnoremap    s   <C-w>
" for keys like C-wf (doc CTRL-W_f), there's no option to make the split
" vertical by default. We make do with this:
nnoremap    <Leader>vf  <C-w>f<C-w>L

" WIP mapping to open files; meant to work under just two windows:
" one window with a list of filenames.
nnoremap    <Leader>se  :let f = expand('<cfile>')<cr><C-w>w:execute('edit ' . f)<cr>

" M.G. - guu/gugu - lower line, u - visual, gu{motion}
nnoremap    <Leader>mg      guip

" mainly for iVim
nnoremap    <Leader>;;      :update<cr>
" open the command window with ,f in the command line
cnoremap    <expr>  <Leader>f    &cedit
nnoremap    <Leader>f       q:

" doc CTRL-G
" alt: let l = execute("normal! 3\<C-g>")
" to get more info from <C-g> 'ruler' needs to be turned off, let's just use
" our own function instead.
nnoremap    <C-g>   :echo UserLoc()<cr>

nnoremap    H   ^
vnoremap    H   ^
nnoremap    L   $
vnoremap    L   $

" disable select-mode mappings
" doc Select-mode-mappings
nnoremap    gh      <nop>
nnoremap    gH      <nop>
nnoremap    g<C-h>  <nop>

" 2022-07-22 haven't used macros/recording for over 20 years, not about to
" start now. keeps getting in the way.
" https://vi.stackexchange.com/a/15466 is clever, but don't like the getchar().
"function! s:q_reg_nop()
"    let l:c = nr2char(getchar())
"    return match(l:c, '[0-9a-zA-Z"]') == -1 ? 'q'.l:c : '\<Nop>'
"endfunction
"nnoremap    <expr> q    <SID>q_reg_nop()
"
" can add mappings to preserve q:, q/ and q? - but i've never needed those
" either. going to the command line first and then hitting the cedit char seems
" more natural.

" can't map q to anything useful - shouldn't get used to actually using it
" (fear of pressing q on installations without my vimrc).
"
" vile's 'q' (quoted motion) is interesting.
"nnoremap    q   <nop>
nnoremap    q   :echo 'You hit me! Picard never hit me!'<cr>

" end q-mappings adventure.

" verymagic
nnoremap    /       /\v
nnoremap    ?       ?\v

" -- ~ eof-map ~ end of most mapping definitions


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
function! UserSymComplFn(findstart, base) abort
    if a:findstart == 1
        " completion starts at cursor column
        return -100
    elseif a:findstart == 0
        let l:compl = []
        " sort by unicode value (not hash key) of symbol, ascending
        let l:sorted_pairs = sort(
            \ items(g:Symbols),
            \ { l1, l2 -> l1[1]==l2[1]?0:l1[1]>l2[1]?1:-1 }
            \ )
        for [l:name, l:sym] in l:sorted_pairs
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


" ----

" doc fo-table
command -bar Nowr    setlocal fo=t nospell ai nosi nocin
command -bar FoText  setl fo=at
command -bar FoCode  setl fo=cjoqr nosi cin
"
" NB: autoindent affects fo-at
" spelling: probably better to switch to native aspell and dict-gcide
"   (GNU Collaborative International Dictionary of English)
command -bar Wr      setlocal tw=78 fo=at nocin nosi noai spell

" for small screens (iVim)
command -bar Mobile  Wr | setl tw=46 nonu nornu nospell

" for transcribing poetry -
" significant whitespace, auto-indenting, no hard tabs, no auto formatting
" remember - delete to beginning of line: 0d (V), Ctrl-U (I);
"   Ctrl-U is readline unix-line-discard.
" set colorcolumn=16,32,48,64,80,96 might also help.
command -bar Poetry  setlocal tw=0 formatoptions-=ta sts=4 sw=4 sts=4 ai et nospell

command -bar Proper  setlocal softtabstop=8 shiftwidth=8 noexpandtab
" for Python and common scripting languages
command -bar Lousy   setlocal softtabstop=4 shiftwidth=4 expandtab
" for lisps
command -bar Lisp    setlocal softtabstop=2 shiftwidth=2 expandtab
command -bar Retab   %retab

command -bar ShowBreak       let &showbreak = g:user_showbreak_char
command -bar NoShowBreak     set showbreak=NONE


" helper for when a 'syntax off' -> 'syntax enable' wipes out our rules.
command -bar Syn            call UserApplySyntaxRules()
command -bar SynSync        syntax sync fromstart
" remember: https://vimhelp.org/usr_44.txt.html#44.10
"   :syntax sync minlines=100
" also remember: doautocmd Syntax


" mnemonic to open all folds in buffer
command -bar Unfold         normal! zR

command -bar Number         setlocal number relativenumber

"command Patch               setlocal patchmode

command -nargs=1 Ch         set cmdheight=<args>

command -bar -nargs=1 Tw    setlocal textwidth=<args>

command Colortest       runtime syntax/colortest.vim

" useful when testing in verbose mode
command -bar -nargs=+ Log    call UserLog(<args>)

" enable/disable paste mode - outdated; vim supports bracketed paste now.
command -bar Pst         setlocal paste
command -bar Nopst       setlocal nopaste
command -bar Spell       setlocal spell
command -bar NoSpell     setlocal nospell

" to turn the status line on/off
command -nargs=1    St          set laststatus=<args>

command Info        call UserShowHelp()
command TermBad     call UserTermBad()

command -bar Stws        call UserStripTrailingWhitespace()

" new window for scribbling
" possible alternative - preview windows (:pedit); seems more limited.
" doc scratch-buffer
command Scratch     new | setlocal buftype=nofile noswapfile | setfiletype text

" like :Explore
command Index       call UserOpenIndexFile()

" enable 'list' in all windows, with or without tab visibility.
" use as :List 1 or :List 0
command -bar -nargs=1 List  let &lcs = UserListchars(<f-args>) | windo setl list
command -bar Nolist     windo setl nolist

command -bar VeDefault   set virtualedit=block,onemore

" search for the nbsps that 'list' also uses
" but vim isn't great for this; use perl5:
"       perl -Mopen=locale -pe 's/[\N{U+202f}\N{U+00a0}]/[X]/g'
command Fnbsp            /[\u202f\ua0]

" WIP/demo; pipe the buffer into some shell command seq, get output into qf.
" use as: :Ce grep f        [no quoting in the command line]
command -nargs=+ CexprSystem     :cexpr system(<q-args>, bufnr())


" use file(1) to determine if fn is a text file
function! UserDetectTextFile(fn)
    if !has('unix') | return -1 | endif
    let l:fnesc = shellescape(a:fn, 1)
    "echom 'passing to file:' l:fnesc
    silent let l:out = systemlist('/usr/bin/file -b --mime ' . l:fnesc)[0]
    if v:shell_error
        echoerr 'file(1) failed, status ' . v:shell_error
        return -2
    endif
    " don't check the charset, but keep the output of file(1) in a buffer-local
    " variable.
    let b:user_content_type = l:out
    if l:out =~# '^text/plain'
        return 0
    endif
    return -3
endfunction


function! UserAutoSetFtText(fn)
    "echom '[userauto ft text]'
    if &binary | return | endif
    " if a filetype's present, don't mess with it
    if did_filetype() | return | endif
    if exists('&l:filetype') && !empty(&l:filetype) | return | endif

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
        setfiletype text
    endif
endfunction


" mine own #-autogroup
augroup UserVimRc
    autocmd!

    " enable auto reformatting when writing journal entries,
    " not for all text files.
    " format manually: gqip or vip, gq
    autocmd BufNewFile,BufReadPost  writing*.txt,NOTES*.txt     Wr
    autocmd BufReadPost *music-comments.txt     setl nospell

    " for file names without an extension -
    " if file(1) thinks it's a text file, treat it as such.
    " not directly related to syntax highlighting - therefore this directive
    " is in this autogroup, and not in the UserVimRcSyntax autogroup.
    autocmd BufReadPost *   call UserAutoSetFtText(expand('<afile>'))

    " last-position-jump
    " beware of fedora badly duplicating this functionality in /etc/vimrc.
    autocmd BufReadPost *   call UserLastPositionJump()

    autocmd BufNewFile,BufReadPost  /etc/*          Proper
    autocmd FileType        c,sh,conf               Proper
    autocmd FileType        perl,python,vim,ruby,eruby  Lousy
    autocmd FileType        lisp,scheme,clojure     Lisp
    " the first line of the commit message should be < 50 chars
    " to allow for git log --oneline
    " FileType *commit / BufNewFile,BufReadPost COMMIT_EDITMSG
    " force cursor position, regardless of viminfo/marks.
    autocmd FileType *commit    setlocal spell tw=78 cc=50,78
                            \ | call setpos('.', [0, 0, 0, 0])

    autocmd BufWritePre *   call UserStripTrailingWhitespace()
    autocmd BufWritePre *   call UserUpdateBackupOptions()

    " no persistent undo info for temporary files
    autocmd BufWritePre /tmp*,~/tmp/*   setlocal noundofile

    " when editing the ex command line, enable listchars and numbers.
    " the idea is to not paste right into the command line, but do paste from
    " the clipboard into the command window - and inspect before running.
    " doc cmdwin-char
    autocmd CmdWinEnter : let &l:lcs = UserListchars(1) | setl list nu nornu

    "autocmd TermResponse * echom 'termresponse:' strtrans(v:termresponse)
augroup end


" autogroup for my weird syntax dealings
augroup UserVimRcSyntax
    autocmd!

    " matches (matchadd(), not syntax highlighting) are per window.
    " can be too eager, can set up a window variable later.
    " works whether syntax is enabled or not.
    "autocmd BufWinEnter,WinEnter    *  call UserMatchAdd()

    autocmd BufWinEnter *       call UserApplySyntaxRules()

    " 2022-07-26 spooky action seems like this didn't work (for filetype
    " change from none to 'text') forever and suddenly started working today.
    "
    " possible match for just empty: {} https://vi.stackexchange.com/a/22961

    autocmd Syntax      *       call UserApplySyntaxRules()

    " on colourscheme load/change, apply our colours, overriding the scheme.
    autocmd ColorScheme *   call UserColours()
augroup end


if v:false
    augroup UserLogAutoEvents
        autocmd!

        autocmd FileType    *   call UserLog('ae FileType')
        autocmd Syntax      *   call UserLog('ae Syntax', expand('<amatch>'))
        autocmd Syntax      {}   call UserLog('ae Syntax', expand('<amatch>'))
        autocmd ColorScheme *   call UserLog('ae ColorScheme')
        autocmd BufEnter    *   call UserLog('ae BufEnter')
        autocmd BufWinEnter *   call UserLog('ae BufWinEnter')
        autocmd WinEnter    *   call UserLog('ae WinEnter')
        autocmd BufReadPost *   call UserLog('ae BufReadPost')
        autocmd BufCreate   *   call UserLog('ae BufCreate')
        autocmd BufNew      *   call UserLog('ae BufNew')
        autocmd OptionSet   *   call UserLog('ae OptionSet',
            \ 'opt', expand('<amatch>'),
            \ 'newval', v:option_new)
    augroup end
endif

" ----
" misc. plumbing/hacks

" colour
" mlterm causes an extra reload of the colorscheme.
" Debian vim might start with syntax off.
" That's actually nice to start with, but syn off -> enable is an Upheaval.
"
" Take care when testing with xterm: vim always seems to think bg == light,
" with both -rv (reverse) and -fg white -bg black.; bright without bold.
" urxvt and bg detection works as expected.

syntax off
" custom syntax rules (UserApplySyntaxRules()) keep working fine even
" when filetype syntax is disabled with a global 'syntax off'.

" 2-300 can easily be insufficient.
set redrawtime=700 synmaxcol=200


if &term ==# 'xterm-direct'
    " cterm colour codes shouldn't be used in direct colour mode.
    " use gui colours instead.
    set termguicolors
else
    " good idea from tpope/sensible; bright without bold.
    " will take effect under screen(1) ($TERM == 'screen').
    if exists('&t_Co') && &t_Co == 8 && $TERM !~# '^Eterm'
        set t_Co=16
    endif
endif

" for non-xterm-direct terminals (VTE, kitty) it might be necessary to
" call UserColours() again after enabling termguicolors.

" sometimes even works.
set background&

" syntax for text isn't worth the trouble but we like good UI colours.
call UserLoadColors()

" ~ fini ~

" vim:tw=80 fo=croq:
