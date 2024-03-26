" Last-Modified: 2023-11-29T15:52:52.91296010+00:00
" vim:set tw=80 noml:
set nocompatible
set secure encoding=utf-8 fileencoding=utf-8 nobomb
scriptencoding utf-8        " must go after 'encoding'

let g:mapleader = ','

set autoindent
set backupcopy=yes
set complete=.
set hidden
set laststatus=2
set listchars=tab:\ \ ,trail:_
set noerrorbells
set novisualbell
set shortmess+=I
set showcmd
set timeout ttimeout timeoutlen=3000 ttimeoutlen=100

set expandtab
set shiftwidth=4
set softtabstop=4

" less-emacs-y window navigation
nnoremap    s   <C-w>
" defang possibly harmful finger-feel mappings
nnoremap    <Leader>C   <Nop>
nnoremap    <Leader>S   <Nop>
nnoremap    <Leader>U   <Nop>

" don't confuse tiny vim (-eval), can't test with older vims.
if version >= 704
    runtime 0.vim
endif

