" vim:set tw=0 noml:

if !has('gui_running') && &t_Co < 256
    finish
endif
if !UserRuntimeHas('colors/iceberg.vim')
    finish
endif


function! ColorPatchIceberg() abort
    " prevent auto-reloading stuff while we're in here
    if exists('g:colors_name')
        unlet g:colors_name
    endif

    highlight link Terminal             Normal
    " override terminal statusline colours defined by iceberg
    highlight! link StatusLineTerm       StatusLine
    highlight! link StatusLineTermNC     StatusLineNC
    highlight link LineNrAbove          LineNr
    highlight link LineNrBelow          LineNr
    highlight link MessageWindow        PMenu
    highlight link PopupNotification    Todo
    highlight link PopupSelected        PmenuSel
    highlight link CurSearch            IncSearch

    if &background !=# 'light'
        " background ==# 'dark'
        highlight LineNr ctermfg=242
        highlight VertSplit ctermfg=214 guifg=orange
        highlight Visual ctermbg=17
    endif   " if-background

    let g:colors_name = 'iceberg~'
endfunction


runtime colors/iceberg.vim

call ColorPatchIceberg()

