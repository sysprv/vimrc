" decision-table test for the pure swap functions in 0.vim
" (UserSwapPidAlive, UserSwapDecision, UserSwapPickSibling).
"
" usage, from any directory:
"   vim -N -u NONE -i NONE -es -c 'source /path/to/swap_decision_test.vim'
" prints the table results; exits nonzero on any failure.
"
" 0.vim can't be sourced headlessly (dies on highlight groups long
" before the swap section), so the functions are extracted by name
" and sourced on their own - they were kept pure exactly for this.

let s:lines = readfile(expand('<sfile>:p:h') . '/0.vim')
let s:keep = []
let s:in = 0
for s:line in s:lines
    if !s:in && s:line =~# '^function! UserSwap\%(PidAlive\|Decision\|PickSibling\)('
        let s:in = 1
    endif
    if s:in
        call add(s:keep, s:line)
        if s:line =~# '^endfunction'
            let s:in = 0
        endif
    endif
endfor
let s:tmp = tempname()
call writefile(s:keep, s:tmp)
execute 'source' fnameescape(s:tmp)
call delete(s:tmp)
if !exists('*UserSwapPidAlive') || !exists('*UserSwapDecision')
            \ || !exists('*UserSwapPickSibling')
    call setline(1, 'FAIL: could not extract functions from 0.vim')
    %print
    cquit
endif

let s:fails = 0
let s:runs = 0

