# CLAUDE.md — Python indent plugin

Guidance for Claude when working on `python.vim` (the COLOSSUS Python
indentation guidance program) and its test suite.

## Ownership and demarcation — READ FIRST

This directory is the **only** part of the repository Claude maintains.
Everything else — `0.vim`, `.vimrc`, `.gvimrc`, `statusline_defs.vim`,
`colors/` — is human-only territory: read it for context when needed,
**never edit it**. Do not create a `CLAUDE.md` at the repo root or
anywhere outside this directory; plugin documentation lives here.

## Comment style: NASA Apollo Guidance Computer (AGC)

`python.vim` is written in the voice of an Apollo-era guidance program
and this style must be preserved in every edit:

- VimL comments are **ALL CAPS**, narrated as mission commentary
  ("TRANS-LUNAR INJECTION: COLON DETECTED", "CONTACT LIGHT",
  "HOUSTON, ALL IS WELL"). Dry humor is welcome; the technical content
  must stay accurate — the jokes decorate real documentation, they
  never replace it.
- Sections are boxed with `===` banners; routines get `---` banners.
  Helpers are titled `SUBROUTINE N: <NAME>`; the indentexpr entry point
  is the `MAJOR MODE`.
- Behavior-affecting comments include concrete `PYTHON EXAMPLE` blocks
  showing input lines and the expected indent, with `<-` annotations.
- Significant behavior changes are marked in-place as
  `REVISION N.M: <what changed>` (see existing examples).
- Python code inside the `py3 << ENDPYTHON` block uses conventional
  lowercase comments and docstrings — the AGC voice is VimL-only.
- Attribution jokes in the header ("BY NASA 1969-2025", "REFER ALL
  COMPLAINTS TO MARGARET HAMILTON") stay.

## Architecture

- Entry point `UserGetPythonIndent()` is set as `indentexpr`, with
  `indentkeys` triggering on new lines, closing brackets, the block
  keywords (`else`, `elif`, `except`, `finally`, `case`), and the
  definition snap triggers (`=def\ `, `=class\ ` — trailing spaces
  intentional — and `=@`). `<:>` is deliberately absent (see
  invariant 6).
- Two engines, decided at call time by `has('python3')`:
  - **python3 / tokenize** (primary): `TokenCache` tokenizes the whole
    buffer once per `b:changedtick`, deriving multi-line string ranges
    and per-line bracket depth.
  - **VimL fallback**: per-line heuristics (`s:StripStringsAndComments`,
    triple-quote parity scan, single-line bracket counting).
- **Every behavior must work on both engines.** Each capability has a
  `s:Fn()` wrapper that dispatches to `py3eval(...)` or `s:FnVimL(...)`;
  when changing behavior, change both paths and run the suite in both
  modes (the test runner does this automatically).

## Invariants (the test suite enforces these)

1. **Reindent is idempotent**: `gg=G` over correctly indented Python
   must produce no changes.
2. **String cargo is sacred**: a line that *begins* inside a
   multi-line string returns `-1` (leave indent alone). The line after
   a closing `"""` takes its reference indent from the line where the
   string *started*, never from the closing quotes' column.
3. **`case` indents one shiftwidth inside its `match`**; the other
   block keywords align flush with their opener.
4. **Terminal-statement dedent** (`return`/`break`/`continue`/`pass`/
   `raise`) applies one level to fresh lines only — a non-empty line
   already sitting at a shallower indent keeps it (how many levels to
   drop is ambiguous; respect manual guidance).
5. **Blank-line dedent ramp at EOF** (Revision 5.0, replaced the old
   reset-to-zero cliff): the first blank line holds altitude (PEP 8
   paragraph spacing); every further blank line dedents one level,
   floored at 0. The base is colon/terminal-aware, which makes PEP 8
   spacing land naturally: one blank after a method's `return` →
   sibling-method level; two blanks → top level. The ramp **never**
   fires inside unclosed brackets (blank lines in a literal are
   formatting — guarded by cumulative bracket depth) or inside
   strings, including *still-open* docstrings (the open string's
   start line is recovered from the tokenizer's error; the VimL
   engine gets this for free from quote parity). Mid-file gaps
   inherit indent from the code below instead of ramping.
6. **Definition keyword snap** (Revision 5.1): typing `def ` /
   `class ` (triggers include the trailing space — that's what keeps
   `defaults`/`classes` from ever firing) or `@` on a fresh line
   snaps to the previous sibling definition's indent. Rules: bare
   keyword only (complete `def foo():` lines never snap, so `=`
   reindent is unaffected); dedent-only; a `def` under a decorator
   glues to the decorator's indent; no snap when the previous line
   opens a block or inside brackets; the upward scan walks the
   indent frontier using structural-line flags (skipping string
   content — including doctest prose — bracket continuations, and
   comment-only lines), walks *through* `if`/`for`/`try` openers,
   and stops at a `class` opener strictly above (a def never
   escapes its class implicitly — first method after class
   attributes stays put). Known ambiguity: a nested def typed after
   body code snaps to the enclosing def's level (siblings are more
   common than closures; one Ctrl-T undoes). Also in 5.1: `<:>` was
   removed from `indentkeys` — every keyword has its own `=word`
   trigger, and the colon retrigger yanked hand-adjusted lines on
   dict/slice/annotation colons and would have undone the snap at
   the `:` of `def b():`.
