" Last-Modified: 2026-01-23T21:34:42.553634264+00:00

" vim:set tw=80 noml:
set secure nobomb
scriptencoding utf-8

if &compatible
    set nocompatible
endif

if has('nvim')
    if has('win32')
        set runtimepath+=~/vimfiles
    else
        set runtimepath+=~/.vim
    endif
endif

" Change log:
"
" 2026-01-23 Spiff up statusline for terminals. showmode hasn't kept up.
" no neovim config, terminal's weird there.
"
" 2026-01-22 cool revamp of swap handling. hasta la vista.
"
" make Capture run in the current buffer before putting the output in a scratch
" buffer.
"
" 2025-11-04 centralise indent config a little more; but revert to keeping
" syntax highlighting. it can help a bit specially with *sh. make it easier to
" turn indentation and syntax highlighting off with one command (Sigh/Nope).
"
" bad (inconsistent, imperfect) cases like python and sh.
"
" 2025-07-16 Bypass undodir/undofile and manage undo file location by ourselves
" with autocmds + :rundo/:wundo.
"
" 2025-05-22 Better wildmenu for buffer switching.
"
" 2025-04-08 Try to optimize syntax rule setting, re-introduce flag
" b:user_syntax to save double work on Syntax vs. BufWinEnter.
"
" 2025-04-07 Back to iceberg; now it's safe to keep syntax highlighting enabled
" by default again.
"
" 2025-04-01 Wrap :runtime and :colorscheme so that the sourced code can't
" modify the current buffer. courtesy of having a stray unquoted i in
" a colorscheme that loaded the colorscheme code into each file vim wanted to
" edit.
"
" 2025-03-02 Only load syntax rules for some filetypes, similar to indentation.
"
" 2024-11-14 Multiple changes
"
"   Cleanup commenting and uncommenting; no space after prefix, use comment pack
"   when available.
"
"   Centralise swap files again, now matches undo files.
"
"   shortmess - restore 'S' (don't show search count)
"
"   viminfo - don't save registers
"
"   Pasting - cleanup register usage, clear register if clipboard is empty or or
"   clipboard reading command errors out.
"
"   Cleanup yank mappings
"
"   normal mode mappints for w/W to use head of word characters, clear search
"   history.
"
"   cleanup echomsg / warn usage and len() 0 / empty() usage.
"
"   tmp files and persistent undo - lean on backupskip patterns.
"

" 2024-09-30 Paste/copy fixes and adjustments - ,p without a gui clipboard - use
" a separate register, don't fallback to unnamed.
"
" 2024-07-12 set nocompatible so that vim -u 0.vim will work.
"
" 2024-04-16 Encountered viwo<Esc>
"   https://www.reddit.com/r/vim/comments/1xzfjy/go_to_start_of_current_word_if_not_already_there/cfg11mr/
"
" 2024-03-05 Copy/paste changes.
"
"   Change how the paste mappings work - now ,x just copies from the clipboard
"   and return the register prefix, leaving me to complete the command with
"   p/P/gp/gP/zP etc.
"
"   No more mappings for pasting in visual mode. Never needed them.
"
"   Change the clipboard copy mapping from ,xc/,xy to ,y (yank) to not interfere
"   with the ,x-as-paste-prefix mappings.
"
"   Make the copy bounce register setting preserve the linewise / charwise /
"   blockwise setting.
"
"   No more mappings for PRIMARY; never needed/used them. WRPR/RDPR commands are
"   still here for use when needed.
"
" Include v:register and line:column in default statusline.
"
" 2023-11-29 Keep some minimal settings in .vimrc, move everything else to 0.vim
" - to not confuse tiny vim builds. TODO - set those options only once?
"
" 2023-10-19 Restore lost functionality - colours for t_Co < 256. statusline
" futzing again - mixing NC colour's bad for small windows.
"
" 2023-10-09 check and cleanup unwanted autoformat behaviour - unset 'comments'
" and 'commentstring' for plain text. Pass textwidth through to par.
"
" 2023-10-04 Back into the fold of laststatus=2, including orthodox
" StatusLine{/NC} usage - due to change messages that can't be turned off.
" Disable the mode message ('showmode'). Move StatusLine and SpellBad highlights
" back in here.
"
" 2023-09-20 Set 'language' early. Turn off 'filetype indent', setup autocmds to
" load indent rules for a few filetypes. Finally English menus.
"
" 2023-09-18 SoftIndent; no more hard tabs for text.
"
" 2023-08-31 Trying out better ways to list and navigate buffers
"
" 2023-08-19 When pasting from the clipboard, always detour through another
" register in characterwise mode. Never pasting in linewise mode, even in gvim.
"
" 2023-08-11 Change <bs> nohlsearch mapping to support a count for <bs>
"
" 2023-08-05 RIP Bram
"
" 2023-07-11 Change custome highlight and syntax definition to check for
" their existence in a more robust way. Change 'completeopt' to tell auto
" completion to not insert anything by default. Windows language settings -
" do less. colorscheme overriding - reinstate SpellCap/SpellLocal/SpellRare
" destagmatization.
"
" 2023-07-01 Color schemes and term backgrounds. Move from Lucius to Iceberg.
"
" 2023-06-29 Better SpecialKey visibility, mappings/function to add local time,
" better URL copy back, listchars/fillchars cleanup.
"
" 2023-06-05 More copy/paste cleanup. Dynamic statusline removed. Added commands
" and mappings (,yp, ,yc) to read from and write to the X11 PRIMARY selection.
" To accomodate terminals like roxterm and sakura that make it a little
" cumbersome to use the CLIPBOARD. map normal 'u' to nothing - undo doesn't need
" to be so easily accessible.
"
" 2023-06-03 Set clipboard=
"
" 2023-05-31 Better paste mappings using <expr> and a function that only decides
" the normal-mode command to use, instead of direct buffer manipulation.
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
" statusline: static by default, use the status line function only when needed,
" with the SL/StatusLevel user command.
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
" FileType indent rules reenabled, disabled only for some filetypes like xml.
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
" 2023-01-14 disable list; take another look at undodir and dir. redo ,n mapping
" for switching between line number display formats.
"
" 2022-09-27 (rip)grep cleanup, unicode whitespace notes.
"
" 2022-09-13 listchars/SpecialKey tinkering. Introspection commands (My*) - use
" :g//d _ - delete to black hole register.
"
" 2022-08-31 fixes to clipboard handling mappings.
"
" 2022-08-30 normal mode paste - support both put before and put after. Function
" + command for running :mkspell! conveniently.
"
" 2022-08-26 filetype removed from statusline, added to on-demand buffer info.
" refactor statusline function.
"
" 2022-08-17 indicate on statusline if no swapfile, ref. iVim and iCloud Drive.
" command (StatusLevel) to easily control how much info the status line shows.
"
" 2022-08-16 bring back window size in the statusline.
"
" 2022-08-15 disable use of xterm modifyOtherKeys. clean up feature checks and
" has-patch. (Again) keep swap and undo files in a central directory under
" ~/.vim.
"
" 2022-08-03 color and listchars changes to deal with non-home systems
"
" 2022-07-29 Usable with vim 7.x now (uses classic forms of bufnr(), bufname(),
" system(), globpath() etc.), but quite a bit of extras won't work or will print
" error messages. Added more checks for nanosecond routines.
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
" 2022-07-13 went away from trying to extend syntax matching with our own rules
" and struggling to have our rules applied in all desired circumstances. Using
" matchadd() now, in UserMatchAdd().  Lots of syntax-related functions and
" comments still left lying around.
"
" On startup, create ~/.vim/syntax/after/text.vim if necessary, to have our
" syntax rules applied in a robust and consistent manner.
"
" Normal mode mapping to paste easily in iVim.
"
" 2022-06-28: Hashtag prefix sequence changed from a single Greek Cross (🞣,
" U+1F7A3) to "-#". The Greek Cross isn't visible and causes rendering issues in
" iVim (iOS.)

" Long, somewhat disorganized, too large a file, my bonsai project. Includes
" an unnamed colorscheme. Lots of barnacles from documentation spelunking and
" trying various options. Tired now, don't want to touch it for the next 10
" years, when it'll be safe to move to vim9script.

" begin notes:

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

" doc :w_c - write to command -- [range]w !<cmd>, no filtering (command output
" not put back into buffer).
"
" filtering ( :[range]!<filter-pipeline> ) - doc :range!
"
" writing a buffer modifies '[ and '] to the range. lockmarks preserves these
" since patch-8.1.2302. lockmarks still doesn't with :wall. bufdo lockmarks
" update?

"
" -- begin tips:

" :sball - show all buffers; inverse: :only / C-w o
"   <F11>

" @% - current filename; @/ - last search pattern;

" :0file - remove name from buffer

" strtrans() (dep 'display'); 0, 10, ^@, ^J, <Nul>, <NL>, doc :key-notation
"   https://unix.stackexchange.com/a/247331

" 8g8   g8  g;  g,  gd, ga/:ascii, viwo<Esc>, "_yiw

" put line in command line :<C-r><C-l>, WORD: :<C-r><C-a>

" list all augroups - :augroup<cr>

" insert a null ("^@"): <C-v>10 ; doc: i_CTRL-V_digit. f.ex. [i] a<C-v>10z.

" from visual mode go to insert mode: I

" debug log: vim -V16vdbg; block buffered; use echom to add markers.
"   verbosity level 10: autocommands; 12: function calls.
"   verbosity can interfere/leak in various places; when redirecting
"   message output, the command window after system() output in gvim.
"

" string to list of chars: split(str, '\zs') : "abc" -> ['a', 'b', 'c']

" weird little thing: copy modeless-selection: c_CTRL-Y

" :file! doesn't truncate long filenames.

" \V - very nomagic.

" vim user command definitions have extra arguments for bracketed attributes
" like <bang> so than an extra viml string concatenation is unnecessary.

" beware loading files (through for example restoring a session in VimEnter) via
" autocmds: by default nested autocmds are suppressed/autocmds are not triggered
" recursively - so BufNew/BufRead etc. won't run for the loaded files. doc:
" autocmd-nested .
"
" one workaround: execute 'bufdo doautocmd BufRead' after; (or \|, bufdo
" consumes |)

" -- end notes

" colour
"
" mlterm causes an extra reload of the colorscheme.
" Debian vim might start with syntax off.
" That's actually nice to start with, but syn off -> enable is an Upheaval.
"
" Take care when testing with xterm: vim always seems to think bg == light,
" with both -rv (reverse) and -fg white -bg black.; bright without bold.
" urxvt and bg detection works as expected.
"
" some distributions wisely don't enable syntax highlighting by default.
"
" syntax-on should be done early, not late. synload.vim and syncolor.vim have
" many side-effects like removing autocmds.
"
" 2025-02-28 foldmethod=syntax can make vim unusable with large files (f.ex.
" json), blocks file loading. regexpengine=2 doesn't help. neither does lowering
" redrawtime.
set regexpengine=2

" alternative: :syntax manual
if get(g:, 'syntax_on', 0) != 1
    syntax on
endif

" custom syntax rules (UserApplySyntaxRules()) keep working fine even
" when filetype syntax is disabled with a global 'syntax off'.

" lowering synmaxcol isn't great since it breaks syntax highlighting after the
" offending line.
"set synmaxcol=300


" important for UserDateComment (language time) and gui menus; better set before
" filetype config and menus ('langmenu').
if has('win32')
    " :lang ctype C.utf8 fails on windows 11, E197.
    language C
    " langmenu - can't get it to work on windows; see gvimrc reloading menus.
endif

" standard plugins in $VIMRUNTIME/plugin - disable.
"{{{
" unimaginable functionality. would be nice to chmod 0, but often can't.
" /usr/share/vim/vim*/plugin/
"   {tohtml,gzip,rrhelper,spellfile,{getscript,tar,vimball,zip}Plugin}.vim
"   matchparen.vim - nice, but the autocommands feel yucky.
"   manpager - vim can be a rather nice manpager.
"
" 2024-02-25 enable plugins again; for
" and https://github.com/mbbill/undotree

" preventing loading by setting variables works but all the files still show up
" with :scriptnames
set noloadplugins
" do load packages from ~/.vim/pack
if exists('+packpath')
    packloadall
endif
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

filetype indent on
filetype plugin on

" 2022-07-28 clear out autocommands of other people.
" {{{

" i.e., redhat/fedora /etc/vimrc duplicates some of defaults.vim, things that
" are meant to be pulled in only when the user has no .vimrc. this seems to
" interfere with jumping to the last location on some files. anybody remember
" /etc/skel? suse.vim does ... a lot - mappings, tty type handling. they all
" ship their own config for root. good to see that debian and bsds don't lean
" that way.
"
" whenever possible (alias), run vim -u ~/.vim/0.vim
"
" at least the worst is in a named augroup. viml parsing is extra picky with
" au/aug (re-opening an augroup just to do autocmd! and then having <aug> END).
" autocmd_delete() isn't available on deathrow rhel boxen. distributions use
" various augroup names. debian doesn't add augroups, thankfully. augroup
" listing in viml is incomplete (:verbose augroup is no different from
" :augroup).
"
" even a single-line execute combining auto! with augr! with a bar doesn't work
" in some old vim versions.

function! UserRemoveVendorAugroups()
    " 2024-07-10 no good doing a plain 'autocmd!' here - synload.vim defines
    " Syntax * autocmd without a group, and filetype.vim defines some without
    " groups, around line 3177. these autocmds shouldn't be removed.
    "
    " check for the generic last-position-jump autocmd with: echo
    " autocmd_get({'group': '', 'event': 'BufRead', 'pattern':
    " '*'})->js_encode()

    " delete any ungrouped autocommands that want to run after reading any file
    if exists('#BufRead#*')
        autocmd! BufRead *
    endif
    if exists('#fedora')
        " remove autocommands from augroup
        autocmd! fedora
        " remove augroup
        augroup! fedora
    endif
    if exists('#redhat')
        autocmd! redhat
        augroup! redhat
    endif
endfunction

" }}}

" for mbbill/undotree - wide diff window
let g:undotree_DiffCommand = "/usr/bin/diff -u"
let g:undotree_WindowLayout = 2
let g:undotree_ShortIndicators = 1
let g:undotree_HelpLine = 0

" by default ftplugin/racket maps K to raco docs -- <kw>
let g:no_racket_maps = 1

" overengineered syntax/tmux.vim
let g:tmux_syntax_colors = 0

" never used grepprg

" journalled filesystems, SSD/NVMe/SD cards. fsync is complex these days, it's
" not clear that vim does everything that's needed.
" https://www.linusakesson.net/programming/vimsuspend/index.php (old)
" https://twitter.com/marcan42/status/1494213855387734019
" fsync directory? aio_fsync?
set nofsync
if exists('+swapsync')
set swapsync=
endif

" 2025-02-28 keeping 'swapfile' enabled doesn't make file loading slow

" how files should be written - whether to rename, or put the new data
" into the same file. the vi default behaviour is yes, and it's the most
" natural with vim as $EDITOR.
set backupcopy=yes

set modeline

" shellredir - pretty bad stuff that'll never get fixed now.
" https://groups.google.com/g/vim_dev/c/SGcwy7GViNs

let g:mapleader = ','

" 2022-07-16 selective syntax highlighting no longer in use.

" ----

" my stuff
let g:u = {}

" my old and slow raspberry pis
let g:u.is_rpi = filereadable('/sys/firmware/devicetree/base/model')

" U+21B3 - DOWNWARDS ARROW WITH TIP RIGHTWARDS
let g:u.showbreak_char = '↳'

let g:u.term_primitive = 1
" test: env -u DISPLAY TERM=linux vim
"
" screen's most useful from the console, but 'linux' doesn't leak through to
" $TERM. assume primitive.
"
" for a toplevel $TERM, if screen.$TERM exists, screen seems to set term to
" that.
"
" don't do fancy things if the encoding isn't utf-8. can happen if shell init
" files are bad, leading to unseemly statusline and fillchars.
if &encoding == 'utf-8'
    if exists('$DISPLAY') || exists('$WAYLAND_DISPLAY') || has('gui_running')
        let g:u.term_primitive = 0
    elseif &term =~# '\v^%(screen\.)?%(xterm|putty|rxvt-unicode)'
        let g:u.term_primitive = 0
    elseif &term =~# '^tmux'
        let g:u.term_primitive = 0
    elseif has('vcon') && &term ==# 'win32'
        let g:u.term_primitive = 0
    endif
endif

let g:u.mark = '_'
if !g:u.term_primitive
    " fence, guard; defend; idle time
    "let g:u.mark = nr2char(0x95F2)
    " to relax, as in rikyū
    let g:u.mark = nr2char(0x4F11)
endif

" 2025-03-10 'directory' is global, so we're stuck with %-separated filenames
" and possibly filename length limits. there's no way to set it per file in
" a directory hierarchy like how we can with 'backupdir'. similar for 'undodir'
" but BufWrite should do the right thing there - undo files are written only
" when the buffer's written.
"
" dirs should end with // even on windows.
"
" going back to swap file near file. they're transient, unlike backups and
" undofiles.
"
let g:u.swap_dir = '.'
if has('nvim')
    " default
    let g:u.swap_dir = '~/.local/state/nvim/swap//'
