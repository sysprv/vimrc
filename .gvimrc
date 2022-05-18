set guioptions=acgimpt

set clipboard+=autoselect
set selectmode+=mouse


if has('unix') && has('gui_gtk')
    "set guifont=Source\ Code\ Pro\ Light\ 12
    "set guifont=Go\ Mono\ 11
    "set guifont=Operator\ Mono\ Light\ 12
    "set guifont=Letter\ Gothic\ Std\ 11	" macrons don't look good
    "set guifont=PragmataPro\ Mono\ 12
    "let &guifont = 'PragmataPro Mono 14'
    "let &guifont = 'Fairfax HD Medium 14'
    " FreeMono - like Courier, a little better than Nimbus Mono
    "let &guifont = 'FreeMono 12'
    " for some reason CMY TT doesn't get antialiased
    "let &guifont = 'CMU Typewriter Text 12'
    "let &guifont = 'Inconsolata Light 12'
    "let &guifont = 'Source Code Pro Light 11'
    " Prestige Elite
    " let deffont = 'PrestigeEliMOT'
    " let deffont = 'Inconsolata Light'
    " let g:deffont = 'Source Code Pro'     " large; use size 11
    let g:deffont = 'Iosevka Term SS08 Light'
    let &g:guifont = deffont . ' 12'

    command Big let &g:guifont = deffont . ' 12'
    command Econ let &g:guifont = 'PragmataPro Mono 10'
elseif has('win32')
    " Consolas is missing some reasonable glyphs.
    "let &g:guifont = 'Consolas:h12:cDEFAULT:qCLEARTYPE'
    let &g:guifont = 'Iosevka_Term_SS08:h12:cDEFAULT:qCLEARTYPE'
    set renderoptions=type:directx
endif

" allows three vertical splits at 80+
command Geometry set lines=50 columns=90
Geometry

" PRIMARY selection
" doc:gui_x11.html#quoteplus
inoremap <silent> <S-Insert>    <C-r>*
inoremap <silent> <C-S-v>       <C-r>*
cnoremap          <C-S-v>       <C-r>*

" adapted http://coganblogs.blogspot.com/2010/09/perfect-cut-copy-paste-with-gvim.html
" CUA - copy
"" vnoremap <silent> <C-c>		"+zy<ESC>
" CUA - cut
"" vnoremap <silent> <C-x>		"+c<ESC>
" CUA - paste
" vnoremap <silent> <C-v>		c<ESC>"+p
" nnoremap <silent> <C-S-v>	c<ESC>"+p
"" set an undo point, then paste, then another undo point
"" inoremap <silent> <C-v>		<C-g>u<C-r>+<C-g>u
"" inoremap <silent> <C-S-v>	<C-g>u<C-r>+<C-g>u
"" command window; <silent> is bad in command mode
"" cnoremap <C-v> <C-r>+

" hp's fucked the Insert key, fn-e too. ergo the duplicate
" mappings for kInsert - the Insert key on the numpad.
" using Insert - copy
vnoremap <silent> <C-Insert>	"+zy<ESC>
vnoremap <silent> <C-kInsert>	"+zy<ESC>
" using Insert - cut
vnoremap <silent> <S-Del>	"+c<ESC>
vnoremap <silent> <S-kDel>	"+c<ESC>
" using Insert - paste - insert mode, with undo points
inoremap <silent><S-Insert>	<C-g>u<C-r>+<C-g>u
inoremap <silent><S-kInsert>	<C-g>u<C-r>+<C-g>u
" using Insert - paste
vnoremap <silent> <S-Insert>	c<ESC>"+p
vnoremap <silent> <S-kInsert>	c<ESC>"+p
nnoremap <silent> <S-Insert>	c<ESC>"+p
nnoremap <silent> <S-kInsert>	c<ESC>"+p
" using Insert - paste command mode
cnoremap <S-Insert>		<C-r>+
cnoremap <S-kInsert>		<C-r>+

" emacs - copy/kill-ring-save
vnoremap <silent> <M-w> "+y<ESC>
" emacs - cut/kill-region
" vnoremap <silent> <C-w> "+c
" emacs - paste/yank
vnoremap <silent> <C-y> c<ESC>"+p
inoremap <silent> <C-y> <C-r>+

inoremap <C-BS> <C-w>


" ctrl-z - don't suspend, spawn a terminal instead
" vim terminal sucks.
nnoremap <silent> <C-z> :call system('xterm &')<CR>
vnoremap <silent> <C-z> <Esc>


" doc:windows.txt.html#%3Asball
amenu &Misc.&Buffers\ to\ tabs	:tab sball<CR>
" amenu &Misc.&Make\ session	:mksession!<CR>
amenu &Misc.&Tab\ page		:tabnew<CR>

