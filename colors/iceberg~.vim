" vim:set tw=0 noml:

if !has('gui_running') && &t_Co < 256
    finish
endif
if !UserRuntimeHas('colors/iceberg.vim')
    finish
endif


function! ColorOverrideIceberg() abort
    " prevent auto-reloading stuff while we're in here
    if exists('g:colors_name')
        unlet g:colors_name
    endif

    " Normal tty - use terminal (emulator) colours.
    highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE
    if &background ==# 'light'
        " guifg: pantone 19-4052 tcx classic blue
        highlight Normal guibg=#f3f3f3 guifg=#0f4c81
    else    " background ==# 'dark'
        " don't like the dark blue of iceberg
        highlight Normal guibg=#000000
    endif   " if-background

    let g:colors_name = 'iceberg~'
endfunction


call PushBg1710()
try
    runtime colors/iceberg.vim
finally
    call PopBg1710()
endtry

call ColorOverrideIceberg()

