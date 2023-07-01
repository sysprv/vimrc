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

    if &background ==# 'light'
        highlight Normal guibg=#f3f3f3

        if UserCO(g:u.coflags.stat)
            highlight StatusLine ctermfg=0 ctermbg=152 cterm=NONE guifg=fg guibg=#b0e0e6 gui=NONE
            highlight StatusLineNC ctermfg=15 ctermbg=60 cterm=NONE guifg=bg guibg=#5a4f74 gui=NONE
            highlight VertSplit ctermfg=60 ctermbg=60 cterm=NONE guifg=#5a4f74 guibg=#5a4f74 gui=NONE
        endif
        if UserCO(g:u.coflags.spell)
            highlight SpellBad ctermfg=NONE ctermbg=254 guifg=fg guibg=grey91 gui=NONE guisp=NONE
        endif
        if UserCO(g:u.coflags.ui)
            "
            " ColorColumn azure2
            " CursorLine palegoldenrod
            "
            highlight NonText ctermfg=NONE ctermbg=7 guifg=#9fa7bd guibg=#dcdfe7
            highlight SpecialKey ctermfg=164 ctermbg=252 guifg=#aa336a guibg=#dcdfe7
        endif
    else
        " background ==# 'dark'
        if UserCO(g:u.coflags.stat)
            highlight StatusLine ctermfg=0 ctermbg=152 cterm=NONE guifg=#000000 guibg=#b0e0e6 gui=NONE
            highlight StatusLineNC ctermfg=15 ctermbg=60 cterm=NONE guifg=fg guibg=#5a4f74 gui=NONE
            highlight VertSplit ctermfg=60 ctermbg=60 cterm=NONE guifg=#5a4f74 guibg=#5a4f74 gui=NONE
        endif
        if UserCO(g:u.coflags.spell)
            highlight SpellBad ctermfg=NONE ctermbg=233 guifg=fg guibg=grey25 gui=NONE guisp=NONE
        endif
        " TODO ModeMsg
        if UserCO(g:u.coflags.ui)
            " similar to LineNr
            highlight NonText ctermfg=NONE ctermbg=233 guifg=#444b71 guibg=#1e2132
            highlight SpecialKey ctermfg=214 ctermbg=233 guifg=orange guibg=#1e2132
            " TODO Visual?
        endif
    endif
    let g:colors_name = 'iceberg~'
endfunction

runtime colors/iceberg.vim

call ColorOverrideIceberg()

