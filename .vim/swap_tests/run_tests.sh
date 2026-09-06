#!/bin/bash
# scenario tests for the swap handling in 0.vim (UserSwapChoice and the
# UserSwap* helpers), driving real vim sessions with real stale swap files.
#
#   ./run_tests.sh                      # system vim
#   VIM=.../vim-8.1.2110/src/vim VIMRUNTIME=.../runtime ./run_tests.sh
#
# the pure decision tables are covered by ../swap_decision_test.vim; this
# covers what vim itself does around the handler. the vim facts these
# scenarios pin down (checked in memline.c of 9.1 and of iVim's 8.1.2110):
#
# - findswapname() runs the ATTENTION block, SwapExists included, only for
#   the .swp name. .swo, .swn, ... are skipped silently to the next free
#   name; a lone .swo is never noticed at all.
# - v:swapchoice 'r' ignores v:swapname: recovery globs <file>.sw? in every
#   'directory' entry and asks "Enter number of swap file to use" when it
#   finds more than one.
# - a clean swap of a dead pid is deleted before SwapExists fires
#   (swapfile_unchanged()), regardless of the file's mtime.
# - there is no autocmd after ml_recover(); a timer does fire at the
#   hit-enter prompt of the recovery messages, but a command that prints
#   there (:preserve -> "File preserved") nests another prompt and blocks.
# - a SIGKILLed session's swap is only dirty once it has been synced
#   ('updatetime' / 'updatecount' / :preserve).
#
# - bufload() inside SwapExists resets swap_exists_action
#   (buffer_ensure_loaded()), and vim only shows its ATTENTION dialog while
#   that's set: the file then opens as "edit anyway". a timer callback
#   that loads a buffer while the dialog is up is harmless.
#
# harness notes: --cmd (not -c) for 'directory' and the autocmd so they
# apply before the file loads; -c commands run before the main loop, so
# state that depends on a timer step is dumped from a later timer.

set -u
cd "$(dirname "$0")"
VIMRC0=$(cd .. && pwd)/0.vim
export VIM=${VIM:-vim}
PTY=$PWD/pty_vim.py
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
cd "$T"

fails=0
runs=0
check() {   # check DESC TEST-ARGS...
    local desc=$1; shift
    runs=$((runs + 1))
    if ! "$@"; then
        fails=$((fails + 1))
        echo "FAIL: $desc"
        grep -o 'E[0-9]\{3\}: [^"]*' out.txt 2>/dev/null | grep -v 'E325\|E308' | sort -u | sed 's/^/  vim: /'
        grep '^! ' msgs 2>/dev/null | sed 's/^/  msgs: /'
    fi
}
dir_is() {
    local got; got=$(ls dir | sed 's/.*t\.txt//' | tr '\n' ' ')
    [ "$got" = "$1" ] || { echo "  swap dir: '$got' expected '$1'"; false; }
}
log_has() { grep -q -- "$1" log 2>/dev/null; }
out_has() { grep -q -- "$1" out.txt; }
msgs_has() { grep -q -- "$1" msgs 2>/dev/null; }

# the handler and helpers, extracted from 0.vim by name (0.vim itself
# can't be sourced headlessly). the backup helper is stubbed: copies into
# ./bak, overwriting, so repeated runs on one file don't fail.
{
    echo "let g:u = {'swap_dir': './dir//'}"
    echo "set directory=./dir// swapfile"
    for f in UserDateTimeComment UserAppendBuf UserSwapPidAlive \
             UserSwapDecision UserSwapPickSibling UserSwapKeepOne \
             UserSwapMoveAside UserSwapAfterRecover UserSwapMessages \
             UserSwapMessagesFlush UserSwapChoice; do
        awk "/^function! $f\(/,/^endfunction/" "$VIMRC0"
    done
    cat <<'EOF'
function! UserBackupCopyFile(file, ...) abort
    let ext = a:0 > 0 ? a:1 : '.swapchoice'
    call mkdir('bak', 'p')
    let dest = 'bak/' . fnamemodify(a:file, ':t')[-12:] . ext
    call system('cp ' . shellescape(a:file) . ' ' . shellescape(dest))
    return [v:shell_error, dest]
endfunction
command DeleteOldSwap   if exists('b:swapname_old') && filereadable(b:swapname_old)
            \ | call delete(b:swapname_old) | unlet b:swapname_old | endif
autocmd SwapExists *    let v:swapchoice = UserSwapChoice(v:swapname)
autocmd BufWritePost *  DeleteOldSwap
EOF
} > rc.vim
grep -c '^function' rc.vim | grep -q '^12$' || { echo "FAIL: function extraction from 0.vim"; exit 1; }
# non-interactive variant (iVim: has('ios')): conflicts delete instead of prompting
sed "s/!has('ios'), swap_local)/0, swap_local)/" rc.vim > rc_ios.vim

STATE='call writefile(["ro=" . &ro . " mod=" . &modified . " swap=" . swapname("%")[-4:] . " lines=" . join(getline(1,"$"), "|")], "log", "a")'
MSGS='call timer_start(500, {-> writefile(getbufline("!swap-messages", 1, "$"), "msgs")})'
run() {   # run SECONDS kill|quit RC [extra vim args...]
    local secs=$1 mode=$2 rc=$3; shift 3
    rm -f log msgs
    timeout 60 python3 "$PTY" "$secs" "$mode" -- -X -N -u "$rc" -i NONE \
        -c "$STATE" -c "$MSGS" "$@" t.txt > out.txt
}
# a stale, dirty swap: edit, sync, SIGKILL
mk_stale() {
    python3 "$PTY" 2 kill -- -X -N -u NONE -i NONE \
        --cmd 'set directory=./dir// swapfile' \
        --cmd "autocmd SwapExists * let v:swapchoice = 'e'" \
        -c 'normal! Achange' -c 'preserve' t.txt > /dev/null
}
fresh() { rm -rf dir bak; cp -r "$1" dir; printf 'line1\nline2\n' > t.txt; touch -d '2000-01-01 00:00' t.txt; }

