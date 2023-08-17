" Last-Modified: 2023-08-16T17:16:53.599985355+00:00
" vim:tw=80 fo=croq noml:
set nocompatible
if version < 704
    nnoremap    s   <C-w>
    set number list
    set backupcopy=yes
    finish
endif

set secure encoding=utf-8 fileencoding=utf-8 nobomb
scriptencoding utf-8        " must go after 'encoding'

" Change log:
"
" 2023-08-11 Change <bs> nohlsearch mapping to support a count for <bs>
"
" 2023-08-05 RIP Bram
"
" 2023-07-11 Change custome highlight and syntax definition to check for their
" existence in a more robust way. Change 'completeopt' to tell auto completion
" to not insert anything by default. Windows language settings - do less.
" Colorscheme overriding - reinstate SpellCap/SpellLocal/SpellRare
" destagmatization.
"
" 2023-07-01 Color schemes and term backgrounds. Move from Lucius to Iceberg.
"
" 2023-06-29 Better SpecialKey visibility, mappings/function to add local
" time, better URL copy back, listchars/fillchars cleanup.
"
" 2023-06-05 More copy/paste cleanup. Dynamic statusline removed. Added
" commands and mappings (,yp, ,yc) to read from and write to the X11 PRIMARY
" selection.  To accomodate terminals like roxterm and sakura that make it a
" little cumbersome to use the CLIPBOARD. map normal 'u' to nothing - undo
" doesn't need to be so easily accessible.
"
" 2023-06-03 Set clipboard=
"
" 2023-05-31 Better paste mappings using <expr> and a function that
" only decides the normal-mode command to use, instead of direct buffer
" manipulation.
"
" 2023-05-15 Replace ad-hoc color override conditions functions with a global
" variable (g:u.co) and a set of bitfield checks. Now we can test different
" colorschemes and overrides in an easier way.
"
" 2023-05-11 Lots of changes.
"
" Refactored copy/paste handling. Can now copy the current command line.
"
" listchars/fillchars setup: listchars: support tab:NONE as two spaces.
" fillchars: support NONE like UserListchars.
"
" statusline: static by default, use the status line function only when
" needed, with the SL/StatusLevel user command.
"
" Introduce b:user_noautomod for nonsensical file formats like markdown and
" yaml. Currently only controls the stripping of trailing spaces.
"
" Small utility functions for defining gui highlight groups.
"
" StatusLineNC/VertSplit - switch from grey to safflower.
"
" guifont setup - moved to a function.
"
" termguicolors - cleaned up, added support for Windows consoles (vcon).
"
" MyMaps report format cleaned up.
"
" Filetype indent rules reenabled, disabled only for some filetypes like xml.
"
" Re-enable some common options like showcmd, showbreak, number, list.
"
" Moved functions around a bit, + calling from a single place at startup:
" UserInit().
"
"
" 2023-05-03 UserListchars()/UserFillchars cleanup. Use scrolloff 0.
"
" 2023-04-30 A lot of fun with many things. Refactored unicode whitespace
" matching, trying echowindow instead of popups, enabled cursorline, colourful
" StatusLineNC, started using concealment to make whitespace visible,
" ifdef'ed-out unused functions - mainly those used to try matchadd() as an
" alternative to syntax matches.
"
" 2023-02-17 Call setcellwidths() for yijing hexagrams and hieroglyphs.
"
" 2023-02-01 Reduce highlight rules a little.
"
" 2023-01-14 disable list; take another look at undodir and dir. redo ,n
" mapping for switching between line number display formats.
"
" 2022-09-27 (rip)grep cleanup, unicode whitespace notes.
"
" 2022-09-13 listchars/SpecialKey tinkering. Introspection commands (My*) -
" use :g//d _ - delete to black hole register.
"
" 2022-08-31 fixes to clipboard handling mappings.
"
" 2022-08-30 normal mode paste - support both put before and put after.
" Function + command for running :mkspell! conveniently.
"
" 2022-08-26 filetype removed from statusline, added to on-demand buffer info.
" refactor statusline function.
"
" 2022-08-17 indicate on statusline if no swapfile, ref. iVim and iCloud
" Drive. command (StatusLevel) to easily control how much info the status line
" shows.
"
" 2022-08-16 bring back window size in the statusline.
"
" 2022-08-15 disable use of xterm modifyOtherKeys. clean up feature checks and
" has-patch. (Again) keep swap and undo files in a central directory under
" ~/.vim.
"
" 2022-08-03 color and listchars changes to deal with non-home systems
"
" 2022-07-29 Usable with vim 7.x now (uses classic forms of bufnr(),
" bufname(), system(), globpath() etc.), but quite a bit of extras won't work
" or will print error messages. Added more checks for nanosecond routines.
"
" 2022-07-28 Added colour overrides for dark backgrounds. For using iVim at
" night.
"
" 2022-07-25 Bring back syntax rule-based custom highlights. I missed the old
" URL syntax behaviour.
"
" 2022-07-22 Fixes to the mapping (,1) that joins a paragraph into one line.
" Disabled 'q' (recording, as well as q[:/?]) in normal mode.
"
" 2022-07-21 Fixes to the auto backup behaviour. Check the current buffer
" filename against 'backupskip' to see if the file would be backed up, before
" creating directory hierarchies under ~/.backup. Also keep 'ignorecase' off.
"
" 2022-07-20 Clean up the functions that manage fillchars and listchars.
" Command-line window: always enable line numbers and 'list'. vim 8.1 or
" thereabouts seems to have trouble parsing trimmed heredocs; so such code
" blocks are now left ugly for compatibility. 'lazyredraw' also seems to delay
" the initial screen painting, maybe depending on other factors. 'lazyredraw'
" removed. also went back to strinc concatenation with a single dot instead of
" '..'.
"
" 2022-07-13 went away from trying to extend syntax matching with our own
" rules and struggling to have our rules applied in all desired circumstances.
" Using matchadd() now, in UserMatchAdd().  Lots of syntax-related functions
" and comments still left lying around.
"
" On startup, create ~/.vim/syntax/after/text.vim if necessary, to have our
" syntax rules applied in a robust and consistent manner.
"
" Normal mode mapping to paste easily in iVim.
"
" 2022-06-28: Hashtag prefix sequence changed from a single Greek Cross (🞣,
" U+1F7A3) to "-#". The Greek Cross isn't visible and causes rendering issues
" in iVim (iOS.)

" Long, somewhat disorganized, too large a file, my bonsai project. Includes
" an unnamed colorscheme. Lots of barnacles from documentation spelunking and
" trying various options. Tired now, don't want to touch it for the next 10
" years, when it'll be safe to move to vim9script.

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
"
" tpope - uses v:vim_did_enter and has('vim_starting')
" https://github.com/tpope/dotfiles/blob/master/.vimrc

" ! check out $VIMRUNTIME/defaults.vim from time to time.

" wish (x)vile had become popular instead of vim. not going to bother
" splitting this up into separate files. missing features: proper stacktraces,
" loggingat specific levels, the ability to trace (without a debugger) when
" options like t_Co change.

" would be nice if functionality had names like emacs and vile, instead of keys
" that can be remapped. though the vi/vim way is more immediate for the common
" case.

" ----------------------------------------------------------------------------
" most insidious: :Next (, :wNext, :cNext etc.)
" ----------------------------------------------------------------------------
" does the same thing as :previous, yet is shaped like the opposite of :prev.
" light dawns when you notice that :Next is :(<shift>n)ext, "inverted" :next.
" looks like a user-defined command, isn't. and poor :Print can be overridden.
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

"
" -- tips

" :sball - show all buffers; inverse: :only / C-w o
"   <F11>

" @% - current filename; @/ - last search pattern;

" :0file - remove name from buffer

" strtrans() (dep 'display'); 0, 10, ^@, ^J, <Nul>, <NL>, doc :key-notation
"   https://unix.stackexchange.com/a/247331

" 8g8   g8  g;  g,  gd

" put line in command line :<C-r><C-l>, WORD: :<C-r><C-a>

" list all augroups - :augroup<cr>

" insert a null ("^@"): <C-v>10 ; doc: i_CTRL-V_digit. f.ex. [i] a<C-v>10z.

" from visual mode go to insert mode: I

" debug log: vim -V16vdbg; block buffered; use echom to add markers.
"   verbosity level 10: autocommands; 12: function calls.
"   verbosity can interfere/leak in various places; when redirecting
"   message output, the command window after system() output in gvim.
"

" string to list: split(str, '\zs')

" weird little thing: copy modeless-selection: c_CTRL-Y

" :file! doesn't truncate long filenames.

" \V - very nomagic.

" -- end tips
"

" standard plugins in $VIMRUNTIME/plugin - disable.
"{{{
" unimaginable functionality. would be nice to chmod 0, but often can't.
" /usr/share/vim/vim*/plugin/
"   {tohtml,gzip,rrhelper,spellfile,{getscript,tar,vimball,zip}Plugin}.vim
"   matchparen.vim - nice, but the autocommands feel yucky.
"   manpager - vim can be a rather nice manpager.
"
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

" 2022-07-30 let g:did_load_filetypes = 1 does prevent filetype detection with
" the filetypedetect augroup. except when /etc/vimrc does a 'syntax on'. then
" it's too late to set did_load_filetypes in the user vimrc. the user would
" have to also delete the filetypedetect group. anyway, we do want filetypes
" setup, the FileType event is convenient sometimes. it's just that, that
" autogroup has too many things - ugly. 700+ autocmds.
"let g:did_load_filetypes = 1

" love/hate relationship with vim bundled filetype plugins. syntax
" highlighting and indenting rules are often less than perfect. that these
" features are enabled, is often assumed. some curious behaviour - vim always
" seems to set filetype for the first buffer, but not other loaded files.
" filetype off ought to exclude setting ft for the first buffer...
"
" a plugin that requires these: vimoutliner
"
" 2023-04-17 trying to live with predef rules
"
" linux distributions may enable these by default, may not happen on windows.

filetype plugin indent on

" 2022-07-28 clear out autocommands of other people.
" {{{

" i.e., redhat/fedora /etc/vimrc duplicates some of defaults.vim, things that
" are meant to be pulled in only when the user has no .vimrc. this seems to
" interfere with jumping to the last location on some files. anybody remember
" /etc/skel?
"
" at least the worst is in a named augroup. viml parsing is extra picky with
" au/aug (re-opening an augroup just to do autocmd! and then having <aug>
" END). autocmd_delete() isn't available on deathrow rhel boxen. distributions
" use various augroup names. debian doesn't add augroups, thankfully. augroup
" listing in viml is incomplete (:verbose augroup is no different from
" :augroup).
"
" even a single-line execute combining auto! with augr! with a bar doesn't work
" in some old vim versions.

function! UserRemoveVendorAugroups()
    for l:vnd_aug in ['fedora', 'redhat']
        if exists('#'.l:vnd_aug)
            " defang
            execute 'autocmd!' l:vnd_aug
            " delete empty group
            execute 'augroup!' l:vnd_aug
        endif
    endfor
endfunction

" }}}

" for mbbill/undotree - wide diff window
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_HelpLine = 0

if has('unix') && exists('*exepath')
    if !empty(exepath('/bin/dash'))
        set shell=/bin/dash
    elseif !empty(exepath('/bin/bash'))
        set shell=/bin/bash
    endif
endif

" ripgrep
"
" 2022-09-27
" "It's very unlikely 'grepprg' is useful to search in buffers"
" but no bgrep/bufgrep has materialized yet.
" https://groups.google.com/g/vim_dev/c/4fYjTCWtWLM
" https://groups.google.com/g/vim_dev/c/idm621ixACU
"
" also https://github.com/tpope/vim-sensible/issues/115
if executable('/usr/bin/rg')
    " trailing /dev/null just helps when you forget %/filename
    set grepprg=/usr/bin/rg\ --vimgrep\ --no-heading\ --smart-case\ $*\ /dev/null
    " use column number provided by ripgrep
    set grepformat=%f:%l:%c:%m
endif


" important for UserDateComment (language time)
if has('win32')
    language en
    " no idea what'll happen here; ctype C.utf8 fails on windows 11, E197.
    language ctype en.utf8
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

" 2022-07-16 selective syntax highlighting no longer in use.

" ----

" my stuff
let g:u = {}

" U+21B3 - DOWNWARDS ARROW WITH TIP RIGHTWARDS
let g:u.showbreak_char = '↳'

let g:u.has_x11 = exists('$DISPLAY')
let g:u.has_cb_builtin = has('gui_running') || has('win32')
let g:u.has_cb_tty = has('unix') && g:u.has_x11 && executable('/usr/bin/xsel')

let g:u.term_primitive = 1
" test: env -u DISPLAY TERM=linux vim
if g:u.has_x11
    let g:u.term_primitive = 0
elseif has('gui_running')
    let g:u.term_primitive = 0
elseif &term =~# '^xterm' || &term =~# '^rxvt-unicode' || &term =~# '^putty'
    let g:u.term_primitive = 0
elseif has('vcon') && &term ==# 'win32'
    let g:u.term_primitive = 0
elseif &term =~# 'screen'
    let g:u.term_primitive = 0
endif

let g:u.mark = '_'
if !g:u.term_primitive
    " fence, guard; defend; idle time
    let g:u.mark = nr2char(0x95F2)
endif

" would like to stick to the default behaviour of keeping undo files in the
" same dir; but breaks badly on iOS when editing files on iCloud Drive -
" the iOS Files API probably doesn't like dot-hidden files.
"
" with centralised undo files, vim will automaticall use the full filename
" with % as separators as the undofile name - does not need trailing slashes
" the way 'directory' does.
" but no file extension's added for such files, unlike for swap files (.swp
" is added even for centralised swap files. inconsistent for no reason.
let g:u.undo_dir = expand('~/.vim/var/un')


" ditto; shouldn't have any trailing slashes - added later.
let g:u.swap_dir = expand('~/.vim/var/swap')

if !exists('$PARINIT')
    let $PARINIT = "rTbgqR B=.,?'_A_a_@ Q=_s>|#"
endif


" it's fine usually. incsearch can be an unwelcome surprise over ssh.
" doesn't handle chained :g/:v.
" doc 'is'
" to put the last match into the command line: <C-r>/
set noincsearch
command -bar Inc let &incsearch = !&incsearch | set incsearch?

" setting 'ignorecase' can be surprising.
" for example, checking filenames against the 'backupskip' patterns uses
" 'ignorecase'.
set noignorecase
set hlsearch
set noshowmatch

" curse god and walk backwards to 1976; speechless at the number of bells
" they've stuck in here. a side effect of audio not working on linux?
set noerrorbells novisualbell
if exists('&belloff')
    set belloff=all
endif

" would be nice to see only partial commands, but 'showcmd' is too overloaded,
" for example visual mode selected char count display switching without
" indication to selected line count. the jumping cursor and redrawing is
" noticeable on slow Windows environments (VMware, large screen, underpowered
" graphics.) v:count is what's good to know; the statusline doesn't update
" often enough to be useful for this. vile throws up an arg: prompt for this,
" which is nice.

set showcmd

" doc fo-table
set formatoptions=t
" leave only one space after ./?/! when joining
set nojoinspaces
" wrapmargin adds <EOL>s, never use.

" http://stackoverflow.com/a/26779916/1183357
set backup backupdir^=~/.backup
" just to save the default to be reused later; since &backupdir is always
" global.
let g:u.backup_dir = &backupdir


function! UserMkdirOnce(dir)
    if a:dir == '.'
        return
    endif
    if !isdirectory(a:dir)
        call mkdir(a:dir, 'p', 0700)
    endif
endfunction


" setup 'directory'.
"
" trailing '//' -> '%' as path separators has been possible since vim 5.4:
" version5.txt:3726 /New variation for naming swap files:/
"
if has('unix') || has('win32')
    call UserMkdirOnce(g:u.swap_dir)
    if g:u.swap_dir ==# '.'
        let &directory = g:u.swap_dir
    else
        let &directory = g:u.swap_dir . '//'
    endif
endif
set swapfile updatecount=10 updatetime=2666
" to see current swap file path: ':sw[apname]' / swapname('%')

" it's great that vim can undo more, but i can't remember that much history.
"set undolevels=20

if has('persistent_undo')
    call UserMkdirOnce(g:u.undo_dir)
    let &undodir = g:u.undo_dir
    set undofile
endif

" mapleader is a variable, not a setting; no &-prefix
let g:mapleader = ','

" "f", "w" are nice, so not adding "a". "s" ('terse') and "S" are also useful.
"
" vim's generally helpless in the face of long file names. important to maintain
" a good cwd, to not get the noisy hit ENTER prompts.
set shortmess+=i
set shortmess+=l
set shortmess+=m
set shortmess+=n
set shortmess+=r
set shortmess+=x
set shortmess+=o    " since we use 'autowriteall'
set shortmess+=W    " don't show "written"/"[w]"
set shortmess+=I    " hide intro
if has('patch-7.4.314')
    set shortmess+=c    " hide ins-complete-menu messages
endif

" a little like :behave mswin, but not all the way. think DOS EDIT.COM.
" set keymodel=startsel selectmode=mouse,key
" don't use SELECT mode
set selectmode= keymodel=

" laststatus: 0 = never, 1 = show if multiple splits, 2 = always.
"
" 2023-02-15 laststatus 1 seems a bit buggy with current gvim; on split +
" statusline drawing, command line height becomes too much.

set laststatus=2

" disabling 'ruler' makes 3<C-g> print more info.
set ruler rulerformat=%=%M\ %{g:u.mark}
" would like to disable showmode; but with all the different modes in
" vim...
set showmode
" never changing tabstop again
set tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab
set fileformats=unix,dos
set smarttab
set shiftround
set backspace=indent,eol,start

" move, in normal+visual with, <left> and <right>.  NB regarding the default
" (b,s) - we map <bs> to disable hlsearch, and i've never used <space> to go
" forward. so, instead of +=, here we do =.
" 2023-01-29 add [,] for left/right in insert mode. can't recall if it's
" already been tried and rejected.
set whichwrap=<,>,[,]


" indentation
" cindentation's a bit too intrusive for plaintext. smartindent too can be
" annoying. have seen 'undeletable' (ineffective x) tabs.
set autoindent
set colorcolumn=+1

" will be fine using visual mode/line numbers and the xsel(1) integration
" mappings and commands further below.
"
" highlight group: NonText

let &showbreak = g:u.showbreak_char

if g:u.has_x11
    " yes, even for vim in X terminal emulators
    set title
endif
"set display+=uhex
if v:version < 802
    " newer vims set this to 'truncate' and that's fine.
    set display+=lastline
endif
" use number column for wrapped lines, including showbreak char
set cpoptions+=n
set cpoptions-=a
set cpoptions-=A

set scrolloff=0

" scrolljump is efficient but jarring.
"set scrolljump=5
set cmdheight=1

"set confirm
set autoread autowrite autowriteall
set hidden
set matchpairs+=<:>,«:»,｢:｣

" ttyfast - seems to be about terminal capabilities and less about line speed.
" can disable if exists('$SSH_CONNECTION') && !g:u.has_x11

set endofline
if exists('+fixendofline')
    set fixendofline
endif
if exists('&langremap')
    set nolangremap
endif
if exists('&modelineexpr')
    set nomodelineexpr
endif

set wildmenu
" don't complete until unique (be like default bash behaviour)
set wildmode=list:longest,list
set wildignorecase
" don't complete swap, undo files and others.
set wildignore+=.*.swp,.*.un~,*.pyc
set suffixes+=.pyc

" viminfo: don't save registers.
set viminfo='100,<0,s0,h,r/tmp
if exists('$TMPDIR') && ($TMPDIR !=# '/tmp')
    execute 'set viminfo+=r' . $TMPDIR
endif

set browsedir=buffer
"set autochdir - too cumbersome
set virtualedit=block
set history=200

" helps with navigating to a line of interest with <no>j and <no>k,
" but also takes up a lot of space.
" see: cursorlineopt=number, 'signcolumn'
set number
set list
"set relativenumber

" but never newtab; maybe split.
set switchbuf=useopen,usetab
set splitbelow splitright
" 'equalalways' is default on; that's nice for vertical splits, don't want
" it with horizontal splits.
set eadirection=hor

if has('gui_running')
    set mouse=a
else
    set mouse=
endif

" I use 'view' a lot. In Red Hat Linux, view is provided by vim-minimal,
" which evidently does not include folding. This if statement avoids
" errors that view will otherwise print while starting.
if has('folding')
    set foldenable
    set foldmethod=marker
    set foldclose=
endif


if v:version >= 801
    set completeopt+=noinsert
    set completeopt+=noselect
endif
" contemporary
if v:version >= 900
    " display completion matches in a popup menu
    set wildoptions=pum

    " use NFA regexp engine?
    "set regexpengine=2

    set diffopt+=indent-heuristic
    set diffopt+=algorithm:patience
endif


" echom's untenable for even print debugging.
" do log if file exists; touch file == enable logging
let g:u.log_file = expand('~/.vimlog')
let g:u.log_enabled = filewritable(g:u.log_file)

function! UserLog(...) abort
    " log when either our own file exists, or if verbose is enabled
    let l:enabled = g:u.log_enabled
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
    let l:msg = strtrans(string(l:s))
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
    let l:logmsg = l:t . ' ' . l:msg . "\t" . l:stack

    if l:enabled
        let l:fn = g:u.log_file
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
    return globpath(&runtimepath, a:pathspec) != ''
endfunction


" set cell widths for unicode char ranges vim doesn't know about

function UserSetCellWidths()
    if v:version < 900
        return
    endif
    let l:yijing_hexagrams = [0x4DC0, 0x4DFF, 2]
    let l:egyptian_hieroglyphs = [0x13000, 0x1342F, 2]
    let l:u_ranges = [l:yijing_hexagrams, l:egyptian_hieroglyphs]
    call setcellwidths(l:u_ranges)
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
"
" By default listchars has eol:$ ; this case and trail: are covered by the
" trailing whitespace highlighting.
"
" Test nbsp with AltGr+Space.
"
" 'tab' hl: SpecialKey
"
" not being able to exclude 'tab' from listchars really seems to favour
" 'expandtabs' ... ?
"

function! UserListcharsDictMerge(lcs, lcs_exst) abort
    let l:lcs_new = copy(a:lcs_exst)
    call extend(l:lcs_new, a:lcs)

    " tab is special, can't be removed and the default is awful.
    if !has_key(l:lcs_new, 'tab') || (l:lcs_new.tab ==# 'NONE')
        let l:lcs_new.tab = '  '     " two spaces
    endif
    " cool new functionality: remove lcs attributes that have been
    " set to 'NONE'.
    call filter(l:lcs_new, "v:val !=# 'NONE'")

    return l:lcs_new
endfunction

function! UserListchars(...) abort
    let l:exst = {}
    if a:0 == 2     " parameter count
        let l:lcs_exst = a:2
        if type(l:lcs_exst) == 1
            " 2nd parameter is a string - convert to dict and use
            call extend(l:exst, UserCoCoToDict(l:lcs_exst))
        elseif type(l:lcs_exst) == 4
            " a 2nd parameter has been given, and it's a dict
            call extend(l:exst, l:lcs_exst)
        endif
    else
        " no 2nd parameter - start with existing listchars
        call extend(l:exst, UserCoCoToDict(&listchars))
    endif

    let l:lcs_choice = {}
    if a:0 > 0
        let l:lcs_input = a:1
        if type(l:lcs_input) == 1
            " input 1 is a string - use as given
            call extend(l:lcs_choice, UserCoCoToDict(l:lcs_input))
        elseif type(l:lcs_input) == 4
            " input 1 is a dict - use as given
            call extend(l:lcs_choice, l:lcs_input)
        endif
    endif

    " extend + override the existent listchars with the input listchars
    let l:lcs_new = UserListcharsDictMerge(l:lcs_choice, l:exst)
    return UserDictToCoCo(l:lcs_new)
endfunction

function! UserSetupListchars() abort
    let g:u.lcs = {}
    " keep listchars in top-level data structures so that i can mess with them
    " easily.
    "
    " for win32 and X11 with a good font:
    " eol: U+21B2 DOWNWARDS ARROW WITH TIP LEFTWARDS
    "   parity with g:u.showbreak_char
    " nbsp: U+263A WHITE SMILING FACE (mocking)
    "   other: U+2423 OPEN BOX
    "
    " tab: U+2192 RIGHTWARDS ARROW  + U+2014 EM DASH
    "   other: interpunct
    "   other: U+2409 SYMBOL FOR HORIZONTAL TABULATION
    "   tabs can be hidden by setting value to "\u20\u20", but showing is more
    "   useful.
    " trail: trailing spaces
    "   other: ␠  U+2420 SYMBOL FOR SPACE

    " bug/inconsistency in vim - it's possible to set showbreak=NONE, but not
    " set listchars=eol:NONE etc.; here we use NONE, because UserListchars()
    " knows how to deal with it. this has the effect of unsetting eol even if
    " the previous listchars defined it.
    "
    " these are most troublesome chars, displaying eol is usually just an
    " immense amount of clutter.

    "let u.lcs.p = UserCoCoToDict('eol:NONE,nbsp:☺,tab:→ ,trail:_')
    " U+21E5 RIGHTWARDS ARROW TO BAR
    "let u.lcs.p = UserCoCoToDict('eol:NONE,nbsp:☺,tab:⇥ ,trail:_')
    " guiellemet right - awkward but legible
    "let u.lcs.p = UserCoCoToDict('eol:NONE,nbsp:☺,tab:»>,trail:_')
    " it's important to make the whole tab visible, without using spaces,
    " to clearly separate it from actual spaces.

    " trailing spaces - underscores are too disturbing. seems too valid,
    " too much like a possible syntax error.
    " but - leave it out, so that our UserTrailingWhitespace syntax match
    " takes effect.

    " high uni chars that take 3 bytes sometimes seem to raise E834 - f.ex.
    " debian serial tty putty-256color screen final TERM = screen.linux
    let l:tab = '· ·'
    " old vims < 8.1.0759 don't support 3-char tab. patch made 2014, applied 2019.
    if !has('patch-8.1.0759') | let l:tab = '· ' | endif
    " trailing chars can be very annoying, so let's try something cool.
    let l:trail = [ '␠', '❤' ][1]

    let g:u.lcs.def = {
                       \ 'eol': '↲'
                       \ , 'extends': '>'
                       \ , 'nbsp': '␣'
                       \ , 'precedes': '<'
                       \ , 'tab': l:tab
                       \ , 'trail': l:trail
                       \ , 'conceal': '?'
                       \ }

    " same as def above, but without eol and trail (distracting)
    let g:u.lcs.p = copy(g:u.lcs.def)
    " ah, i liked having those bright little hearts..
    " but a bit too much with deep indenting and expandtabs.
    let g:u.lcs.p.eol = 'NONE'
    let g:u.lcs.p.trail = 'NONE'

    " for the linux console or old X bitmap fonts:
    let g:u.lcs.ascii = copy(g:u.lcs.def)
    " better that and have the key (eol).
    let g:u.lcs.ascii.eol = '$'
    let g:u.lcs.ascii.nbsp = '!'
    let g:u.lcs.ascii.tab = 'NONE'
    let g:u.lcs.ascii.trail = '_'

    let g:u.lcs.cur = g:u.term_primitive ? g:u.lcs.ascii : g:u.lcs.p
    let &listchars = UserListchars(g:u.lcs.cur)
endfunction

set conceallevel=0
" beware spooky action at a distance with cursorline and syntax matches.
set concealcursor=nvi

" 'fillchars' can accumulate items of same type. the last is effective. but
" the accumulated output is a mess and can be confusing. this function
" can be used to remove redundant items.
"
" input should be a dict of items that 'fillchars' understands,
" or a comma-column string.
"
" usage:
"
"   let &fcs = UserFillchars({'stl': 'x', 'stlnc': 'y'})
"   let &fcs = UserFillchars('vert:NONE')    " set vert to space
"
function! UserFillchars(...) abort
    " start with existing fillchars. if first param is a map, append it.
    let l:fcs = UserCoCoToDict(&fillchars)
    if a:0 > 0
        let l:input = a:1
        if type(l:input) == 1   " convert to dict and use
            call extend(l:fcs, UserCoCoToDict(l:input))
        elseif type(l:input) == 4   " a dict
            call extend(l:fcs, l:input)
        endif
    endif

    " fillchars doesn't natively support NONE, try to emulate with space.
    " similar to how UserListchars handles NONE for listchars.
    for k in keys(l:fcs)
        if l:fcs[k] ==# 'NONE'
            let l:fcs[k] = ' '
        endif
    endfor

    return UserDictToCoCo(l:fcs)
endfunction


function! UserSetupFillchars()
    " plain underscores don't join, that's ugly. elsewhere, for old
    " vim versions, we use a full, traditional statusline. don't want to use
    " fillchars stl/stlnc then.
    let l:fcs = {}

    if !g:u.term_primitive
        " U+2502 - BOX DRAWINGS LIGHT VERTICAL
        "   (vert default: U+007C    VERTICAL LINE)
        " U+2504 - BOX DRAWINGS LIGHT TRIPLE DASH HORIZONTAL
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

        " touchy; use pretty fancy chars only if we're reasonably free to.
        " but really, it's important - fully coloured statuslines seem bloated.
        "
        " 2022-09-04 on ultrawide monitors with slow VMware graphics, stl/stlnc
        " can cause windows gvim to crash.
        if 0 && has('patch-8.2.2569') && UserCanLoadColorscheme()
            " BOX DRAWINGS LIGHT HORIZONTAL
            let l:hrz = nr2char(0x2500)
            let l:fcs.stl = l:hrz
            let l:fcs.stlnc = l:hrz
        endif
    endif

    " set fillchars once we're done with all the if's.
    let &fillchars = UserFillchars(l:fcs)
endfunction


" cursorline - can be confusing with splits.
"
" the CursorLine highlight doesn't combine well with other highlights
" sometimes, including UserTrailingWhitespace. Can use 'set list' + listchars
" += trail:x as a workaround - then, when there is a char and not just
" whitespace to show, the SpecialKey highlight does show up "above" the
" CursorLine highlight.
"
" UserUnicodeWhitespace is out of luck. But 'Search'/'CurSearch' combine, even
" with just whitespace.
"
" Alternative: conceal, with a syn-cchar or listchars lcs-conceal.
"
" https://github.com/vim/vim/issues/10654
if v:version >= 802
    set cursorlineopt=line,number
endif

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
"set stl=%f%<\ %n\ %{UserBufModStatus()},%{&paste?'!P':&tw}%R%W%Y%#Normal#%#ModeMsg#%{UserModeMsg()}%#Normal#%=%{g:u.mark}\ %l:%v
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
    if &modified    | let l:m .= '+'        | endif
    if !&modifiable | let l:m .= '-'        | endif

    " if neither modified nor unmodifiable:
    if empty(l:m)   | let l:m .= '_'        | endif

    if &readonly    | let l:m .= '.ro'      | endif

    " normal buffer without a swapfile - warn
    if &buftype == '' && (!&swapfile || (&updatecount == 0))
        let l:m .= '.!swf'
    endif
    return l:m
endfunction


function! UserStLnBufUndoCount()
    let l:u = undotree()
    let l:diff = l:u.seq_last - l:u.seq_cur
    return l:diff > 0 ? 'un:' . l:diff : ''
endfunction

" if in paste mode, indicate that and not just the fact that paste mode
" temporarily forces textwidth to 0.
function! UserStLnTextWidth()
    return &paste ? '!P' : &textwidth
endfunction

function! UserStLnFenc()
    let l:s = ''
    if &fileencoding !=# 'utf-8'
        let l:s = 'fenc:' . &fileencoding
    endif
    return l:s
endfunction

function! UserStLnFf()
    let l:s = ''
    if &fileformat !=# 'unix'
        let l:s = 'ff:' . &fileformat
    endif
    return l:s
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

" gather up buffer info into one function - to execute in a single %{}. should
" usually go inside a matching pair of separators like []. other statusline
" flags like %W should go after this.
function! UserStLnBufFlags()
    let l:l = [ UserStLnBufModStatus() ]
    call add(l:l, UserStLnTextWidth())
    call add(l:l, UserStLnFenc())
    call add(l:l, UserStLnFf())
    call add(l:l, UserStLnBufUndoCount())

    " searching (for unicode whitespace) - costly

    " erase numbers that are 0, erase empty strings
    call filter(l:l, "v:val != 0 || v:val !=# ''")
    return join(l:l, ',')
endfunction

" NB: last double quote starts a comment and preserves the trailing space. vim
" indicates truncated names with a leading '<'.
"
" to show column: \ %{col('.')}/%{col('$')}
"
" current register: %{v:register}

set statusline=%n:%<%{UserStLnBufFlags()}%W%H/%#StatusLineNC#%t%=\ %{g:u.mark}\ "

" -- enough now.

" test statusline appearance with:
"   command window: :<C-f>
"   help
"   preview: :pedit <file>
"   :setl modified nomodifiable readonly

" 2022-08-17 tried using the tabline as an extension of the statusline a few
" times now, still hasn't felt right.
"
" the tabline doesn't update itself in the same way the statusline does. i
" don't use tab pages, but the tabline can be useful with long filenames.
" this way, the statusline can contain just window-specific info, with
" buffer-specifics in the tabline.

"set tabline=%n\ '%.50f'\ %{UserStLnBufFlags()}%W%H\ %=\ %{g:u.mark}\ "
"set showtabline=0


function! UserDateTimeComment()
    " month (%b) and day (%a) should be 3 chars each
    return strftime('-- date %F %T%z (%b, %a)')
endfunction


function! UserDate()
    return strftime('%F')
endfunction

function! UserDateTime()
    return strftime('%FT%T%z')
endfunction


" like 2022-07-05T12:57:18.568367478+00:00
"
" https://bugs.python.org/issue15443 - datetime doesn't support nanoseconds.
"
" 2022-07-05 syntax highlighting can break easily here. if using an endmarker,
" the ending endmarker should be at col 0 (beginning of line.) if a dot is
" used to terminate the heredoc, without no endmarkers, the dot being on a col
" > 0 doesn't seem to break syn.
"
" some old vim versions built with python3 < 3.7 can fail with missing
" time_ns().

function! UserNsUtcPy()
    if !has('python3')
        return -1
    endif

python3 << PYEOF
import datetime, decimal, time

def rfc3339ns():
    if not hasattr(time, 'time_ns'):
        return -2

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
"
" date commands on various platforms can do basically check anything. make
" sure we have GNU date.
function! UserNsUtcGnuDate()
    silent let l:ver = system('/usr/bin/date --version')
    if v:shell_error
        return -1
    endif
    if l:ver !~# '^date (GNU coreutils)'
        return -2
    endif
    let l:s = system('/usr/bin/date --utc --rfc-3339=ns')
    if v:shell_error
        return -3
    endif
    " todo fix before year 10000 or other major calendar changes.
    " len()-2 -- exclude the last ^@ from system()
    return l:s[0:9] . 'T' . l:s[11:len(l:s)-2]
endfunction

function! UserUtcNow()
    let l:ts = -10
    " iVim ships with python3, and it's trivial to get vim and python3
    " to work together on windows.
    let l:ts = UserNsUtcPy()
    if l:ts > 0
        return l:ts
    endif
    " old vims don't support 'linux', though date(1) on such systems
    " might be fine.
    if has('unix')
        let l:ts = UserNsUtcGnuDate()
    endif
    if l:ts > 0
        return l:ts
    endif
    return "<no nano>"
endfunction


" Run a vim command with output redireced to a variable.  Compatible with vim
" versions that don't have the execute() function.
"
" Modifies verbosity temporarily - otherwise the verbose log messages leak
" into the redirection. prepending 0verbose to cmd or setting verbosefile
" doesn't seem to prevent verbose messages ending up in l:val. running
" commands like 'verbose map' still works.
"
" sandbox is too strict, prevents useful commands like 'au'. hard to get side
" effects right with destructive commands. caveat emptor.

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
    if exists(':echowindow')
        " all lines get batched into one window
        for l:ln in a:lines
            echowindow l:ln
        endfor
    elseif has('popupwin')
        let l:opts = UserPopupNotfOpts()
        call popup_notification(a:lines, l:opts)
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
    let l:bufp = { 'ai': &ai, 'et': &et, 'fo': &fo, 'ft': &ft,
        \ 'sts': &sts, 'sw': &sw,
        \ 'ts': &ts, 'tw': &tw }
    return bufnr('%').': ['.UserStLnBufFlags().'] '.UserDictToStr(l:bufp)
endfunction


" https://stackoverflow.com/a/23323958
function! UserGetScreenChar()
    return matchstr(getline('.'), '\%' . col('.') . 'c.')
endfunction

" unicode name lookup.
" previously, lookup via https://ucdapi.org/unicode/10.0.0/codepoint/hex/
" now, python3 has more recent UCD data.
"
" unicodedata doesn't have names for control characters.
function! UserScreenCharLookup() abort
    let l:screen_char = UserGetScreenChar()
    if l:screen_char ==# ''
        return 'NUL'
    endif

python3 << PYEOF
import unicodedata
import vim

# the curses.ascii module is often missing on non-unix platforms, for
# no good reason. included inline here.

# begine most of python 3.10 curses.ascii

"""Constants and membership tests for ASCII characters"""

controlnames = [
    "NUL", "SOH", "STX", "ETX", "EOT", "ENQ", "ACK", "BEL",
    "BS",  "HT",  "LF",  "VT",  "FF",  "CR",  "SO",  "SI",
    "DLE", "DC1", "DC2", "DC3", "DC4", "NAK", "SYN", "ETB",
    "CAN", "EM",  "SUB", "ESC", "FS",  "GS",  "RS",  "US",
    "SP"
]

def _ctoi(c):
    if type(c) == type(""):
        return ord(c)
    else:
        return c

def isalnum(c): return isalpha(c) or isdigit(c)
def isalpha(c): return isupper(c) or islower(c)
def isascii(c): return 0 <= _ctoi(c) <= 127          # ?
def isblank(c): return _ctoi(c) in (9, 32)
def iscntrl(c): return 0 <= _ctoi(c) <= 31 or _ctoi(c) == 127
def isdigit(c): return 48 <= _ctoi(c) <= 57
def isgraph(c): return 33 <= _ctoi(c) <= 126
def islower(c): return 97 <= _ctoi(c) <= 122
def isprint(c): return 32 <= _ctoi(c) <= 126
def ispunct(c): return isgraph(c) and not isalnum(c)
def isspace(c): return _ctoi(c) in (9, 10, 11, 12, 13, 32)
def isupper(c): return 65 <= _ctoi(c) <= 90
def isxdigit(c): return isdigit(c) or \
    (65 <= _ctoi(c) <= 70) or (97 <= _ctoi(c) <= 102)
def isctrl(c): return 0 <= _ctoi(c) < 32
def ismeta(c): return _ctoi(c) > 127

def ascii(c):
    if type(c) == type(""):
        return chr(_ctoi(c) & 0x7f)
    else:
        return _ctoi(c) & 0x7f

def ctrl(c):
    if type(c) == type(""):
        return chr(_ctoi(c) & 0x1f)
    else:
        return _ctoi(c) & 0x1f

def alt(c):
    if type(c) == type(""):
        return chr(_ctoi(c) | 0x80)
    else:
        return _ctoi(c) | 0x80

def unctrl(c):
    bits = _ctoi(c)
    if bits == 0x7f:
        rep = "^?"
    elif isprint(bits & 0x7f):
        rep = chr(bits & 0x7f)
    else:
        rep = "^" + chr(((bits & 0x7f) | 0x20) + 0x20)
    if bits & 0x80:
        return "!" + rep
    return rep

# end python 3.10 curses.ascii

screen_char = vim.eval('screen_char')

if len(screen_char) == 1 and \
    unicodedata.category(screen_char) == 'Cc' and \
    isctrl(screen_char) and \
    ord(screen_char) < len(controlnames):
    u_name = controlnames[ord(screen_char)] + \
        ' (' + unctrl(screen_char) + ')'
elif screen_char == "\x7f":
    u_name = 'DEL (' + unctrl(screen_char) + ')'
else:
    try:
        u_name = unicodedata.name(screen_char)
    except ValueError:
        # exception just says "no such name"
        u_name = '(UNKNOWN)'

b = screen_char.encode('utf8')
# utf8_hex = b.hex()
utf8_hex = ' '.join([ '%x' % x for x in b ])

PYEOF

    let l:u_name = py3eval('u_name')
    " like g8
    let l:utf8_hex = py3eval('utf8_hex')
    let l:fmt = printf('''%s'' U+%04X %s; UTF-8: %s',
        \ strtrans(l:screen_char), char2nr(l:screen_char), l:u_name, l:utf8_hex)
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


function! UserCurWinSz()
    if !exists('*win_getid')
        return []
    endif
    " also getwininfo()
    let l:winid = win_getid()
    if l:winid == 0
        return []
    endif
    return [ l:winid, winwidth(l:winid), winheight(l:winid) ]
endfunction

command WinSize     echo UserCurWinSz()


function! UserGetInfoLines()
    let l:lines = []

    call add(l:lines, UserBufferInfo())

    " window info
    let l:win = 'wnd: ' . winnr() . ' ' . string(UserCurWinSz())
    call add(l:lines, l:win)

    let l:enc = { 'enc': &enc, 'fenc': &fenc, 'tenc': &termencoding }
    call add(l:lines, UserDictToStr(l:enc))

    " syntax groups under the cursor, if any
    let l:syn_cur = 'syn: ' . join(UserSyntaxNamesAtCursor(), ' ')
    call add(l:lines, l:syn_cur)

    call add(l:lines, 'matches (pat. hl.): ' . len(getmatches()))

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
    call add(l:lines, '--')
    call add(l:lines, l:char_info)

    " reminders, which have to be manually maintained for now.
    " damian conway has his own documented mappings; not yet worth the trouble.

    return l:lines
endfunction


" return some info about the buffer and the current location,
" a little like 3<C-g>
function! UserLoc()
    let l:name = bufname('%')
    let l:lno_cur = line('.')
    let l:lno_end = line('$')
    let l:perc = l:lno_cur * 100 / l:lno_end
    return printf('buf %d: "%s" %d:%d (%d) $ %d --%d%%--',
        \ bufnr('%'), l:name, l:lno_cur, col('.'), virtcol('.'), l:lno_end, l:perc)
endfunction


" NB: return value ("\<Ignore>") - important for using in insert mode.
" otherwise, function return value will be appended to the buffer.
" doc :map-expression
function! UserShowHelp()
    if has('popupwin')
        let l:lines = UserGetInfoLines()
        call UserAlert(l:lines)
    else
        " can't make a big fuss and interrupt the flow.
        " just echo one line.
        let l:info = UserBufferInfo()
        echo l:info
    endif
    return "\<Ignore>"
endfunction


" compute backupdir and backupext that should be used for automatic backups.
" $HOME is very long on iOS.
"
" would be nice to use RCS for this, but incurs setup overhead.
function! UserBufferBackupLoc(fn) abort
    let l:filepath = fnamemodify(a:fn, ':p:h')

    if has('win32')
        " for microsoft windows - replace the ':' after drive letters with '$'
        let l:filepath = l:filepath[0] . '$' . l:filepath[2:]
    endif

    " could start with g:backupdir
    let l:backup_root = expand('~/.backup')
    let l:tm = localtime()

    " like: ~/.backup/example.com/yyyy-mm-dd/path.../file.ext.<runnr>
    " keeps related changes within a day together.
    "
    " the slash between strftime() and l:filepath makes for two slashes
    " in unix, but windows requires it (no slash before drive letter).
    let l:dir = simplify(expand(l:backup_root
        \ . '/' . hostname()
        \ . '/' . strftime('%F', l:tm)
        \ . '/' . l:filepath))

    call UserMkdirOnce(l:dir)

    " 2023-06-22 used to set the extension to hhmm, keeping just one backup
    " per minute. but it's not satisfactory. let's really have a backup per
    " write, starting from 0. it'll be limited per day by the timestamp in the
    " backup path.

    let l:target = l:dir . '/' . fnamemodify(a:fn, ':t') . '*'
    let l:ext = '.' . len(glob(l:target, 1, 1))

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
" args:
"   fn: a filename, usually <amatch>
function! UserUpdateBackupOptions(fn) abort
    let l:fn = a:fn

    " if filename matches 'backupskip', file won't be backed up. no point
    " doing a lot of work to setup backupdir and backupext.
    if UserTestBackupskip(l:fn) != 0
        " writing a new file - no backup will be written by vim,
        " no need to create directories.
        return
    endif

    let [l:dir, l:ext] = UserBufferBackupLoc(l:fn)

    " 'set backupdir' can get messy with paths that contain spaces; and these
    " settings are always global, &l: / setlocal means nothing.
    " filename escape + comma...
    let l:diresc = escape(fnameescape(l:dir), ',')

    " manual combining, without ^=, with original global backupdir, to prevent
    " accumulation when crossing midnight.
    let l:backupdir = l:diresc . ',' . g:u.backup_dir

    execute 'setlocal' 'backupext=' . l:ext 'backupdir=' . l:backupdir

    " echom 'backup-options' &bex &bdir
    " expand() to fix up path separators
    let b:user_last_backup =  expand(l:dir . '/' . fnamemodify(l:fn, ':t') . l:ext)

    " echom 'b' pathshorten(b:user_last_backup)
endfunction


function! UserStripTrailingWhitespace()
    if !&l:modifiable || &l:readonly || &l:binary
        return
    endif
    if exists('b:user_noautomod') && b:user_noautomod
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

command -bar NoAutomod  let b:user_noautomod = 1

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


" fallback definitions for the highlight groups used by our own syntax rules,
" in case our colorscheme wrapper isn't present.
function! UserDefineSyntaxHighlightGroups()
    let l:hl = {}

    " unlike for :syntax list, :filter works for :highlight. but :filter's not
    " old enough to be available everywhere.
    "
    " highlight groups may have been cleared (but still left defined) by a
    " colorscheme reload. we don't treat these as present. i.e. we only want
    " to select User highlight groups that haven't been cleared.

    for l:ln in split(UserRun('silent highlight'), "\n")
        let l:matchresult = matchstr(l:ln, '^User\w\+')
        if l:matchresult !=# '' && match(l:ln, ' cleared$') == -1
            let l:hl[l:matchresult] = 1
        endif
    endfor

    " because we don't want to put the UserUnicodeWhitespace in a colorscheme
    " override, we don't do a quick exhaustive check here (like we do for
    " syntax items).

    if !has_key(l:hl, 'UserDateComment')
        " 2023-06-30 cterm italic can break easily (freebsd termcap)
        highlight UserDateComment ctermbg=grey guibg=grey
    endif

    if !has_key(l:hl, 'UserTrailingWhitespace')
        highlight UserTrailingWhitespace term=standout ctermbg=grey guibg=grey
    endif

    if !has_key(l:hl, 'UserHashTag')
        highlight UserHashTag ctermbg=grey guibg=grey
    endif

    " for URIs at top level, with syntax highlighting and not matchadd()
    if !has_key(l:hl, 'UserHttpURI')
        highlight! default link UserHttpURI Normal
    endif

    " __UNIWS__; this isn't something we want to put in a colorscheme override
    " file, maybe - unless we work with a red background. blinking would have
    " been nice, if hi start/stop worked everywhere.
    if !has_key(l:hl, 'UserUnicodeWhitespace')
        highlight UserUnicodeWhitespace term=standout ctermbg=red guibg=orange
    endif

    " UserHttpURI: if using non-syntax matches (matchadd/UserMatchAdd), define
    " a ctermbg to hide spell errors. f.ex. ctermbg=255 guibg=bg
endfunction


" bring some sanity to vim UI element colours.
" remember; TERM(vt100, vt220) -> term, TERM(ansi, linux, xterm) -> cterm
"
" Only needs to run on non-gui, non-256-colour ttys.
function! UserSafeUIHighlights()
    if g:u.term_primitive
        highlight ColorColumn   term=reverse
        highlight CursorColumn  NONE
        highlight CursorLine    NONE
        highlight CursorLineNr  term=NONE cterm=NONE
        highlight EndOfBuffer   NONE
        highlight ErrorMsg      term=standout
        highlight Ignore        NONE
        "highlight LineNr        NONE
        highlight MatchParen    NONE
        " in some situations the default bold attribute of ModeMsg caused
        " problems. clear the term attribute.
        highlight ModeMsg       NONE
        highlight Normal        NONE
        " for cterm with 8/16/88 colours
        highlight Visual        term=reverse cterm=reverse ctermbg=NONE
    endif

    if UserCO(g:u.coflags.spell)
        " we'll set our own later
        highlight SpellBad      NONE
    endif

    " we want to be safe for monochrome ttys, and at the same time
    " clear cterm and gui attributes that can be bad in 256 color and gui modes.
    " since the attributes here are initial values and get inherited later.
    " and bearable with screen(1) defaults, where t_Co == 8.

    " NonText - by default used, among others, for the end-of-buffer tildes.
    " here, with low-color ttys in mind, we don't want to set a ctermbg.
    " listchars: eol, extends, precedes
    highlight NonText       term=NONE ctermfg=NONE ctermbg=NONE cterm=NONE
    " listchars: tab, nbsp, trail (+ space, multispace, lead)
    highlight SpecialKey    ctermfg=blue ctermbg=NONE cterm=NONE

    if UserCO(g:u.coflags.stat)
        " specifying ctermfg in case of a dark tty background
        highlight StatusLine    ctermfg=grey    ctermbg=black   cterm=NONE
        highlight StatusLineNC  ctermfg=black   ctermbg=grey    cterm=NONE
    endif
endfunction     " UserSafeUIHighlights


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
    highlight Constant term=bold cterm=bold gui=bold
endfunction

"
" Tip: set tty (xterm, rxvt-unicode, VTE) colour 12 to azure2/#e0eeee.
" For mlterm: ~/.mlterm/color, 12 = #e0eeee;
"   manpage section "Color Configuration File"
"
" For ROXTerm: ~/.config/roxterm.sourceforge.net/Colours/<custom profile>:
"   [roxterm colour scheme]
"       12=#e0e0eeeeeeee
"
" For xterm/rxvt-unicode: XResources
"   *color12: azure2
"

" There are no close soft blues within the common 16 colours, and it's not
" straightforward to override a blue within the 88/256 colours.
"
" NonText and SpecialKey bg should match UserTrailingWhitespace. now that we
" can use background colors, we clear ctermfg.
"
" SpecialKey's also used with :map - too light isn't great, but can use MyMaps.
"
" Old vims don't know EndOfBuffer, just NonText. So NonText shouldn't use the
" same ctermbg as StatusLineNC.

" 'light' only
" sea green ?
"
" statusline colours a little like this gameboy theme:
" https://lospec.com/palette-list/grue: stl #b8c7bf, stlnc #4d5964
" and the Diana F+ camera body.
" guibg=#grey82 (typo) produced a nice colour, probably #efdf82
" also dark turquoise.

function! UserSetGuiFont()
    if has('linux') && has('gui_gtk')
        let &guifont = 'Iosevka Fixed Slab 11'
    elseif has('win32')
        " default cANSI:qDRAFT
        set guifont=Iosevka_Fixed_Slab:h11
        set guifont+=Cascadia_Mono:h11
        set guifont+=Consolas:h11
        " more cleartype; no hidpi here.
        " 2023-03-02 have hidpi now.
        " 2023-07-09 not everywhere (ultrawide at work)
        set renderoptions=type:directx,taamode:1
    elseif has('ios')
        " iVim, iPhone
        set guifont=Menlo:h11.0
    endif
endfunction

" 2022-12-08 - removing autoselect; too easy to unintentionally wipe the
" clipboard that way. gvim's like a terminal emulator anyway - shouldn't work
" too hard to be a good gui app.  2023-01-02 - just unnamedplus is no good for
" win32. doesn't fail, but breaks y/p.
function! s:setupClipboard()
    " pasting from the system clipboard is nice, but all small cuts and pastes
    " going to the system clipboard is not great.
    set clipboard=
    return

    " previously,
    if 0
    if g:u.has_cb_builtin
        set clipboard=unnamed
        if has('unnamedplus')
            " only when built for X11
            set clipboard+=unnamedplus
        endif
    elseif has('X11') && has('clipboard')
        " debian vim used to.. maybe BSDs still do.
        "
        " if not gvim or win32, do not connect to X; can slow down startup due
        " to xauth/cookie issues etc.
        "
        " doesn't seem to be a problem on fedora, vim-enhanced doesn't have
        " +X11
        set clipboard=exclude:.*
    endif
    endif
endfunction


" works, but again, loses context. verbose hi shows the line number within
" this function as the modification location, not the callsite of this
" function.
function! UserCopyHiAttr(from_hl, to_hl, attr) abort
    let l:src = hlget(a:from_hl, v:true)[0]
    let l:dest = hlget(a:to_hl)[0]
    let l:dest[a:attr] = l:src[a:attr]
    call hlset([l:dest])
endfunction


" Meant to run after a colorscheme we like is loaded. Overrides highlights
" we don't agree with (StatusLine(NC), NonText, SpecialKey), defines good
" highlights in case the colorscheme file might not be available (Visual).
"
" mlterm starts with t_Co 8, later changes to 256.
function! UserColours()
    call UserLog('UserColours enter win', winnr())
    " 'background' at the time this function ran - save to inspect later
    let g:u.user_colours_last_bg = &background

    " 2023-07-01 our colorscheme overrides are now in an external colorscheme
    " file. overrides depend on the scheme, no point in keeping them in this
    " vimrc as long as we depend on another external file (the colorscheme)
    " anyway.

    " vim spell isn't worth suffering this much over.
    highlight clear SpellCap
    highlight clear SpellLocal
    " decriminalise rare words
    highlight clear SpellRare

    " define the highlight groups for our custom syntax items. these will get
    " cleared on colorscheme changes etc.
    call UserDefineSyntaxHighlightGroups()
endfunction


let g:UserCustomSynHash = { 'UserTrailingWhitespace': 1,
            \ 'UserUnicodeWhitespace': 1,
            \ 'UserDateComment': 1,
            \ 'UserHashTag': 1,
            \ 'UserHttpURI': 1 }

" define custom syntax items for things we want highlighted.
"
" we want these to run even when syntax highlighting is globally off.
function! UserApplySyntaxRules()
    call UserLog('UserApplySyntaxRules enter win', winnr())

    " no good way to check if just a syntax item's defined (hlID/hlexists pass
    " for either syntax item or highlight group). and execute()'s rather new.
    "
    " :filter doesn't work either - i.e. :filter /^User/ syntax list doesn't
    " exclude anything.
    "
    " we don't want to be too smart and keep any buffer-local var for this -
    " syntax items can get invalidated due to reasons like colorscheme
    " changes.

    let l:syn = {}
    for l:ln in split(UserRun('silent syntax list'), "\n")
        let l:matchresult = matchstr(l:ln, '^User\w\+')
        if l:matchresult !=# ''
            let l:syn[l:matchresult] = 1
        endif
    endfor

    if len(l:syn) != 0 && l:syn == g:UserCustomSynHash
        " everything's already defined
        return
    endif

    " some or none of our custom syntax items are defined. clear and define
    " all of them.
    "
    " reason for syntax clear <name>: syntax item definitions are always
    " additive.
    "
    " we could wrap each of the definitions in an if has_key...

    syntax clear UserTrailingWhitespace
    syntax match UserTrailingWhitespace /\s\+$/
        \ display oneline containedin=ALLBUT,UserTrailingWhitespace
    "
    " to make them visible only on the current line, after the cursor:
    " https://github.com/thoughtstream/Damian-Conway-s-Vim-Setup/blob/master/.vimrc
    "   /InvisibleSpaces
    "syntax match UserTrailingWhitespace /\S\@<=\s\+\%#\ze\s*$/
    "    \ display oneline containedin=ALLBUT,UserTrailingWhitespace

    " reveal unicode whitespace; __UNIWS__
    "
    " 2023-04-28 using a highlight group defined elsewhere, but also
    " concealment, with syn-cchar defined with listchars (which is used by
    " concealment even when 'list' is disabled. hlsearch highlight does not
    " override conceal highlight :-) what a wonderful stew of interactions.)
    " 2023-05-01 no concealing - doesn't buy a lot for whitespace.

    let l:expr_synmatch_uniws = 'syntax match'
                \ . ' UserUnicodeWhitespace'
                \ . ' /' . UserGetUnicodeWhitespaceRegexp() . '/'
                \ . ' display oneline containedin=ALLBUT,UserUnicodeWhitespace'
    syntax clear UserUnicodeWhitespace
    execute l:expr_synmatch_uniws

    " canary:
    " -- date 2022-07-25 14:42:43+0200 (Jul, Mon)dnl
    syntax clear UserDateComment
    syntax match UserDateComment
        \ /\v-- date 20\d\d+-\d\d-\d\d \d\d:\d\d:\d\d.{,16}/
        \ display oneline containedin=ALLBUT,UserDateComment

    " canary: [✚x] [✚'x'] [✚'x ✚'x](pathological, overlap)
    "              [✚"x"] [✚"x ✚"x] [✚"xs-xp-xq'-xz"]
    "   [✚'a\'b']
    "   [✚'a\✚b\'cde']
    syntax clear UserHashTag
    syntax match UserHashTag /\v✚[_[:lower:][:upper:][:digit:]]{1,30}/
        \ display oneline containedin=ALLBUT,UserHashTag
    "syntax match UserHashTag /\v✚'[^^'✚]{-1,30}'/
    "
    " in single quotes, allow escaping anything - including single quotes
    " and tag-starting cross.
    " %() - non-capturing group.
    syntax match UserHashTag /\v✚'%([^✚'\\]|\\.){-1,30}'/
        \ display oneline containedin=ALLBUT,UserHashTag

    " make URIs effectively transparent; if contained, highlight like the
    " container. if at toplevel, highlight like the Normal hl group.
    " see hl definition of UserHttpURI.
    "
    " canary:
    "https://web.archive.org/web/20010301154434/http://www.vim.org/"
    if 0
        https://web.archive.org/web/20010301154434/http://www.vim.org/
    endif
    syntax clear UserHttpURI

    " < (\v<) - match at beginning of word; help /\<
    "
    " > - match at end of word; help /\>
    "
    " this regexp isn't universal; it's important to not include quote chars
    " (", ' even though it's allowed in STD 66, browsers seem to pctencode
    " it), to prevent syntax highlighting from breaking.
    "
    " pchar / sub-delims / ispunct() / [:punct:] might be:
    "
    "   !"#$%&'()*+,-./:;<=>?@[\]^_`{|}~
    "
    " parens/brackets are common in query strings, but i don't need them in my
    " files often. so: !#$%&*+,\-\./:;<=>?@^_~
    "
    " 2023-08-16 consider turning the whole thing off. spell checking is not
    " extremely helpful (we attenuate the colour anyway). synmaxcol applies
    " to the rules below but doesn't apply for spell checking (SpellBad
    " highlighting happens beyond synmaxcol).

    let l:uri_re = '\v<https?://\w[-\.[:alnum:]]*\w%(:\d+)?%(/[-\.[:alnum:]_~%:/]*)?%(\?[[:alnum:]!#$%&*+,\-\./:;<=>?@^_~]*)?%(#[[:alnum:]!#$%&*+,\-\./:;<=>?@^_~]*)?>'
    " with delimiters for syntax match:
    let l:s = '=' . l:uri_re . '='

    " toplevel:
    execute 'syntax match UserHttpURI' l:s 'contains=@NoSpell'
    " contained in other syntax matches:
    execute 'syntax match UserHttpURI' l:s 'transparent contained containedin=ALLBUT,UserHttpURI contains=@NoSpell'
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


" doc slow-terminal
function! UserTermSlow()
    set noincsearch noruler noshowcmd nottyfast
endfunction


function! UserColoursPrelude()

    " 2023-06-30 background light/dark detection seems to work as documented,
    " though maybe not bg&.
    "
    " a possible race - vim starts up with bg=light, and bg may get changed to
    " dark while a colorscheme runs. some colorschemes (lucius, hybrid) do a
    " set bg with the bg at the time the colorscheme started running - setting
    " dark bg back to light.

    let l:done = 0

    if !l:done && has('gui_running')
        let l:done = 1
    endif

    " hints for when the defaults or vim's guessing fails.
    " https://www.freedesktop.org/software/systemd/man/sd_session_get_type.html#
    " can't check tty(1), screen(1) -> devpts. maybe things to check:
    " XDG_SESSION_TYPE (tty, incl. for ssh with X), SSH_CONNECTION
    "
    " no COLORFGBG over serial or across ssh.
    "
    " redhat /etc/vimrc - not much thought goes on there. 8.x loads the desert
    " colorscheme. that in turn sets bg=dark. seems impossible to fix - set
    " all& just sets bg to light.
    "
    " there doesn't seem to be a way to re-trigger vim's detection
    " (may_req_bg_color). this is what set bg& should have done. workaround,
    " use an external command that does something like:
    "
    " printf '\033]11;?\007' > /dev/tty read -rs -t 0.2 -d "" < /dev/tty if
    " cat -A <<< "$REPLY" | grep 'rgb:0000/0000/0000' > /dev/null; then
    "
    " https://www.unix.com/shell-programming-and-scripting/276281-problem-reading-terminal-response-string-zsh.html#post303010590
    " https://stackoverflow.com/questions/47938109/reading-answer-to-control-string-sent-to-xterm
    " https://invisible-island.net/xterm/ctlseqs/ctlseqs.html#h3-Operating-System-Commands
    " https://stackoverflow.com/a/38287998
    " https://github.com/vim/vim/issues/869

    if !l:done && has('termguicolors')
        if &term ==# 'xterm-direct'
            " lovely; but, pretty much have to use gui colors.
            " unlike VTE, cterm colors and gui colors can't coexist here.
            set termguicolors
            let l:done = 1
        elseif &term ==# 'win32' && has('vcon')
            " windows console since Windows 10 Insiders Build #14931 or whatever
            set termguicolors
            " but t_Co stays at 256. setting to 2**24 does something, but
            " t_Co itself stays at 256.
            let l:done = 1
        elseif &term =~# '^xterm' && exists('$VTE_VERSION')
            " probably maybe VTE?
            " unlike xterm-direct, t_Co stays at 256. unlike vcon, can set it.
            set termguicolors t_Co=16777216
            let l:done = 1
        endif
    endif

    " could also enable tgc for PuTTY; seems default on now. but
    " terminfo/termcap might not have caught up yet.

    if !l:done && exists('&t_Co') && &t_Co == 8 && $TERM !~# '^Eterm'
        " good idea from tpope/sensible; bright without bold.
        " will take effect under screen(1) ($TERM == 'screen').
        set t_Co=16
        let l:done = 1
    endif
endfunction

" -- colorscheme control
" mnemonic: co/CO == colour override
" script-local
"
" useage example:
"
"   let u.co = u.coflags.min | colo iceberg
"
function! UserInitColourOverride()
    " mnemonic: cof == colour override flags
    let g:u.coflags = {}
    let g:u.coflags.none =       0    " don't override anything
    let g:u.coflags.stat =       1    " StatusLine* + VertSplit
    let g:u.coflags.spell =      2    " SpellBad
    let g:u.coflags.mode =       4    " ModeMsg
    let g:u.coflags.ui =         8    " the rest
    let g:u.coflags.normguibg = 16    " Normal guibg - gui background

    let g:u.coflags.min =        7    " sane minimum: stat + spell + mode
    let g:u.coflags.all =       31    " override all known

    " control variable
    let g:u.co = g:u.coflags.all
endfunction

" bitwise check if a flag is set
function! UserCO(p)
    return and(g:u.co, a:p) == a:p
endfunction

function! UserCOAny()
    return g:u.co != g:u.coflags.none
endfunction

" -- end colorscheme control

" syntax for text isn't worth the trouble but we like good UI colours. for
" non-xterm-direct terminals (VTE, kitty) it might be necessary to call
" UserColours() again after enabling termguicolors. do all the ui/content
" color changes and loading of a color scheme.

function! UserLoadColors()

    " most colorschemes don't pull their own weight. would be great if a
    " colorscheme + reload behaviour would take a closure instead of requiring
    " a file on disk.  And seperate user interface component highlights from
    " text content highlights.
    "
    " start by erasing the default highlights, which are very annoying,
    " specially on terminals with few colours. we do this whether we have a
    " colorscheme or not.

    if exists('g:syntax_on')
        call UserClearContentHighlights()
    endif

    " in any case, the default vim syntax definitions are maybe 60% good
    " anyway. setting non-tty-fg dark colours on "normal" text bothers me a
    " little too.

    if UserCanLoadColorscheme()
        " load iceberg with our overrides.
        if UserRuntimeHas('colors/iceberg~.vim')
            colorscheme iceberg~
        endif

        " other good: PaperColor?
        "
        " honorable mention:
        "
        "   monochromenote - https://github.com/koron/vim-monochromenote
        "
        " zenchrome (https://github.com/g0xA52A2A/zenchrome.vim/) is a nice,
        " comprehensive framework; should integrate it into this vimrc
        " someday.

    endif

    " if no colorscheme found/loaded, the ColorScheme autocmd won't fire. load
    " our UI colour overrides.

    if !exists('g:colors_name') | call UserColours() | endif
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
    update

    if winnr('$') == 1
        " just one window (i don't use tab pages)
        confirm bdelete
        return
    endif

    " keep current buffer number, we'll need it later
    let l:bufnr = bufnr('%')

    let l:bufnr_alt = bufnr('#')
    if l:bufnr_alt != -1
        " has alternate buffer, switch to it.
        " using execute instead of a simple buffer #, too close to a comment.
        execute 'confirm buffer' l:bufnr_alt

        " try to delete the original buffer, if it's not in any other window
        if !bufloaded(l:bufnr)
            execute 'confirm bdelete' l:bufnr
        endif

        " other new-fangled ways to see if a buffer's visible in any windows:
        " getbufinfo(l:bufnr) -> <dict>.windows
        " win_findbuf(l:bufnr)
    else
        " no alternate buffer - new empty buffer
        " to keep the window from closing
        enew
    endif
endfunction

command XB                  call UserBufCloseKeepWin()


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
"window, fails since the buffer's unmodifiable. " Since the command runs in a
"new buffer, some things like :syntax (listing syntax definitions) won't work.
"
" prior:
" https://github.com/AmaiSaeta/capture.vim/blob/master/plugin/capture.vim

function! UserSpoolEx(cmd)
    if 0 && (&l:readonly || !&l:modifiable)
        echom 'unmodifiable'
        return
    endif

    Scratch
    if exists('*win_getid')
        let l:winid = win_getid()
        "echom 'opened' l:winid
    else
        let l:winid = -1
    endif
    let l:close = 1
    try
        let l:v = UserRun(a:cmd)
        if empty(l:v)
            "echom 'nothing to put'
        else
            put = l:v

            " can make the buffer readonly nomodifiable here, but it can be
            " nice to play around/test editing commands.

            " everything seems fine, leave window open.
            let l:close = 0
        endif
    catch /^Vim\%((\a\+)\)\=:E21:/
        echom v:exception
    catch /^Vim\%((\a\+)\)\=:E382:/
        echom 'cannot write -' &buftype
    catch /^Vim\%((\a\+)\)\=:E/
        " echoerr throws; messy.
        echohl Error
        echom 'unexpected error' v:exception
        echohl None
    finally
        if l:close
            " something went wrong before l:close could be set to zero,
            " close the window if possible
            if l:winid != -1
                "echom 'closing' l:winid
                " get win number only when needed.
                let l:winnr = win_id2win(l:winid)
                execute l:winnr . 'wincmd c'
                " leaves the actual buffer lying around
            endif
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
    call append(0, ['Maps'])       | normal! G
    " :map doesn't show mappings for all modes; meh
    " doc map-overview
    call append('.', ['', '-- :map'])   | normal! G
    put= UserRun('verbose map')         | normal! G
    call append('.', ['', '-- :cmap'])  | normal! G
    put= UserRun('verbose cmap')        | normal! G
    call append('.', ['', '-- :imap'])  | normal! G
    put= UserRun('verbose imap')        | normal! G

    " get rid of the line breaks in the 'verbose' output
    " conceptually cleaner: :g/^\sLast set from/-1j    [join with line above]
    global/\n\s\+Last set from/s//\t# src =/
    " delete lines that don't refer to a vimrc/gvimrc at home.
    " 2022-08-22 actually it's useful to see all mappings.
    "global/src =/g!/src = \~\S\+vimrc\>/d _
    " replace <file> line <lineno> with something gF can jump to
    global/ line \(\d\+\)$/s//:\1/

    normal! gg

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
    " our config = any line with "src = ~" + "vimrc" + word boundary.
    " should work with windows/vimfiles too.
    " this deletes commands from plugins/colorschemes under ~/.vim.
    global/src =/g!/src = \~\S\+vimrc\>/d _
    " enable going to location - replace "<file> line <lineno>" in the
    " 'verbose' output with <file>:<lineno>
    global/ line \(\d\+\)$/s//:\1/

    " ':command' output is already sorted.
    " delete empty lines
    global/^$/d _

    setlocal readonly nomodifiable
endfunction

command MyCommands  silent call UserShowCommands()


function! UserShowFunctions()
    Scratch
    call append(0, ['Functions', ''])
    put= UserRun('verbose function')
    global/\n\s\+Last set from/s//\t# src =/
    global/src =/g!/src = \~\S\+vimrc\>/d _
    global/ line \(\d\+\)$/s//:\1/
    global/^$/d _
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
    let l:bufnr = bufnr('%')
    " execute in current buffer
    let l:syn = execute('syntax list')
    Scratch
    " add output to new scratch buffer
    call append(0, ['Syntax items for buffer ' . l:bufnr])
    put =l:syn
    /^--- Syntax items ---$/d _
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
    " don't restore sometimes
    if &filetype =~# '\vcommit|rebase|diff'
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


" -- spelling

" NB vim automatically creates ~/.vim/spell/ when necessary. no need to ensure
" that it's present.

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
function! UserSpellLangs() abort
    let l:spls = []
    if UserRuntimeHas('spell/enlocal.utf-8.spl')
        call add(l:spls, 'enlocal')
    else
        " vim default would be 'en'; start with that since we'll add other
        " languages (at least 'cjk') later.
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
"set spellfile=~/.vimspell.utf-8.add
" 2022-08-29 leave spellfile at vim default.
" clean default for english: ~/.vim/spell/en.utf-8.add
" default for enlocal: ~/.vim/spell/enlocal.utf-8.add

" for easily updating spell files from modified .add files.
" https://vi.stackexchange.com/a/5052
"
" :mkspell prints; can call this function with :silent to suppress that.
function! UserMkspell() abort
    " might also use &spelllang and skip 'cjk';
    let l:globres = glob('~/.vim/spell/*.add', 1)
    if l:globres == ''
        " no .add files
        return
    endif
    let l:addfs = split(l:globres, "\n")
    let l:modified = []
    for l:addf in l:addfs
        if !filereadable(l:addf)
            continue
        endif
        let l:splf = l:addf . '.spl'
        if !filereadable(l:splf) || (getftime(l:addf) > getftime(l:splf))
            execute 'mkspell!' fnameescape(l:addf)
            call add(l:modified, l:addf)
        endif
    endfor
    return l:modified
endfunction

command -bar Mkspell    call UserMkspell()


" for disabling things that indent plugins do. overkill maybe.
" sometimes setting b:did_indent shows up as a solution, but
" indent.vim::s:LoadIndent() (filetype autocmd) resets it before loading
" indentation rules.
function! UserResetIndent()
    " could set to a function returning -1...
    setlocal indentexpr& indentkeys&
endfunction

command! -bar NoIndentFancy     call UserResetIndent()


set spellcapcheck=

" -- end spelling configuration

set sessionoptions-=curdir
set sessionoptions-=globals
set sessionoptions-=options
set sessionoptions-=resize
set sessionoptions-=terminal
set sessionoptions-=winpos
" sesdir - only way to get vim to not save absolute paths to buffers;
" does save/do a "cd"; yucky.
set sessionoptions+=sesdir

set viewoptions-=curdir
set viewoptions-=options


" ---- mappings

" 2022-08-15 disable modifyOtherKeys usage; we haven't needed such mappings
" yet. with this enabled (default), vim swallows Control-3 and turns it into
" a simple 3, for example. the default ctrl-3 -> esc equivalance is nice to
" keep. doc modifyOtherKeys (https://vimhelp.org/map.txt.html#modifyOtherKeys)
"
" https://vt100.net/docs/vt220-rm/chapter3.html#T3-5
"
" also applies to gvim, term == builtin_gui.

" checking with &option-name and not +option-name;
" disabling only for unix, both tty and gui.
if exists('&t_TI') && exists('&t_TE') && has('unix')
    set t_TI= t_TE=
endif

" arrow keys are good, bill joy used arrow keys.
" use zz to recenter all the time
nnoremap        k       gk
nnoremap        j       gj
nmap            <Up>    k
nmap            <Down>  j
xnoremap        k       gk
xnoremap        j       gj
vmap            <Up>    k
vmap            <Down>  j

" 2022-07-16 - recognition, through vimrc.
" https://github.com/hotchpotch/dotfiles-vim/blob/master/.vimrc
" https://secon.dev/entry/20061225/1167032528/
" for working with gettext code using tpope/vim-surround.
" nnoremap        g'      cs'g
" nnoremap        g"      cs"G

" on hitting F1 instead of Esc by accident when sleepy - do something a little
" less intrusive than opening help. <expr> is brittle. <Cmd>'s robust, but
" very new.
"
" the quiet alternative: <Nop>

nnoremap    <silent> <F1>      :call UserShowHelp()<cr>
" insert mode <F1> - don't change mode
inoremap    <silent> <F1>      <C-\><C-o>:call UserShowHelp()<cr>

command -bar B      echo UserBufferInfo()

" mnemonic: show buffer info
nnoremap        <Leader><Leader>   :echo UserBufferInfo()<cr>

" show some info in a new scratch buffer (and not a popup window)
command -bar BB     Scratch | call append(0, UserGetInfoLines())


" for misconfigured virtual serial lines with putty. better to set
" TERM=putty-256color before starting (above mappings work then).

" quickly toggle spellcheck
" used to use F6 to toggle spell, but setl [no]spell is easier to remember.

" show all buffers in windows; was just thinking of fullscreen.
nnoremap        <F11>  :sball<cr>

" lots more modes... doc :noremap and doc xterm-function-keys

" buffer switching
"
" Trying out a mapping to show buffers quickly and unobtrusively.
" https://stackoverflow.com/a/16084326 https://github.com/Raimondi/vim-buffalo
" The <space> after :b allows wildmenu to come into play easily.
"
" NB: can't be a silent mapping.
"
" used to use '+', but turns out it's somewhat useful.
nnoremap    K           :ls!<cr>:b<space>
nnoremap    Q           :bnext<CR>

" alt, the remote protocol:
"
" gvim --servername PQR --remote-expr "execute('ls!')"
"
" on win32, console vim supports the same protocol; under X11 better stick to
" gvim.

" --

" emacs/readline-like mappings for the command line; doc emacs-keys
" don't mess with C-f, the default 'cedit' value.
cnoremap    <C-a>       <Home>
cnoremap    <C-d>       <Del>
cnoremap    <C-e>       <End>

" Switch to alternate file: Ctrl-6
" doc CTRL-^ (https://vimhelp.org/editing.txt.html#CTRL-%5E)

" map backspace to turn hlsearch off; from Damian Conway.
"nnoremap    <BS>   :nohlsearch<cr>
" can also let v:hlsearch = 0; <C-u> to erase line range (count in command
" mode); "\b" is <bs>; all this to get a mapping that supports a count, that
" won't complain about E481; unsure why "\<bs>" doesn't work here - exe normal
" in command mode through mapping?
nnoremap    <silent> <bs>   :<C-u>nohls <bar> exe "normal!" v:count1 . "\b"<cr>

xnoremap    <bs>    x


" 2022-02-14 from defaults.vim - delete to beginning, with undo
inoremap    <C-u>   <C-g>u<C-u>
" same for deleting words; from tpope's vim-sensible
inoremap    <C-w>   <C-g>u<C-w>

"" insert timestamp
"
" :put =<expr> is elegant, but working on the line below is disconcerting.
nnoremap        <silent> <Leader>dt "=UserDateTimeComment()<cr>p:put _<cr>

inoremap <expr> <silent> <Leader>dt "\<C-g>u" . UserDateTimeComment() . "\<C-g>u"

"" ,dt is too complicated when tired/sleepy.
nmap        <Leader>.      <Leader>dt
imap        <Leader>.      <Leader>dt

"" insert date
"" nnoremap        <silent> <Leader>dd :put=UserDate()<cr>
inoremap <expr> <silent> <Leader>dd     UserDate()
" so i can do :e f-<,dd> in the vim command window
cnoremap <expr> <Leader>dd              UserDate()

nnoremap        <silent> <Leader>dT     "=UserDateTime()<cr>p:put _<cr>
inoremap <expr> <silent> <Leader>dT     UserDateTime()

nnoremap        <silent> <leader>dU     "=UserUtcNow()<cr>p:put _<cr>
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

if executable('/usr/bin/par')
    nnoremap        <Leader>j     {!}/usr/bin/par 78<cr>}
endif

" join paragraphs to one line, for sharing.
"
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
"nnoremap        <Leader>1       vip:join<cr>
" alternative, repurposing !{motion} to pass to :join ex command and not an
" external (shell) command. visual mode unnecessary.
" https://vi.stackexchange.com/a/37142
nnoremap        <Leader>1       {!}<bs>join<cr>

" format paragraph without formatprg/formatexpr. k's just close to , .
nnoremap <silent> <Leader>k     gwip
xnoremap <silent> <Leader>k     gw


" -- begin copy/paste adventures.
"
" paste.vim for vim 7.0x:
" https://github.com/vim/vim/blob/0fd9289de3079583cd19c88425277b99b5a15253/runtime/autoload/paste.vim
"
" other:
" https://vim.fandom.com/wiki/Unconditional_linewise_or_characterwise_paste
" https://github.com/inkarkat/vim-UnconditionalPaste
" https://github.com/tpope/vim-unimpaired/blob/master/plugin/unimpaired.vim

" write a string to the clipboard.
"
" works for both gui and tty (@+ or xsel).

function! UserWrCb(txt, destination)
    if a:txt == '' | return | endif

    " default destination - CLIPBOARD
    let l:dest_reg = '+'
    let l:dest_cmd = '/usr/bin/xsel -b -i'
    if a:destination ==# 'PRIMARY'
        let l:dest_reg = '*'
        let l:dest_cmd = '/usr/bin/xsel -p -i'
    endif

    if g:u.has_cb_builtin
        " vim automatically sets regtype v or V (latter if the string ends
        " with a newline)
        call setreg(l:dest_reg, a:txt)
    elseif g:u.has_cb_tty
        silent call system(l:dest_cmd, a:txt)
        if v:shell_error
            echohl Error
            echo 'xsel invocation failed, code' v:shell_error
            echohl None
        endif
    else
        echohl Error
        echo 'do not know how to write to' a:destination
        echohl None
    endif
endfunction


" return a register name, like v:register.
function! UserGetCbReg(src)
    " by default, work with the X CLIPBOARD
    let l:src_reg = '+'
    let l:src_cmd = '/usr/bin/xsel -b -o'
    let l:result = { 'status': -1 }

    if a:src ==# 'PRIMARY'
        let l:src_reg = '*'
        let l:src_cmd = '/usr/bin/xsel -p -o'
    endif

    if g:u.has_cb_builtin
        let l:result = { 'reg': l:src_reg, 'status': 0 }
    elseif g:u.has_cb_tty
        silent let l:clp = system(l:src_cmd)
        if v:shell_error
            echohl Error
            echo 'xsel invocation failed, code' v:shell_error
            echohl None

            let l:result = { 'status': -2 }
        else
            " put into a register + return register name
            let l:dest_reg = 'u'
            call setreg(l:dest_reg, l:clp)
            let l:result = { 'reg': l:dest_reg, 'status': 0 }
        endif
    else
        echohl Error
        echo 'do not know how to read from' a:src
        echohl None

        let l:result = { 'status': -3 }
    endif
    return l:result
endfunction

" used for copying the current command line to the clipboard. requires a
" c_CTRL-\_e mapping - this function gets the current command line, copies it
" to the clipboard, and returns the command line unchanged, so that the C-\ e
" mapping changes nothing.
"
" swallows errors.

function! UserTeeCmdLineCb(destination)
    let l:cmdl = getcmdline()
    " also put in the unnamed register, as a yank would.
    call setreg('', l:cmdl)

    if a:destination ==# 'PRIMARY' || a:destination ==# 'CLIPBOARD'
        try
            call UserWrCb(l:cmdl, a:destination)
        catch
            " ignored - we probably don't want to put any error messages in
            " the command line.
        endtry
    endif

    return l:cmdl
endfunction

" works for both gui and tty since UserGetCbReg() does (@+ or xsel).
"
" test:
"   put a single char on column 1,
"   in normal mode, with cursor on char, pasting a line (end nl)
"   should put the line after the char.
"
" https://www.dr-qubit.org/Evil_cursor_model.html
" https://vi.stackexchange.com/questions/15565/mystery-cursor-motion
" https://vi.stackexchange.com/questions/18137/determine-if-the-cursor-is-on-the-first-last-character-of-word
" https://vi.stackexchange.com/questions/15565/mystery-cursor-motion
" https://stackoverflow.com/questions/19542901/detect-if-the-caret-is-at-the-end-of-a-line-in-insert-mode
" https://github.com/vim/vim/issues/9549 (!?)

" decide on which commands to use for pasting. to be used lated in expr
" mappings or from other functions. helps with insert mode, where:
"
" 2023-05-30 bug related to whitespace inserted by autoindent. after
" autoindent whitespace, <C-\><C-o>g[pP] works well - appends as expected.
" This is what current paste.vim does.  But bouncing through command mode,
" either a function call or :normal! gp, disregards autoindent whitespace and
" pastes after the last non-blank character.

" wretched - with virtualedit=all like in paste.vim, "gp" is no good. -
" virtualedit creates a space and 'gp' puts after that.
"
" if at end of line or beginning of empty line - put text after cursor. test:
" multiple consecutive pastes.
"
" if beginning/middle of line - put text before cursor. feels natural.

function! UserPasteExpr()
    return &ve == 'all' ? 'gP' : col('.') == col('$') - 1 ? 'gp' : 'gP'
endfunction

" a little helper for tty + xsel
function! UserReadCbRetExpr(src)
    let l:reg = UserGetCbReg(a:src)
    if l:reg.status < 0 | return "\<Ignore>" | endif

    " now we'll be using @", not @*/@+. so, no register prefix is needed -
    " but we have it, should use it anyway.
    "
    " the following makes an expression like: ""gP
    return '"' . l:reg.reg . UserPasteExpr()
endfunction


" mappings to copy/paste using the X clipboard from tty vim, without resorting
" to the +X11 vim feature.
" doc :write_c
"
" the deciding factor is what's in 'clipboard', but we use other invariables
" like gui_running or if running under X11.

" -- pasting

" when a piece of text has newlines, <C-r><C-r>= (expression register) use
" in tty vim doesn't break lines, but inserts all keys in one line and
" shows the linebreaks as ^@. but when the text is put into a register and
" <C-r><C-r><reg, no=> is done, the newlines seem interpreted, escaping other
" control codes as <C-r><C-r> should do.

" gui vim any platform, or win32 including console
if g:u.has_cb_builtin

    " use gp/gP directly, with @* / @+ without bouncing through any other
    " register. needs 'clipboard' to be set properly.

    nnoremap    <expr>  <Leader>yp      "\"*" . UserPasteExpr()
    nnoremap    <expr>  <Leader>xp      "\"+" . UserPasteExpr()

    command!    RDPR    put *
    command!    RDCB    put +

    inoremap    <expr>  <Leader>yp      "\<C-\>\<C-o>\"*" . UserPasteExpr()
    inoremap    <expr>  <Leader>xp      "\<C-\>\<C-o>\"+" . UserPasteExpr()

    xmap                <Leader>yp      "-c<Leader>yp<Esc>
    xmap                <Leader>xp      "-c<Leader>xp<Esc>

    " doc: i_CTRL-R_CTRL-R -- literal insert
    cnoremap    <Leader>yp                  <C-r><C-r>*
    cnoremap    <Leader>xp                  <C-r><C-r>+

    " paste in gui mode with <C-[S-]v>.

    " pretty indispensable; unix: sadly the shift seems to depend on
    " modifyOtherKeys even for builtin_gui? test and make sure that C-v keeps
    " working to insert literally and for visual block select - not paste.
    "
    " win32, gvim: seems gvim can't see the shift anyway. the following maps
    " breaks C-v.
    "
    " win32 console: C-S-v seems to be handled outside vim; forces a paste,
    " doing the wrong thing in normal mode.
    "
    " win32 console vim (has('win32')) sees insert but can't map it?
    "
    " win32 gvim seems to map S-Insert by itself.
    "
    " just have to stick with ,xp, get used to C-q (emacs quoted-insert),
    " keeping xon/xoff flow control in mind.

    if has('gui_running')
        nmap    <S-Insert>  <Leader>xp
        xmap    <S-Insert>  <Leader>xp
        imap    <S-Insert>  <Leader>xp
        cmap    <S-Insert>  <Leader>xp
        nmap    <S-kInsert>  <Leader>xp
        xmap    <S-kInsert>  <Leader>xp
        imap    <S-kInsert>  <Leader>xp
        cmap    <S-kInsert>  <Leader>xp
        nmap    <C-S-v>     <Leader>xp
        xmap    <C-S-v>     <Leader>xp
        imap    <C-S-v>     <Leader>xp
        cmap    <C-S-v>     <Leader>xp
    endif
elseif g:u.has_cb_tty

    " ttys and bracketed paste cover this well...
    nnoremap    <expr>  <Leader>yp  UserReadCbRetExpr('PRIMARY')
    nnoremap    <expr>  <Leader>xp  UserReadCbRetExpr('CLIPBOARD')

    command     RDPR    execute 'put' UserGetCbReg('PRIMARY').reg
    command     RDCB    execute 'put' UserGetCbReg('CLIPBOARD').reg

    inoremap    <expr>  <Leader>yp  "\<C-\>\<C-o>" . UserReadCbRetExpr('PRIMARY')
    inoremap    <expr>  <Leader>xp  "\<C-\>\<C-o>" . UserReadCbRetExpr('CLIPBOARD')

    " visual mode, useful for replacing the current visual selection with
    " what's in the clipboard. "-c - cut selection to small delete register
    " and go to insert mode
    "

    xmap                <Leader>yp  "-c<Leader>yp<Esc>
    xmap                <Leader>xp  "-c<Leader>xp<Esc>

    " !! beware clipboard autoselect/guioption a (go-a) and [other copy/visual
    " selection start] order, as vim clipboard grabbing can overwrite the
    " copied data.  1. start visual selection, 2. copy from other app, 3.
    " paste in vim works.

    " dangerous, but tty mappings and <C-r>+ etc. work anyway. defined for
    " completeness and consistency.
    "
    " cannot be a silent mapping.
    "
    " literal insert - doc: c_CTRL-R_CTRL-R
    cnoremap <expr> <Leader>yp "\<C-r>\<C-r>" . UserGetCbReg('PRIMARY').reg
    cnoremap <expr> <Leader>xp "\<C-r>\<C-r>" . UserGetCbReg('SECONDARY').reg
else
    nnoremap    <expr>  <Leader>xp      UserPasteExpr()
    inoremap    <expr>  <Leader>xp      "\<C-\>\<C-o>" . UserPasteExpr()
    xmap                <Leader>xp      "-c<Leader>xp<Esc>
    cnoremap            <Leader>xp      <C-r><C-r>"
endif


" -- copying; separate definitions for tty vs. gui - write to the
" clipboard in whatever way works best.

if g:u.has_cb_builtin
    " normal mode, copy current line - this includes the last newline,
    " makes unnamedplus linewise.
    " nnoremap  <silent>    <Leader>xc      "+yy
    "
    " for details see ,xc mapping for ttys below.
    nnoremap    <silent>    <Leader>yc      m`^vg_"*y``
    nnoremap    <silent>    <Leader>xc      m`^vg_"+y``

    command! -range WRPR    <line1>,<line2>y *
    command! -range WRCB    <line1>,<line2>y +

    " visual mode, copy selection, not linewise; doc: v_zy
    " zy and zp are rather new, not in iVim yet.
    xnoremap    <silent>    <Leader>yc      "*y
    xnoremap    <silent>    <Leader>xc      "+y

    cnoremap    <Leader>yc  <C-\>eUserTeeCmdLineCb('PRIMARY')<cr>
    cnoremap    <Leader>xc  <C-\>eUserTeeCmdLineCb('CLIPBOARD')<cr>

    if has('gui_running')
        nmap    <C-Insert>  <Leader>xc
        xmap    <C-Insert>  <Leader>xc
        cmap    <C-Insert>  <Leader>xc
        nmap    <C-kInsert>  <Leader>xc
        xmap    <C-kInsert>  <Leader>xc
        cmap    <C-kInsert>  <Leader>xc
        nmap    <C-S-c>     <Leader>xc
        xmap    <C-S-c>     <Leader>xc
        " no C-c / C-S-c for the command line
    endif
elseif g:u.has_cb_tty

    " trim-select with visual mode:
    "   m` - set previous context mark,
    "   ^ - go to first non-blank char,
    "   v - visual,
    "   g_ - go to last non-blank char,
    "   y - yank
    "       this moves the cursor.
    "       https://github.com/vim/vim/blob/master/runtime/doc/change.txt
    "       /Note that after a characterwise yank command
    "   `` - jump back
    "   and pass the unnamed register contents to the X11 selection.
    nnoremap    <silent>    <Leader>yc  m`^vg_y``:call UserWrCb(@", 'PRIMARY')<cr>
    nnoremap    <silent>    <Leader>xc  m`^vg_y``:call UserWrCb(@", 'CLIPBOARD')<cr>

    " define an ex command that takes a range and pipes to xsel
    " doc :write_c
    "R use: :.,+10WRCB
    command -range WRPR     silent <line1>,<line2>:w !/usr/bin/xsel/xsel -p -i
    command -range WRCB     silent <line1>,<line2>:w !/usr/bin/xsel/xsel -b -i

    " for the visual selection (not necessarily linewise).
    " yank, then [in normal mode] pass the anonymous register
    " to the X11 selection.
    xnoremap    <silent>    <Leader>yc  m`y``:call UserWrCb(@", 'PRIMARY')<cr>
    xnoremap    <silent>    <Leader>xc  m`y``:call UserWrCb(@", 'CLIPBOARD')<cr>

    " copy the current command line.
    " doc: getcmdline()
    cnoremap                <Leader>yc  <C-\>eUserTeeCmdLineCb('PRIMARY')<cr>
    cnoremap                <Leader>xc  <C-\>eUserTeeCmdLineCb('CLIPBOARD')<cr>
else
    nnoremap                <Leader>xc  m`^vg_y``
    xnoremap                <Leader>xc  m`y``
    cnoremap                <Leader>xc  <C-\>eUserTeeCmdLineCb('SELF')<cr>
endif


" visually select the last modified (including pasted) text
"nnoremap    <Leader>lp      `[v`]

" url paste adapter - if pasting a url, often it's convenient to treat
" it in line mode - repeated pastes etc. but urls copied from browsers
" or mobile apps don't end with a newline, and the type of "+/"* remains
" c(haracterwise). this function can sometimes help with that.
"
" safe for C-o insert mode, but no need for that.
"
" maybe: redo as a filter called inside UserGetCbReg().

function! UserUrlPasteMunge()
    " this chunk of code considers very little, ought to work no matter where
    " in a line the tweet url is, when there are multiple urls (including
    " duplicates).

    " save 'clipboard' and 'virtualedit' to restore later.
    let l:cb = ''
    if has('clipboard')
        let l:cb = &clipboard
        set clipboard=
    endif
    let l:ve = &virtualedit

    " virtualedit required to make use exclusive motions (F) and later to
    " not fall down into an undecidable hell of col('.') vs. col('$').
    set virtualedit=onemore

    let l:copy_back = 0
    let l:urlpos = searchpos('\vhttps?://\S+', 'bn', line('.'))
    lockvar l:urlpos
    if l:urlpos[0] == line('.')

        " if pasted in normal mode, the cursor stays beyond url - after eol or
        " any text that was already present.
        "
        " but if pasted in insert mode and vim went to normal, the cursor
        " moves to the last char of the url.
        "
        " so we move the the end of the last changed text - if we didn't do
        " that, the normal! l below would be one l too much - and a char that
        " may have been there from before would get deleted by the backwards
        " delete that can happen later.

        if getpos("']")[1] == line(".")
            normal! `]
        endif
        normal! l

        " if the url's for a tweet, erase the query parameters.
        if search('\v//%(x|twitter)\.com/\w+/status/\d+\?', 'bn', line('.')) == line('.')
            " to the black hole register, delete backwards until (including) ?
            " but excluding what the cursor was on.
            normal! "_dF?
            let l:copy_back = 1
        endif


        " breaking a line is hard in normal mode. there might be something
        " after us. delete, put on next line.
        "
        " 2023-05-28 even with ve=onemore and cursor past eol, d$ will delete
        " the last char of the line, a char that was not under the cursor.
        " with ve=all that doesn't happen.
        "
        " 2023-05-28 back to column conditional delete and ve=onemore. with
        " ve=all, some text already on the line, cursor past eol - d$ should
        " delete nothing, but still successfully deletes a single space into
        " @-/@". in contrast to ve=onemore, where d$ does delete the last real
        " character. behaviour going back to vim7.. seems like a bug, can't
        " find a doc reference. caught with listchars+trail.

        if col('.') >= col('$')
            put _
        else
            normal! d$
            put
        endif

        " if we modified the url, and url is at the beginning of the line,
        " copy back. copying just the url when some other text precedes it...
        " going against the grain of line orientation and cursor movement is
        " hard.
        if l:copy_back
            " go to line above,
            " normal with mappings:
            " 0 - go to first column
            " count-| to go right to the first char of the url (doc: bar)
            " v - start visual mode
            " $ - to the end of the line
            " ,xc - copy [using <Leader> is cumbersome]
            " j - go back down
            " 0 - beginning of line
            execute "normal" "-0" . l:urlpos[1] . "|v$,xcj0"
        endif
    endif

    let &virtualedit = l:ve
    if has('clipboard')
        let &clipboard = l:cb
    endif
endfunction


" -- end copy/paste adventures.

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
    \ ,'em dash':       nr2char(0x2014)
    \ ,'en dash':       nr2char(0x2013)
    \ ,'dagger':        nr2char(0x2020)
    \ ,'greek cross, heavy': nr2char(0x271A)
    \ ,'brkt left corner': nr2char(0xFF62)
    \ ,'brkt right corner': nr2char(0xFF63)
    \ ,'silcrow':       nr2char(0xA7)
    \ ,'bourbaki bend': nr2char(0x2621)
    \ }
lockvar Symbols

inoremap <expr> <Leader>ip      Symbols['interpunct']
inoremap <expr> <Leader>lz      Symbols['lozenge']
inoremap <expr> <Leader>dg      Symbols['dagger']
inoremap <expr> <Leader>sc      Symbols['silcrow']
" 2022-08-26
inoremap <expr> <Leader>mm      Symbols['em dash']
inoremap <expr> <Leader>nn      Symbols['en dash']

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
execute "inoremap \u00A0 <Space>"

" use 's' for window commands instead of the default emacsness.
nnoremap    s   <C-w>
" for keys like C-wf (doc CTRL-W_f), there's no option to make the split
" vertical by default. We make do with this:
nnoremap    <Leader>vf  <C-w>f<C-w>L

" WIP mapping to open files; meant to work under just two windows:
" one window with a list of filenames.
nnoremap    <Leader>se  :let f = expand('<cfile>')<cr><C-w>w:execute('edit ' . f)<cr>

" M.G. - guu/gugu - lower line, u - visual, gu{motion}
nnoremap    <Leader>mg      guip

" mainly for iVim. the changing of the modified flag in the statusline is
" indication enough.
nnoremap    <silent> <Leader>;;      :silent update<cr>

" open the command window with ,f in the command line
cnoremap    <expr>  <Leader>f    &cedit
nnoremap            <Leader>f   q:

" doc CTRL-G
" alt: let l = execute("normal! 3\<C-g>")
" to get more info from <C-g> 'ruler' needs to be turned off, let's just use
" our own function instead.
nnoremap    <C-g>   :echo UserLoc()<cr>

noremap    H   ^
noremap    L   $

" disable mappings that enter select mode; doc: Select-mode-mapping
nnoremap    gh      <nop>
nnoremap    gH      <nop>
nnoremap    g<C-h>  <nop>
xnoremap    <C-g>   <nop>


" 2022-07-22 haven't used macros/recording for over 20 years, not about to
" start now. i prefer ex/ed commands. the default keeps getting in the way.
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
" nnoremap    q   :echo 'Temper temper / mon capitaine.'<cr>
nmap    <silent> q <Leader>xp:call UserUrlPasteMunge()<cr>:silent update<cr>
" -- end q-mappings adventure.

" never used the tagstack. sometimes due to window focus i end up hitting
" new-tab C-t in vim. we could conditionally enable it for help buffers and
" anything else with tags by checking taglist('.') BufReadPost. Maybe later.

if g:u.term_primitive
    nnoremap    <C-t>           <nop>
    nnoremap    <C-LeftMouse>   <nop>
else
    " on-site cat: https://jijitanblog.com/construction/genbaneko-matome/
    nnoremap    <C-t>           :echo 'ヨシ！'<cr>
    nnoremap    <C-LeftMouse>   :echo 'ヨシ！'<cr>
endif
imap            <C-t>           <Esc><C-t>
imap            <C-LeftMouse>   <Esc><C-LeftMouse>

" three-state switch for 'number' and 'relativenumber'.
" 0 0, 1 0, 1 1, 0 0

function! UserLineNumberSwitch()
    let l:nu = &number
    let l:rnu = &relativenumber

    let l:rnu = !l:rnu && l:nu
    let l:nu = !( l:nu && !l:rnu )

    " echo 'nu=' l:nu 'rnu=' l:rnu
    " set both options in one go
    let l:opt_nu = l:nu ? 'number' : 'nonumber'
    let l:opt_rnu = l:rnu ? 'relativenumber' : 'norelativenumber'
    execute 'setlocal' l:opt_nu l:opt_rnu
endfunction

nnoremap    <silent> <Leader>n   :call UserLineNumberSwitch()<cr>

" nosleep
nnoremap    gs      <nop>

" demo - for searching with strings with f.ex. many forward slashes;
" use :g with a non-/ delimiter, and : (null ex command).
nnoremap    <Leader>/   :global ==:<Left><Left>

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
function! UserSymComparator(l1, l2)
    return a:l1[1] == a:l2[1] ? 0 : a:l1[1] > a:l2[1] ? 1 : -1
endfunction

function! UserSymComplFn(findstart, base) abort
    if a:findstart == 1
        " completion starts at cursor column
        return -100
    elseif a:findstart == 0
        let l:compl = []
        " sort by unicode value (not hash key) of symbol, ascending
        let l:sorted_pairs = sort(items(g:Symbols), 'UserSymComparator')
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

" tab settings
" https://ericasadun.com/2016/03/31/swift-style-are-you-a-4-denter/
" Unix (drank the 80's soda)
command -bar Proper  setlocal softtabstop=8 shiftwidth=8 noexpandtab
" for Python and common scripting languages
command -bar Lousy   setlocal softtabstop=4 shiftwidth=4 expandtab
" for lisps
command -bar Lisp    setlocal softtabstop=2 shiftwidth=2 expandtab
" shift by 4 spaces, with hard tabs
command -bar T4x4    setlocal softtabstop=4 shiftwidth=4 noexpandtab

" rtfm'ed - :retab! uses % as the range by default.

" for prose
" doc fo-table
command -bar Nowr    setlocal fo=tq nospell ai nosi nocin | Proper
" auto-format, without depending on trailing spaces (fo-w)
" the 2 (indent of the 2nd line) requires auto-indent.
command -bar FoText  setl ai nosi nocin fo=atq2
command -bar FoCode  setl ai nosi cin   fo=cjoqr

" NB: autoindent affects fo-at
" spelling: probably better to switch to native aspell and dict-gcide
"   (GNU Collaborative International Dictionary of English)

function! UserWr()
    if &textwidth == 0
        setlocal textwidth=80
    endif
    setlocal spell
    FoText
    " 4-denting + hard tabs
    T4x4
endfunction

command -bar Wr      call UserWr()

" for small screens (iVim) - iPhone 13 Pro, Menlo:h11.0
command -bar Mobile  Wr | setl tw=60 nonu nornu

" for transcribing poetry -
" significant whitespace, auto-indenting, no hard tabs, no auto formatting
" remember - delete to beginning of line: 0d (V), Ctrl-U (I);
"   Ctrl-U is readline unix-line-discard.
" set colorcolumn=16,32,48,64,80,96 might also help.
command -bar Poetry  setlocal tw=0 formatoptions-=ta ai nospell | Lousy


command -bar ShowBreak       let &showbreak = g:u.showbreak_char
" vim 8.0 don't support NONE (showbreak gets set to "NONE")
command -bar NoShowBreak     set showbreak=


" helper for when a 'syntax off' -> 'syntax enable' wipes out our rules. and,
" we want our syntax rules enabled even in empty buffers or plain text files,
" where the Syntax autocommand won't fire.
command -bar Syn            syntax enable | call UserApplySyntaxRules()
command -bar SynSync        syntax sync fromstart
" remember: https://vimhelp.org/usr_44.txt.html#44.10
"   :syntax sync minlines=100
" also remember: doautocmd Syntax


" mnemonic to open all folds in buffer
command -bar Unfold         normal! zR

command -nargs=1 Ch         set cmdheight=<args>

" query or set textwidth; if value given, set. always show.
command -bar -nargs=?   Tw  if len(<q-args>) != 0
    \ |     setlocal textwidth=<args>
    \ | endif
    \ | setlocal textwidth?


" kludge for 256 colour dark terminals
" and for when 'background' changes some time after initialization.
command -bar Dark       set background=dark
            \ | if !exists('g:colors_name') | call UserColours() | endif
command -bar Light      set background=light
            \ | if !exists('g:colors_name') | call UserColours() | endif

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
command TermSlow    call UserTermSlow()

command -bar Stws        call UserStripTrailingWhitespace()

" new window for scribbling
" possible alternative - preview windows (:pedit); seems more limited.
" doc scratch-buffer
command -bar Scratch new | setlocal buftype=nofile noswapfile | setfiletype text

" pretty-print g:u
command -bar PrintU Scratch | put =json_encode(g:u) | .! jq --sort-keys .

" like :Explore
command Index       call UserOpenIndexFile()

command -bar Nolist         windo setlocal nolist
command -bar ListDef        let g:u.lcs.cur = g:u.lcs.def
    \ | let &lcs = UserListchars(g:u.lcs.cur)
command -bar ListP          let g:u.lcs.cur = g:u.lcs.p
    \ | let &lcs = UserListchars(g:u.lcs.cur)
command -bar ListAscii      let g:u.lcs.cur = g:u.lcs.ascii
    \ | let &lcs = UserListchars(g:u.lcs.cur)

" runtime changes to listchars via an anonymous dictionary.
" this can make trailing hard tabs invisible unless the SpecialKey highlight
" accounts for that.
command -bar ListShowTab    let &lcs = UserListchars('tab:' . g:u.lcs.cur.tab)
command -bar ListHideTab    let &lcs = UserListchars('tab:NONE')
command -bar ListShowTrail  let &lcs = UserListchars('trail:' . g:u.lcs.cur.trail)
command -bar ListHideTrail  let &lcs = UserListchars('trail:NONE')
command -bar ListShowEol    let &lcs = UserListchars('eol:' . g:u.lcs.cur.eol)
command -bar ListHideEol    let &lcs = UserListchars('eol:NONE')
command -bar ListShowConceal let &lcs = UserListchars('conceal:' . g:u.lcs.cur.conceal)
command -bar ListHideConceal let &lcs = UserListchars('conceal:NONE')

" search for the nbsps that 'list' also uses
" but vim isn't great for this; use perl5:
"       perl -Mopen=locale -pe 's/[\N{U+202F}\N{U+00A0}]/[X]/g'
"
" with perl and ripgrep (no need for pcre), \p{Zs} works.
"
" to exclude ordinary space, use double negation: [^\P{Zs} ]
"   inverted Zs + ordinary space, inverted.
"
" \p{Zs} == \p{Space_Separator}
"
"   https://perldoc.perl.org/perlunicode#General_Category
"   https://perldoc.perl.org/perluniprops#Properties-accessible-through-%5Cp%7B%7D-and-%5CP%7B%7D
"
" \s matches horizontal tab, but \p{Zs} won't.
" https://perldoc.perl.org/perlrecharclass#Whitespace
" /a complete listing of characters matched by \s, \h and \v as of Unicode 14.0./
"
"
" pattern in double quotes instead of single quotes, for windows cmd.
" requires a capable grep like ripgrep.
command Grepws         :grep "[^\P{Zs} ]" %

" make a regular expression to match unicode whitespace in pure vim: __UNIWS__
"   LRM/RLM aren't strictly whitespace.
"
" https://vi.stackexchange.com/a/33312
" https://en.wikipedia.org/wiki/Whitespace_character#Unicode
" test: https://jkorpela.fi/chars/spaces.html
" https://github.com/sg16-unicode/sg16/issues/74
" https://util.unicode.org/UnicodeJsps/list-unicodeset.jsp?a=%5B%3APattern_White_Space%3A%5D&g=&i=

function! UserGetUnicodeWhitespaceRegexp()
    " code points
    let l:nbsp                      =   0xA0
    let l:next_line                 =   0x85
    let l:ogham_space_mark          = 0x1680
    let l:mongolian_vowel_separator = 0x180E
    let l:en_quad                   = 0x2000
    let l:em_quad                   = 0x2001
    let l:en_space                  = 0x2002
    let l:em_space                  = 0x2003
    let l:three_per_em_space        = 0x2004
    let l:four_per_em_space         = 0x2005
    let l:six_per_em_space          = 0x2006
    let l:figure_space              = 0x2007
    let l:punctuation_space         = 0x2008
    let l:thin_space                = 0x2009
    let l:hair_space                = 0x200A
    let l:zero_width_space          = 0x200B
    let l:left_to_right_mark        = 0x200E
    let l:right_to_left_mark        = 0x200F
    let l:line_separator            = 0x2028
    let l:paragraph_separator       = 0x2029
    let l:narrow_nbsp               = 0x202F
    let l:medium_mathematical_space = 0x205F
    let l:ideographic_space         = 0x3000
    let l:zero_width_nbsp           = 0xFEFF

    " don't need to match all of the above. ideographic space is fine.
    " 2023-04-27 vim seems to show zero-width space (0x200b), zero-width nbsp
    " (0xfeff), LRM (0x200e) and RLM (0x200f) as angle-bracket-surrounded code
    " point values. matchadd() doesn't override that. but hlsearch highlights
    " these.

    let l:m = [
                \ l:nbsp,
                \ l:next_line,
                \ l:ogham_space_mark,
                \ l:mongolian_vowel_separator,
                \ l:en_quad,
                \ l:em_quad,
                \ l:en_space,
                \ l:em_space,
                \ l:three_per_em_space,
                \ l:four_per_em_space,
                \ l:six_per_em_space,
                \ l:figure_space,
                \ l:punctuation_space,
                \ l:thin_space,
                \ l:hair_space,
                \ l:zero_width_space,
                \ l:left_to_right_mark,
                \ l:right_to_left_mark,
                \ l:line_separator,
                \ l:paragraph_separator,
                \ l:narrow_nbsp,
                \ l:medium_mathematical_space,
                \
                \ l:zero_width_nbsp
                \ ]

    let l:match_parts = []
    " expression should not require magic.
    for l:sp in l:m
        call add(l:match_parts, printf('\%%u%04x', l:sp))
    endfor
    let l:regexp = join(l:match_parts, '\|')
    return l:regexp
endfunction!

" set last search pattern, go to next match; for some reason feels more
" natural to have this as a command rather than a mapping.
" moving from :-command mode to /-command mode...
" can't catch the no-match case...
command! Findws let @/ = UserGetUnicodeWhitespaceRegexp() | call feedkeys('n', 'n')

" replace unicode whitespace with an ordinary space; __UNIWS__
" then retab
function! UserFixUnicodeWhitespace() range
    let l:regexp = UserGetUnicodeWhitespaceRegexp()
    let l:cmd = a:firstline.','.a:lastline.'s/'.l:regexp.'/ /g'
    try
        execute l:cmd
    catch /^Vim\%((\a\+)\)\=:E486:/
        " the default error message when the pattern finds no matches is
        " unsightly and can take up multiple lines because it echoes the
        " long regexp.
        echom 'No weird whitespace found.'
        return
    endtry

    " redo indents to respect the buffer's tab settings
    execute a:firstline.','.a:lastline.'retab!'
endfunction

command -bar -range=% Fixws     <line1>,<line2>call UserFixUnicodeWhitespace()


" WIP/demo; pipe the buffer into some shell command seq, get output into qf.
" use as: :Ce grep f        [no quoting in the command line]
command -nargs=+ CexprSystem     :cexpr system(<q-args>, bufnr('%'))


" use file(1) to determine if fn is a text file
function! UserDetectTextFile(fn)
    if !has('unix') | return -1 | endif
    if !executable('/usr/bin/file') | return -1 | endif
    let l:fnesc = shellescape(a:fn, 1)
    "echom 'passing to file:' l:fnesc
    silent let l:out = system('/usr/bin/file -b --mime ' . l:fnesc)
    if v:shell_error
        echohl Error
        echo 'file(1) failed, status ' . v:shell_error
        echohl None
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


" persistent undo doesn't feel good sometimes.
" doc clear-undo
function! UserClearUndo() abort
    let l:old_undolevels = &undolevels
    set undolevels=-1
    execute "normal a \<bs>\<esc>"
    let &undolevels = l:old_undolevels
endfunction

command -bar ClearUndo  call UserClearUndo()

" for lines that don't start with [whitespace]#, prepend a #
" and clear the last search pattern (set by :s), turning hlsearch off.
command -range CommentOnce  <line1>,<line2>g/^\s*[^#]/s/^/# / | let @/ = ''
" put # just before the first non-whitespace char
" command -range CommentOnce  <line1>,<line2>g!/^\s*#/s/\v^(\s*)([^\s])/\1# \2/


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
    autocmd FileType        c,conf,bash,go,sh,zsh   Proper
    "autocmd FileType        c,bash,go,sh,zsh        ListHideTab
    " 2023-04-17 became a 4-denter
    autocmd FileType        text                    T4x4
        \ | setlocal linebreak nonumber
    autocmd FileType        perl,python,vim         Lousy
    autocmd FileType        ruby,eruby              Lousy
    autocmd FileType        javascript,json         Lousy
    autocmd FileType        jproperties             Lousy
        \ | setlocal fileencoding=latin1
    autocmd FileType        markdown                Lousy
    autocmd FileType        java,xml                Lousy
    autocmd FileType        lisp,scheme,racket,clojure  Lisp
    " with whimsical fileformats, don't be rational
    autocmd FileType        yaml                    let b:user_noautomod = 1
    autocmd FileType        markdown                let b:user_noautomod = 1
    " indent reset, when default rules conflict with external constraints
    autocmd FileType        xml     call UserResetIndent()

    " the first line of the commit message should be < 50 chars
    " to allow for git log --oneline
    " FileType *commit / BufNewFile,BufReadPost COMMIT_EDITMSG
    autocmd FileType *commit    setlocal spell tw=78 cc=50,78

    autocmd BufWritePre *   call UserStripTrailingWhitespace()
    autocmd BufWritePre *   call UserUpdateBackupOptions(expand('<amatch>'))

    " no persistent undo info for temporary files
    autocmd BufWritePre /tmp*,~/tmp/*   setlocal noundofile

    " when editing the ex command line, enable listchars and numbers.
    " the idea is to not paste right into the command line, but do paste from
    " the clipboard into the command window - and inspect before running.
    "
    " listchars is set to something that includes eol (g:u.lcs.def), which
    " is useful in the command window.
    "
    " doc cmdwin-char
    "
    " 2023-05-20 local list/listchars seems surprising in iVim. but number/
    " relativenumber is enough.
    autocmd CmdWinEnter :   setlocal number norelativenumber

    " for iVim on iOS; by default, swap seems to be automatically disabled
    " for files loaded from iCloud Drive. we keep swap files at home (appdir),
    " there will not be an attempt to create swap files on iCloud Drive.
    "
    " autocmd-pattern - * includes path separators.
    autocmd BufReadPost /private/var/mobile/*       setlocal swapfile

    " if swapfile exists, always open read-only
    "autocmd SwapExists *    let v:swapchoice = 'o'

    "autocmd TermResponse * echom 'termresponse:' strtrans(v:termresponse)

    if has('cmdline_hist')
        " forget :q!/:qall! ; clearing must run after viminfo's loaded.
        autocmd VimEnter * call histdel(':', '\v^w?q')
    endif

    " test: fires under:
    "
    " xterm -tn xterm-256color -fg white -bg black (no COLORFGBG)
    "
    " xterm -tn xterm-direct -fg white -bg black (no COLORFGBG, truecolor)
    "
    " dark VTE terminal (sakura) with both COLORFGBG and COLORTERM

    if exists('##OptionSet')
        autocmd OptionSet background
                    \ echom UserDateTime() 'background set to' v:option_new
    endif

    " bg heuristic: i don't use screen(1) when not under duress; if in screen
    " and there's been no response (yet) for the terminal background colour
    " request, assume dark.

    autocmd VimEnter *
                    \ if &background ==# 'light' && &term =~# 'screen' &&
                    \ (!exists('v:termrbgresp') || len(v:termrbgresp) == 0)
                    \ | set background=dark
                    \ | endif
augroup end

" autogroup for my weird syntax dealings
augroup UserVimRcSyntax
    autocmd!

    autocmd BufWinEnter *       call UserApplySyntaxRules()

    " 2022-07-26 spooky action seems like this didn't work (for filetype
    " change from none to 'text') forever and suddenly started working today.
    "
    " possible match for just empty: {} https://vi.stackexchange.com/a/22961

    autocmd Syntax      *       call UserApplySyntaxRules()

    " on colourscheme load/change, apply our colours, overriding the scheme.
    autocmd ColorScheme *       call UserColours()
augroup end


if 0
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

" some key gui things:

" disable cursor blinking.
" someone's really gone on a wild ride with the guicursor possibilities.
set guicursor=a:block-blinkon0

" load things in order
call UserRemoveVendorAugroups()
call UserSetCellWidths()
call UserSetupFillchars()
call UserSetupListchars()
call UserSetGuiFont()
call UserInitColourOverride()
call UserColoursPrelude()
call UserLoadColors()
call s:setupClipboard()

" ~ fini ~
