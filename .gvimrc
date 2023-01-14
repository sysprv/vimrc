" 2022-12-08 - remove 'a'
set guioptions=cgimpt
" 2022-12-08 - removing autoselect; gvim's like a terminal emulator anyway.
" 2023-01-02 - just unnamedplus is no good for win32. doesn't fail early, but
" breaks y/p.
set clipboard=unnamed
if has('unnamedplus')
    set clipboard=unnamedplus
endif

" for the popup menu
set mousemodel=popup

set mouseshape-=v:rightup-arrow
set mouseshape+=n-v:beam

" guifont - see .vimrc:/guifont/

command Geometry set lines=50 columns=90
Geometry

" mappings for clipboard - see .vimrc

inoremap <C-BS> <C-w>


" ctrl-z - don't suspend, spawn a terminal instead
" vim terminal sucks.
if has('linux')
    nnoremap <silent> <C-z> :call system('xterm &')<cr>
endif
vnoremap <silent> <C-z> <Esc>


" doc:windows.txt.html#%3Asball
amenu &Misc.&Buffers\ to\ tabs  :tab sball<cr>g
" amenu &Misc.&Make\ session    :mksession!<cr>g
amenu &Misc.&Tab\ page          :tabnew<cr>g
amenu &Misc.Copy\ &all          :%WX11<cr>g

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

" clear out trash added for the 'terminal' feature.
"
" "menu entries for all modes at once, except for Terminal mode."
" pretty ad-hoc. might need to be adjusted for new vim versions.
"
" 2022-07-04 - it seems menus can be added to terminal mode even
" when vim hasn't been built with the terminal feature. so doing
" 'tlunmenu' under has('terminal') won't clear these up.
try
    tlunmenu Edit
    if has('win32')
        tlunmenu Tools
        tlunmenu Syntax
    endif
    tlunmenu Help
catch /^Vim\%((\a\+)\)\=:E329:/
    " ignore
endtry

" doc:gui.txt.html#menu-priority
" default File menu has prio 10;
" add a new File menu before everything we've defined above.
1amenu &File.&Exit              :confirm qa<cr>g


" started with https://github.com/tlvince/vim-auto-commit, then
" fixed modified/fixed some things.
"
" could use partials... will be messy.
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


function! UserSessionUpdate()
    execute 'mksession!' fnameescape(v:this_session)
    echom '(session updated)'
endfunction

augroup UserGvimRc
    autocmd!

    " 2022-12-08 now that we've settled on sessionoptions we're happy with,
    " if we loaded a session, add an autocmd to save it when focus is lost.
    autocmd SessionLoadPost *
        \ autocmd UserGvimRc FocusLost * call UserSessionUpdate()
augroup end

if has('unix')
    autocmd UserGvimRc BufWritePost /stuff/notes/* call UserGitCommitAdapter()
endif


" .vimrc has a 'set backgroundg&', which works well in linux. but gvim on
" windows still starts with bg == 'dark'. manually doing 'set bg&' does the
" correct thing. not spending more time on debugging this, given the obscurity
" and state of the platform. https://github.com/vim/vim/issues/869
"
" tangential comment: https://vimhelp.org/syntax.txt.html#%3Ahighlight-normal
" When using reverse video ("gvim -fg white -bg black"), the default value of
" 'background' will not be set until the GUI window is opened, which is after
" reading the gvimrc.  Use :gui, which has its own caveats (-f).

if has('win32') && &background ==# 'dark'
    set background=light
endif

" vim:tw=80 fo=croq:
