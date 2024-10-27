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

    highlight VertSplit ctermbg=NONE guibg=NONE

    " Normal tty - use terminal (emulator) colours.
    highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE
    highlight link Terminal Normal
    if &background ==# 'light'
        " guifg: pantone 19-4052 tcx classic blue
        highlight Normal guifg=#0f4c81 guibg=#f3f3f3
    else    " background ==# 'dark'
        " don't like the dark blue of iceberg; and the
        " forground could be a little brigter.
        highlight Normal guifg=#f3f3f3 guibg=#000000

        highlight LineNr ctermfg=242
        highlight VertSplit ctermfg=214 guifg=orange
        highlight Visual ctermbg=17
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

