#!/bin/sh
# ===================================================================
# NON-INTERACTIVE TEST SUITE FOR ../python.vim
# ===================================================================
# Usage: run_tests.sh [path-to-indent-script]
#
# Exercises the plugin by driving real vim in silent ex mode:
#   - reindent (gg=G) idempotence on correctly indented fixtures,
#     on both engines (python3/tokenize, and the VimL fallback via a
#     sed-patched copy with has('python3') forced to 0)
#   - tokenize survival on inconsistently dedented code
#   - insert-mode typing simulations (indentkeys must fire)
#
# See ../CLAUDE.md for the invariants these tests enforce.
# ===================================================================
set -u

DIR=$(cd "$(dirname "$0")" && pwd)
PLUGIN=${1:-$DIR/../python.vim}
WORK=$(mktemp -d) || exit 1
trap 'rm -rf "$WORK"' EXIT INT TERM

FAIL=0
VIMBASE="vim -N -u NONE -i NONE -es"

have_py3=0
if vim --version | grep -q '+python3'; then
    have_py3=1
fi

reindent() { # $1=plugin $2=infile $3=outfile
    $VIMBASE \
        -c 'set shiftwidth=4 expandtab' \
        -c "source $1" \
        -c 'normal! gg=G' -c "w! $3" -c 'qa!' "$2" 2>/dev/null
}

check() { # $1=name $2=expected $3=actual
    if diff -u "$2" "$3" >/dev/null 2>&1; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"; diff -u "$2" "$3"; FAIL=1
    fi
}

# --- reindent idempotence (python3 engine and VimL fallback) -------
sed "s/has('python3')/0/g" "$PLUGIN" > "$WORK/fallback_python.vim"
for f in correct strings; do
    if [ "$have_py3" -eq 1 ]; then
        reindent "$PLUGIN" "$DIR/$f.py" "$WORK/$f.out"
        check "reindent $f.py (python3)" "$DIR/$f.py" "$WORK/$f.out"
    else
        echo "SKIP: reindent $f.py (python3) - vim lacks +python3"
    fi
    reindent "$WORK/fallback_python.vim" "$DIR/$f.py" "$WORK/$f.fb.out"
    check "reindent $f.py (VimL fallback)" "$DIR/$f.py" "$WORK/$f.fb.out"
done

# --- broken dedent must not raise through py3eval ------------------
if [ "$have_py3" -eq 1 ]; then
    $VIMBASE \
        -c "source $PLUGIN" \
        -c 'let res = "??" | try | let res = "ret " . py3eval("check_in_string(2)") | catch | let res = "EXCEPTION: " . v:exception | endtry' \
        -c "call writefile([res], '$WORK/bad.result')" -c 'qa!' \
        "$DIR/bad_dedent.py" 2>/dev/null
    case $(cat "$WORK/bad.result") in
        "ret "*) echo "PASS: tokenize survives inconsistent dedent" ;;
        *) echo "FAIL: tokenize on bad dedent -> $(cat "$WORK/bad.result")"; FAIL=1 ;;
    esac
else
    echo "SKIP: tokenize bad-dedent probe - vim lacks +python3"
fi

# --- interactive typing simulations --------------------------------
typed() { # $1=name $2=keys $3=expected-file
    $VIMBASE \
        -c 'set shiftwidth=4 expandtab' \
        -c "source $PLUGIN" \
        -c "execute \"normal! i$2\"" \
        -c "w! $WORK/typed.out" -c 'qa!' /dev/null 2>/dev/null
    check "typing $1" "$3" "$WORK/typed.out"
}

printf 'if x > 0:\n    y = 1\n    return y\nelse:\n    y = 2\n' > "$WORK/exp_ifelse.py"
typed "if/else with terminal dedent" 'if x > 0:\<CR>y = 1\<CR>return y\<CR>else:\<CR>y = 2' "$WORK/exp_ifelse.py"

printf 'match cmd:\n    case 1:\n        return 1\n    case _:\n        return 2\n' > "$WORK/exp_case.py"
typed "match/case" 'match cmd:\<CR>case 1:\<CR>return 1\<CR>case _:\<CR>return 2' "$WORK/exp_case.py"

printf 'data = {\n    "key": 1,\n}\nx = f(\n)\n' > "$WORK/exp_brackets.py"
typed "brackets" 'data = {\<CR>\"key\": 1,\<CR>}\<CR>x = f(\<CR>)' "$WORK/exp_brackets.py"

printf 'def f():\n    return 1\n\n\ndef g():\n    return 2\n' > "$WORK/exp_blank.py"
typed "two-blank-line reset" 'def f():\<CR>return 1\<CR>\<CR>\<CR>def g():\<CR>return 2' "$WORK/exp_blank.py"

printf 'def f():\n    doc = """\nline one\nline two\n"""\n    return doc\n' > "$WORK/exp_docstring.py"
typed "across a docstring" 'def f():\<CR>doc = \"\"\"\<CR>\<C-D>line one\<CR>line two\<CR>\"\"\"\<CR>return doc' "$WORK/exp_docstring.py"

exit $FAIL