function! s:Case(desc, expected, sw, filetime, myhost, pid_alive, interactive,
            \ swap_local)
    let s:runs += 1
    let got = UserSwapDecision(a:sw, a:filetime, a:myhost, a:pid_alive,
                \ a:interactive, a:swap_local)[0]
    if got !=# a:expected
        let s:fails += 1
        call append('$', 'FAIL: ' . a:desc . ': expected ''' . a:expected
                    \ . ''' got ''' . got . '''')
    endif
endfunction

let s:T = 1000000000     " arbitrary file mtime epoch

" 1. unreadable swap -> prompt
call s:Case('swapinfo error', '',
            \ {'error': 'Cannot open file'}, s:T, 'h', 0, 1, 1)
" 2. different host, swap outside local dir (shared mount) -> read-only,
"    even if dirty and process dead
call s:Case('different host, non-local swap', 'o',
            \ {'host': 'other', 'dirty': 1, 'pid': 1, 'mtime': s:T}, s:T, 'h', 0, 1, 0)
" 2a. different host but swap in local central dir (hostname drift) ->
"     host mismatch ignored, dirty dead swap recovers
call s:Case('hostname drift, local swap, recover', 'r',
            \ {'host': 'old-name', 'dirty': 1, 'pid': 1, 'mtime': s:T}, s:T, 'h', 0, 1, 1)
" 2b. hostname drift, local swap, owner alive -> still read-only
call s:Case('hostname drift, local swap, pid alive', 'o',
            \ {'host': 'old-name', 'dirty': 1, 'pid': 1, 'mtime': s:T}, s:T, 'h', 1, 1, 1)
" 2c. hostname drift, local swap, clean + file slightly newer -> read-only
call s:Case('hostname drift, local swap, clean', 'o',
            \ {'host': 'old-name', 'dirty': 0, 'pid': 1, 'mtime': s:T - 5}, s:T, 'h', 0, 1, 1)
" 3. owning process alive -> read-only, even if dirty
call s:Case('pid alive', 'o',
            \ {'host': 'h', 'dirty': 1, 'pid': 1, 'mtime': s:T}, s:T, 'h', 1, 1, 1)
" 4. dead process, dirty, swap same age as file -> recover
call s:Case('dirty, swap not older', 'r',
            \ {'host': 'h', 'dirty': 1, 'pid': 1, 'mtime': s:T}, s:T, 'h', 0, 1, 1)
" 5. dead process, dirty, swap newer than file -> recover
call s:Case('dirty, swap newer', 'r',
            \ {'host': 'h', 'dirty': 1, 'pid': 1, 'mtime': s:T + 5}, s:T, 'h', 0, 1, 1)
" 6. dirty conflict (file newer), interactive -> prompt
call s:Case('dirty conflict, interactive', '',
            \ {'host': 'h', 'dirty': 1, 'pid': 1, 'mtime': s:T - 5}, s:T, 'h', 0, 1, 1)
" 7. dirty conflict (file newer), non-interactive -> delete
call s:Case('dirty conflict, non-interactive', 'd',
            \ {'host': 'h', 'dirty': 1, 'pid': 1, 'mtime': s:T - 5}, s:T, 'h', 0, 0, 1)
" 8. clean, file much newer (>= 3600) -> delete
call s:Case('clean, file much newer', 'd',
            \ {'host': 'h', 'dirty': 0, 'pid': 1, 'mtime': s:T - 3600}, s:T, 'h', 0, 1, 1)
" 9. clean, swap mtime >= file mtime -> recover
call s:Case('clean, swap newer', 'r',
            \ {'host': 'h', 'dirty': 0, 'pid': 1, 'mtime': s:T + 5}, s:T, 'h', 0, 1, 1)
" 10. clean, file slightly newer -> read-only
call s:Case('clean, file slightly newer', 'o',
            \ {'host': 'h', 'dirty': 0, 'pid': 1, 'mtime': s:T - 5}, s:T, 'h', 0, 1, 1)

" sibling pick: [name, swapinfo, pid_alive] candidates -> name to keep.
function! s:Pick(desc, expected, cands)
    let s:runs += 1
    let got = UserSwapPickSibling(a:cands)
    if got !=# a:expected
        let s:fails += 1
        call append('$', 'FAIL: ' . a:desc . ': expected ''' . a:expected
                    \ . ''' got ''' . got . '''')
    endif
endfunction

" P1. both dirty, dead -> newest
call s:Pick('both dirty, newest wins', 'a.swo',
            \ [['a.swp', {'dirty': 1, 'mtime': s:T}, 0],
            \  ['a.swo', {'dirty': 1, 'mtime': s:T + 5}, 0]])
" P2. dirty beats clean even when older
call s:Pick('dirty beats newer clean', 'a.swo',
            \ [['a.swp', {'dirty': 0, 'mtime': s:T + 5}, 0],
            \  ['a.swo', {'dirty': 1, 'mtime': s:T}, 0]])
" P3. a live session's swap beats everything
call s:Pick('live beats dirty', 'a.swo',
            \ [['a.swp', {'dirty': 1, 'mtime': s:T + 5}, 0],
            \  ['a.swo', {'dirty': 0, 'mtime': s:T}, 1]])
" P4. unreadable candidates are skipped
call s:Pick('garbage skipped', 'a.swo',
            \ [['a.swp', {'error': 'Not a swap file'}, 0],
            \  ['a.swo', {'dirty': 0, 'mtime': s:T}, 0]])
" P5. nothing readable -> ''
call s:Pick('all garbage', '',
            \ [['a.swp', {'error': 'x'}, 0], ['a.swo', {'error': 'y'}, 0]])
" P6. tie on rank and mtime -> first listed (stable)
call s:Pick('tie keeps first', 'a.swp',
            \ [['a.swp', {'dirty': 1, 'mtime': s:T}, 0],
            \  ['a.swo', {'dirty': 1, 'mtime': s:T}, 0]])

" pid liveness. pid 0 is never alive anywhere; real checks need /proc.
let s:runs += 1
if UserSwapPidAlive(0) != 0
    let s:fails += 1 | call append('$', 'FAIL: pid 0 should never be alive')
endif
if isdirectory('/proc')
    let s:runs += 2
    if UserSwapPidAlive(getpid()) != 1
        let s:fails += 1 | call append('$', 'FAIL: own pid should be alive')
    endif
    if UserSwapPidAlive(999999999) != 0
        let s:fails += 1 | call append('$', 'FAIL: bogus pid should be dead')
    endif
endif

call setline(1, s:fails == 0
            \ ? 'PASS: all ' . s:runs . ' cases'
            \ : 'FAILURES: ' . s:fails . '/' . s:runs)
%print
if s:fails
    cquit
endif
qa!
