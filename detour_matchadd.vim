if 0
" cruft warning; not failsafe, depends on vim version.
function! UserIsWinRegular()
    " check for popup/preview/command line etc.
    if v:version >= 802 && win_gettype() != ''
        return 0
    endif

    " check for quickfix/terminal
    let l:wi_lst = getwininfo(win_getid())
    "" info for current window; l:wi_lst should never be empty.
    let l:wi = l:wi_lst[0]
    if get(l:wi, 'loclist') || get(l:wi, 'quickfix') || get(l:wi, 'terminal')
        return 0
    endif

    " nothing more to check
    return 1
endfunction

function! UserHlNames()
    return [
        \ 'UserTrailingWhitespace',
        \ 'UserDateComment',
        \ 'UserHashTag',
        \ 'UserHttpURI',
        \ 'UserUnicodeWhitespace'
        \ ]
endfunction

function! UserGetCurWinMatchHls()
    let l:hl_exst = []
    let l:hls = UserHlNames()

    for l:m in getmatches()
        for l:hl in l:hls
            if l:m['group'] ==# l:hl
                if index(l:hl_exst, l:hl) == -1
                    call add(l:hl_exst, l:hl)
                endif
                break
            endif
        endfor
    endfor

    return l:hl_exst
endfunction

" try out matchadd() instead of trying to extend the ft/syntax regime.
" has the advantage of working even with 'syntax off'.
" https://stackoverflow.com/questions/41083829/how-can-i-apply-custom-syntax-highlighting-in-vim-to-all-file-types
"
" disadvantages:
"   - for excluding URIs from spell check, using a highlight group
" linked to Normal doesn't seem to work. However, using a highlight group
" that defines ctermbg and guibg hides the SpellBad highlighting.
" workable, though it may not make URIs perfectly transparent in terminals.
" gvim is fine, with guibg=bg.
" So, not excluded from spell checking, just occluded.
"
" it's a great relief to be free of the filetype/syntax rigmarole, the expected
" way of defining a filetype. non-syntax matchadd() is ultimate freedom.
"
" On WinEnter:
" we don't want to highlight things in special buffer types or
" non-modifiable buffers - but, WinEnter is too early to check anything.
" win_gettype() is nice, but doesn't cover help windows.
" https://stackoverflow.com/questions/68001855/vimscript-reliable-way-of-checking-win-and-buf-type-of-a-new-window-with-autoc
" so this setup will add the matches to many places where it's not necessary.
" should be harmless in the end. it is funny to see trailing spaces in vim help
" files.
"
function! UserMatchAdd() abort
    " if we've defined all the matches we want in this window, no need to act
    if exists('w:user_matches') && w:user_matches == len(UserHlNames())
        return
    endif
    let w:user_matches = 0

    " the names of our highlight-groups.
    let [l:hg_utws, l:hg_udtc, l:hg_uht, l:hg_uhuri, l:hg_uniws] = UserHlNames()

    " matches that have already been defined
    let l:hl_exst = UserGetCurWinMatchHls()

    " regular expressions
    let l:re_utws = '\s\+$'

    " this date range should be enough to outlast me.
    " the seconds part should cater for leap seconds.
    let l:re_udtc = '\v-- date 20\d\d+-\d\d-\d\d \d\d:\d\d:\d\d.{,16}'
    " date comment, optional trailing part, after seconds: [+-]\d{4} \(\a+, \a+\)

    let l:re_uht_simple = '\v✚[_[:lower:][:upper:][:digit:]]{1,30}'
    " non-greedily ("-1") match anything except
    "   caret, apostrophe, hash
    " (too broad but must include unicode) chars between apostrophes.
    " canary: [✚x] [✚'x'] [✚'x ✚'x](pathological, overlap)
    " if a tag is over 30 chars - could indicate a problem.
    let l:re_uht_liberal = "\v✚'%([^✚'\\]|\\.){-1,30}'"

    let l:re_uhuri = '\v<https?:\/\/\S+>'

    function! s:needs(s) closure
        return index(l:hl_exst, a:s) == -1
    endfunction

    " let hlsearch (priority 0) override our match highlights
    let l:prio = -2
    " trailing whitespace
    if s:needs(l:hg_utws)
        call matchadd(l:hg_utws, l:re_utws, l:prio)
        let w:user_matches += 1
    endif
    if s:needs(l:hg_udtc)
        call matchadd(l:hg_udtc, l:re_udtc, l:prio)
        let w:user_matches += 1
    endif
    if s:needs(l:hg_uht)
        call matchadd(l:hg_uht, l:re_uht_simple, l:prio)
        call matchadd(l:hg_uht, l:re_uht_liberal, l:prio)
        let w:user_matches += 2
    endif
    if s:needs(l:hg_uhuri)
        call matchadd(l:hg_uhuri, l:re_uhuri, l:prio)
        let w:user_matches += 1
    endif
    if s:needs(l:hg_uniws)
        call matchadd(l:hg_uniws, UserGetUnicodeWhitespaceRegexp(), l:prio)
        let w:user_matches += 1
    endif

    delfunction s:needs
endfunction

" helper
function! UserMatchReset()
    call clearmatches()
    let w:user_matches = 0
    call UserMatchAdd()
endfunction
endif