endif
if has('win32') || has('ivim')
    " it's just me, the swapfile won't help as a lock file.
    let g:u.swap_dir = expand('~') . '/.vim/var/swap//'
endif

" it's fine usually. incsearch can be an unwelcome surprise over ssh.
" doesn't handle chained :g/:v.
" doc 'is'
" to put the last match into the command line: <C-r>/
set noincsearch
command -bar Inc    set incsearch! | set incsearch?
" 2024-04-21 hlsearch's distracting in multiple windows with different search
" patterns.
set nohlsearch
" 2024-12-26 showmatch is irritating and often wrong in vimscript angle bracket
" matching
"set showmatch matchtime=1
set noshowmatch


" setting 'ignorecase' can be surprising.
" for example, checking filenames against the 'backupskip' patterns uses
" 'ignorecase'.
" 2025-08-26 another go
" 2025-12-17 ignorecase is too wrong.
set noignorecase

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
"
" 2025-02-10 re-enabled. it's slow but i keep looking for the visual feedback.
set showcmd

" set-formatoptions; doc fo-table
" fo-r - add comment leader on new lines, insert mode
" fo-n - recognize numbered lists
" fo-2 - use indent of 2nd line for the rest of the paragraph
" fo-B - no space between two multibyte chars when joining
"   multibyte can be many things, not just CJK. breaks too many texts.
" fo-1 - try to not break lines after one-letter words
" fo-j - remove comment leader when joining lines
set formatoptions+=r21j
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
    let l:dir = expand(a:dir)
    if !isdirectory(l:dir)
        call mkdir(l:dir, 'p', 0700)
    endif
endfunction


" setup 'directory'.
"
" trailing '//' -> '%' as path separators has been possible since vim 5.4:
" version5.txt:3726 /New variation for naming swap files:/
"
" unlike persistent undo files, swap files are well-behaved (start with .).
"
" not great to keep swapfiles on onedrive; not great to not be able to share
" swap files and undo files either.
if g:u.swap_dir != '.'
    call UserMkdirOnce(g:u.swap_dir)
    execute 'set directory^=' . g:u.swap_dir
endif

" undodir
let g:u.undo_dir = '~/.vim/var/un//'
if has('nvim')
    " default
    let g:u.undo_dir = '~/.local/state/nvim/undo//'
endif
if has('persistent_undo')
    let undo_dir = get(g:u, 'undo_dir', '.')
    if undo_dir !=# '.'
        call UserMkdirOnce(undo_dir)
        execute 'set undodir^=' . undo_dir
    endif
    unlet undo_dir
    set undofile
endif
if g:u.is_rpi
    set noswapfile noundofile
endif

"
" leave swapfile at the default (on).
" damian conway
set updatetime=500 updatecount=10
" to see current swap file path: ':sw[apname]' / swapname('%')

" no: s, T,
"
"   F - requires patch-7.4.1570; https://github.com/vim/vim/pull/686
"
"   S (searchcount()) - requires patch-8.1.1270; nice for explicit search, not
"   so much when search is used in mappings. S is present in shm by default,
"   keep it that way.
"
"   https://github.com/vim/vim/pull/4317
set shortmess+=filmnrwxoOtWI
" hide ins-complete-menu messages
if has('patch-7.4.314')
    set shortmess+=c
endif

" a little like :behave mswin, but not all the way. think DOS EDIT.COM.
" set keymodel=startsel selectmode=mouse,key
" don't use SELECT mode
set selectmode= keymodel=

" 2022-12-08 - removing autoselect; too easy to unintentionally wipe the
" clipboard that way. pasting from the system clipboard is nice, but all small
" cuts and pastes going to the system clipboard is not great. gvim's like
" a terminal emulator anyway - shouldn't work too hard to be a good gui app.
"
" 2023-01-02 - just unnamedplus is no good for win32. doesn't fail, but breaks
" y/p.
"
" old memory - with default 'clipboard' and X forwarding over ssh, slow
" startup... clearing 'clipboard' was enough to start fast, -X wasn't necessary?

set clipboard=

" laststatus: 0 = never, 1 = show if multiple splits, 2 = always.
"
" 2023-08-22 gvim bug: on laststatus=1, C-w f (open
" filename under cursor in split), if the origin window had winfixheight, after
" splitting, the command window size can become 2 high, can go to 0
" on more splits of the new split, the option cmdheight can go to 2 if cmdheight
" was set to 1 in vimrc, otherwise the cmdheight option stays at 1 while the
" command window size goes to whatever.
"
" probably winfixheight wasn't meant to be in a modeline.

" don't like flimflam when editing a single thing.
"
" 2023-10-03 g-/g+ prints long messages like "1 line less; before #1  2 seconds
" ago". Can't be turned off, 'report' doesn't affect them. when the statusline's
" missing and the ruler's active and cmdheight's 1, the message doesn't fit and
" causes hit-enter prompts. shm-T truncation in the middle also sucks.
" cmdheight>1 sucks. laststatus=2 sucks least. maybe forcing the ruler to be
" shorter can help, but can't be bothered anymore.
"
" 2024-03-21 the above issue with ruler and messages was for iOS? phone screen's
" wide enough now.
" 2024-04-09 seeing the buffer name is nice...
set laststatus=2

" disabling 'ruler' makes 3<C-g> print more info.
set ruler
" must always be 8
if &tabstop != 8
    set tabstop=8
endif
set shiftwidth=4 softtabstop=4 expandtab list

set fileformats=unix,dos
set smarttab
set shiftround
set backspace=indent,eol
if has('patch-8.2.0590')
    " C-W/C-U is documented as stopping at start-of-insert.
    " this fixes that. wow bram 2020.
    set backspace+=nostop
else
    set backspace+=start
endif

" <Left>, <Right> in visual mode (vw at the last word of a line moves to the new
" line...)
" 2024-12-12 use space (and bs) in visual mode.
set whichwrap=b,s


" indentation
" cindentation's a bit too intrusive for plaintext. smartindent too can be
" annoying.
set autoindent


" will be fine using visual mode/line numbers and the xsel(1) integration
" mappings and commands further below.
"
" highlight group: NonText

"let &showbreak = g:u.showbreak_char

"set display+=uhex
if v:version < 802
    " newer vims set this to 'truncate' and that's fine.
    set display+=lastline
endif
set scrolloff=2
" scrolljump is efficient but jarring.
"set scrolljump=5
"
" 2024-01-16 vim can't really scroll windows by screenlines yet.
" 'smoothscroll' WIP. bad for long paragraphs or URLs.
" https://stackoverflow.com/a/27753674
" https://vi.stackexchange.com/q/11315

set cpoptions-=A        " don't modify alternate filename on :w <fn>

"set confirm
set autoread autowrite autowriteall
set hidden
set matchpairs+=<:>,«:»,｢:｣

" default commentstring's /* %s */, mostly wrong
set commentstring=\#\ %s

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

