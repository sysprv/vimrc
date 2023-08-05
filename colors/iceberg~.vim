" vim:tw=0 noml:

if !has('gui_running') && &t_Co < 256
    finish
endif
if !UserRuntimeHas('colors/iceberg.vim')
    finish
endif


function! ColorOverrideIceberg() abort
    " prevent auto-reloading stuff while we're in here
    unlet g:colors_name

    highlight Normal ctermfg=NONE ctermbg=NONE cterm=NONE
    highlight ModeMsg term=NONE cterm=NONE gui=NONE

    if &background ==# 'light'
        highlight Normal guibg=#f3f3f3

        if UserCO(g:u.coflags.stat)
            highlight StatusLine ctermfg=0 ctermbg=152 cterm=NONE guifg=fg guibg=#b0e0e6 gui=NONE
            highlight StatusLineNC ctermfg=15 ctermbg=60 cterm=NONE guifg=bg guibg=#5a4f74 gui=NONE
            highlight VertSplit ctermfg=60 ctermbg=60 cterm=NONE guifg=#5a4f74 guibg=#5a4f74 gui=NONE
        endif
        if UserCO(g:u.coflags.spell)
            highlight SpellBad term=NONE ctermfg=NONE ctermbg=254 cterm=NONE guifg=fg guibg=grey91 gui=NONE guisp=NONE
        endif
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
    else
        " background ==# 'dark'

        " don't like the dark blue of iceberg
        highlight Normal guibg=#000000

        if UserCO(g:u.coflags.stat)
            " amber: #fc9505
            highlight StatusLine ctermfg=NONE ctermbg=0 cterm=NONE guifg=fg guibg=#000000 gui=NONE
            highlight StatusLineNC ctermfg=NONE ctermbg=52 cterm=NONE guifg=grey75 guibg=firebrick4 gui=NONE
            highlight VertSplit ctermfg=52 ctermbg=52 cterm=NONE guifg=firebrick4 guibg=firebrick4 gui=NONE
        endif
        if UserCO(g:u.coflags.spell)
            highlight SpellBad term=NONE ctermfg=NONE ctermbg=235 cterm=NONE guifg=fg guibg=grey25 gui=NONE guisp=NONE
        endif
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
    endif

    let g:colors_name = 'iceberg~'
endfunction

runtime colors/iceberg.vim

call ColorOverrideIceberg()