7. **tokenize error handling**: catch `tokenize.TokenError` and
   `SyntaxError` separately. `IndentationError` (a `SyntaxError`
   subclass) is raised for inconsistent dedents — routine in
   half-typed code — and newer Pythons (3.12+) raise `SyntaxError`
   from tokenize more often. An uncaught exception escapes `py3eval`
   and breaks the indentexpr. When the error is an unterminated
   multi-line string, record its start line (`open_string_start`) so
   string protection covers docstrings being typed.
8. **No `b:did_indent` guard, on purpose**: this file must run even if
   the distribution's indent plugin ran first. Consequence: if two
   copies of this file are on the runtimepath, the later one silently
   wins (`function!` redefinition). Isolate tests with
   `--cmd 'set rtp=<dir>,$VIMRUNTIME'`.
9. Requires Vim >= 8.02 (`v:version < 802` guard at the top).

## Testing

Run `tests/run_tests.sh` (from anywhere; optionally pass an alternate
plugin path). It exercises, non-interactively:

- reindent idempotence (`gg=G`) on fixtures, on **both** engines — the
  fallback is tested by `sed`-ing `has('python3')` to `0` in a copy;
- survival of `tokenize` on inconsistently dedented code;
- insert-mode typing simulations, also on both engines, via
  `execute "normal! i...\<CR>..."` so `indentkeys` actually fire:
  if/else terminal dedent, match/case, brackets, typing across a
  docstring, the four ramp behaviors (sibling method, top level,
  step-per-blank, ground-level clamp), the two no-ramp guards
  (open brackets, unclosed docstring), and the seven definition-snap
  cases (sibling def, stay-inside-class, walk through if-blocks,
  decorator + glue, sibling class, `defaults` non-trigger,
  async def).

Recipe for one-off experiments:

    vim -N -u NONE -i NONE -es \
        -c 'set shiftwidth=4 expandtab' \
        -c 'source python.vim' \
        -c 'normal! gg=G' -c 'w! /tmp/out.py' -c 'qa!' input.py

Do **not** smoke-test through the real vimrc in `-es` mode: `0.vim`
hits `E411: Highlight group not found: UserUnicodeWhitespace` when
headless and aborts before `filetype indent on`, so the plugin never
loads and failures are silent.

## Deployment

The repo is not symlinked into `$HOME`. `./INSTALL` (repo root) copies
files into the live config; from this directory it copies **only**
`python.vim` to `~/.vim/indent/`. The live `~/.vim/indent/` also holds
the user's manual backups (`python.vim-`, `python.vim-3`, ...) — never
touch those. Before suggesting `./INSTALL`, diff the other files it
copies against their live counterparts so a newer live edit is not
clobbered.
