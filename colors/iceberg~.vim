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

    highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE
    highlight ModeMsg term=NONE cterm=NONE gui=NONE

    if &background ==# 'light'
        " guifg: pantone 19-4052 tcx classic blue
        highlight Normal guibg=#f3f3f3 guifg=#0f4c81

        if UserCO(g:u.coflags.ui)
            "
            " ColorColumn azure2
            " CursorLine palegoldenrod
            "
            highlight NonText ctermfg=NONE ctermbg=7 guifg=#9fa7bd guibg=#dcdfe7
            highlight SpecialKey ctermfg=164 ctermbg=252 guifg=#aa336a guibg=#dcdfe7
        endif
        highlight UserDateComment ctermfg=241 ctermbg=254 guifg=grey40 guibg=azure2 gui=italic
        "highlight UserHashTag ctermbg=194 guibg=#b9ebc4
        highlight UserHashTag               ctermbg=152     guibg=#b0e0e6
        " trailing whitespace same as SpellBad
        highlight UserTrailingWhitespace    ctermbg=254     guibg=grey91
    else    " background ==# 'dark'

        " don't like the dark blue of iceberg
        highlight Normal guibg=#000000

        " TODO ModeMsg
        if UserCO(g:u.coflags.ui)
            " similar to LineNr
            highlight NonText ctermfg=NONE ctermbg=235 guifg=#444b71 guibg=#1e2132
            highlight SpecialKey ctermfg=214 ctermbg=235 guifg=orange guibg=#1e2132
            " TODO Visual?
        endif
        highlight UserDateComment ctermfg=246 guifg=grey70 guibg=#1e2132 gui=italic
        highlight UserHashTag ctermbg=24 guibg=#005f5f
        " trailing whitespace same as SpellBad
        highlight UserTrailingWhitespace    ctermbg=235     guibg=grey25
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

