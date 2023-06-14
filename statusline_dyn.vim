" it's nice to see the the window size. or, the width.
"
" info display levels:
"   > 1     buffer flags
"   > 2     filename (tail)
"   > 3     line:columns
"   > 4     window width
"   > 5     window height
"
" touching a myriad bits of state with disdain.
"
if has('patch-8.1.1372')
    function! UserStatusLine()
        if !exists('g:u.statusline_level')
            let g:u.statusline_level = 3
        endif

        " 2022-09-05 we can bump up the level depending on the window count
        " or buffer count. but really, the buffer name becomes necessary very
        " often.

        let l:lvl = g:u.statusline_level

        let l:stlparts = {}
        " * buffer number
        let l:stlparts[0] = "%n%<"

        " if more than one window, show bufname regardless of level
        if l:lvl > 1
            " *** buffer flags
            let l:stlparts[20] = " [%{UserStLnBufFlags()}%W%H]"

            if l:lvl > 2
                " ****** buffer name - after everything else.
                let l:stlparts[900] = " %.30f"

                if l:lvl > 3
                    " **** line:column
                    " padded to reduce jank; virtual/screen column can be seen
                    " by UserLoc() / C-g; %V is extreme jank. whether %c can be
                    " replaced by %v - depends, i guess.

                    let l:stlparts[30] = " [%5l:%4c]"

                    if l:lvl > 4
                        " ***** current window width
                        let l:w = g:statusline_winid
                        let l:stlparts[40] = " ｢" . winwidth(l:w)

                        if l:lvl > 5
                            " ***** current window height
                            let l:stlparts[40] .= "x" . winheight(l:w) . "｣"
                        endif
                    endif
                endif
            endif
        endif

        " show current register
        let l:stlparts[70] = " r%{v:register}"

        let l:stlparts[80] = "%#StatusLineNC#"
        " if fillchars has stl and stlnc, make the rest effectively invisible.
        " vim9+ fcs defines a 'lastline' attribute, so not enough to check for
        " 'stl' without separating colon.
        if &fcs =~# 'stl:' && &fcs =~# 'stlnc:'
            let l:stlparts[80] = "%#Normal#"
        endif

        let l:stlparts[1000] = "%= " . g:u.mark . " "

        let l:s = ''
        for l:key in sort(keys(l:stlparts), 'N')
            let l:s .= l:stlparts[l:key]
        endfor

        return l:s
    endfunction

    " UI support for easily setting info level
    function! UserStatusLevel(lvl)
        " 2023-05-09 small (awful) hack - set statusline to the function
        " defined above only if we need something dynamic..
        "
        " otherwise, just live with the default static statusline defined
        " firther up.

        set statusline=%!UserStatusLine()
        let l:lvl = 3
        if exists('g:u.statusline_level')
            let l:lvl = g:u.statusline_level
        endif

        if type(a:lvl) == 1     " string
            if a:lvl ==# '+'
                let l:lvl = l:lvl + 1
            elseif a:lvl ==# '-'
                let l:lvl = l:lvl - 1
            else
                let l:lvl = str2nr(a:lvl)
            endif
        elseif type(a:lvl) == 0 " number
            let l:lvl = a:lvl
        endif

        let g:u.statusline_level = l:lvl
        redrawstatus!
    endfunction

    command -bar -nargs=1 StatusLevel   call UserStatusLevel(<f-args>)
    command -bar -nargs=1 SL            call UserStatusLevel(<f-args>)
endif   " has patch-8.1.1372

