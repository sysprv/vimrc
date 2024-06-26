" Last-Modified: 2023-11-29T15:52:52.91296010+00:00
" vim:set tw=80 noml:
set nocompatible
set secure encoding=utf-8 fileencoding=utf-8 nobomb
scriptencoding utf-8        " must go after 'encoding'

set autoindent
set backupcopy=yes
set complete=.
set hidden
set nojoinspaces
set laststatus=1
set listchars=tab:\ \ ,trail:_
set noerrorbells
set novisualbell
set shortmess+=I
set showcmd
set noincsearch
set nohlsearch

set expandtab
set shiftwidth=4
set softtabstop=4

" less-emacs-y window navigation
nnoremap    s           <C-w>

nnoremap    q           <Nop>

nnoremap    j           gj
nnoremap    k           gk
nnoremap    <Down>      gj
nnoremap    <Up>        gk

" defang possibly harmful finger-feel mappings.
" mapleader can't be set in vim tiny.
nnoremap    ,C   <Nop>
nnoremap    ,S   <Nop>
nnoremap    ,U   <Nop>

" listchars extends important for nowrap view
set listchars=conceal:?,extends:>,nbsp:!,precedes:<,tab:\ \ ,trail:_

set noloadplugins

command -range WRCB     silent <line1>,<line2>:w !/usr/bin/xsel -b -i

" don't confuse tiny vim (-eval), can't test with older vims.
if version >= 704
    " if huge+view (has eval, can't by tiny/small vim) or no view but vim -R,
    " exit early.
    if exists('v:argv')
        let u_argv = v:argv
    elseif filereadable('/proc/self/cmdline')
        let u_argv = split(readfile('/proc/self/cmdline')[0], "\0")
    else
        let u_argv = []
    endif
    " checks only for -R, not -<other-flags>R
    if len(u_argv) > 0 && (u_argv[0] =~# 'view$' || index(u_argv, '-R') > 0)
        " view mode
        set list nowrap
        syntax off
        finish
    endif
    unlet u_argv
    runtime 0.vim
endif