" viminfo: don't save registers (<0). why wasn't i saving search pattern history?
" neovim: 's' has wider blast radius, s0 prevents saving history to shada.
" <0 should exclude registers in both vim and neovim.
set viminfo='100,<0,h,s100,r/tmp
if exists('$TMPDIR') && ($TMPDIR !=# '/tmp')
    execute 'set viminfo+=r' . $TMPDIR
endif

if exists('+browsedir')
set browsedir=buffer
endif

" 2024-03-01 have i tried and and stopped using onemore before?
" onemore is good when pasting.
" 2024-12-10 good how? no-onemore is nice when i want to x backwards from the
" end of a line.
set virtualedit=block

" set selection=exclusive doesn't really consistently (v, no move, there is
" a selection and it's the char under the cursor.) and in the linux console the
" cursor doesn't get the same colour as hi-Visual.
"
" https://groups.google.com/g/vim_use/c/YBocFskMxSA
"
" this isn't the emacs mark-point-region model...

set history=1000
set timeout timeoutlen=1500 ttimeout ttimeoutlen=200

" helps with navigating to a line of interest with <n>j/+ and <n>k/-,
" but also takes up a lot of space.
" see: cursorlineopt=number, 'signcolumn'.
"set number relativenumber

" but never newtab; maybe split.
set switchbuf=useopen,usetab
if has('patch-8.1.2315')
    set switchbuf+=uselast
endif
" 2024-03-23 vertical split - feels better to have the new, focused split appear
" at the top, not below.
set nosplitbelow splitright
" 'equalalways' is default on; that's nice for vertical splits, don't want
" it with horizontal splits.
set eadirection=hor

set mouse=

set titlestring=Vim:\ %n'%f\ %m
" 2026-01-14 why was title off? with tabbed ttys it's nice
if !g:u.term_primitive
    set title
endif

" I use 'view' a lot. In Red Hat Linux, view is provided by vim-minimal,
" which evidently does not include folding. This if statement avoids
" errors that view will otherwise print while starting.
if has('folding')
    set nofoldenable    " default off
    set foldmethod=marker
endif


" don't complete until unique (like default bash behaviour)
set wildmode=list:longest,list
set wildmenu
" don't complete swap, undo files and others.
set wildignore+=.*.swp,.*.un~,*.pyc
set suffixes+=.pyc


" -- buffer switching
"
" Trying out a mapping to show buffers quickly and unobtrusively.
" https://stackoverflow.com/a/16084326 https://github.com/Raimondi/vim-buffalo
" The <space> after :b allows wildmenu to come into play easily.
"
" NB: can't be a silent mapping.
"
" used to use '+', but turns out it's somewhat useful.
"nnoremap    K           :ls!<cr>:b<space>

" 2025-05-22 default wildmenu for :b skips buffers without names, that's no
" good.
"
" first, define a custom command completion function.
function! UserBufferComplFn(arglead, cmdline, cursorpos) abort
    let ls_out = UserRun(':ls!')
    " splitting removes the first empty line from :ls!
    let lst = split(ls_out, "\n")
    return join(lst, "\n")
endfunction

" then, a custom command that extracts the buffer number from the :ls!
" output and passes it to :b, handling no-args (no wildmenu selection)
command -nargs=* -complete=custom,UserBufferComplFn     Bnum
            \ if len(<q-args>) > 0
            \ | execute str2nr(get([<f-args>], 0)) . 'b'
            \ | endif

" wildmenu without wildoptions-pum looks weird
nnoremap    K           :ls!<CR>:Bnum<Space>

" contemporary
if v:version >= 900
    " display completion matches in a popup menu
    set wildoptions=pum,fuzzy
    set wildmode=longest:full
    set wildcharm=<tab>     " this seems clunky. but, works.

    nnoremap    K   :Bnum<Space><C-r>=nr2char(&wildcharm)<CR>

    " buffer list can be shown in a popup menu. a lot better than having
    " :ls shift window contents up. requires wildoptions, wildmode full or
    " longest:full, and wildcharm.
    "
    " it's a shame that buffer numbers aren't shown/can't be used.
    " command-completion-custom might have helped, but that doesn't support
    " returning a dict like 'completefunc'. alt: popup_menu()
    "
    " do :b, <space to prevent vim-command completion and switch to :b arg
    " completion, <tab> (wildchar_m_) to trigger wildcard expansion popup.
    "
    " https://gist.github.com/g0xA52A2A/7cb1be24a078724f4522444a0da5de0a

    set diffopt+=indent-heuristic
    set diffopt+=algorithm:patience

    " following needs patch-8.2.2569 for multibyte chanrs in fcs/stl,
    " patch-8.2.3578, patch-8.2.3605 for hlget/hlset.
    function! UserUi() abort
        if g:u.term_primitive
            return -1
        endif

        if UserUiIsThin()
            call UserFillcharsThin()
            call UserUiStatusLine(g:u.ui, &background)
            " no good way to restore when blocky...
            if exists('*hlget')
                let l:hi = hlget('VertSplit')
                if has_key(l:hi[0], 'cterm')
                    let g:user_last_vertsplit = l:hi
                endif
            endif
            highlight VertSplit cterm=NONE ctermbg=NONE gui=NONE guibg=NONE
        elseif UserUiIsBlocky()
            call UserFillcharsBlocky()
            call UserUiStatusLine(g:u.ui, &background)
            if exists('*hlset') && exists('g:user_last_vertsplit')
                call hlset(g:user_last_vertsplit)
            endif
            highlight StatusLine cterm=NONE gui=NONE
        endif
    endfunction

    command -bar Thin   let g:u.ui = g:u.uiflags.thin   | echo UserUi()
    command -bar Blocky let g:u.ui = g:u.uiflags.blocky | echo UserUi()

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
" 'expandtab' ... ?
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
    " but a bit too much with deep indenting and expandtab.
    let g:u.lcs.p.eol = 'NONE'
    let g:u.lcs.p.trail = 'NONE'

    " for the linux console or old X bitmap fonts:
    let g:u.lcs.ascii = copy(g:u.lcs.def)
    " eol $ is very distracting.
    " let g:u.lcs.ascii.eol = '$'
    let g:u.lcs.ascii.eol = 'NONE'
    let g:u.lcs.ascii.nbsp = '!'
    let g:u.lcs.ascii.tab = 'NONE'
    let g:u.lcs.ascii.trail = '_'

    let g:u.lcs.cur = g:u.term_primitive ? g:u.lcs.ascii : g:u.lcs.p
    let &listchars = UserListchars(g:u.lcs.cur)
endfunction


function! User70s() abort
    " not turning 'list' off, but just spaces for tab listing.
    setlocal listchars-=tab:\·\ \·      listchars+=tab:\ \ \ "

    " clear the highlight
    highlight! default link SpecialKey Normal
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


" cursorline - can be confusing with vertical splits.
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
    set cursorlineopt=number,line
    if has('patch-8.1.2028')
        set cursorlineopt-=line
        set cursorlineopt+=screenline
    endif
endif
set nocursorline

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


" helper for loading (with 'runtime' or 'colorscheme') files without any stray
" 'i' s messing up the buffer and maybe vim startup
function! ExecuteNomodifiable(cmd) abort
    let b:_mod = 0
    if &modifiable
        set nomodifiable
        let b:_mod = 1
    endif
    try
        execute a:cmd
    finally
        if b:_mod
            set modifiable
        endif
        unlet b:_mod
    endtry
endfunction


if v:version >= 900 && has('vim9script') && filereadable(expand('~/.vim/statusline_defs.vim'))
    " in a separate file so that vim7/8 won't try to parse the defs.
    call ExecuteNomodifiable('runtime statusline_defs.vim')
    "set statusline=%2n'%<<%f>%=\ %{UserStLnBufFlags()}\ %P\ %{g:u.mark}\ "
    "set statusline=%2n'%<<%f>\ %{UserModeMsg()}%=\ %{UserStLnBufFlags()}\ %P\ %{g:u.mark}\ "
    set statusline=%{&buftype==#'terminal'?UserModeMsg():''}%2n'%<<%f>%=\ %{UserStLnBufFlags()}\ %P\ %{g:u.mark}\ "
elseif has('nvim') && filereadable(expand('~/.vim/statusline_defs.lua'))
    " it's nice that neovim cleans up those thousands of filetype autocmds
    runtime statusline_defs.lua
    set statusline=%2n'%<<%f>%=\ %{v:lua.UserStLnBufFlags()}\ %P\ %{g:u.mark}\ "
else
    function! UserStLnBufModStatus()
        let l:m = ''
        " NB attribute check order
        if &modified    | let l:m .= '+'        | endif
        if !&modifiable | let l:m .= '-'        | endif
        " if neither modified nor unmodifiable:
        if empty(l:m)   | let l:m = '_'         | endif

        if &readonly    | let l:m .= '.ro'      | endif

        " normal buffer without a swapfile and swapfile is globally on - warn
        " except on iOS (iVim) where swap is disabled by default.
        if &buftype == '' && (&g:swapfile && (!&l:swapfile || (&updatecount == 0)))
            let l:m .= '.!swf'
        endif
        return l:m
    endfunction


    " if in paste mode, indicate that and not just the fact that paste mode
    " temporarily forces textwidth to 0.

    function! UserStLnTextWidth()
        return &paste ? '!P' : &textwidth
    endfunction

    function! UserStLnFenc()
        let l:s = ''
        if !empty(&fileencoding) && &fileencoding !=# 'utf-8'
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

    " terse format indentation options
    function! UserStLnIndentation()
        if &ts == 8 && &et && &sw == &sts && (&sw == 4 || &sw == 2)
            " zeitgeist
            return ''
        endif
        if &ts == 8 && !&et && &sw == 0 && &sts == 0
            " classic tab mode
            return ''
        endif
        let l:l = []
        if &tabstop != 8
            call add(l:l, 'ts:' . &tabstop)
        endif
        " moniker: soft/hard
        call add(l:l, &expandtab ? 'so' : 'ha')
        if &shiftwidth == &softtabstop
            call add(l:l, 'sf:' . &shiftwidth)
        else
            call add(l:l, 'sw:' . &shiftwidth)
            call add(l:l, 'sts:' . &softtabstop)
        endif

        if l:l == ['so', 'sf:2'] && &filetype == 'json'
            " my defaults for json
            return ''
        endif
        if empty(l:l)
            return ''
        endif

        return '{' . join(l:l, ',') . '}'
    endfunction

    " tried prev: if fillchars has 'stl', use hl Normal between the buffer
    " attrib flags and the right hand side, as: %...%#Normal#%=...
    "
    " %Y is too loud, %y has brackets - use raw &filetype, show always. ! NB
    "   non-current (NC) status lines don't update immediately when the filetype
    "   changes. %y doesn't help (same behaviour as %{&filetype}). workaround:
    "   :redrawstatus, of course. actually, moving to the command line (no need
    "   to run redrawstatus) seems to be enough, with nolazyredraw.
    "
    " %w (Preview) is somewhat special, so it gets to hang around.
    "
    " would prefer parentheses, but brackets are hardcoded for default buffer
    "   names ("[No Name]", "[Scratch]").
    "
    " aside: Mathematica: brackets
    " - https://mathematica.stackexchange.com/q/72976
    "
    " d[] for delta -> change -> modified/modifiable status. d[f] == quiescent,
    "   no unwritten changes, finalised -> delta? false.
    "

    " gather up buffer info into one function - to execute in a single %{}.
    " should usually go inside a matching pair of separators like []. other
    " statusline flags like %W should go after this.

    function! UserFmtPos() abort
        let l:pos = getpos('.')
        return printf('<%3d:%-2d>', l:pos[1], l:pos[2])
    endfunction

    let g:mode_map = {
                \ 't': 'TERMINAL',
                \ 'n': 'NORMAL',
                \ 'i': 'INSERT',
                \ 'v': 'VISUAL',
                \ 'V': 'V-LINE',
                \ "\<C-v>": 'V-BLOCK',
                \ 'c': 'COMMAND',
                \ 'R': 'REPLACE'
                \ }


    function! UserModeMsg() abort
        if !has('terminal') || &buftype !=# 'terminal'
            return ''
        endif

        let l:m = mode()
        if l:m ==# 'n'
            return ''
        endif
        return '-- ' . get(g:mode_map, l:m) . ' -- '
    endfunction

    function! UserStLnBufFlags() abort
        let l:l = []
        if &buftype ==# 'terminal'
            call add(l:l, 'TERM')    " should get its own format flag for statusline
            " something like this (line:col only in terminal normal mode) should
            " be done more efficiently by the statusline.
            let l:term_win_mode = mode()
            if l:term_win_mode != 't'
                call add(l:l, UserFmtPos())
            else
                " reduce visual jitter
                call add(l:l, '<  *:* >')
            endif
        else
            call add(l:l, UserStLnBufModStatus())
            if &previewwindow
                call add(l:l, 'PRV')    " %W
            endif
            if &diff
                call add(l:l, 'DIF')
            endif
            let l:pos = getpos('.')
            call add(l:l, UserFmtPos())
            call add(l:l, UserStLnIndentation())
            call add(l:l, UserStLnTextWidth())
            call add(l:l, UserStLnFenc())
            call add(l:l, UserStLnFf())
            if &formatoptions =~# 'a'
                call add(l:l, 'fo-a')
            endif
        endif

        " searching (for unicode whitespace) - costly

        " erase numbers that are 0, erase empty strings
        call filter(l:l, "v:val != 0 || v:val !=# ''")
        "return '[' . join(l:l, '][') . ']'
        return '[' . join(l:l, '/') . ']'
    endfunction

    set statusline=%{&buftype==#'terminal'?UserModeMsg():''}%2n'%<<%f>%=\ %{UserStLnBufFlags()}\ %P\ %{g:u.mark}\ "
endif

" NB: last double quote starts a comment and preserves the trailing space. vim
" indicates truncated names with a leading '<'.
"
" current register: %{v:register}

" don't forget to kee a space/separator after the filename
"set statusline=%2n'%<<%f>%=\ %{UserStLnBufFlags()}\ %P\ %{g:u.mark}\ "
" there ought to be a 'tstatusline' for terminal windows?

" in case we close all normal windows and end up with something like the preview
" window as the only window - the ruler should show the same buffer flags as the
" status line.
"
" 2024-04-02 in chaotic situations (xterm has no fonts to display ma), vim may
" print errors about conflicting with listchars, and fail to redraw properly.
" having a statusline works better, but taking ma away from rulerformat for now.
" + reducing the ruler width from 17 to 8.
set rulerformat=%8(%=%M%)

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

function! UserTimeShort()
    return strftime('%H:%M')
endfunction

" like 2022-07-05T12:57:18.568367478+00:00
"
" https://github.com/python/cpython/issues/59648 - datetime doesn't support
" nanoseconds.
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

if exists('*execute')
    function! UserRun(cmd)
        let l:verbosity = &verbose
        if l:verbosity != 0
            set verbose=0
        endif
        try
            return execute(a:cmd)
        finally
            if l:verbosity != 0
                let &verbose = l:verbosity
            endif
        endtry
    endfunction
else
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
endif

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
    else
        echom join(a:lines, ',')
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
    let l:bufp = []
    " order's significant
    call add(l:bufp, 'tw=' . &textwidth)
    call add(l:bufp, 'wm=' . &wrapmargin)

    call add(l:bufp, "(")
    if &tabstop != 8
        call add(l:bufp, 'ts=' . &tabstop)
    endif
    call add(l:bufp, 'ai=' . &autoindent)
    call add(l:bufp, 'et=' . &expandtab)
    call add(l:bufp, 'sw=' .  &shiftwidth)
    call add(l:bufp, 'sts=' .  &softtabstop)
    call add(l:bufp, ")")

    call add(l:bufp, 'ft=' . &filetype)
    call add(l:bufp, 'fo=' . &formatoptions)

    return bufnr('%') . ': ' . UserStLnBufFlags() . ' ' . join(l:bufp)
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
function! UserUniNames(screen_char) abort
    if a:screen_char ==# ''
        return 'NUL'
    endif

python3 << PYEOF
import unicodedata
import vim

# the curses.ascii module isn't present on non-unix platforms, for no good
# reason. included inline here.

# begine some of python 3.11 curses.ascii
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

def isprint(c): return 32 <= _ctoi(c) <= 126
def isctrl(c): return 0 <= _ctoi(c) < 32

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
# end curses.ascii

screen_char = vim.eval('a:screen_char')

if len(screen_char) == 1 and \
    unicodedata.category(screen_char) == 'Cc' and \
    isctrl(screen_char) and \
    ord(screen_char) < len(controlnames):
    u_names = controlnames[ord(screen_char)] + \
        ' (' + unctrl(screen_char) + ')'
elif screen_char == "\x7f":
    u_names = 'DEL (' + unctrl(screen_char) + ')'
else:
    try:
        # unicodedata.name() wants just one char; in case
        # screen_char is a string with combining characters -
        # map over each char in screen_char.
        u_names = map(unicodedata.name, screen_char)
    except ValueError:
        # exception just says "no such name"
        u_names = '(UNKNOWN)'

PYEOF

    " -- back in viml --
    let l:u_names = py3eval('u_names')
    let l:fmt = printf('''%s'' %s',
                \ strtrans(a:screen_char), join(l:u_names, ', '))
    return l:fmt
endfunction

" test: а́ - CYRILLIC SMALL LETTER A, COMBINING ACUTE ACCENT
if has('python3')
    command UC  echom UserUniNames(UserGetScreenChar())
else
    command UC  ascii
endif
nnoremap    <silent> <Leader>C   :UC<CR>


" given a string, return U+... formatted unicode scalar value for each char.
" requires patch-7.4.1730 - build on g8 instead?
"
" don't want to get into python3 strings for this.

function! UserUniScalars(str) abort
    let l:result = []
    for i in range(len(a:str))
        let l:n = strgetchar(a:str, i)
        if l:n < 0
            break
        endif
        call add(l:result, printf('U+%04X', l:n))
    endfor
    return l:result
endfunction

if has('patch-7.4.1730')
    command UN  echom join(UserUniScalars(UserGetScreenChar()), ' ')
else
    command UN  echom '(not supported)
endif
nnoremap <silent> <Leader>U :UN<CR>
nnoremap <silent> g7        :UN<CR>


" list all the syntax groups in effect under the cursor.
function! UserSyntaxNamesAtCursor() abort
    let l:tmp = synstack(line('.'), col('.'))
    let l:syn_ids = []
    " 2024-03-25 skip duplicates; f.ex. with
    " https://github.com/vim-jp/vim-vimlparser ?
    for l:id in l:tmp
        if index(l:syn_ids, l:id) == -1
            call add(l:syn_ids, l:id)
        endif
    endfor

    let l:syn_names = []
    for l:syn_id in l:syn_ids
        let l:syn_name = synIDattr(l:syn_id, 'name')
        call add(l:syn_names, l:syn_name)
    endfor

    return l:syn_names
endfunction

" 2024-03-25 old vims can't echo lists
command SynNames    echom join(UserSyntaxNamesAtCursor(), ' ')
nnoremap <silent>   <Leader>S   :SynNames<CR>


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
    let l:char_info = UserRun('UC')
    if l:char_info[0] ==# "\n"
        " remove leading ^@
        let l:char_info = strpart(l:char_info, 1)
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
function! UserShowHelp() abort
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


" 2025-07-14 unset undofile/undodir and use autocmds with :wundo/:rundo just to
" keep the filenames the same as backup file names (nested directory hierarchy
" without %), respect backupskip, avoid occasional E828 on windows.
"
" 'undofile' / 'undodir' behaviour likely won't ever get fixed.
"
" NB undotree plugin asumes too much and interferes, creates undodir and sets
" undofile if undofile not set. remove autocmds added by plugin:
if exists('#undotreeDetectPersistenceUndo')
    autocmd! undotreeDetectPersistenceUndo
    augroup! undotreeDetectPersistenceUndo
endif

function! UserUndoFile(fn) abort
    let l:file_abs_path = fnamemodify(a:fn, ':p')
    if has('win32')
        " for microsoft windows - replace the ':' after drive letters with '$'
        let l:file_abs_path = l:file_abs_path[0] . '$' . l:file_abs_path[2:]
    endif
    if has('ios')
        " iVim - for files in app Documents, shorten
        let l:docs = '/private' . $HOME
        if stridx(l:file_abs_path, l:docs) == 0
            let l:file_abs_path = strpart(l:file_abs_path, len(l:docs) + 1)
        endif
    endif
    let l:undo_dir_base = '~/.vim/var/un'
    if has('nvim')
        " neovim changed undo format; don't let things mix.
        let l:undo_dir_base = '~/.local/state/nvim/undo'
    endif
    let l:undo_file = simplify(expand(l:undo_dir_base
                \ . '/' . l:file_abs_path . '.un'))
    return l:undo_file
endfunction


function! UserWriteUndo(fn) abort
    if UserTestBackupskip(a:fn) != 0
        return
    endif
    let l:undo_file = UserUndoFile(a:fn)
    let l:undo_dir = fnamemodify(l:undo_file, ':h')
    call UserMkdirOnce(l:undo_dir)
    execute 'silent' 'wundo' l:undo_file
    let b:user_undo_file = l:undo_file
endfunction


function! UserReadUndo(fn) abort
    if &filetype ==# 'help' && !&modifiable
        " just browsing help
        return
    endif
    let l:undo_file = UserUndoFile(a:fn)
    " check just for existence
    if glob(l:undo_file, 1, 1) != [ l:undo_file ]
        return
    endif
    execute 'silent' 'rundo' l:undo_file
    let b:user_undo_file = l:undo_file
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
    if has('ios')
        " iVim - for files in app Documents, shorten
        let l:docs = '/private' . $HOME
        if stridx(l:filepath, l:docs) == 0
            let l:filepath = strpart(l:filepath, len(l:docs) + 1)
        endif
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
function! UserOpenIndexFile() abort
    if filereadable('index')
        "edit +setlocal\ nomodifiable index
        view index
        normal! gg
        " leave 10 lines for the index window. the rest is the new main window
        " that fill load the first named file in the index file.
        let height = &lines - 10
        if height >= 20
            execute height . 'split'
            " cursor in new split, go to named file.
            normal! gf
        endif
    else
        echom 'no index'
    endif
endfunction

" like :Explore
command Index       call UserOpenIndexFile()


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
    " both hlexists() and hlID() return non-zero when a syntax item's defined,
    " doesn't require highlight group definition.
    "
    " run hi discarding output, check v:errmsg.

    " grey as default can look really bad; better to just define cleared
    " highlight group to keep the syntax rules from failing, than actually set
    " colours.

    silent! highlight UserDateComment
    if v:errmsg ==? 'E411: Highlight group not found: UserDateComment'
        highlight clear UserDateComment
    endif

    silent! highlight UserTrailingWhitespace
    if v:errmsg ==? 'E411: Highlight group not found: UserTrailingWhitespace'
        highlight clear UserTrailingWhitespace
        " turn on 'list', hope 'trail' is defined and working.
        set list
    endif

    silent! highlight UserHashTag
    if v:errmsg ==? 'E411: Highlight group not found: UserHashTag'
        highlight clear UserHashTag
    endif

    " for URIs at top level, with syntax highlighting and not matchadd()
    silent! highlight UserHttpURI
    if v:errmsg ==? 'E411: Highlight group not found: UserHttpURI'
        highlight! default link UserHttpURI Normal
    endif

    " __UNIWS__; this isn't something we want to put in a colorscheme override
    " file, maybe - unless we work with a red background. blinking would have
    " been nice, if hi start/stop worked everywhere.
    silent! highlight UserUnicodeWhitespace
    if v:errmsg ==? 'E411: Highlight group not found: UserUnicodeWhitespace'
        highlight! default link UserUnicodeWhitespace Error
    endif

    " UserHttpURI: if using non-syntax matches (matchadd/UserMatchAdd), define
    " a ctermbg to hide spell errors. f.ex. ctermbg=255 guibg=bg
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
"
" Iosevka SS04 - Menlo style
"   SS01 - Andale Mono style, dotted zero, straight braces
"
" mononoki's good for code. no greek crosses though.
"
" 2024-04-09 working in hi res, iosevka light's too light.

" set guifontname to something, to take effect before the window's drawn
function! UserSetGuiFont()
    " init default font size
    let g:u.gfn_size = 11

    if has('linux') && has('gui_gtk')
        " fontconfig doesn't need a gui
        function! UserFontExists(name) abort
            let l:res = system("fc-match -f '%{family}\n' '" . a:name . "'")
            if v:shell_error
                return 0
            endif
            return l:res =~? a:name
        endfunction

        " make iosevka-fixed boxed-drawings-light-vertical-s touch:
        "if !has('win32') set linespace=-2 endif
        " but bitstream vera sans mono / dejavu sans mono book
        " lose underscores with linespace < 0.

        function! UserGetFonts() abort
            let possible_fonts = ['Iosevka Fixed SS01', 'Source Code Pro', 'Adwaita Mono', 'DejaVu Sans Mono']
            let avail_fonts = possible_fonts->filter({ idx, val -> UserFontExists(val) })
            let F = { name -> name . ' ' . g:u.gfn_size }
            if !empty(avail_fonts)
                return F(avail_fonts[0])
            endif
            " weird if DejaVu Sans Mono doesn't exist
            return F('Monospace')
        endfunction
        "command! -bar FnMononoki let &guifont = 'mononoki ' . g:u.gfn_size
    elseif has('win32')
        " getfontname() doesn't work this early
        function! UserGetFonts() abort
            return 'Iosevka_Fixed_SS01:h11:qCLEARTYPE'
        endfunction
    elseif has('ios')
        function! UserGetFonts() abort
            return 'Menlo:h10.0'
        endfunction
    else
        function! UserGetFonts() abort
            return 'Monospace'
        endfunction
    endif

    command! -bar FnDef  let &guifont = UserGetFonts()
    nnoremap <silent> <F7>  :let g:u.gfn_size += 1 <bar> FnDef<CR>
    " don't go down too much
    nnoremap <silent> <F6>  :let g:u.gfn_size = max([g:u.gfn_size - 1, 8])
                \ <bar>
                \ FnDef<CR>
    nnoremap <silent> <F5>  :let g:u.gfn_size = 12 <bar> FnDef<CR>
endfunction

" called after window is drawn
function! UserLoadGuifont()
    if !has('win32')
        return
    endif

    function! UserFontExists(name) abort
        let n = substitute(a:name, ' ', '_', 'g')
        return getfontname(n) ==# n
    endfunction

    function! UserGetFonts() abort
        let possible_fonts = ['Iosevka Fixed SS01', 'Cascadia Mono Light']
        let avail_fonts = possible_fonts->filter({ idx, val -> UserFontExists(val) })
        let F = { name -> substitute(name, ' ', '_', 'g') . ':h' . g:u.gfn_size . ':qCLEARTYPE' }
        " depend on Cascadia Mono existing
        return F(avail_fonts[0])
    endfunction
    "
    " windows doesn't seem to like mononoki.
    "
    " more cleartype; no hidpi here
    " 2023-03-02 have hidpi now
    " 2023-07-09 not everywhere (ultrawide at work)
    " 2023-08-20 very slow on vmware vdi
    if !exists('$ViewClient_Type')
        set renderoptions=type:directx,taamode:1
    endif
endfunction

function! UserSetGuicursor() abort
    " someone's really gone on a wild ride with the guicursor possibilities.
    "set guicursor+=a:blinkon0
    set guicursor&
    " don't disable blink for operator-pending (o) and showmatch (sm)
    set guicursor+=n-v-ve-i-r-c-ci-cr:blinkon0
endfunction


" turn off most highlights; 'highlight clear' defaults are not great. too much
" underlining - usually seen on serial lines, 88 color ttys (rxvt/urxvt)..
" better without than with.
"
" these are highlights for text/content, not vim UI elements.
"
" source: hi clear, hi -> dump, grep underline
function! UserClearContentHighlights()
    " source: syntax/syncolor.vim
    "
    " remove term=bold/underline from defaults. except Special and Underlined.
    "   grep term=b/u <syncolor.vim>
    highlight Comment       term=NONE cterm=NONE
    highlight Constant      term=NONE cterm=NONE
    highlight Identifier    term=NONE cterm=NONE
    highlight Statement     term=NONE cterm=NONE
    highlight Type          term=NONE cterm=NONE
    highlight PreProc       term=NONE cterm=NONE

    " don't ignore that hard
    highlight Ignore        NONE

    " vim spell isn't worth suffering this much over.
    highlight clear SpellCap
    highlight clear SpellLocal
    " decriminalise rare words
    highlight clear SpellRare
endfunction


function! UserMinimalContentHighlights()
    " https://vimhelp.org/syntax.txt.html#%7Bgroup-name%7D
    let his = [ 'Comment', 'Constant', 'Identifier', 'Statement', 'PreProc',
                \ 'Type', 'Special', 'Underlined', 'Ignore', 'Error', 'Todo',
                \ 'Added', 'Changed', 'Removed' ]
    for hi in his
        execute 'highlight!' 'clear' hi
        execute 'highlight!' 'link' hi 'Normal'
    endfor
endfunction


" bring some sanity to vim UI element colours.
" remember; TERM(vt100, vt220) -> term, TERM(ansi, linux, xterm) -> cterm
"
" Only needs to run on non-gui, non-256-colour ttys.
function! UserColoursFailsafe()
    highlight ColorColumn   term=NONE cterm=NONE
    highlight CursorColumn  term=NONE cterm=NONE
    highlight CursorLine    term=NONE cterm=NONE
    highlight CursorLineNr  term=NONE cterm=NONE
    highlight EndOfBuffer   term=NONE cterm=NONE
    highlight ErrorMsg      term=standout
    highlight LineNr        NONE
    highlight MatchParen    term=NONE cterm=NONE
    highlight TabLine       NONE
    highlight ToolbarLine   NONE
    highlight VisualNOS     NONE
    " in some situations the default bold attribute of ModeMsg caused
    " problems. clear the term attribute.
    highlight ModeMsg       term=NONE cterm=NONE
    highlight Normal        term=NONE cterm=NONE
    " for cterm with 8/16/88 colours - magenta on grey
    highlight Visual        term=reverse ctermfg=7 ctermbg=5 cterm=NONE

    if UserCO(g:u.coflags.spell)
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
        highlight StatusLine    ctermfg=0   ctermbg=6   cterm=NONE
        highlight StatusLineNC  ctermfg=0   ctermbg=7   cterm=NONE
    endif
endfunction     " UserColoursFailsafe()


" a minimal colorscheme implementation, delegate everything to tty.
" better than the default colours.
function! UserColoursTty()
    highlight clear
    if exists('g:syntax_on')
        syntax reset
    endif
    "call UserClearContentHighlights()
    call UserMinimalContentHighlights()
    call UserColoursFailsafe()
endfunction


" 2022-09-04 on ultrawide monitors with slow VMware graphics, stl/stlnc
" can cause windows gvim to crash.
" 2023-08-21 still there :) 352 columns good, 353 columns bad.
" 2024-05-01 still there, windows 11. but i don't use windows anymore.
function! UserFillcharsThin() abort
    " TODO check u.term_primitive, patch-8.2.2569, can-load-colorscheme
    let l:fcs = {}
    " vert default: U+007C    VERTICAL LINE
    let l:fcs.vert = nr2char(0x2502)    " BOX DRAWINGS LIGHT VERTICAL
    let l:hrz = nr2char(0x2500)         " BOX DRAWINGS LIGHT HORIZONTAL
    "let l:hrz = nr2char(0x23BD)        " Horizontal Scan Line-9
    let l:fcs.stl = l:hrz
    let l:fcs.stlnc = l:hrz
    let &fillchars = UserFillchars(l:fcs)
endfunction

function! UserFillcharsBlocky() abort
    let l:fcs = {}
    let l:fcs.vert = nr2char(0x2502)    " BOX DRAWINGS LIGHT VERTICAL
    let l:fcs.stl = 'NONE'
    let l:fcs.stlnc = 'NONE'
    let &fillchars = UserFillchars(l:fcs)
endfunction

function! UserUiStatusLine(mode, bg) abort
    let l:mode = a:mode
    let l:bg = a:bg
    if l:bg ==# 'light' && and(l:mode, g:u.uiflags.blocky)  " blocky light
        " color 24's good.
        highlight StatusLine ctermfg=254 ctermbg=60 cterm=NONE guifg=#f3f3f3 guibg=#5a4f74 gui=NONE
        " prev: ctermfg 238, ctermbg 252 (grey82)
        highlight StatusLineNC ctermfg=254 ctermbg=96 cterm=NONE guifg=#f3f3f3 guibg=plum4 gui=NONE
    elseif l:bg ==# 'light' && and(l:mode, g:u.uiflags.thin)    " thin light
        " for fillchars-only mode - no background color
        highlight StatusLine ctermfg=60 ctermbg=NONE cterm=NONE guifg=#5a4f74 guibg=NONE gui=NONE
        highlight StatusLineNC ctermfg=96 ctermbg=NONE cterm=NONE guifg=plum4 guibg=NONE gui=NONE
    elseif l:bg ==# 'dark' && and(l:mode, g:u.uiflags.blocky)   " blocky dark
        " amber: #fc9505
        " firebrick4
        " guifg - use a fixed value so that Normal can be changed freely
        " 2024-04-15 was: ctermbg 24, guibg deepskyblue4
        "
        " 2024-06-09 set ctermfg to something light, for cases like the win32
        " con, where we might use vim with darkbg on a light term where fg text
        " is dark.
        highlight StatusLine ctermfg=7 ctermbg=52 cterm=NONE guifg=#f3f3f3 guibg=firebrick4 gui=NONE
        " grey27/#444444
        " 2024-04-15 was: ctermbg 95, guibg plum4
        highlight StatusLineNC ctermfg=NONE ctermbg=236 cterm=NONE guifg=#f3f3f3 guibg=grey20 gui=NONE
    elseif l:bg ==# 'dark' && and(l:mode, g:u.uiflags.thin)     " thin dark
        " for fillchars-only mode - no background color
        " ctermfg would be 52 to match blocky, but it's too illegible
        highlight StatusLine ctermfg=124 ctermbg=NONE cterm=NONE guifg=firebrick4 guibg=NONE gui=NONE
        highlight StatusLineNC ctermfg=236 ctermbg=NONE cterm=NONE guifg=grey20 guibg=NONE gui=NONE
    endif
endfunction


function! UserTerminalModeHighlight() abort
    if &background ==# 'dark'
        " Bright orange/amber - very visible for dark backgrounds
        highlight UserTerminalMode ctermfg=0 ctermbg=214 cterm=bold
                    \ guifg=#000000 guibg=#ffaf00 gui=bold
    else
        " Deep orange - very visible for light backgrounds
        highlight UserTerminalMode ctermfg=231 ctermbg=202 cterm=bold
                    \ guifg=#ffffff guibg=#ff5f00 gui=bold
    endif
endfunction


function! UserColours256()
    let g:colors_overridden = 0
    let l:bg = &background

    if UserCO(g:u.coflags.stat)
        call UserUiStatusLine(g:u.ui, l:bg)
        " make terminal statuslines the same as ordinary statuslines
        highlight StatusLineTerm NONE
        highlight! link StatusLineTerm StatusLine
        highlight StatusLineTermNC NONE
        highlight! link StatusLineTermNC StatusLineNC
    endif

    if UserCO(g:u.coflags.ui)
        " non-gui tty - don't override terminal (emulator) colours.
        highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE

        highlight Terminal NONE
        highlight! link Terminal Normal

        if !g:u.term_primitive && &fillchars =~# 'vert:' . nr2char(0x2502)
            " thin, BOX DRAWINGS LIGHT VERTICAL
            highlight VertSplit NONE
        else
            highlight VertSplit ctermbg=NONE guibg=NONE
        endif
    endif

    if l:bg ==# 'light'
        if UserCO(g:u.coflags.spell)
            highlight SpellBad
                        \ term=NONE
                        \ ctermfg=NONE ctermbg=254 cterm=NONE
                        \ guifg=fg guibg=grey91 gui=NONE guisp=NONE
        endif
        if UserCO(g:u.coflags.ui)
            "
            " ColorColumn azure2
            " CursorLine palegoldenrod
            "
            highlight NonText ctermfg=NONE ctermbg=7 guifg=#9fa7bd guibg=#dcdfe7
            highlight SpecialKey ctermfg=164 ctermbg=252
                        \ guifg=#aa336a guibg=#dcdfe7
            " guifg: pantone 19-4052 tcx classic blue
            highlight Normal guifg=#0f4c81 guibg=#f3f3f3
        endif
        highlight UserDateComment ctermfg=241 ctermbg=254
                    \ guifg=grey40 guibg=azure2 gui=italic
        "highlight UserHashTag ctermbg=194 guibg=#b9ebc4
        highlight UserHashTag ctermbg=152 guibg=#b0e0e6
        " trailing whitespace same as SpellBad
        highlight UserTrailingWhitespace ctermbg=254 guibg=grey91
    else    " background is dark
        if UserCO(g:u.coflags.spell)
            " 235 -> 238, for lighter dark bg #212121
            " blue black    #0a0a0f
            highlight SpellBad
                        \ term=NONE
                        \ ctermfg=NONE ctermbg=238 cterm=NONE
                        \ guifg=fg guibg=grey25 gui=NONE guisp=NONE
        endif
        if UserCO(g:u.coflags.ui)
            " similar to LineNr
            highlight NonText ctermfg=NONE ctermbg=238 guifg=#444b71 guibg=grey25
            highlight SpecialKey ctermfg=214 ctermbg=238 guifg=orange guibg=grey25
            " TODO Visual?
            highlight Normal guifg=#f3f3f3 guibg=#0a0a0f
        endif
        " amber
        highlight UserDateComment ctermfg=130 guifg=#ffb000 gui=italic
        highlight UserHashTag ctermbg=24 guibg=#005f5f
        " trailing whitespace same as SpellBad
        highlight UserTrailingWhitespace ctermbg=24 guibg=grey25
    endif

    highlight UserUnicodeWhitespace term=standout ctermbg=red guibg=orange

    " 2024-11-30 high-vis orange #ff7900 to firebrick3 #cd2626
    if UserCO(g:u.coflags.ui)
        highlight Cursor guifg=bg guibg=goldenrod gui=NONE
        " ?
        "call UserTerminalModeHighlight()
    endif

    let g:colors_overridden = 1
endfunction


" Meant to run after a colorscheme we like is loaded. Overrides highlights
" we don't agree with (StatusLine(NC), NonText, SpecialKey), defines good
" highlights in case the colorscheme file might not be available (Visual).
"
" mlterm starts with t_Co 8, later changes to 256.
function! UserColours() abort
    call UserLog('UserColours enter win', winnr())

    " 2023-07-01 our colorscheme overrides are now in an external colorscheme
    " file. overrides depend on the scheme, no point in keeping them in this
    " vimrc as long as we depend on another external file (the colorscheme)
    " anyway.

    " iceberg statusline colours in 256 mode suck. the StatusLine* and
    " SpellBad really should be here and not in an external colorscheme
    " wrapper.
    if UserCanLoadColorscheme()
        call UserColours256()
    endif

    " juse use tty defaults for the mode display - regardless of colorscheme
    highlight clear ModeMsg

    " define the highlight groups for our custom syntax items. these will get
    " cleared on colorscheme changes etc.
    call UserDefineSyntaxHighlightGroups()
endfunction

" set Normal colours for gui dark mode
command -bar Amber  highlight Normal guifg=#ffb000
command -bar Green  highlight Normal guibg=#41ff00


" define custom syntax items for things we want highlighted.
"
" we want these to run even when syntax highlighting is globally off.
function! UserApplySyntaxRules() abort
    let l:user_syntax = get(b:, 'user_syntax', 0)
    call UserLog('UserApplySyntaxRules enter win', winnr(), l:user_syntax)
    if &binary || l:user_syntax
        return
    endif
    " don't check for g:syntax_on; we want to work even if syntax is off.

    " no good way to check if just a syntax item's defined (hlID/hlexists pass
    " for either syntax item or highlight group). and execute()'s rather new.
    "
    " :filter doesn't work either - i.e. :filter /^User/ syntax list doesn't
    " exclude anything.
    "
    " we don't want to be too smart and keep any buffer-local var for this -
    " syntax items can get invalidated due to reasons like colorscheme
    " changes.
    "
    " 2024-06-30 listing syntax items and iterating can be expensive - f.ex. vim
    " syntax now loads lua, perl, python syntaxes. don't check all defined
    " syntax items anymore.

    " some or none of our custom syntax items are defined. clear and define
    " all of them.
    "
    " reason for syntax clear <name>: syntax item definitions are always
    " additive.
    "
    " we could wrap each of the definitions in an if has_key...
    "
    " 2025-04-08 do try buffer-local flag, to skip double work on BufWinEnter.

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
    syntax match UserHashTag /\v[⌽✚][_[:lower:][:upper:][:digit:]]{1,30}/
        \ display oneline containedin=ALLBUT,UserHashTag contains=@NoSpell

    " in single quotes, allow escaping anything - including single quotes
    " and tag-starting cross.
    " %() - non-capturing group.
    syntax match UserHashTag /\v[⌽✚]'%([^✚'\\]|\\.){-1,30}'/
        \ display oneline containedin=ALLBUT,UserHashTag contains=@NoSpell

    " ^ maybe - add contained matches to use @NoSpell when hashtags are
    " contained in other syntax items. but i usually don't use hashtags within
    " other syntax items.

    " make URIs effectively transparent; if contained, highlight like the
    " container. if at toplevel, highlight like the Normal hl group.
    " see hl definition of UserHttpURI.
    "
    " canary:
    "https://web.archive.org/web/20010301154434/http://www.vim.org/"
    if 0
        https://web.archive.org/web/20010301154434/http://www.vim.org/
    endif

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
    "
    " 2025-10-18 @ for mastodon
    " prev: [-\.[:alnum:]_~@%:/]*
    " now: [:@\-\._~!\$&'()\*\+,:=[:alnum:]/]*
    " https://stackoverflow.com/a/5914123
    " https://illegalargumentexception.blogspot.com/2009/12/java-safe-character-handling-and-url.html#URI2009_RESOURCES

    let l:uri_re = '\v<https?://'
    let l:uri_re .= '\w[-\.[:alnum:]]*\w%(:\d+)?'
    let l:uri_re .= '%(/[:@\-\._~!\$&''()\*\+,:=[:alnum:]/]*)?'
    let l:uri_re .= '%(\?[[:alnum:]!#$%&*+,\-\./:;<=>?@^_~]*)?'
    let l:uri_re .= '%(#[[:alnum:]!#$%&*+,\-\./:;<=>?@^_~]*)?>'
    " with delimiters for syntax match:
    let l:s = '=' . l:uri_re . '='

    syntax clear UserHttpURI
    " toplevel:
    execute 'syntax match UserHttpURI' l:s 'contains=@NoSpell'
    " contained in other syntax matches:
    execute 'syntax match UserHttpURI' l:s 'transparent contained containedin=ALLBUT,UserHttpURI contains=@NoSpell'

    let b:user_syntax = 1
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

    " urxvt/rxvt-unicode - specifying forground and background as a number sets
    " those numbers in the exported COLORFGBG env var.

    " 2023-11-20 when gvim is started when env var COLORFGBG is set, as in when
    " starting from a tty like konsole, that affects the gui instance's
    " background. unset COLORFGBG/COLORTERM and why not even TERM when starting
    " gvim.

    " enable termguicolors only if must - keep tgc off in ttys that support
    " indexed colors. tgc doesn't apply to the tty cursor.

    " always set after checking, to help ourselves later :verbose set bg?
    if !l:done && has('gui_running')
        " last resort; default: background=light - unless windows?
        if &background !=# 'light'
            set background=light
        endif
        let l:done = 1
    endif

    if !l:done && has('termguicolors')
        " 2025-02-10 recent versions of vim (patch 9.1.1054) do this.
        " recent versions of vim flip flop.
        if &term =~# '-direct$'
            " xterm-direct / tmux-direct
            if !&termguicolors
                set termguicolors
            endif
            let l:done = 1
        elseif has('vcon') && &term ==# 'win32'
            " contemporary conhost/wt seems to depend on desire for rgb colors?
            " t_Co stays at 256.
            "
            " with the right windows terminal settings about contrast/colours,
            " no need to force the background.
            "
            " 2026-01-22 windows terminal/settings/palettes aren't ready for
            " light bg. vim default's dark, not setting again.
            if exists('$WT_SESSION')
                set termguicolors
            endif
            let l:done = 1
        elseif &term =~# '.*kitty.*'
            " ain't gonna go editing config for the occasional run
            set background=dark termguicolors
            let l:done = 1
        endif
    endif

    if !l:done && exists('$COLORFGBG')
        " it's probably me
        let l:done = 1
    endif

    if has('ios')
        set background=dark
        let l:done = 1
    endif

    " could also enable tgc for PuTTY; PuTTY has support turned on by default.
    " but terminfo/termcap might not have caught up yet.
    "
    " PuTTY doesn't support OSC 11, vim doesn't define t_RB and defaults to
    " background=dark.

    " forcing t_Co to 16 in the linux console works, but not under screen.
    " unreliable.
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

    " control variable - assign default value
    let g:u.co = g:u.coflags.all
    " to use colorscheme's defaults for statusline:
    "let g:u.co = and(g:u.coflags.all, invert(g:u.coflags.stat))
endfunction

function! UserInitUiFlags() abort
    let g:u.uiflags = {}
    let g:u.uiflags.none =      0
    let g:u.uiflags.blocky =    1
    let g:u.uiflags.thin =      2

    let g:u.ui = g:u.uiflags.blocky
endfunction


" restore u.co to default behaviour
command -bar CoOverrideDefault  let g:u.co = g:u.coflags.all
" to not apply our highlights to the statusline, keep the highlights provided by
" a colorscheme.
command -bar CoTestStat     let g:u.co = and(g:u.coflags.all, invert(g:u.coflags.stat))


" bitwise check if a flag is set
function! UserCO(p)
    return and(g:u.co, a:p) == a:p
endfunction

function! UserCOAny()
    return g:u.co != g:u.coflags.none
endfunction

function! UserUiIsBlocky()
    return and(g:u.ui, g:u.uiflags.blocky)
endfunction

function! UserUiIsThin()
    return and(g:u.ui, g:u.uiflags.thin)
endfunction

" -- end colorscheme control


" workaround for old vims, f.ex. vintage rhel 7 vim 7.4 (2013, "Included
" patches: 1-207, 209-629"). setting the Normal highlight group can change
" 'background'. current iceberg.vim line 158 (the bg == dark branch hi Normal)
" triggers this. the kind of bug that makes you doubt your sanity.
"
" you can see this workaround in older colorschemes like zenburn and lucius
" - with or without comments, often setting 'background' unconditionally,
" causing some superfluous work in newer vim versions via autocmds.
"
" fixed in patch 8.0.0616. https://github.com/vim/vim/pull/1710
"
" thanks, LemonBoy.

if has('patch-8.0.0616')
    function! PushBg1710()
    endfunction

    function! PopBg1710()
    endfunction
else
    function! PushBg1710()
        let g:u.pre_background = &background
    endfunction

    function! PopBg1710()
        if &background !=# g:u.pre_background
            let &background = g:u.pre_background
        endif
    endfunction
endif

function! ColorScheme(name) abort
    call PushBg1710()

    call UserClearContentHighlights()
    call UserColoursFailsafe()
    try
        call ExecuteNomodifiable('colorscheme ' . a:name)
    finally
        call PopBg1710()
    endtry
endfunction

command -bar -nargs=1 -complete=color Colorscheme   call ColorScheme(<q-args>)


" syntax for text isn't worth the trouble but we like good UI colours. for
" non-xterm-direct terminals (VTE, kitty) it might be necessary to call
" UserColours() again after enabling termguicolors. do all the ui/content
" color changes and loading of a color scheme.

" other good: PaperColor?
"
" honorable mention:
"
"   monochromenote - https://github.com/koron/vim-monochromenote
"
" zenchrome (https://github.com/g0xA52A2A/zenchrome.vim/) is a nice,
" comprehensive framework; should integrate it into this vimrc someday.
function! UserLoadColors() abort

    " most colorschemes don't pull their own weight. would be great if a
    " colorscheme + reload behaviour would take a closure instead of requiring
    " a file on disk.  And seperate user interface component highlights from
    " text content highlights.

    try
        let l:candidates = []
        " doesn't care about colours
        if UserRuntimeHas('colors/tty.vim')
            call insert(l:candidates, 'tty')
            let l:colorscheme = l:candidates[0]
        endif
        if UserCanLoadColorscheme()
            " not including 'default'
            call insert(l:candidates, 'quiet')
            call insert(l:candidates, 'iceberg~')

            for l:candidate in l:candidates
                if UserRuntimeHas('colors/' . candidate . '.vim')
                    let l:colorscheme = l:candidate
                    break
                endif
            endfor
        endif
        if exists('l:colorscheme')
            call ColorScheme(l:colorscheme)
        endif
    catch /^Vim\%((\a\+)\)\=:E/
        if exists('g:colors_name')
            unlet g:colors_name
        endif
        call UserColoursTty()
        " throw doesn't do what i want; neither does throw 'x ' . v:exception
        echoerr v:exception
    finally
        " if no colorscheme found/loaded, the ColorScheme autocmd won't fire.
        " load our UI colour overrides.
        if !exists('g:colors_name')
            call UserColours()
        endif
    endtry
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
        if !bufloaded(l:bufnr) || bufwinnr(l:bufnr) == -1
            execute 'confirm bdelete' l:bufnr
        endif

        " other new-fangled ways to see if a buffer's visible in any windows:
        " getbufinfo(l:bufnr) -> <dict>.windows
        " win_findbuf(l:bufnr)
    else
        " no alternate buffer - open new empty buffer to keep the window from
        " closing
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
    let l:origin_buf_readonly = &readonly
    let l:origin_buf_modifiable = &modifiable
    setlocal readonly nomodifiable

    let l:v = UserRun(a:cmd)

    let &readonly = l:origin_buf_readonly
    let &modifiable = l:origin_buf_modifiable

    Scratch
    if exists('*win_getid')
        let l:winid = win_getid()
        "echom 'opened' l:winid
    else
        let l:winid = -1
    endif
    let l:close = 1
    try
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
        echomsg 'unexpected error' v:exception
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


" bufnr() / bufexists() lookup by name isn't great. using [] and fnameescape()
" is a world of annoyances, so not calling the buffer [Buffer List] like vile.
"
" 2023-08-31 empty 'bufhidden' should follow 'hidden', but setting bh seems
" needed, to prevent scratch buffers from getting saved by mksession.

function! UserPreviewBufferList() abort
    let l:bn = 'v_buffer_list'
    let l:lookupname = '^' . l:bn . '$'
    " if a regular buffer with the same name exists, don't thrash it.
    " getbufvar() always returns empty for unloaded buffers...
    let l:bufnr = bufnr(l:lookupname)
    if l:bufnr != -1 && bufloaded(l:bufnr) && getbufvar(l:bufnr, '&buftype') == ''
        echohl Error
        echomsg 'cannot modify regular buffer' l:bufnr
        echohl None
    endif

    " would be good if pedit could work with buffer numbers
    let l:p_opts = '+setlocal\ nobuflisted\ buftype=nofile\ bufhidden=unload\ noswapfile'
    let l:ls = split(UserRun('ls!'), "\n")
    execute 'pedit' l:p_opts l:bn
    wincmd P            " switch to preview window
    if &previewwindow
        " modify buffer in preview window
        setlocal modifiable
        " beware '--No lines in buffer--' message
        silent %d
        call append(0, l:ls)
        setlocal nomodifiable
        wincmd p        " switch out of preview window
    endif
endfunction

command -bar Ls     call UserPreviewBufferList()


" something like 'gf' but for any number that might be a buffer number
function UserGoBufCurs()
    let l:w = expand('<cword>')
    if l:w == ''
        return
    endif
    let l:numeric = matchstr(l:w, '\v<[1-9]\d*>')
    if l:numeric == ''
        return
    endif
    let l:bn = str2nr(l:numeric, 10)
    if l:bn < 1
        return
    endif
    if !bufexists(l:bn)
        return
    endif
    execute l:bn . 'b'
endfunction

nnoremap    gb      :call UserGoBufCurs()<cr>


" fun little hacks; show things defined by me, from my .vimrc / .gvimrc
" since these functions use currently loaded data, settings defined
" in .gvimrc won't be visible when queried under tty vim.
function! UserShowMaps()
    ScrEphem
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
    " hide mappings from system plugins like matchit. from all the lines that
    " have src =, delete lines where the filename doesn't start with ~.
    global/src =/global!/src = \~/d _
    " delete lines that don't refer to a vimrc/gvimrc at home.
    " 2022-08-22 actually it's useful to see all mappings.
    " replace <file> line <lineno> with something gF can jump to
    global/ line \(\d\+\)$/s//:\1/

    normal! gg

    setlocal readonly nomodifiable
endfunction

command MyMaps      silent call UserShowMaps()


function! UserShowCommands()
    ScrEphem
    call append(0, ['Commands', ''])
    put= UserRun('verbose command')
    global/\n\s\+Last set from/s//\t# src =/
    " select the lines that have an 'src =' but not our config file. this
    " preserves the header row (that's been generated by ':command'.) our config
    " = any line with "src = ~<non-whitespace>" + word boundary. should work
    " with windows/vimfiles too.
    global/src =/g!/src = \~\S\+\>/d _
    " enable going to location - replace "<file> line <lineno>" in the 'verbose'
    " output with <file>:<lineno>
    global/ line \(\d\+\)$/s//:\1/

    " ':command' output is already sorted. delete empty lines.
    global/^$/d _

    setlocal readonly nomodifiable
endfunction

command MyCommands  silent call UserShowCommands()


function! UserShowFunctions()
    ScrEphem
    call append(0, ['Functions', ''])
    put= UserRun('verbose function')
    global/\n\s\+Last set from/s//\t# src =/
    " remove lines where the src isn't in ~
    global/src =/g!/src = \~\S\+\>/d _
    global/ line \(\d\+\)$/s//:\1/
    global/^$/d _
    sort

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
    ScrEphem
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
" doc last-position-jump
"
" https://vim.fandom.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
"
" emacs: save-place-mode

function! UserLastPositionJump()
    " don't restore sometimes
    if &binary || (&filetype =~# '\vcommit|rebase|diff|xxd')
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
set spellcapcheck=

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


" -- end spelling configuration

" for disabling things that indent plugins do. overkill maybe. sometimes
" setting b:did_indent shows up as a solution, but indent.vim::s:LoadIndent()
" (filetype autocmd) resets it before loading indentation rules... and i don't
" want to maintain ~/.vim/indent/<filetype>.vim with b:did_indent = 1.

function! UserResetIndent()
    " could set to a function returning -1...
    let l:indentexpr = &indentexpr
    let l:indentkeys = &indentkeys
    let l:retval = []

    " indentexpr default's empty
    if l:indentexpr != ''
        let b:indentexpr_orig = l:indentexpr
        call add(l:retval, b:indentexpr_orig)
    endif

    " indentkeys default is not empty; so first we reset the options, and then
    " compare the current (default) value to what was there before. no way to
    " get the default value (not just the global value) of an option without
    " setting the option to default.

    setlocal indentexpr& indentkeys& lisp< autoindent<

    if l:indentexpr != '' && l:indentkeys != &indentkeys
        let b:indentkeys_orig = l:indentkeys
        call add(l:retval, b:indentkeys_orig)
    endif

    if exists('b:did_indent')
        unlet b:did_indent
    endif

    return l:retval
endfunction

command! -bar InDisable     call UserResetIndent()
command! -bar Sigh          InDisable | set syntax=OFF
command! -bar Nope          InDisable | set syntax=OFF
" this'll be a noop when $MYVIMDIR/indent/<filetype>.vim has b:did_indent = 1
command! -bar InEnable
            \ call ExecuteNomodifiable('runtime indent/' . &filetype . '.vim')

set sessionoptions-=curdir
set sessionoptions-=globals
set sessionoptions-=options
set sessionoptions-=resize
set sessionoptions-=terminal
set sessionoptions-=winpos
if v:version < 900
    " don't need complicated features with old vims.
    set sessionoptions-=folds
endif
" sesdir - only way to get vim to not save absolute paths to buffers;
" does save/do a "cd"; yucky.
set sessionoptions+=sesdir
set sessionoptions+=unix

set viewoptions-=curdir
set viewoptions-=options
set viewoptions+=unix


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
if 0 && exists('&t_TI') && exists('&t_TE') && has('unix')
    set t_TI= t_TE=
endif

" arrow keys are good, bill joy used arrow keys.
" use zz to recenter all the time

nnoremap        j       gj
nnoremap        k       gk
nnoremap        <Down>  gj
nnoremap        <Up>    gk
" for visual mode only, not visual line mode; shouldn't navigate in display line
" mode in visual line mode.
xnoremap    <expr>  j       mode() ==# 'v' ? 'gj' : 'j'
xnoremap    <expr>  k       mode() ==# 'v' ? 'gk' : 'k'
xnoremap    <expr>  <Down>  mode() ==# 'v' ? 'gj' : 'j'
xnoremap    <expr>  <Up>    mode() ==# 'v' ? 'gk' : 'k'
" insert mode, preserving menu key bindings -
" up and down should just be up and down if the popup menu's active.
inoremap    <silent> <expr>  <Down>  pumvisible() ? '<Down>' : '<C-o>gj'
inoremap    <silent> <expr>  <Up>    pumvisible() ? '<Up>'   : '<C-o>gk'

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
" UserShowHelp()'s too loud.
"
" the quiet alternative: <Nop>

nnoremap    <silent> <F1>      :echo UserBufferInfo()<CR>
" insert mode <F1> - don't change mode
inoremap    <silent> <F1>      <C-\><C-o>:echo UserBufferInfo()<CR>

" mnemonic: show buffer info
nnoremap    <Leader>i           :echo UserBufferInfo()<CR>


" for misconfigured virtual serial lines with putty. better to set
" TERM=putty-256color before starting (above mappings work then).

" quickly toggle spellcheck
" used to use F6 to toggle spell, but setl [no]spell is easier to remember.

" show all buffers in windows; was just thinking of fullscreen.
nnoremap        <F11>  :sball<cr>

" lots more modes... doc :noremap and doc xterm-function-keys

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
inoremap    .       .<C-g>u
inoremap    ;       ;<C-g>u

"" insert timestamp
"
" :put =<expr> is elegant, but working on the line below is disconcerting,
" because i usually care to ,dt on a new line.
"
" 0 - put comment text in expression register
" 1 - paste
" 2 - paste blackhole register below, creating new line
"
nnoremap        <silent> <Leader>dt "=UserDateTimeComment()<cr>p:put _<cr>

inoremap <expr> <silent> <Leader>dt "\<C-g>u" . UserDateTimeComment() . "\<C-g>u"

"" ,dt is too complicated when tired/sleepy.
nmap        <Leader>.      <Leader>dt
imap        <Leader>.      <Leader>dt

"" insert date
"" nnoremap        <silent> <Leader>dd :put=UserDate()<cr>
nnoremap        <silent> <Leader>dd "=UserDate()<cr>p:put _<cr>
inoremap <expr> <silent> <Leader>dd "\<C-g>u" . UserDate() . "\<C-g>u"
" so i can do :e f-<,dd> in the vim command window
cnoremap <expr> <Leader>dd              UserDate()
if has('terminal')
    tnoremap <expr> <Leader>dd              UserDate()
endif

nnoremap        <silent> <Leader>t      "=UserTimeShort()<cr>p:put _<cr>
inoremap <expr> <silent> <Leader>t      "\<C-g>u" . UserTimeShort() . "\<C-g>u"

nnoremap        <silent> <Leader>dT     "=UserDateTime()<cr>p:put _<cr>
inoremap <expr> <silent> <Leader>dT     "\<C-g>u" . UserDateTime() . "\<C-g>u"

nnoremap        <silent> <leader>dU     "=UserUtcNow()<cr>p:put _<cr>
inoremap <expr> <silent> <Leader>dU     "\<C-g>u" . UserUtcNow() . "\<C-g>u"

"" see also: insert mode, <C-r>=    doc i_CTRL-R

"" format paragraph with par(1) -  for justify
""      see also: plugin/justify.vim; doesn't seem as good as par.
""
"" mapping deciphered:
"" { - go to beginning of paragraph exclusive
"" !}par... - doc ! (https://vimhelp.org/change.txt.html#%21)
""      filter to end of paragraph
"" } - move to end of paragraph
"" http://www.softpanorama.org/Editors/Vimorama/vim_piping.shtml#Using_vi_as_a_simple_program_generator
"" http://www.nicemice.net/par/par-doc.var
"
" 2024-12-30 {!} (start with exclusive mothin) somehow knows that the first
" empty line in range - the paragraph separator - should be preserved? this
" breaks when the same thing is attempted with seperate :d and :p.
"
"nnoremap        <Leader>j     {!}/usr/bin/par 78<cr>}
"
" export current textwidth or default 78 with an expression register
" substitution
"nnoremap    <Leader>j {!}/usr/bin/par w<C-r>=(&tw == 0 ? 78 : &tw)<CR> j<CR>
"
" use Filter. <bs> to remove the ! inserted by vim
"
" opensuse package par is parity archiver, and exits with ok status on unknown
" arguments like w78. par formatter package is par_text.
"
"" mapping deciphered:
"" { - go to beginning of paragraph exclusive
"" j - back into paragraph (like vip)
"" !} - fills in line range in the command window
"" Filter...<CR>
"" } - move to end of paragraph

nnoremap    <Leader>j {j!}<BS>call Filter('par w' . (&tw == 0 ? 78 : &tw))<CR>}

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

function! UserGetClipboardStrategy(...) abort
    let l:result = {}
    if has('win32')
        let l:result = { 'mode': 'native', 'reg': '+' }
    elseif has('gui_running') && !exists('$GVIM_ENABLE_WAYLAND')
        if !empty(a:000) && a:1 ==# 'PRIMARY'
            let l:result = { 'mode': 'native', 'reg': '*' }
        else
            let l:result = { 'mode': 'native', 'reg': '+' }
        endif
    elseif exists('$WAYLAND_DISPLAY')
        " 2024-10-23 "* / "+ don't work with wayland yet
        let l:result = { 'mode': 'cmd', 'reg': 'w',
                    \ 'read_cmd': '/usr/bin/wl-paste --no-newline',
                    \ 'write_cmd': '/usr/bin/wl-copy'
                    \ }
    elseif exists('$DISPLAY')
        if !empty(a:000) && a:1 ==# 'PRIMARY'
            let l:result = { 'mode': 'cmd', 'reg': 'w',
                        \ 'read_cmd': '/usr/bin/xsel -p -o',
                        \ 'write_cmd': '/usr/bin/xsel -p -i'
                        \ }
        else
            let l:result = { 'mode': 'cmd', 'reg': 'w',
                        \ 'read_cmd': '/usr/bin/xsel -b -o',
                        \ 'write_cmd': '/usr/bin/xsel -b -i'
                        \ }
        endif
    else
        let l:result = { 'mode': 'native', 'reg': 'w' }
    endif
    return l:result
endfunction

" takes a register name, returns the same register name or _, the black hole
" register
function! UserGetClearedReg(reg) abort
    try
        " clear register
        call setreg(a:reg, [])
        return a:reg
    catch /^Vim\%((\a\+)\)\=:E730:/
        " just for vim7 (< patch-7.4.243?) - no way to unset a register in a way
        " that reading the register would raise E353: Nothing in register x.
        return '_'
    endtry
endfunction


function! UserReadClipboard(...) abort
    let l:st = call('UserGetClipboardStrategy', a:000)
    let l:result = {}

    if l:st.mode ==# 'native'
        let l:result = { 'reg': l:st.reg, 'status': 0 }
    elseif l:st.mode ==# 'cmd'
        let l:cmd = l:st.read_cmd
        silent let l:clp = system(l:cmd)
        let l:shell_error = v:shell_error
        if l:shell_error
            echohl WarningMsg
            echomsg 'clipboard: ' . l:cmd . ' failed, status ' . l:shell_error
            echohl None

            let l:clear_reg = UserGetClearedReg(l:st.reg)
            let l:result = { 'reg': l:clear_reg, 'status': l:shell_error }
        else
            if !empty(l:clp)
                call setreg(l:st.reg, l:clp)
                let l:result = { 'reg': l:st.reg, 'status': 0 }
            else
                " empty clipboard
                let l:clear_reg = UserGetClearedReg(l:st.reg)
                let l:result = { 'reg': l:clear_reg, 'status': 0 }
            endif
        endif
    else
        echohl WarningMsg
        echomsg 'do not know how to paste'
        echohl None

        let l:result = { 'reg': '_', 'status': -1 }
    endif

    " mode() isn't very reliable, can't be used here to made decisions on
    " linewise register mode vs. charwise, when the function might be called in
    " insert-normal mode.

    return l:result
endfunction

function! UserWriteClipboard(txt, ...) abort
    if empty(a:txt)
        return
    endif

    let l:st = call('UserGetClipboardStrategy', a:000)
    if l:st.mode ==# 'native'
        call setreg(l:st.reg, a:txt)
    elseif l:st.mode ==# 'cmd'
        let l:cmd = l:st.write_cmd
        silent call system(l:cmd, a:txt)
        let l:shell_error = v:shell_error
        if l:shell_error
            echohl WarningMsg
            echomsg 'clipboard: ' . l:cmd . ' failed, status ' . l:shell_error
            echohl None
        endif
    else
        echohl WarningMsg
        echomsg "do not know how to yank"
        echohl None
    endif
endfunction

" used for copying the current command line to the clipboard. requires a
" c_CTRL-\_e mapping - this function gets the current command line, copies it
" to the clipboard, and returns the command line unchanged, so that the C-\ e
" mapping changes nothing.
"
" swallows errors.

function! UserTeeCmdLineCb() abort
    let l:cmdl = getcmdline()
    silent call UserWriteClipboard(l:cmdl)
    return l:cmdl
endfunction

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

" wretched - with virtualedit=all like in paste.vim, "gp" is no good.
" - virtualedit creates a space and 'gp' puts after that.
"
" if beginning/middle of line - put text before cursor. feels natural.
"
" if at end of line or beginning of empty line - put text after cursor. test:
" multiple consecutive pastes.
"
" 2024-03-01 the above isn't great - you really always want text to go before
" (gP). f.ex. in insert mode.. ? you've just typed a pair of delimiters and want
" to paste in the middle. gP with virtualedit-onemore.

"function! UserPasteExpr()
"    return 'gP'
"    " return &ve == 'all' ? 'gP' : col('.') == col('$') - 1 ? 'gp' : 'gP'
"endfunction

" a little helper for tty + xsel
function! UserReadCbRetExpr(p_opt, ...) abort
    let l:clp = call('UserReadClipboard', a:000)
    " the following makes an expression like: "<reg>gp
    let l:expr = '"' . l:clp.reg . a:p_opt
    return l:expr
endfunction

" for insert-normal mode; if the clipboard register's in line mode, paste-before
" will put the clipboard text before the current line, no matter where the
" cursor is. this is jarring in insert mode. take the clipboard text and force
" it into a register in linewise mode.
function! UserReadCbCharacterwiseRetExpr(p_opt, ...) abort
    let l:clp = call('UserReadClipboard', a:000)
    if getregtype(l:clp.reg) ==# 'V'
        " source register is linewise, convert - append nothing, change type
        "call setreg(l:clp.reg, '', 'av')
        call setreg(l:clp.reg, trim(getreg(l:clp.reg), "\r", 2), 'v')
    endif
    return '"' . l:clp.reg . a:p_opt
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

" normal mode paste - read from clipboard and wait for the next
" p/P/gp/gP. Of course it might be anything, like c or x..
"
" 2024-03-07 gp/gP's too long. add explicit mappings, always g.
"

nnoremap    <expr>  <Leader>r   UserReadCbRetExpr('gp', 'PRIMARY')
nnoremap    <expr>  <Leader>R   UserReadCbRetExpr('gP', 'PRIMARY')
nnoremap    <expr>  <Leader>p   UserReadCbRetExpr("gp")
nnoremap    <expr>  <Leader>P   UserReadCbRetExpr("gP")

" visual mode paste - never needed it.

" command mode paste - dangerous, but tty mappings and <C-r>+ etc. work anyway.
" defined for completeness and consistency.
"
" cannot be a silent mapping.
"
" literal insert - doc: c_CTRL-R_CTRL-R

" insert under the cursor, pushing what was under cursor to the right
cnoremap    <expr>  <Leader>P   "\<C-r>\<C-r>" . UserReadClipboard().reg
cmap                <Leader>p   <Right><Leader>P

cnoremap            <Leader>y   <C-\>eUserTeeCmdLineCb()<cr>

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
"nnoremap    <Leader>y       m`^vg_"wy``:call UserWriteClipboard(@w)<CR>
"
" without visual mode:
"   m` - set previous context mark,
"   ^ - go to first non-blank char,
"   "wyg_ - to register w, yank until last non-blank char
"   `` - jump back
nnoremap    <silent> <Leader>y       m`^"wyg_``:call UserWriteClipboard(@w)<CR>
xnoremap    <silent> <Leader>y       m`"wy``:call UserWriteClipboard(@w)<CR>

"
" insert-mode paste / insert-paste
"
"imap        <Leader>p       <C-\><C-o><Leader>p
"imap        <Leader>P       <C-\><C-o><Leader>P
"
" 2024-12-25 going to normal mode and pasting is bad when the clipboard register
" is linewise - the pasted text will end up in a line above the current line, no
" matter where the cursor is.
"
" test: <abc def >, paste text ending with newlines when cursor is at end of
" line/on d (paste before, paste after)
"inoremap    <expr> <Leader>z    "\<C-\>\<C-o>" . UserReadCbCharacterwiseRetExpr("gp")

"
" echo -ne 'xkc\n' | xsel -i -b
"
" printf '[abc\n\txy^H!z\n\t\tpqr]\n' | xsel -i -b
"
" 2025-02-11 why did i revert from C-r C-r ? just because of the text length? let's try.
" 2025-02-27 switch to non-indenting paste. indenting doesn't work well often anyway.
" 2025-04-24 C-r C-o pasts above with the reg is linewise; back to C-r C-r
"inoremap    <expr>  <Leader>p   "\<C-g>u\<C-r>\<C-r>" . UserReadClipboard().reg
"inoremap    <expr>  <Leader>P   "\<C-g>u\<C-r>\<C-p>" . UserReadClipboard().reg
"
" 2025-04-29
"
"   1 - new undo point
"   2 - insert-normal
"   3 - set paste, back to insert mode
"   4 - insert register
"   5 - insert-normal
"   6 - set nopaste, back to insert mode

function! UserPasteInsertMode(insp, pastemode) abort
    let reg = UserReadClipboard().reg
    let expr = "\<C-g>u"
    if (a:pastemode)
        let expr .= "\<C-\>\<C-o>:set paste\<CR>"
    endif
    let expr .= a:insp . reg
    if (a:pastemode)
        let expr .= "\<C-\>\<C-o>:set nopaste\<CR>"
    endif
    return expr
endfunction

inoremap    <expr>  <Leader>p   UserPasteInsertMode("<C-r><C-r>", 1)
inoremap    <expr>  <Leader>q   UserPasteInsertMode("<C-r><C-r>", 0)
inoremap    <expr>  <Leader>r   UserPasteInsertMode("<C-r><C-p>", 0)

" both C-r C-o and C-r C-p have 'P'-like linewise-insert-above behaviour.
inoremap    <expr>  <Leader>P   UserPasteInsertMode("<C-r><C-p>", 1)

if exists('+pastetoggle')
    set pastetoggle=<F2>
endif


if has('gui_running') || has('win32')

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

    nmap    <S-Insert>      <Leader>P
    imap    <S-Insert>      <Leader>p
    cmap    <S-Insert>      <Leader>P
    nmap    <S-kInsert>     <Leader>P
    imap    <S-kInsert>     <Leader>p
    cmap    <S-kInsert>     <Leader>P
    nmap    <C-S-v>         <Leader>P
    imap    <C-S-v>         <Leader>p
    cmap    <C-S-v>         <Leader>P

    nmap    <C-Insert>      <Leader>y
    xmap    <C-Insert>      <Leader>y
    cmap    <C-Insert>      <Leader>y
    nmap    <C-kInsert>     <Leader>y
    xmap    <C-kInsert>     <Leader>y
    cmap    <C-kInsert>     <Leader>y
    nmap    <C-S-c>         <Leader>y
    xmap    <C-S-c>         <Leader>y

    " no C-c / C-S-c for the command window.
endif

" copy the contents of double-quoted strings
nmap    <Leader>"   vi"<Leader>y

function! UserPutClipboard(bang, ...) abort
    let l:clp = call('UserReadClipboard', a:000)
    " skip the :put if reg has no content/clipboard is empty -
    " don't create empty lines.
    if l:clp.status == 0 && l:clp.reg !=# '_'
        execute 'put' . a:bang l:clp.reg
    endif
endfunction

" <bang> in quotes - should expand to either "" or "!"
command -bang RDPR  call UserPutClipboard("<bang>", 'PRIMARY')
command -bang RDCB  call UserPutClipboard("<bang>")

command -bar -range Yank    <line1>,<line2>y w

command -range WRPR <line1>,<line2>Yank | call UserWriteClipboard(@w, 'PRIMARY')
command -range WRCB <line1>,<line2>Yank | call UserWriteClipboard(@w)

" visually select the last modified (including pasted) text
" for getpos, ' works: getpos("'["), getpos("']")
" 2025-03-23 why was this commented out
nnoremap    <Leader>M      `[v`]

" url paste adapter - if pasting a url, often it's convenient to treat
" it in line mode - repeated pastes etc. but urls copied from browsers
" or mobile apps don't end with a newline, and the type of "+/"* remains
" c(haracterwise). this function can sometimes help with that.
"
" maybe: redo as a filter called inside UserGetCbReg().

function! UserUrlPasteMunge() abort
    try
        RDCB
    catch /^Vim\%((\a\+)\)\=:E353:/
        echom 'nothing in clipboard'
        return
    endtry

    "echom getpos("'[") getpos("']")
    let l:lineno = line('.')
    let l:urlpos = searchpos('\vhttps?://\S+', 'cnW', l:lineno)
    let l:selstart = l:urlpos[1]
    if l:urlpos[0] == l:lineno
        " twitter: s=, meta/facebook threads: xmt=
        if search('\v//%(x|twitter|www\.%(threads|instagram))\.com/.*\?', 'cnW', l:lineno) == l:lineno
            " to last char of changed text
            normal! `]
            let l:pos_change_end = getpos(".")

            " move backwards, count, delete forward.
            normal! F?
            let l:url_qm_char_col = col('.')
            let l:ln = getline(l:lineno)
            let l:text_before_qm = strpart(l:ln, 0, l:url_qm_char_col - 1)
            let l:text_after_change_end = strpart(l:ln, l:pos_change_end[2])
            let l:text_without_qp = l:text_before_qm . l:text_after_change_end
            if len(l:text_without_qp) != len(l:ln)
                call setline(l:lineno, l:text_without_qp)
                " rewind change-end mark, exclude deleted text
                let l:pos_change_end[2] = l:url_qm_char_col - 1
                call setpos("']", l:pos_change_end)
                " move to beginning of changed text
                normal! '[
            endif
        endif
        " url quoting:
        "
        " column offsets in line
        let l:selend = getpos("']")[2]
        let l:ln = getline('.')
        let l:sel = strpart(l:ln, l:selstart - 1, l:selend - l:selstart + 1)
        " check for chars: !"#$%&'()*;<>?[\]`{|}
        if l:sel =~# '\v[\x21-\x2a\x3b\x3c\x3e\x3f\x5b-\x5d\x60\x7b-\x7d]'
            let l:quote_start = '"'
            let l:quote_end = '"'
            " check for chars: "$
            if l:ln =~# '\v[\x22\x24]'
                " to be shell-safe, would have to escape raw $ and raw double
                " quotes, but we shouldn't manipulate the line. giving up.
                " save me ruby delimited strings...
                " %q() - no interpolation, parens in string don't need escaping.
                " %q( !#$%&'()*;<>?[\]`{|}"$) -> " !\#$%&'()*;<>?[\\]`{|}\"$"
                "
                " alt - raku ｢｣/Q[]
                " alt - zsh quote-line/quote-region
                let l:quote_start = '%q('
                let l:quote_end = ')'
            endif
            " splice string without going into insert mode (that changes marks)
            let l:prefix = strpart(l:ln, 0, l:selstart - 1)
            let l:suffix = strpart(l:ln, l:selend - l:selstart + 1)
            let l:quoted = l:prefix . l:quote_start . l:sel . l:quote_end . l:suffix
            call setline(l:lineno, l:quoted)
        endif
    endif
endfunction

function! UserUrlPasteAndUpdate() abort
    call UserUrlPasteMunge()
    if bufname('%') !=# '' && &buftype ==# ''
        " preserve '[ and '] marks through the buffer write. someday lockmarks?
        let l:s = getpos("'[")
        let l:e = getpos("']")
        silent update
        call setpos("'[", l:s)
        call setpos("']", l:e)
    endif
endfunction

" mapping to url-paste regardless of filetype
nnoremap    <silent>    <Leader>u :call UserUrlPasteAndUpdate()<CR>

" 2025-06-16
" 1 undo break
" 2 insert-normal paste url
" ! insert-normal silent update slow if no filename
inoremap    <silent>    <Leader>u <C-g>u<C-o>:call UserUrlPasteAndUpdate()<CR>

function! UserAddUrlPasteMapping() abort
    nnoremap <buffer> <silent> q    :call UserUrlPasteAndUpdate()<CR>
endfunction

command! -bar MapQ      call UserAddUrlPasteMapping()


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
" U+238D - Monostable symbol from Miscellaneous Technical
"
" 0x1F7A3 MEDIUM GREEK CROSS - too many bytes, not widely available in fonts

let Symbols = {
    \ 'silcrow':        nr2char(0xA7)
    \ ,'not':           nr2char(0xAC)
    \ ,'interpunct':    nr2char(0xB7)
    \ ,'en dash':       nr2char(0x2013)
    \ ,'em dash':       nr2char(0x2014)
    \ ,'dagger':        nr2char(0x2020)
    \ ,'circle stile':  nr2char(0x233D)
    \ ,'angzarr':       nr2char(0x237C)
    \ ,'lozenge':       nr2char(0x25CA)
    \ ,'bourbaki bend':         nr2char(0x2621)
    \ ,'greek cross, heavy':    nr2char(0x271A)
    \ ,'brkt left corner':      nr2char(0xFF62)
    \ ,'brkt right corner':     nr2char(0xFF63)
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
"
" mapmode-ic
noremap!    <expr> <Leader><Leader>   Symbols['circle stile']
" mapmode-t
if has('terminal')
    tnoremap    <expr> <Leader><Leader>   Symbols['circle stile']
endif

" abbreviations aren't so useful in such cases, they expand after whitespace.

" prevent accidental nbsp entry; using 'execute' for mapping whitespace
execute "inoremap \u00A0 <Space>"

" use 's' for window commands instead of the default emacs-ness.
nmap            s           <C-w>

" C-w o / :only is a pain because it closes windows, can't go back to the
" previous layout. instead, lean on tab pages.
"
" Mnemonic: split current buffer, but in new tab page.
"
" can't use the current buffer number in a command definition?
"
" sbuffer always reuses existing windows/tab pages.
command -bar -count=0 BufTab
            \ if <count> == 0 || <count> == bufnr('%') | tab split
            \ | else | tab <count>sbuffer
            \ | endif

" unconditinal new tab page
command         BufNewTab   tab split

nnoremap        <C-w>o      :BufTab<CR>

" for keys like C-wf (doc CTRL-W_f), there's no option to make the split
" vertical by default. We make do with this:
nnoremap    <Leader>vf  <C-w>f<C-w>L

" WIP mapping to open files; meant to work under just two windows:
" one window with a list of filenames.
nnoremap    <Leader>se  :let f = expand('<cfile>')<cr><C-w>w:execute('edit ' . f)<cr>

" M.G. - guu/gugu - lower line, u - visual, gu{motion}
" gu in paragraph
nnoremap    <Leader>mg      guip
nnoremap    <Leader>l       guip
" U for uppercase, u for not-U
xnoremap    <Leader>mg      u
xnoremap    <Leader>l       u

" mainly for iVim. the changing of the modified flag in the statusline is
" indication enough.
nnoremap    <silent> <Leader>;;      :silent update<cr>

" open the command window with ,f in the command line
" (the cnoremap's bad if you end up typing ,full etc.)
"cnoremap    <expr>  <Leader>f    &cedit
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
" 2024-06-09 mapping for pasting now limited by filetype.
nnoremap    q   :echo 'Temper temper / mon capitaine.'<CR>
" -- end q-mappings adventure.

" never used the tagstack. sometimes due to window focus i end up hitting
" new-tab C-t in vim. we could conditionally enable it for help buffers and
" anything else with tags by checking taglist('.') BufRead[Post]. Maybe later.

if g:u.term_primitive
    nnoremap    <C-t>           <nop>
    nnoremap    <C-LeftMouse>   <nop>
else
    " on-site cat: https://jijitanblog.com/construction/genbaneko-matome/
    nnoremap    <C-t>           :echo 'ヨシ！'<cr>
    nnoremap    <C-LeftMouse>   :echo 'ヨシ！'<cr>
endif
"imap <C-t> <Esc><C-t> -- insert shiftwidth at start, useful
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
nnoremap    <silent> <Leader>n   :call UserLineNumberSwitch()<CR>

nnoremap    <Leader>c       :let &cursorcolumn = !&cursorcolumn<CR>

" quick toggle laststatus between 1 and 2
" nnoremap    <silent> <Leader>t :let &laststatus = (&laststatus % 2) + 1<CR>

" nosleep
nnoremap    gs      <nop>

" demo - for searching with strings with f.ex. many forward slashes;
" use :g with a non-/ delimiter, and : (null ex command).
nnoremap    <Leader>/   :global ==:<Left><Left>

" too dangerous when drunk; just use :undo; or g-/g+.
" 'c' is equally dangerous. just try to deal with u and c.
" nnoremap    u       <nop>

" not to self - put the last yank, not from the unnamed register
nnoremap    <C-p>   "0p

nnoremap    <silent> <C-s>  :silent wall<CR>
" ctrl-s in insert mode - go to normal mode; it's a small break.
inoremap    <silent> <C-s>  <Esc>:silent wall<CR>

" mapping to wrap current word in ksh88 array expansion syntax.
" https://unix.stackexchange.com/a/382964
"
" vim doesn't have a good way to go to the beginning of the current word without
" jumping to other words, including when the word is only a single char. 'yiw'
" has the right behaviour as a side-effect. 'w' and 'e' are a lot.

" nnoremap    <silent>    <Leader>w   :call search('\<', 'bcW', line('.'))<CR>

" must run on an actual word, doesn't work without one. 'e'/'E' can silently
" fail and abort the rest of the mapping.

" mnemonic: gxk -> g expand korn
"nnoremap        gxk     viwo<Esc>i"${<Esc>ea[@]}"<Esc>
"
" "_yiw - yank current word to black hole register, cursor ends up on beginning
" of word
nnoremap        gxk     "_yiwi"${<Esc>ea[@]}"<Esc>

" https://www.reddit.com/r/vim/comments/4aab93/comment/d0z0kyj/
"
" preserving @/ (search reg) is messy here, but not restoring "/ means you can
" use 'n'; go to visual mode and n n n f.ex.
"
" instead, we remove \<\h from the search history the next time we do a search
" (including use of this very mapping).
"
" modifying iskeyword doesn't help; 'w' still considers empty lines.
"
" \h doesn't work for japanese etc., of course. but 'w' by default does. our
" mapping searches for any except whitespace+digits+punctuation.

let epic_w = '\<[^[:space:][:digit:][:punct:]]'
nnoremap    <silent> <expr> t      '/' . epic_w . '<CR>'
nnoremap    <silent> <expr> T      '?' . epic_w . '<CR>'
xnoremap    <silent> <expr> t      '/' . epic_w . '<CR>'
xnoremap    <silent> <expr> T      '?' . epic_w . '<CR>'

command     FixSearchHistory    call histdel('/', escape(epic_w, '\[]'))

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

" for testing colours
cnoreabbrev histl   highlight StatusLine
cnoreabbrev hisnc   highlight StatusLineNC

if has('terminal')
    " mapping to go to terminal-normal mode;
    " mnemonic: tty flow control
    tnoremap    <C-s>   <C-w>N
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

" completion - only use current buffer + other windows, not includes etc.
set complete=.,w

set completeopt=menu,menuone    " maybe: popup/preview
if v:version >= 801
    set completeopt+=noinsert
endif

" ----

" tab settings
"
" https://ericasadun.com/2016/03/31/swift-style-are-you-a-4-denter/
"
" http://www.opimedia.be/DS/languages/tabs-vs-spaces/
"
" important to fix 'tabstop' - some misguided ftplugins like python and rust
" have the temerity to change it. (rg '\btabstop=[0-79]')
"
" some ftplugins (scala, ada) are really good. make.vim even disables expandtab
" and doesn't mess with tabstop.

command -bar -nargs=1 SoftIndent setlocal
            \ nosmartindent
            \ tabstop=8 softtabstop=<args> shiftwidth=<args> expandtab
            \ list

command -bar HardIndent setlocal
            \ nosmartindent
            \ tabstop=8 softtabstop=8 shiftwidth=8 noexpandtab
            \ nolist

" Unix (drank the 80's soda); editable with ed.
command -bar Proper     HardIndent
command -bar Lousy      SoftIndent 4
command -bar Lisp       SoftIndent 2
" shift by 4 spaces, with hard tabs
command -bar T4x4       SoftIndent 4 | setlocal noexpandtab
command -bar In2        SoftIndent 2

" rtfm'ed - :retab! uses % as the range by default.

" spelling: probably better to switch to native aspell and dict-gcide
"   (GNU Collaborative International Dictionary of English)

" NB: autoindent affects fo-at
"
" for plain text - clear default comment options for plain text. the default
" 'com' fb:- can cause autoformatting fo-a with fo-q to insert unwanted spaces,
" if the line above happens to start with '- ' -- false positive comment
" recognition. also disable comment handling in formatoptions.
"
" fo-n (numbered list match) and formatlistpat can also cause trouble. it
" mismatches timestamps like 23:00 at the beginning of a line.

command -bar FoText  setlocal
            \ autoindent nosmartindent nocindent formatoptions<
            \ comments= commentstring= formatlistpat=
            \ nojoinspaces
            \ | setlocal formatoptions-=c
            \ | setlocal formatoptions-=n
            \ | setlocal formatoptions-=q
            \ | silent! setlocal formatoptions-=p

" for prose
command -bar Wr     FoText | setlocal textwidth=80 formatoptions+=a spell
            \ indentexpr=UserTextIndent()

" for double-spaced prose; fo-p since patch 8.1.0728.
" joinspaces is a global option for some reason.
command -bar Wr2    Wr | setlocal formatoptions+=p joinspaces

command -bar Nowr    setlocal
            \ autoindent nosmartindent nocindent formatoptions< nospell
            \ indentexpr< nojoinspaces

command -bar FoCode  setlocal
            \ autoindent nosmartindent cindent formatoptions< nospell
            \ nojoinspaces


" WIP - 2nd line in buffer or paragraph - no indentation (don't follow the
" first line's indentation). ending up on column 1, it's easier to indent than
" to unindent. but only on one level of indent, a small number of spaces <= 4.
function! UserTextIndent()
    let l:lnk2 = v:lnum - 2
    let l:lnk1 = v:lnum - 1
    if v:lnum >= 2 && empty(getline(l:lnk2))
        let l:lnk1ind = indent(l:lnk1)
        if l:lnk1ind > 0 && l:lnk1ind <= 4
            return 0
        endif
    endif

    " default: autoindent
    return -1
endfunction


" for small screens (iVim) - iPhone 15 Pro Max, Menlo:h11.0
command -bar Mobile  Wr | setlocal textwidth=70 nonumber norelativenumber

" for transcribing poetry -
" significant whitespace, auto-indenting, no hard tabs, no auto formatting
" remember - delete to beginning of line: 0d (V), Ctrl-U (I);
"   Ctrl-U is readline unix-line-discard.
" set colorcolumn=16,32,48,64,80,96 might also help.
command -bar Poetry  Lousy | setlocal tw=0 formatoptions-=ta ai nospell


command -bar ShowBreak       let &showbreak = g:u.showbreak_char
" vim 8.0 doesn't support NONE (showbreak gets set to "NONE")
command -bar NoShowBreak     set showbreak=


" helper for when a 'syntax off' -> 'syntax enable' wipes out our rules. and,
" we want our syntax rules enabled even in empty buffers or plain text files,
" where the Syntax autocommand won't fire.
command -bar SynEnableGlobal    syntax enable | call UserApplySyntaxRules()
command -bar SynDisableGlobal   syntax off | silent! unlet b:current_syntax | silent! unlet g:syntax_on
command -bar SynSync            syntax sync fromstart
" turn off syntax for buffer, not globally; similar to :ownsyntax NONE?
" set syntax=OFF (and =ON)
" NB: clears our User* syntax items.
" synload.vim SynSet() handles setting 'syntax' to &filetype
" remember: https://vimhelp.org/usr_44.txt.html#44.10
"   :syntax sync minlines=100
" also remember: doautocmd Syntax

command! -bar SynLoad
            \ call ExecuteNomodifiable('runtime syntax/' . &filetype . '.vim')

command! -bar Enable3   if &filetype !=# ''
            \ | InEnable
            \ | SynLoad
            \ | endif

" mnemonic to open all folds in buffer
command -bar Unfold         normal! zR

command -nargs=1 Ch         set cmdheight=<args>

" query or set textwidth; if value given, set. always show.
command -bar -nargs=?   Tw  if !empty(<q-args>)
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

command Info        call UserShowHelp()
command TermBad     call UserTermBad()
command TermSlow    call UserTermSlow()

command -bar Stws        call UserStripTrailingWhitespace()

" new window for scribbling
" possible alternative - preview windows (:pedit); seems more limited.
" doc scratch-buffer
command -bar Scratch    new
            \ | setlocal buftype=nofile bufhidden=hide noswapfile
            \ | setfiletype text
command -bar ScrEphem   Scratch | setlocal bufhidden=unload

" pretty-print g:u
command -bar PrintU ScrEphem | put =json_encode(g:u) | .Filter jq --sort-keys .

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
endfunction

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
        echohl WarningMsg
        echomsg 'file(1) failed, status ' . v:shell_error
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

" decent alternative to autochdir
command CdBuffer   lcd %:h


" -- comment/uncomment by line range
function UserGetCommentString(cms) abort
    let cms = a:cms
    if empty(cms)
        echom '(no commentstring)'
        return []
    endif
    let cms_parts = split(cms, '%s')    " keep any surrounding spaces
    if len(cms_parts) == 1
        call add(cms_parts, '')
    endif
    if len(cms_parts) != 2
        echom '(invalid commentstring)'
        return []
    endif
    return cms_parts
endfunction

" could be nice to actually printf() with the cms as the format string the way
" comment.vim does, but then have to gather the lines in memory and put them
" back.
"
" comment.vim explainer:
"
"   substitute(cms, '%s\@!', '%%', 'g') - %-escape. replace any % signs that are
"   not %s with %% - for later use with printf().
"
" silly to reuse possibly block comments line by line, but it is more flexible
" when hacking.

function! UserDoComment() range abort
    let cms = UserGetCommentString(&commentstring)
    if empty(cms) | return | endif
    " put comment strings after leading whitespace and before trailing
    " whitespace.
    "
    " pick lines that have anything other than whitespace,
    " and don't have cms-1.
    let cmd = printf('%d,%d'
                \ . 'global!/^\s*%s/'
                \ . 'substitute/^\s*\zs\(.\+\)\ze/%s\1%s/',
                \ a:firstline, a:lastline, escape(cms[0], '/!\\*.'),
                \ escape(cms[0], '/'), escape(cms[1], '/'))
    " silent to hide the N substitutions on N lines msg
    silent execute cmd
endfunction

function! UserUnComment() range abort
    let cms = UserGetCommentString(&commentstring)
    if empty(cms) | return | endif
    " anchoring to the beginning-of-line and end-of-line (cms-1, if present) has
    " the effect of removing one commenting level at a time (also for non-block
    " comments.)
    let s = '^\s*\zs' . escape(cms[0], '/!\\*.')
    " regexp or - only use if cms-1 is not the empty string
    if !empty(cms[1])
        let s = s . '\|' . escape(cms[1], '/!\\*.') . '$'
    endif
    " /e - don't raise error if search pattern not found; doc :s-flags
    let cmd = printf('%d,%dsubstitute/%s//ge', a:firstline, a:lastline, s)
    silent execute cmd
endfunction

" command -range CommentOnce  <line1>,<line2>g/^\s*[^#]/s/^/# / | let @/ = ''
" put # just before the first non-whitespace char
" command -range CommentOnce  <line1>,<line2>g!/^\s*#/s/\v^(\s*)([^\s])/\1# \2/
"
" without a functioncall, and if we used hlsearch, we would clear the last
" search pattern with let @/ = ''; the function return does that here.
command -range CommentOnce <line1>,<line2>call UserDoComment()
command -range UnComment   <line1>,<line2>call UserUnComment()

nnoremap    gcc     :CommentOnce<CR>
nnoremap    guc     :UnComment<CR>
xnoremap    gcc     :CommentOnce<CR>
xnoremap    guc     :UnComment<CR>


nnoremap    <C-Left>    g;
nnoremap    <C-Right>   g,

" freaky; if at end of line, create new line
"nnoremap    <expr>  <CR>    line('.') == line('$') ? "o\<Esc>" : "\<CR>"
" the hard way without mode switching
"nnoremap    <silent> <expr> <CR>    ":\<C-u>"
            "\ . (
            "\ line('.') == line('$')
            "\ ?
            "\ 'put =repeat(\"\n\", v:count1)'
            "\ : 'execute "normal!" v:count1 . "\n"'
            "\ ) . "\<CR>"
" 2026-01-17 3rd way
if has('patch-8.2.1978')
    nnoremap    <silent> <expr>     <CR>    line('.') == line('$')
                \ ? "<Cmd>call append('.', repeat([''], v:count1))<CR>G"
                \ : 'j'
else
    nnoremap    <silent> <expr>     <CR>    line('.') == line('$')
                \ ? ":\<C-u>call append('.', repeat([''], v:count1))\<CR>G"
                \ : 'j'
endif

" search - start out case-insensitive; have i tried this before?
" 2025-12-30 don't want
"nnoremap    /   /\c


" wrapper for filtering through an external command safely, without clobbering
" the current buffer on error.
"
" test: :Filter echo to-stdout; echo to-stderr >&2; exit 10
function! Filter(cmd) range abort
    let f_stdin = tempname()
    let f_stderr = tempname()
    let text = getline(a:firstline, a:lastline)
    call writefile(text, f_stdin)
    unlet text
    " braces to compose shell redir
    let stdout = split(system('{ ' . a:cmd . ' } < ' . f_stdin . ' 2> ' . f_stderr), "\n")
    if v:shell_error
        echohl ErrorMsg
        echo 'shell error ' . v:shell_error
        echohl None
        if !empty(stdout)
            " failed with some output - dump into a new window
            "split +enew
            ScrEphem
            put=stdout
        endif
    else
        " filter succeeded.
        " first append any new text
        execute a:lastline . 'put=stdout'
        " then delete input range
        execute a:firstline . ',' . a:lastline . 'deletep'
    endif
    call delete(f_stdin)
    if getfsize(f_stderr) > 0
        " stderr has something - open in a new window
        ScrEphem
        execute 'edit' f_stderr
    else
        call delete(f_stderr)   " no stderr
    endif
endfunction

command -range -nargs=+ Filter <line1>,<line2>call Filter(<q-args>)

function! UserAppendBuf(buf, text) abort
    return appendbufline(a:buf, '$', a:text)
endfunction

" requires swapinfo() and appendbufline()/setbufline()
" swapinfo()        8.1.0313
" appendbufline()   8.1.0037
" setbufline()      8.0.1039
"
" enough to work on current iVim.
function! UserSwapChoice(swapname) abort
    let swapchoice = ''     " ask
    if !has('patch-8.1.0313')
        return swapchoice
    endif

    let msgbuf = bufadd('!swap-messages')
    call setbufvar(msgbuf, '&buftype', 'nofile')
    call bufload(msgbuf)
    call setbufvar(msgbuf, '&buflisted', 1)

    let swapname = a:swapname
    let sw = swapinfo(swapname)
    let b:swapname_old = swapname
    " mtime of file being edited
    let filetime = getftime(expand('<afile>'))
    let swapfile_mtime = get(sw, 'mtime', 0)
    let timediff = filetime - swapfile_mtime
    let dirty = get(sw, 'dirty', 0)
    let host = get(sw, 'host', '')
    let dirty_msg = dirty ? 'yes' : 'no'
    " log/inspect
    call UserAppendBuf(msgbuf, 'filename = ' . expand('<afile>'))
    call UserAppendBuf(msgbuf, 'old swapname = ' . swapname)
    call UserAppendBuf(msgbuf, 'dirty = ' . dirty_msg)
    call UserAppendBuf(msgbuf, 'host = ' . host)
    call UserAppendBuf(msgbuf, 'filetime = ' . strftime('%F %T', filetime))
    call UserAppendBuf(msgbuf, 'swap mtime = ' . strftime('%F %T', swapfile_mtime))
    call UserAppendBuf(msgbuf, 'timediff = ' . timediff)
    call UserAppendBuf(msgbuf, 'error = ' . get(sw, 'error', ''))
    " the new swap file name (f.ex. .swo) that'll be created for the new buffer
    " isn't available until later, i.e. swapname('%') returns nothing.
    if host ==# hostname()
        if has_key(sw, 'pid')
            " having a pid in the swapfile doesn't mean that process is still
            " running.
            call UserAppendBuf(msgbuf, 'file opened by pid ' . sw['pid'])
            if !has('ios')
                let swapchoice = 'o'    " read-only
            else
                " iOS - it's just me, pid doesn't matter
                let swapchoice = 'r'
            endif
        else
            " time isn't reliable
            if !dirty
                if abs(timediff) >= 3600
                    call UserAppendBuf(msgbuf, swapname . ': deleting')
                    let swapchoice = 'd'    " delete
                elseif swapfile_mtime >= filetime
                    let swapchoice = 'r'    " recover
                else
                    let swapchoice = 'o'    " read-only
                endif
            else
                " ? ? ? dirty; only seen on iOS
                let swapchoice = 'r'
            endif
        endif
    else
        " hosts differ
        let swapchoice = 'o'    " read-only
    endif
    call UserAppendBuf(msgbuf, 'swapchoice = ''' . swapchoice . '''')
    if swapchoice ==# 'r'
        call UserAppendBuf(msgbuf, '')
        call UserAppendBuf(msgbuf, '!' . swapname . ': recovering + queuing for rename')
        call UserAppendBuf(msgbuf, '! DiffOrig?')
        call UserAppendBuf(msgbuf, '')
        autocmd UserVimRc BufUnload RenameOldSwap
    endif
    call UserAppendBuf(msgbuf, string(sw))
    call UserAppendBuf(msgbuf, '--')
    if swapchoice ==# 'o'
        " read-only but modifiable allows edits, a pain to back out from.
        set nomodifiable
    endif
    return swapchoice
endfunction

command RenameOldSwap   if exists('b:swapname_old') &&
            \ (glob(b:swapname_old, 1, 1) == [ b:swapname_old ])
            \ | call rename(b:swapname_old, b:swapname_old . '-recovered')
            \ | endif

" useful sometimes
command!    DiffOrig    vert new | set bt=nofile | r ++edit # | 0d_
            \ | diffthis | wincmd p | diffthis

" try to detect 2 vs 4 indentation; javascript/typescript: i like fourdenting
" but prettier.io / gts defaults to twodenting.

function! UserDetectSoftIndent() abort
    let min_indent = 0
    for line in getline(1, 100)
        " skip empty or non-indented lines
        if line =~# '^\s*$' || line !~# '^ '
            continue
        endif
        let spaces = len(matchstr(line, '^ *'))
        if spaces > 0 && (min_indent == 0 || spaces < min_indent)
            let min_indent = spaces
        endif
    endfor
    if min_indent == 2
        return 2
    elseif min_indent == 4
        return 4
    endif
    return 0
endfunction

function! UserSetSoftIndent() abort
    let min_indent = UserDetectSoftIndent()
    if min_indent == 4
        SoftIndent 4
    else
        SoftIndent 2
    endif
endfunction


" mine own #-autogroup
augroup UserVimRc
    autocmd!

    " custom undofile read/write
    if has('persistent_undo') && !g:u.is_rpi
        "autocmd BufRead         *  if &undofile | setlocal noundofile | endif
        "autocmd BufRead         *  call UserReadUndo(expand('<afile>'))
        autocmd BufWritePost    *  call UserWriteUndo(expand('<afile>'))
    endif

    " for 'autoread'
    " 2023-10-30 seems CursorHold is triggered in the command line history
    " window, and checktime doesn't like that.
    " autocmd CursorHold *    checktime

    " enable auto reformatting when writing journal entries,
    " not for all text files.
    " format manually: gqip or vip, gq
    autocmd BufNewFile,BufRead  writing*.txt,NOTES*.txt     Wr
    autocmd BufRead             *music-comments.txt         setl nospell

    " for file names without an extension -
    " if file(1) thinks it's a text file, treat it as such.
    " not directly related to syntax highlighting - therefore this directive
    " is in this autogroup, and not in the UserVimRcSyntax autogroup.
    autocmd BufRead             *   call UserAutoSetFtText(expand('<afile>'))

    " last-position-jump
    " beware of fedora badly duplicating this functionality in /etc/vimrc.
    autocmd BufRead             *   call UserLastPositionJump()

    " *sh - only indentation, no syntax highlighting.
    "autocmd FileType *sh            set syntax=OFF
    " 2025-04-25 json - trailing comma error's ugly
    "autocmd FileType json           set syntax=OFF

    autocmd FileType            text    FoText

    autocmd BufNewFile,BufRead  *.list.txt,linkdump*.txt    MapQ

    autocmd BufNewFile,BufRead  *.xresources            setfiletype xdefaults

    " limited indentation detection - search for \t in the first hundred lines.
    " if hard tab found, switch to hard tab mode.
    autocmd FileType conf if match(getline(2, 100), "\t") != -1 | HardIndent | endif

    autocmd FileType lisp               Lisp
    autocmd FileType scheme             Lisp
    autocmd FileType racket             Lisp
    autocmd FileType clojure            Lisp

    autocmd FileType *sql               SoftIndent 2

    autocmd FileType json               call UserSetSoftIndent()
    autocmd FileType typescript*        call UserSetSoftIndent()
    autocmd FileType javascript*        call UserSetSoftIndent()

    autocmd FileType xdefaults          setlocal commentstring=!\ %s
    autocmd FileType text               setlocal commentstring=#\ %s

    " smalltalk - upstream st.vim doesn't set commentstring
    autocmd FileType st                 setlocal commentstring=\"%s\"
    " plantuml - no upstream plugin
    autocmd BufNewFile,BufRead  *.pu,*.puml setlocal commentstring='\ %s

    " 2025-10-02 ft resolv keeps default commentstring of /* %s */.
    " set to semicolon instead of hash/pound just to differentiate better.
    autocmd FileType resolv             setlocal commentstring=;\ %s
    "autocmd FileType text               setlocal commentstring=/*\ %s\ */

    " whimsical file formats with trailing whitespace sometimes
    autocmd FileType yaml               let b:user_noautomod = 1
    autocmd FileType markdown           let b:user_noautomod = 1

    autocmd FileType jproperties        Lousy | setlocal fileencoding=latin1

    autocmd FileType racket             call ExecuteNomodifiable('runtime plugin/matchparen.vim')

    " would be nice to be able to unload a script; maybe delete functions
    " using :scriptnames and :delf.

    "autocmd FileType text,markdown,vim  setlocal colorcolumn=+1

    " the first line of the commit message should be < 50 chars
    " to allow for git log --oneline
    autocmd FileType *commit    setlocal spell colorcolumn=50,72

    " decriminalize hard tabs; the SpecialKey highlighting still applies
    autocmd FileType    make    call User70s()
    autocmd FileType    go      call User70s()

    autocmd BufWrite    *   call UserStripTrailingWhitespace()
    autocmd BufWrite    *   call UserUpdateBackupOptions(expand('<amatch>'))

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

    if has('patch-8.0.1206')
        autocmd CmdlineEnter    [/?]    FixSearchHistory
    endif

    " for iVim on iOS; by default, swap seems to be automatically disabled
    " for files loaded from iCloud Drive. we keep swap files at home (appdir),
    " there will not be an attempt to create swap files on iCloud Drive.
    "
    " autocmd-pattern - * includes path separators.
    "
    " 2025-07-16 back to noswapfile on iOS
    "autocmd BufRead    /private/var/mobile/*       setlocal swapfile<

    " if swapfile exists, open read-only without the lecturing. q (quit),
    " a (abort) are rather useless, fails silently when trying to open
    " a file-with-swap in a new split. a little better with new vim run - just
    " exits with status 1.
    autocmd SwapExists *    let v:swapchoice = UserSwapChoice(v:swapname)

    "autocmd TermResponse * echom 'termresponse:' strtrans(v:termresponse)

    if has('cmdline_hist')
        " forget :q!/:qall! ; clearing must run after viminfo's loaded.
        autocmd VimEnter        *   call histdel('cmd', '\v^w?q')
    endif

    " test: fires under:
    "
    " xterm -tn xterm-256color -fg white -bg black (no COLORFGBG)
    "
    " xterm -tn xterm-direct -fg white -bg black (no COLORFGBG, truecolor)
    "
    " dark VTE terminal (sakura) with both COLORFGBG and COLORTERM

    " would be nice to have a way to reject option settings
    "if exists('##OptionSet')
        "autocmd OptionSet background
                    "\ echom UserDateTime() 'background set to' v:option_new
    "endif

    autocmd VimEnter *  call UserClearVColorNames()
augroup end
" /UserVimRc


function! UserClearVColorNames() abort
    if exists('v:colornames')
        " no cathedrals no bazaars; let's see what if anything breaks
        call map(keys(v:colornames), {_, k -> remove(v:colornames, k)})
        call garbagecollect()
    endif
endfunction


" set indentation settings

" default: hard tabs; C, Go, plain old Unix.

" keeping 'filetype indent off', load indent rules just for a few we like. no:
" xml, sql, yaml, markdown.
"
" see $VIM/indent.vim
"
" descent: rust; keep: ada, c, go, java, javascript, json, perl, racket, raku,
" ruby, rust, scala, typescript, vim, terraform, *sh
"
" 2023-10-31 been here before; things that make syntax highlighting fragile,
" also make indenting fragile - namely, unclosed quotes.
"
" 2024-04-10 python.vim autoindent's very weird. disabled. 2025-04-07 fixed with
" g:python_indent? not always, sometimes indentation goes haywire.
"
" 2025-10-27 defang upstream indent scripts by populating
" ~/.vim/indent/<filetype>.vim having let b:did_indent = 1; if any get through,
" reset indentexpr and indentkeys here.
augroup UserVimRcIndent
    autocmd!

    " for plugins that like to touch tabstop - always reset tabstop to global
    autocmd FileType *  if &tabstop != &g:tabstop | setlocal tabstop< | endif

    " reset python indentexpr
    autocmd FileType python if &indentexpr !~# '^U' | InDisable | endif

    " 2025-10-27 have i tried the same thing before?
    autocmd FileType sh,bash,zsh    InDisable
    autocmd FileType perl           InDisable
augroup end


" other: v:this_session
function! UserMakeDefaultSession() abort
    " don't do the initial creation, that's up to the user.
    if !filereadable('Session.vim')
        return 0
    endif

    " if hasn't been written to in N s
    let l:mk = (localtime() - getftime('Session.vim')) > 20
    if l:mk
        silent mksession!
    endif
    return l:mk
endfunction


" autogroup for my weird syntax dealings
augroup UserVimRcSyntax
    autocmd!

    autocmd BufWinEnter *       call UserApplySyntaxRules()

    " 2022-07-26 spooky action seems like this didn't work (for filetype
    " change from none to 'text') forever and suddenly started working today.
    "
    " possible match for just empty: {} https://vi.stackexchange.com/a/22961

    " for the 'syntax' option; buffer-local.
    "
    " for any Syntax event, start by turning flag off; don't complicate it.
    " otherwise syntax may be loaded without our rules.
    autocmd Syntax      *       let b:user_syntax = 0
    autocmd Syntax      \cuser  call UserApplySyntaxRules()
    " don't re-apply User* syntax rules if syntax is being turned off
    autocmd Syntax      *       if expand('<amatch>') !=? 'OFF'
                \ |     call UserApplySyntaxRules()
                \ | endif

    "autocmd Syntax      *       call UserLog('autoevent Syntax, amatch=' . expand('<amatch>'))

    " -----------------------------------------------

    " on colourscheme load/change, apply our colours, overriding the scheme.
    autocmd ColorScheme *       call UserColours()
augroup end     " UserVimRcSyntax


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
        autocmd BufRead     *   call UserLog('ae BufRead[Post]')
        autocmd BufCreate   *   call UserLog('ae BufCreate')
        autocmd BufNew      *   call UserLog('ae BufNew')
        autocmd OptionSet   *   call UserLog('ae OptionSet',
            \ 'opt', expand('<amatch>'),
            \ 'newval', v:option_new)
        autocmd SessionLoadPost * call UserLog('ae SessionLoadPost', v:this_session)
    augroup end
endif

" ----
" misc. plumbing/hacks


" load things in order
call UserRemoveVendorAugroups()
call UserSetCellWidths()
call UserSetupListchars()
call UserInitUiFlags()
call UserInitColourOverride()
call UserColoursPrelude()
call UserLoadColors()
if has('win32') || has('gui_running')
    set mouse=a
    call UserSetGuicursor()
endif
" disable application keypad mode; default enabled in PuTTY, default off in
" xterm - set t_ks= t_ke= , vim7 seems to need it for arrow keys.
if has('gui_running')
    call UserSetGuiFont()
    FnDef

    if has('win32')
        autocmd UserVimRc GUIEnter * call UserLoadGuifont() | FnDef
    endif
endif
if !g:u.term_primitive
    let &fillchars = UserFillchars({ 'vert': nr2char(0x2502) })
endif

" ~ fini ~

" latro mode - iOS 26 kills apps more often than iOS 18, having to :e often is
" a pain.
if has('ivim') && argc() == 0 && filereadable('Session.vim')
    " autocmds to update Session.vim
    autocmd UserVimRc BufWritePost    * call UserMakeDefaultSession()
    " VimLeavePre - too intrusive

    " 2025-11-19 workaround for vim < 8.2; only the last &scrolloff lines of the
    " buffer are displayed, at the top of the window. switching buffers, z- or
    " zb fixes it. not bisecting all that, maybe someday.
    "
    " too troublesome to workaround for all cases/all versions (feedkeys)/all
    " file sizes.
    if has('ivim') && v:version < 802
        call timer_start(0, {-> execute('normal! z-')})
    endif

    " silent to suppress Press ENTER or type command to continue
    silent source Session.vim
endif