$VIM --version | head -2 | tr '\n' ' '; echo
printf 'line1\nline2\n' > t.txt; touch -d '2000-01-01 00:00' t.txt
mkdir dir && mk_stale && mk_stale && cp -r dir pair
check "stale pair created" dir_is '.swo .swp '
mkdir single && cp pair/*swp single/

echo "0. premise: SwapExists fires once, for .swp; 'r' on a pair prompts"
fresh pair
timeout 60 python3 "$PTY" 3 quit -- -X -N -u NONE -i NONE \
    --cmd 'set directory=./dir// swapfile' \
    --cmd "autocmd SwapExists * let v:swapchoice = 'r' | call writefile([v:swapname[-4:]], 'log', 'a')" \
    t.txt > out.txt
check "only .swp fired" bash -c "[ \"\$(cat log | tr '\n' ' ')\" = '.swp ' ]"
check "vim asks which swap" out_has 'Enter number of swap file'

echo "A. pair: recover without a prompt, old swap disposed"
fresh pair; run 4 quit rc.vim
check "A no number prompt" bash -c '! grep -q "Enter number" out.txt'
check "A recovered text" log_has 'lines=line1change|line2'
check "A new session owns .swp" log_has 'swap=.swp'
check "A sibling logged" msgs_has '^deleted sibling'
check "A old swap disposed" msgs_has '^deleted old swap'
check "A swap dir empty after quit" dir_is ''
check "A date comment heads each block" bash -c '[ "$(grep -c "^-- date" msgs)" = 2 ]'

echo "B. pair: recover, killed at the hit-enter prompt, reopen"
fresh pair; run 5 kill rc.vim
check "B1 recovered text" log_has 'lines=line1change|line2'
check "B1 only the new .swp survives the kill" dir_is '.swp '
run 5 quit rc.vim
check "B2 reopen recovers" log_has 'lines=line1change|line2'
check "B2 no number prompt" bash -c '! grep -q "Enter number" out.txt'
check "B2 swap dir empty after quit" dir_is ''

echo "C. single stale .swp"
fresh single; run 4 quit rc.vim
check "C recovered text" log_has 'lines=line1change|line2'
check "C old swap moved aside then disposed" msgs_has '^moved aside'
check "C swap dir empty after quit" dir_is ''

echo "D. pair, file newer than the swaps: conflict"
# interactive: the handler returns '' and vim's own dialog must appear
# (it doesn't if anything in the handler loads a buffer - see
# UserSwapMessages). answer it with real keys.
fresh pair; touch t.txt
KEYS='2:o' run 5 quit rc.vim
check "D dialog shown" out_has 'pen Read-Only, (E)dit anyway'
check "D decision was to prompt" msgs_has '^decision: PROMPT'
check "D keeper renamed to .swp for the dialog" msgs_has '^renamed .*swo -> .*swp'
check "D 'o' at the dialog: read-only" log_has 'ro=1'
fresh pair; touch t.txt
KEYS='2:r' run 5 quit rc.vim
check "D 'r' at the dialog recovers the keeper" log_has 'lines=line1change|line2'
fresh pair; touch t.txt; run 4 quit rc_ios.vim
check "D2 non-interactive: deleted" msgs_has '^decision: delete'
check "D2 swap dir empty" dir_is ''
check "D2 both backups kept" bash -c 'ls bak | grep -q deleted-swap && ls bak | grep -q sibling-swap'

echo "F. after-recovery callback branches that the scenarios don't reach"
# vim only parses a function line when it runs; an untested branch can hide
# a syntax error (E114 from a comment after a bare :return, seen on iVim).
# old swap already gone: must log, not error.
$VIM -N -u NONE -i NONE -es -c 'source rc.vim' \
    -c 'try | call UserSwapAfterRecover(bufnr("%"), 0) | call UserSwapMessagesFlush(0) | catch | call writefile([v:exception], "f.err") | endtry' \
    -c 'call writefile(getbufline("!swap-messages", 1, "$"), "f.out")' -c 'qa!'
check "F old swap gone: no error" bash -c '! [ -e f.err ]'
check "F old swap gone: logged" bash -c 'grep -q "already gone" f.out'
# wrong buffer: must log, not error
$VIM -N -u NONE -i NONE -es -c 'source rc.vim' \
    -c 'try | call UserSwapAfterRecover(bufnr("%") + 100, 0) | call UserSwapMessagesFlush(0) | catch | call writefile([v:exception], "f2.err") | endtry' \
    -c 'call writefile(getbufline("!swap-messages", 1, "$"), "f2.out")' -c 'qa!'
check "F wrong buffer: no error" bash -c '! [ -e f2.err ]'
check "F wrong buffer: logged" bash -c 'grep -q "not the current buffer" f2.out'

echo "E. live session on .swp, stale .swo beside it"
fresh single; rm -rf dir; mkdir dir
python3 "$PTY" 12 quit -- -X -N -u NONE -i NONE --cmd 'set directory=./dir// swapfile' t.txt > /dev/null &
sleep 2; cp pair/*swo dir/
run 4 quit rc.vim
check "E read-only" log_has 'ro=1'
check "E live swap untouched, stale sibling removed" dir_is '.swp '
check "E stale sibling backed up" bash -c 'ls bak | grep -q "swo.sibling-swap"'
wait

echo
if [ "$fails" = 0 ]; then
    echo "PASS: all $runs checks"
else
    echo "FAILURES: $fails/$runs"
    exit 1
fi