" delete the autocmd that does the lazy loading -
" otherwise the autocmd will cause Edit and Tools menus to reappear.
" see menu.vim, au CursorHold,CursorHoldI
au! SetupLazyloadMenus

" keep the Buffers menu, discard everything else.
" some open inconsistencies - https://github.com/vim/vim/issues/3563
aunmenu File
aunmenu Edit
aunmenu Tools
aunmenu Syntax
"aunmenu Window
aunmenu Help
" even when the gui toolbar's hidden, the definition stays
aunmenu ToolBar
" "menu entries for all modes at once, except for Terminal mode."
" pretty ad-hoc. might need to be adjusted for new vim versions.
if has('terminal')
    tlunmenu Edit
    if has('win32')
        tlunmenu Tools
        tlunmenu Syntax
    endif
    tlunmenu Help
endif

" doc:gui.txt.html#menu-priority
" default File menu has prio 10;
" add a new File menu before everything we've defined above.
1amenu &File.&Exit		:confirm qa<CR>

" for the popup menu
set mousemodel=popup

" if we loaded a session, save it when focus lost
" autocmd SessionLoadPost * autocmd! FocusLost * :mksession!

" started with https://github.com/tlvince/vim-auto-commit, then
" fixed modified/fixed some things.
"
" could use partials... will be messier.
" with :wq f.ex., vim will exit before this runs or finishes running.
" acceptable.
" this version, using the job api looks pretty good.
" :terminal gives very little control, and system() is clunky.
function! UserAutoGitCommitJob()
    let l:msg = expand('%:.')
    let l:fullp = expand('%:p')
    let l:git = '/usr/bin/git'
    " git output sent to a temporary, hidden buffer
    let l:buffer = '!git-auto-commit'
    let l:opts = { 'in_io': 'null',
        \ 'out_io': 'buffer',
        \ 'err_io': 'buffer',
        \ 'out_name': l:buffer,
        \ 'err_name': l:buffer }

    " long function names for namespacing, short locals for readability

    " job status check
    function! UserAGCJobExitOk(job)
        let l:ji = job_info(a:job)
        return ji['status'] == 'dead' && ji['exitval'] == 0
    endfunction

    let l:E0 = function('UserAGCJobExitOk')

    function! UserAGCOptCb(name) closure
        let l:v = copy(l:opts)
        let l:v['exit_cb'] = a:name
        return l:v
    endfunction

    let l:ExitCb = function('UserAGCOptCb')

    " `closure' required to access l:E0
    " if git commit worked, print a message
    " no message -> just check the buffer with job output
    function! UserAGCCB3(job, status) closure
        if l:E0(a:job)
            echom '(committed)'
        endif
    endfunction

    " if git add worked, run git commit
    function! UserAGCCB2(job, status) closure
        if l:E0(a:job)
            let l:cc = [l:git, 'commit', '-m', l:msg, l:fullp]
            call job_start(l:cc, l:ExitCb('UserAGCCB3'))
        endif
    endfunction

    " if rev-parse succeeded, run git add
    function! UserAGCCB1(job, status) closure
        if l:E0(a:job)
            let l:ac = [l:git, 'add', l:fullp]
            call job_start(l:ac, l:ExitCb('UserAGCCB2'))
        endif
    endfunction

    " start, with a git rev-parse
    call job_start([l:git, 'rev-parse', '--git-dir'], l:ExitCb('UserAGCCB1'))
endfunction


" adapter that just accepts parameters, from time_start() f.ex.
function! UserGitCommitAdapter(...)
    call UserAutoGitCommitJob()
endfunction


" disable cursor blinking - a:blinkon0
let g:user_default_guicursor = &guicursor
lockvar g:user_default_guicursor
" default: n-v-c:block,o:hor50,i-ci:hor15,r-cr:hor30,sm:block
" default blinking: blinkwait700-blinkon400-blinkoff250
"
" blink in almost all cases; no blink in normal mode.
set guicursor=a:blinkwait500-blinkon600-blinkoff971,v-c:block,n:block-blinkon0,o:hor50,r-cr:hor30,sm:block,i-ci:hor15-blinkwait500-blinkon600-blinkoff971

augroup UserGvimRc
    autocmd!
augroup end

if has('unix')
    autocmd UserGvimRc BufWritePost /stuff/notes/* call UserGitCommitAdapter()
endif

" don't enter SELECT mode with the mouse
set selectmode=
set mouse=inv

set mouseshape-=v:rightup-arrow
set mouseshape+=n-v:beam

" .vimrc has a 'set backgroundg&', which works well in linux. but gvim on
" windows still starts with bg == 'dark'. manually doing 'set bg&' does the
" correct thing. not spending more time on debugging this, given the obscurity
" and state of the platform. https://github.com/vim/vim/issues/869
if has('win32') && &background == 'dark'
    set background=light
endif

" vim:sts=4:sw=4:et:ai:
