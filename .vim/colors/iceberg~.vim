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

    " highlights Terminal, StatusLineTerm, StatusLineTermNC
    " overridden for all colorschemes in vimrc:UserColours()/UserColours256()

    highlight link LineNrAbove          LineNr
    highlight link LineNrBelow          LineNr
    highlight link MessageWindow        PMenu
    highlight link PopupNotification    Todo
    highlight link PopupSelected        PmenuSel
    highlight link CurSearch            IncSearch

    if &background ==# 'dark'
        highlight LineNr ctermfg=242
        highlight VertSplit ctermfg=214 guifg=orange
        highlight Visual ctermbg=17
    endif

    let g:colors_name = 'iceberg~'
endfunction


runtime colors/iceberg.vim

call ColorPatchIceberg()

