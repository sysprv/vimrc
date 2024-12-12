vim9script

def g:UserStLnBufModStatus(): string
    var m = ''
    # NB attribute check order
    if &modified
        m ..= '+'
    endif
    if !&modifiable
        m ..= '-'
    endif
    if empty(m)
        # neither modified nor unmodifiable
        m = '_'
    endif

    if &readonly
        m ..= '.ro'
    endif

    # normal buffer without a swapfile and swapfile is globally on - warn
    if &buftype == '' && (&g:swapfile && (!&l:swapfile || (&updatecount == 0)))
        m ..= '.!swf'
    endif
    return m
enddef

def g:UserStLnTextWidth(): string
    return &paste ? '!P' : string(&textwidth)
enddef

def g:UserStLnFenc(): string
    var s = ''
    if !empty(&fileencoding) && &fileencoding !=# 'utf-8'
        s = 'fenc:' .. &fileencoding
    endif
    return s
enddef

def g:UserStLnFf(): string
    var s = ''
    if &fileformat !=# 'unix'
        s = 'ff:' .. &fileformat
    endif
    return s
enddef

def g:UserStLnIndentation(): string
    var s = ''
    if &tabstop != 8
        s = '!' .. string(&tabstop) .. '!,'
    endif
    # moniker: soft/hard
    s ..= &expandtab ? 's' : 'h'
    s ..= string(&softtabstop)
    if &shiftwidth != &softtabstop
        s ..= ',' .. string(&shiftwidth)
    endif

    if s ==# 's4'
        # the default. no need to show.
        return ''
    endif
    return 't:' .. s
enddef

def g:UserStLnBufFlags(): string
    var l: list<string> = []
    if &buftype ==# 'terminal'
        l->add('TERM')    # should get its own format flag for statusline
        # something like this (line:col only in terminal normal mode) should
        # be done more efficiently by the statusline.
        if mode() ==# 'n'
            var pos = getpos('.')
            l->add(string(pos[1]) .. ':' .. string(pos[2]))
        endif
    else
        if &previewwindow
            l->add('PRV')    # %W
        endif
        var pos = getpos('.')
        l->add(printf('%3d:%2d', pos[1], pos[2]))
        l->add(g:UserStLnBufModStatus())
        l->add(g:UserStLnIndentation())
        l->add(g:UserStLnTextWidth())
        l->add(g:UserStLnFenc())
        l->add(g:UserStLnFf())
        if &formatoptions =~# 'a'
            l->add('fo-a')
        endif
    endif

    # erase numbers that are 0, erase empty strings
    l = l->filter((_, v) => v != '0' && v != '')
    return '[' .. l->join('/') .. ']'
enddef

defcompile
