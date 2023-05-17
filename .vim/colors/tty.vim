highlight clear
if exists('syntax_on')
    syntax reset
endif

" clear up things, to reduce confusion and for editing in low light.
"
if exists('*UserSafeUIHighlights')
    call UserSafeUIHighlights()
endif

" this is redundant, a ColorScheme autocommand should run this.
if v:false && exists('*UserColours')
    call UserColours()
endif

let g:colors_name = expand('<sfile>:t:r')

" vim:ts=8 sw=4 sts=4 et ai:

