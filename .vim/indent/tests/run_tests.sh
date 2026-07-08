#!/bin/sh
# ===================================================================
# NON-INTERACTIVE TEST SUITE FOR ../python.vim
# ===================================================================
# Usage: run_tests.sh [path-to-indent-script]
#
# Exercises the plugin by driving real vim in silent ex mode:
#   - reindent (gg=G) idempotence on correctly indented fixtures
#   - tokenize survival on inconsistently dedented code
#   - insert-mode typing simulations (indentkeys must fire):
#     block/dedent flows, the blank-line dedent ramp, and the
#     no-ramp guards (open brackets, unclosed docstrings)
#
# Everything except the tokenize probe runs on BOTH engines: the
# python3/tokenize primary, and the VimL fallback via a sed-patched
# copy with has('python3') forced to 0.
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

sed "s/has('python3')/0/g" "$PLUGIN" > "$WORK/fallback_python.vim"

plugin_for() { # $1=engine (py3|viml)
    if [ "$1" = py3 ]; then echo "$PLUGIN"; else echo "$WORK/fallback_python.vim"; fi
}

engine_available() { # $1=engine
    [ "$1" = viml ] || [ "$have_py3" -eq 1 ]
}

check() { # $1=name $2=expected $3=actual
    if diff -u "$2" "$3" >/dev/null 2>&1; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"; diff -u "$2" "$3"; FAIL=1
    fi
}

# --- reindent idempotence ------------------------------------------
reindent() { # $1=plugin $2=infile $3=outfile
    $VIMBASE \
        -c 'set shiftwidth=4 expandtab' \
        -c "source $1" \
        -c 'normal! gg=G' -c "w! $3" -c 'qa!' "$2" 2>/dev/null
}

for f in correct strings; do
    for eng in py3 viml; do
        if engine_available $eng; then
            reindent "$(plugin_for $eng)" "$DIR/$f.py" "$WORK/$f.$eng.out"
            check "reindent $f.py ($eng)" "$DIR/$f.py" "$WORK/$f.$eng.out"
        else
            echo "SKIP: reindent $f.py ($eng) - vim lacks +python3"
        fi
    done
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

# --- interactive typing simulations (both engines) -----------------
typed() { # $1=name $2=keys $3=expected-file
    for eng in py3 viml; do
        if ! engine_available $eng; then
            echo "SKIP: typing $1 ($eng) - vim lacks +python3"
            continue
        fi
        $VIMBASE \
            -c 'set shiftwidth=4 expandtab' \
            -c "source $(plugin_for $eng)" \
            -c "execute \"normal! i$2\"" \
            -c "w! $WORK/typed.out" -c 'qa!' /dev/null 2>/dev/null
        check "typing $1 ($eng)" "$3" "$WORK/typed.out"
    done
}

printf 'if x > 0:\n    y = 1\n    return y\nelse:\n    y = 2\n' > "$WORK/exp_ifelse.py"
typed "if/else with terminal dedent" 'if x > 0:\<CR>y = 1\<CR>return y\<CR>else:\<CR>y = 2' "$WORK/exp_ifelse.py"

printf 'match cmd:\n    case 1:\n        return 1\n    case _:\n        return 2\n' > "$WORK/exp_case.py"
typed "match/case" 'match cmd:\<CR>case 1:\<CR>return 1\<CR>case _:\<CR>return 2' "$WORK/exp_case.py"

printf 'data = {\n    "key": 1,\n}\nx = f(\n)\n' > "$WORK/exp_brackets.py"
typed "brackets" 'data = {\<CR>\"key\": 1,\<CR>}\<CR>x = f(\<CR>)' "$WORK/exp_brackets.py"

printf 'def f():\n    doc = """\nline one\nline two\n"""\n    return doc\n' > "$WORK/exp_docstring.py"
typed "across a docstring" 'def f():\<CR>doc = \"\"\"\<CR>\<C-D>line one\<CR>line two\<CR>\"\"\"\<CR>return doc' "$WORK/exp_docstring.py"

# --- the blank-line dedent ramp ------------------------------------
# ONE blank after a method's return -> sibling method level (PEP 8)
printf 'class C:\n    def a(self):\n        return 1\n\n    def b(self):\n        pass\n' > "$WORK/exp_ramp1.py"
typed "ramp: 1 blank after return = sibling method" 'class C:\<CR>def a(self):\<CR>return 1\<CR>\<CR>def b(self):\<CR>pass' "$WORK/exp_ramp1.py"

# TWO blanks after a method's return -> top level (PEP 8)
printf 'class C:\n    def a(self):\n        return 1\n\n\nx = 1\n' > "$WORK/exp_ramp2.py"
typed "ramp: 2 blanks after return = top level" 'class C:\<CR>def a(self):\<CR>return 1\<CR>\<CR>\<CR>x = 1' "$WORK/exp_ramp2.py"

# non-terminal body: blank holds, each further blank steps out once
printf 'class C:\n    def a(self):\n        x = 1\n\n\n    def b(self):\n        pass\n' > "$WORK/exp_ramp3.py"
typed "ramp: steps one level per extra blank" 'class C:\<CR>def a(self):\<CR>x = 1\<CR>\<CR>\<CR>def b(self):\<CR>pass' "$WORK/exp_ramp3.py"

# ramp clamps at column zero
printf 'def f():\n    return 1\n\n\ndef g():\n    return 2\n' > "$WORK/exp_ramp4.py"
typed "ramp: clamps at ground level" 'def f():\<CR>return 1\<CR>\<CR>\<CR>def g():\<CR>return 2' "$WORK/exp_ramp4.py"

# --- no-ramp guards -------------------------------------------------
# blank lines inside an unclosed bracket are formatting, not a gap
printf 'data = {\n    "a": 1,\n\n\n    "b": 2,\n' > "$WORK/exp_guard_bracket.py"
typed "no ramp inside open brackets" 'data = {\<CR>\"a\": 1,\<CR>\<CR>\<CR>\"b\": 2,' "$WORK/exp_guard_bracket.py"

# blank lines inside a still-unclosed docstring are prose, not a gap
printf 'def f():\n    doc = """\n    para one\n\n\n    para two\n' > "$WORK/exp_guard_string.py"
typed "no ramp inside unclosed docstring" 'def f():\<CR>doc = \"\"\"\<CR>para one\<CR>\<CR>\<CR>para two' "$WORK/exp_guard_string.py"

# --- the definition keyword snap ------------------------------------
# def after a non-terminal body + one blank -> sibling method level
printf 'class C:\n    def a(self):\n        x = 1\n\n    def b(self):\n        pass\n' > "$WORK/exp_snap1.py"
typed "snap: def after non-terminal body" 'class C:\<CR>def a(self):\<CR>x = 1\<CR>\<CR>def b(self):\<CR>pass' "$WORK/exp_snap1.py"

# first method after class attributes must NOT escape the class
printf 'class C:\n    x = 1\n\n    def __init__(self):\n        pass\n' > "$WORK/exp_snap2.py"
typed "snap: first method after attributes stays" 'class C:\<CR>x = 1\<CR>\<CR>def __init__(self):\<CR>pass' "$WORK/exp_snap2.py"

# the scan walks through non-class openers (if/for/try)
printf 'class C:\n    def a(self):\n        if x:\n            y()\n\n    def b(self):\n        pass\n' > "$WORK/exp_snap3.py"
typed "snap: def after if-block finds sibling" 'class C:\<CR>def a(self):\<CR>if x:\<CR>y()\<CR>\<CR>def b(self):\<CR>pass' "$WORK/exp_snap3.py"

# decorator snaps like def; the def below glues to the decorator
printf 'class C:\n    def a(self):\n        x = 1\n\n    @property\n    def b(self):\n        pass\n' > "$WORK/exp_snap4.py"
typed "snap: decorator + glued def" 'class C:\<CR>def a(self):\<CR>x = 1\<CR>\<CR>@property\<CR>def b(self):\<CR>pass' "$WORK/exp_snap4.py"

# class prefers a sibling class (here: back to top level)
printf 'class C:\n    def a(self):\n        x = 1\n\n\nclass D:\n    pass\n' > "$WORK/exp_snap5.py"
typed "snap: class seeks sibling class" 'class C:\<CR>def a(self):\<CR>x = 1\<CR>\<CR>\<CR>class D:\<CR>pass' "$WORK/exp_snap5.py"

# identifiers with keyword prefixes must never trigger the snap
printf 'class C:\n    def a(self):\n        x = 1\n        defaults = 2\n' > "$WORK/exp_snap6.py"
typed "snap: 'defaults' does not trigger" 'class C:\<CR>def a(self):\<CR>x = 1\<CR>defaults = 2' "$WORK/exp_snap6.py"

# async def snaps like def
printf 'class C:\n    def a(self):\n        x = 1\n\n    async def b(self):\n        pass\n' > "$WORK/exp_snap7.py"
typed "snap: async def" 'class C:\<CR>def a(self):\<CR>x = 1\<CR>\<CR>async def b(self):\<CR>pass' "$WORK/exp_snap7.py"

exit $FAIL
