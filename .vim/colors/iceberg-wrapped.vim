if exists('*UserRuntimeHas')
    if UserRuntimeHas('colors/iceberg.vim')
        runtime colors/iceberg.vim
        if exists('g:colors_name')
            if g:colors_name == 'iceberg'
                " iceberg actually ran; override
                highlight Normal ctermbg=NONE guibg=NONE
                highlight NonText ctermbg=NONE guibg=NONE
                let g:colors_name = expand('<sfile>:t:r')
            endif
        endif
    endif
endif

" no need; autocommands will take care of this
if v:false && exists('*UserColours')
    call UserColours()
endif
