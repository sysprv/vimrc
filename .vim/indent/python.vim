" ===================================================================
" COLOSSUS - PYTHON INDENTATION GUIDANCE PROGRAM
" ===================================================================
"
" BY NASA  1969-2025
" REVISED BY CREW FOR EXTENDED MISSION PARAMETERS
"
" THIS PROGRAM PROVIDES AUTOMATIC GUIDANCE FOR PYTHON INDENTATION
" DURING ALL PHASES OF CODE ENTRY. IT IS HOPED THAT THE CREW WILL
" FIND THIS USEFUL. IF NOT, PLEASE FILE ANOMALY REPORT.
"
" REFER ALL COMPLAINTS TO MARGARET HAMILTON.
"
" FEATURES:
"   - BLOCK INDENTATION AFTER COLON (DEF/IF/FOR/WHILE/ETC)
"   - DEDENT AFTER TERMINAL STATEMENTS (RETURN/BREAK/CONTINUE/PASS/RAISE)
"   - KEYWORD ALIGNMENT (ELSE/ELIF/EXCEPT/FINALLY ALIGN WITH OPENER)
"   - BRACKET CONTINUATION (OPEN PAREN/BRACKET/BRACE)
"   - TWO-BLANK-LINE RESET (ONLY AT END OF FILE)
"
" ===================================================================

" ===================================================================
"
" IMPORTANT: DON'T 'finish' IF 'b:did_indent' IS PRESENT. THIS MAY BE
" SET FROM THE VIM DISTRIBUTION'S DEFAULT INDENT PLUGIN.
"
" ALTERNATIVELY, PLACE THIS FILE in ~/.vim/after/indent/.
"
" ===================================================================

" -------------------------------------------------------------------
" MAJOR MODE: INDENTATION COMPUTATION
" -------------------------------------------------------------------
" THIS IS THE MAIN GUIDANCE ROUTINE. IT DECIDES HOW FAR RIGHT THE
" CREW SHOULD POSITION THEIR CODE. THE MATHEMATICS ARE NOT AS
" COMPLEX AS LUNAR ORBIT INSERTION BUT THE CREW SHOULD STILL
" TRUST THE COMPUTER.
" -------------------------------------------------------------------
function! UserGetPythonIndent() abort
    " V:LNUM IS THE LINE NUMBER BEING PROCESSED
    " TRANSMITTED FROM MISSION CONTROL (VIM)
    let lnum = v:lnum

    " FIRST LINE IS ALWAYS AT ORIGIN - LIKE LEAVING THE LAUNCH PAD
    if lnum == 1
        return 0
    endif

    " ACQUIRE PREVIOUS NON-BLANK LINE FOR NAVIGATION REFERENCE
    " IF WE CANNOT FIND IT, WE ARE LOST IN SPACE - RETURN TO ORIGIN
    let pnum = prevnonblank(lnum - 1)
    if pnum == 0
        return 0
    endif

    " ---------------------------------------------------------------
    " PROGRAM ALARM: BLANK LINE GAP DETECTION
    " ---------------------------------------------------------------
    " COUNT THE VOID BETWEEN US AND THE LAST SIGN OF LIFE.
    " IF GAP EXCEEDS 2 LINES, WE MUST DECIDE: ARE WE STARTING A
    " NEW MISSION (RESET TO ZERO) OR MERELY INSERTING INTO AN
    " EXISTING TRAJECTORY?
    "
    " IF AT END OF FILE -> RESET TO ZERO (NEW TOP-LEVEL BLOCK)
    " IF CODE EXISTS BELOW -> INHERIT FROM TERRAIN BELOW
    "
    " THE LOGIC IS SOUND. PROBABLY.
    " ---------------------------------------------------------------
    let empty_lines = 0
    let check_line = lnum - 1
    while check_line > 0 && getline(check_line) =~ '^\s*$'
        let empty_lines = empty_lines + 1
        let check_line = check_line - 1
    endwhile

    if empty_lines >= 2
        " TWO OR MORE LINES OF VOID DETECTED
        if s:AtEndOfFile(lnum)
            " AFFIRMATIVE - WE ARE IN FREE SPACE
            " THE EAGLE HAS LANDED (AT COLUMN ZERO)
            return 0
        else
            " NEGATIVE - THERE IS TERRAIN BELOW
            " ACQUIRE TARGET INDENTATION FROM SURFACE
            let next_nonblank = s:NextNonBlankLine(lnum)
            if next_nonblank > 0
                return indent(next_nonblank)
            endif
            " BACKUP GUIDANCE - BETTER SAFE THAN SORRY
            return indent(pnum)
        endif
    endif

    " ---------------------------------------------------------------
    " NORMAL GUIDANCE SEQUENCE
    " NO SIGNIFICANT GAP - PROCEED WITH STANDARD CALCULATIONS
    " ---------------------------------------------------------------

    " ACQUIRE LINE DATA FOR ANALYSIS
    let pline = getline(pnum)
    let cline = getline(lnum)

    " PREVIOUS INDENT IS OUR BASELINE ALTITUDE
    let pindent = indent(pnum)

    " ---------------------------------------------------------------
    " STRING LITERAL DETECTION
    " ---------------------------------------------------------------
    " IF WE ARE INSIDE A TRIPLE-QUOTED STRING, MAINTAIN CURRENT
    " HEADING. DO NOT ATTEMPT COURSE CORRECTION INSIDE A STRING.
    " THAT WAY LIES MADNESS.
    " ---------------------------------------------------------------
    if s:InString(pnum)
        return pindent
    endif

    " STRIP STRINGS AND COMMENTS FROM PREVIOUS LINE
    " WE NEED TO SEE THE REAL STRUCTURE, NOT THE DECORATION
    " LIKE REMOVING THERMAL BLANKETS TO INSPECT THE SPACECRAFT
    let pline_clean = s:StripStringsAndComments(pline)
    let cline_clean = s:StripStringsAndComments(cline)

    " ---------------------------------------------------------------
    " KEYWORD ALIGNMENT: ELSE/ELIF/EXCEPT/FINALLY/CASE
    " ---------------------------------------------------------------
    " WHEN THE CREW TYPES THESE KEYWORDS, WE MUST FIND THE MATCHING
    " BLOCK OPENER AND ALIGN WITH IT, REGARDLESS OF WHERE THE CREW
    " INITIALLY PLACED THE CURSOR.
    "
    " THIS IS LIKE THE LEM'S RADAR FINDING THE CORRECT LANDING SPOT
    " EVEN WHEN THE PILOT IS LOOKING IN THE WRONG DIRECTION.
    "
    " PYTHON EXAMPLE - STANDARD BLOCKS:
    "     if x > 0:
    "         do_something()
    "     elif x < 0:          <- ALIGNS WITH 'if'
    "         do_other()
    "     else:                <- ALIGNS WITH 'if'
    "         fallback()
    "
    " PYTHON EXAMPLE - TRY/EXCEPT:
    "     try:
    "         risky()
    "     except ValueError:   <- ALIGNS WITH 'try'
    "         handle()
    "     finally:             <- ALIGNS WITH 'try'
    "         cleanup()
    "
    " PYTHON EXAMPLE - MATCH/CASE (3.10+):
    "     match command:
    "         case "quit":     <- ALIGNS WITH 'match'
    "             return
    "         case "help":     <- ALIGNS WITH 'match'
    "             show_help()
    "         case _:          <- ALIGNS WITH 'match'
    "             unknown()
    " ---------------------------------------------------------------
    if cline_clean =~ '^\s*\(else\|elif\|except\|finally\|case\)\>'
        let match_indent = s:FindBlockOpener(lnum, cline)
        if match_indent >= 0
            return match_indent
        endif
    endif

    " ---------------------------------------------------------------
    " RETROGRADE BURN: CLOSING BRACKET DETECTED
    " ---------------------------------------------------------------
    " IF CURRENT LINE BEGINS WITH ) OR ] OR }, WE MUST ADJUST ALTITUDE.
    "
    " REVISION 2.0: CHECK IF PREVIOUS LINE OPENED THE BRACKET
    " IF SO, ALIGN WITH IT (EMPTY BRACKETS ACROSS LINES)
    " OTHERWISE, DEDENT BY ONE SHIFTWIDTH (NORMAL CLOSING)
    "
    " PYTHON EXAMPLE - EMPTY BRACKETS:
    "     s = f(         <- OPENS BRACKET
    "     )              <- ALIGN WITH OPENER (INDENT 4)
    "
    " PYTHON EXAMPLE - CONTENT THEN CLOSE:
    "     s = {          <- OPENS BRACKET
    "         "key": 1,  <- INSIDE BRACKET (INDENT 8)
    "     }              <- DEDENT FROM 8 TO 4
    " ---------------------------------------------------------------
    if cline_clean =~ '^\s*[}\])]'
        let bracket_delta = s:GetBracketDelta(pnum)
        if bracket_delta > 0
            " PREVIOUS LINE OPENED BRACKETS - ALIGN WITH IT
            return pindent
        else
            " NORMAL CASE - DEDENT ONE LEVEL
            return pindent - shiftwidth()
        endif
    endif

    " ---------------------------------------------------------------
    " TRANS-LUNAR INJECTION: COLON DETECTED
    " ---------------------------------------------------------------
    " PREVIOUS LINE ENDS WITH COLON - THIS IS DEF/IF/FOR/WHILE/ETC
    " INCREASE ALTITUDE BY ONE SHIFTWIDTH
    " WE ARE ENTERING A NEW BLOCK - GODSPEED
    " ---------------------------------------------------------------
    if pline_clean =~ ':\s*$'
        return pindent + shiftwidth()
    endif

    " ---------------------------------------------------------------
    " TERMINAL STATEMENT DETECTION: RETURN/BREAK/CONTINUE/PASS/RAISE
    " ---------------------------------------------------------------
    " THESE STATEMENTS SIGNAL END OF CURRENT BLOCK LOGIC
    " THE NEXT LINE SHOULD DEDENT ONE LEVEL
    "
    " THIS IS LIKE THE DESCENT ENGINE CUTTING OFF - TIME TO
    " DROP TO A LOWER ALTITUDE
    "
    " REVISION 2.0: CHECK BRACKET STATE BEFORE DEDENTING
    " IF THE LINE HAS UNCLOSED BRACKETS (E.G. "return (" OR
    " "raise ValueError("), DO NOT DEDENT - LET BRACKET LOGIC HANDLE IT
    "
    " PYTHON EXAMPLE - MULTILINE RETURN:
    "     return (       <- TERMINAL + OPEN BRACKET, DO NOT DEDENT
    "         value      <- BRACKET LOGIC INDENTS TO 8
    "     )
    " ---------------------------------------------------------------
    if s:IsTerminalStatement(pline_clean)
        " ONLY DEDENT IF NOT FOLLOWED BY BLOCK CONTINUATION KEYWORD
        " AND NOT INSIDE UNCLOSED BRACKETS
        if cline_clean !~ '^\s*\(else\|elif\|except\|finally\|case\)\>'
            let bracket_delta = s:GetBracketDelta(pnum)
            if bracket_delta == 0
                let new_indent = pindent - shiftwidth()
                " DO NOT GO BELOW GROUND LEVEL
                return new_indent >= 0 ? new_indent : 0
            endif
        endif
    endif

    " ---------------------------------------------------------------
    " BRACKET IMBALANCE DETECTION
    " ---------------------------------------------------------------
    " IF PREVIOUS LINE OPENED MORE BRACKETS THAN IT CLOSED, INDENT
    "
    " REVISION 3.0: CHECK DELTA, NOT CUMULATIVE DEPTH
    " THIS ENSURES WE ONLY INDENT AFTER THE LINE THAT OPENS BRACKETS,
    " NOT ON EVERY LINE INSIDE THE BRACKETS
    "
    " PYTHON EXAMPLE:
    "     s = {             <- DELTA = 1, INDENT NEXT LINE
    "         "key": val,   <- DELTA = 0, MAINTAIN INDENT
    "         "k2": v2,     <- DELTA = 0, MAINTAIN INDENT
    "     }                 <- CLOSING BRACKET HANDLED ELSEWHERE
    " ---------------------------------------------------------------
    let bracket_delta = s:GetBracketDelta(pnum)
    if bracket_delta > 0
        return pindent + shiftwidth()
    endif

    " ---------------------------------------------------------------
    " DEFAULT: MAINTAIN CURRENT ALTITUDE
    " ---------------------------------------------------------------
    " NO SPECIAL CONDITIONS DETECTED
    " STAY THE COURSE
    " HOUSTON, ALL IS WELL
    " ---------------------------------------------------------------
    return pindent
endfunction

" ===================================================================
"          SUBROUTINES - NUMBERED FOR YOUR CONVENIENCE
" ===================================================================

" -------------------------------------------------------------------
" SUBROUTINE 1: END OF FILE DETECTION
" -------------------------------------------------------------------
" SCANS FROM CURRENT POSITION TO END OF FILE
" RETURNS 1 IF NO NON-WHITESPACE EXISTS BELOW
" RETURNS 0 IF THERE IS STILL CODE OUT THERE
"
" USED TO DETERMINE IF WE ARE TRULY AT THE EDGE OF THE VOID
" OR MERELY PASSING THROUGH EXISTING STRUCTURE
"
" IT IS UNCLEAR WHY FORTRAN DID NOT HAVE THIS PROBLEM
" -------------------------------------------------------------------
function! s:AtEndOfFile(lnum)
    let last_line = line('$')

    " SCAN TOWARD END OF FILE LIKE RADAR SWEEPING THE LUNAR SURFACE
    for i in range(a:lnum, last_line)
        if getline(i) =~ '\S'
            " AFFIRMATIVE - TERRAIN DETECTED
            return 0
        endif
    endfor

    " NEGATIVE - NOTHING BUT VOID FROM HERE TO END
    " WE HAVE ACHIEVED FREE SPACE
    return 1
endfunction

" -------------------------------------------------------------------
" SUBROUTINE 2: NEXT NON-BLANK LINE FINDER
" -------------------------------------------------------------------
" LOOKS DOWNWARD FOR THE NEXT LINE WITH CONTENT
" RETURNS LINE NUMBER IF FOUND, 0 IF NOTHING THERE
"
" WHEN INSERTING IN MIDDLE OF FILE, THIS TELLS US WHAT
" INDENTATION LEVEL TO INHERIT. THE TERRAIN BELOW DETERMINES
" OUR TRAJECTORY.
" -------------------------------------------------------------------
function! s:NextNonBlankLine(lnum)
    let last_line = line('$')

    for i in range(a:lnum, last_line)
        if getline(i) =~ '\S'
            " CONTACT LIGHT
            return i
        endif
    endfor

    " NOTHING BELOW - DEFENSIVE PROGRAMMING SAVES MISSIONS
    return 0
endfunction

" -------------------------------------------------------------------
" SUBROUTINE 3: STRING AND COMMENT STRIPPER
" -------------------------------------------------------------------
" REMOVES DECORATION FROM LINE SO WE CAN SEE THE STRUCTURE
" ELIMINATES:
"   - STRING LITERALS (SINGLE AND DOUBLE QUOTED)
"   - COMMENTS (EVERYTHING AFTER #)
"   - TRIPLE QUOTED STRINGS (SIMPLIFIED)
"
" THIS IS LIKE REMOVING THE LEM'S OUTER PANELS TO INSPECT WIRING
"
" KNOWN LIMITATIONS:
"   - ESCAPE SEQUENCES ARE HANDLED BUT NOT PERFECTLY
"   - NESTED QUOTES MAY CAUSE ANOMALIES
"   - DO NOT BLAME THE COMPUTER
" -------------------------------------------------------------------
function! s:StripStringsAndComments(line)
    let result = a:line

    " FIRST PASS: REMOVE SAME-LINE TRIPLE QUOTES
    let result = substitute(result, '""".*"""', '', 'g')
    let result = substitute(result, "'''.*'''", '', 'g')

    " SECOND PASS: CHARACTER BY CHARACTER ANALYSIS
    " THIS IS THE CAREFUL WAY. SLOW BUT SURE.
    let in_single = 0
    let in_double = 0
    let in_escape = 0
    let cleaned = ''

    for i in range(len(result))
        let char = result[i]

        " ESCAPE SEQUENCE HANDLING
        if in_escape
            let in_escape = 0
            continue
        endif

        if char == '\'
            let in_escape = 1
            continue
        endif

        " DOUBLE QUOTE STATE MACHINE
        if char == '"' && !in_single
            let in_double = !in_double
            continue
        endif

        " SINGLE QUOTE STATE MACHINE
        if char == "'" && !in_double
            let in_single = !in_single
            continue
        endif

        " IF OUTSIDE STRINGS, THIS CHARACTER COUNTS
        if !in_single && !in_double
            if char == '#'
                " COMMENT DETECTED - THE REST IS JUST FOR HUMANS
                break
            endif
            let cleaned = cleaned . char
        endif
    endfor

    return cleaned
endfunction

" -------------------------------------------------------------------
" SUBROUTINE 4: CHARACTER COUNTER
" -------------------------------------------------------------------
" COUNTS OCCURRENCES OF SPECIFIED CHARACTER IN STRING
" USED FOR BRACKET BALANCING
"
" NOTE: VARIABLE NAMED 'CNT' NOT 'COUNT' TO AVOID CONFLICT WITH
" VIM'S BUILT-IN COUNT. LEARNED THIS THE HARD WAY.
"
" THIS ROUTINE IS SIMPLE AND RELIABLE
" LIKE THE ABORT GUIDANCE SYSTEM
" BUT HOPEFULLY WE WILL NOT NEED TO ABORT
" -------------------------------------------------------------------
function! s:CountChar(str, char)
    let cnt = 0
    for i in range(len(a:str))
        if a:str[i] == a:char
            let cnt = cnt + 1
        endif
    endfor
    return cnt
endfunction

" -------------------------------------------------------------------
" SUBROUTINE 5: MULTI-LINE STRING DETECTOR
" -------------------------------------------------------------------
" DETERMINES IF WE ARE INSIDE A TRIPLE-QUOTED STRING
" SCANS FROM LINE 1 TO CURRENT LINE, COUNTING TRIPLE QUOTES
" IF COUNT IS ODD, WE ARE INSIDE. IF EVEN, WE ARE OUTSIDE.
"
" THIS IS THE SAME LOGIC USED TO DETERMINE IF AN ASTRONAUT
" HAS EXITED AND RE-ENTERED THE SPACECRAFT AN ODD OR EVEN
" NUMBER OF TIMES. (NOT REALLY BUT IT SOUNDS GOOD)
"
" REVISION 2.0: HYBRID PYTHON/VIML APPROACH
" IF PYTHON3 IS AVAILABLE AND CODE PARSES, USE AST FOR ACCURACY
" IF PYTHON3 UNAVAILABLE OR CODE INCOMPLETE, FALL BACK TO VIML
"
" PYTHON EXAMPLE - TRICKY STRINGS THE AST HANDLES CORRECTLY:
"     x = "this has ''' inside"      <- NOT a triple quote
"     y = f"nested {val!r} here"     <- f-string with conversion
"     z = r"\n is literal"           <- raw string
"     multi = """
"         this spans
"         multiple lines
"     """                            <- accurate end detection
" -------------------------------------------------------------------

" -------------------------------------------------------------------
" PYTHON3 TOKENIZE-BASED ANALYZER
" -------------------------------------------------------------------
" USES PYTHON'S TOKENIZE MODULE FOR ACCURATE LEXICAL ANALYSIS
" UNLIKE AST, TOKENIZE WORKS ON INCOMPLETE CODE - IT YIELDS
" TOKENS UNTIL IT HITS AN ERROR, GIVING US PARTIAL INFORMATION
"
" THIS IS THE BLOCK II GUIDANCE COMPUTER - EVEN MORE PRECISE
" NAVIGATION THROUGH CODE SPACE
"
" CAPABILITIES:
"   - STRING DETECTION: EXACT TOKEN POSITIONS, ALL STRING TYPES
"   - BRACKET DEPTH: ACCURATE COUNT AT ANY LINE
"   - CONTINUATION: DETECTS BACKSLASH AND BRACKET CONTINUATIONS
"
" PYTHON EXAMPLE - WHAT TOKENIZE HANDLES:
"     x = "normal string"           <- STRING token
"     y = f"hello {name}"           <- STRING token (f-string)
"     z = r"\n literal"             <- STRING token (raw)
"     multi = """
"         spans lines
"     """                           <- STRING token with start/end
"     data = [                      <- LSQB, depth increases
"         1,                        <- NL (not NEWLINE - continues)
"     ]                             <- RSQB, depth decreases
"     continued = foo \
"         .bar()                    <- continuation via backslash
" -------------------------------------------------------------------
if has('python3')

py3 << ENDPYTHON
import tokenize
import io
import vim

class TokenCache:
    """
    Cache tokenization results to avoid re-tokenizing on every call.
    Invalidated when buffer changes (using vim's changedtick).

    MEMORY EFFICIENT:
      - No duplicate buffer storage
      - No token list storage
      - Uses b:changedtick for O(1) change detection
      - Clears automatically on buffer switch
    """
    def __init__(self):
        self.buffer_id = None
        self.changedtick = None
        self.string_ranges = None
        self.bracket_depth_by_line = None
        self.continuation_lines = None

    def _is_cache_valid(self):
        """Check if cache is still valid for current buffer state."""
        try:
            buf_id = vim.current.buffer.number
            tick = int(vim.eval('b:changedtick'))
            return buf_id == self.buffer_id and tick == self.changedtick
        except:
            return False

    def _tokenize_buffer(self):
        """Tokenize current buffer, caching derived results only."""
        if self._is_cache_valid() and self.string_ranges is not None:
            return  # Cache still valid

        # Update cache identity
        self.buffer_id = vim.current.buffer.number
        self.changedtick = int(vim.eval('b:changedtick'))

        # Clear derived data
        self.string_ranges = []
        self.bracket_depth_by_line = {}
        self.continuation_lines = set()

        # Tokenize without storing tokens
        source = '\n'.join(vim.current.buffer[:])
        depth = 0
        current_line = 1

        try:
            readline = io.StringIO(source).readline
            for tok in tokenize.generate_tokens(readline):
                # Track string ranges (multi-line strings only)
                if tok.type == tokenize.STRING:
                    start_line, start_col = tok.start
                    end_line, end_col = tok.end
                    if end_line > start_line:
                        self.string_ranges.append((start_line, end_line))

                # Track bracket depth per line
                if tok.type == tokenize.OP:
                    if tok.string in '([{':
                        depth += 1
                    elif tok.string in ')]}':
                        depth -= 1

                # Record depth at end of each line we pass
                line_no = tok.start[0]
                if line_no > current_line:
                    for ln in range(current_line, line_no):
                        if ln not in self.bracket_depth_by_line:
                            self.bracket_depth_by_line[ln] = depth
                    current_line = line_no
                self.bracket_depth_by_line[line_no] = depth

                # Track continuation lines (NL = line continues)
                if tok.type == tokenize.NL:
                    self.continuation_lines.add(tok.start[0])

        except tokenize.TokenError:
            # Incomplete code - use what we got
            pass

    def get_string_ranges(self):
        """Get list of (start_line, end_line) for multi-line strings."""
        self._tokenize_buffer()
        return self.string_ranges

    def get_bracket_depth(self, lnum):
        """Get bracket nesting depth at end of line lnum."""
        self._tokenize_buffer()
        if lnum in self.bracket_depth_by_line:
            return self.bracket_depth_by_line[lnum]
        # Line not yet processed, find nearest earlier line
        for ln in range(lnum, 0, -1):
            if ln in self.bracket_depth_by_line:
                return self.bracket_depth_by_line[ln]
        return 0

    def is_continuation_line(self, lnum):
        """Check if line lnum continues to next line."""
        self._tokenize_buffer()
        return lnum in self.continuation_lines

# Global cache instance
_token_cache = TokenCache()

def check_in_string(lnum):
    """
    Check if line lnum (1-indexed) is inside a multi-line string.
    Returns: 1 if inside string, 0 if not.

    Unlike AST version, this NEVER returns -1 - tokenize always works.
    """
    ranges = _token_cache.get_string_ranges()

    for start, end in ranges:
        # Line is inside if it's strictly between start and end
        if start < lnum < end:
            return 1
        # Also inside if on start line but string continues
        if start == lnum and end > lnum:
            return 1

    return 0

def get_bracket_depth(lnum):
    """
    Get bracket/paren/brace nesting depth at end of line lnum.
    Returns integer >= 0.
    """
    return _token_cache.get_bracket_depth(lnum)

def get_bracket_delta(lnum):
    """
    Get the net bracket change on line lnum.
    Returns: positive if line opens more than it closes,
             0 or negative otherwise.
    """
    depth_after = _token_cache.get_bracket_depth(lnum)
    if lnum <= 1:
        depth_before = 0
    else:
        depth_before = _token_cache.get_bracket_depth(lnum - 1)
    delta = depth_after - depth_before
    return delta if delta > 0 else 0

def is_continuation(lnum):
    """
    Check if line lnum is a continuation line (inside brackets or backslash).
    Returns: 1 if continuation, 0 if not.
    """
    return 1 if _token_cache.is_continuation_line(lnum) else 0

def invalidate_cache():
    """Force re-tokenization on next call."""
    _token_cache.buffer_contents = None
ENDPYTHON

endif

" -------------------------------------------------------------------
" MAIN STRING DETECTOR - TRIES PYTHON FIRST, FALLS BACK TO VIML
" -------------------------------------------------------------------
" WITH TOKENIZE, PYTHON ALWAYS RETURNS A VALID RESULT (0 OR 1)
" FALLBACK ONLY NEEDED WHEN PYTHON3 IS UNAVAILABLE
" -------------------------------------------------------------------
function! s:InString(lnum)
    " TRY THE BLOCK II GUIDANCE COMPUTER FIRST
    if has('python3')
        return py3eval('check_in_string(' . a:lnum . ')')
    endif

    " FALL BACK TO ORIGINAL VIML APPROACH
    " (ONLY WHEN PYTHON3 UNAVAILABLE)
    return s:InStringVimL(a:lnum)
endfunction

" -------------------------------------------------------------------
" VIML FALLBACK STRING DETECTOR (ORIGINAL ALGORITHM)
" -------------------------------------------------------------------
" SCANS FROM LINE 1 COUNTING TRIPLE QUOTES
" LESS ACCURATE BUT WORKS ON INCOMPLETE CODE
" -------------------------------------------------------------------
function! s:InStringVimL(lnum)
    let triple_single = 0
    let triple_double = 0

    " SCAN FROM BEGINNING OF MISSION (LINE 1) TO CURRENT POSITION
    for i in range(1, a:lnum)
        let line = getline(i)

        " SEARCH FOR TRIPLE QUOTE SEQUENCES
        let idx = 0
        while idx < len(line) - 2
            if line[idx:idx+2] == "'''"
                let triple_single = !triple_single
                let idx = idx + 3
            elseif line[idx:idx+2] == '"""'
                let triple_double = !triple_double
                let idx = idx + 3
            else
                let idx = idx + 1
            endif
        endwhile
    endfor

    " IF EITHER COUNTER IS ODD, WE ARE FLOATING IN STRING SPACE
    return triple_single || triple_double
endfunction

" -------------------------------------------------------------------
" BRACKET DEPTH DETECTOR - USES PYTHON TOKENIZE OR VIML FALLBACK
" -------------------------------------------------------------------
" RETURNS THE BRACKET NESTING DEPTH AT THE END OF LINE LNUM
" DEPTH > 0 MEANS WE ARE INSIDE UNCLOSED BRACKETS
"
" PYTHON VERSION: EXACT, HANDLES BRACKETS IN STRINGS/COMMENTS
" VIML VERSION: SCANS LINE WITH STRIPPED STRINGS, LESS ACCURATE
" -------------------------------------------------------------------
function! s:GetBracketDepth(lnum)
    " TRY PYTHON TOKENIZE FIRST - MORE ACCURATE
    if has('python3')
        return py3eval('get_bracket_depth(' . a:lnum . ')')
    endif

    " FALL BACK TO VIML: COUNT ON CURRENT LINE ONLY
    " (LESS ACCURATE - DOESN'T TRACK CUMULATIVE DEPTH)
    return s:GetBracketDepthVimL(a:lnum)
endfunction

" -------------------------------------------------------------------
" BRACKET DELTA DETECTOR - NET CHANGE ON A SINGLE LINE
" -------------------------------------------------------------------
" RETURNS THE NET BRACKET CHANGE ON LINE LNUM
" POSITIVE MEANS LINE OPENED MORE BRACKETS THAN IT CLOSED
"
" USED TO DETERMINE IF WE SHOULD INDENT AFTER A LINE:
"   - s = {           <- DELTA = 1, INDENT NEXT LINE
"   - "key": value,   <- DELTA = 0, MAINTAIN INDENT
"
" PYTHON VERSION: COMPARES CUMULATIVE DEPTHS
" VIML VERSION: ALREADY COUNTS SINGLE LINE, SO REUSE IT
" -------------------------------------------------------------------
function! s:GetBracketDelta(lnum)
    if has('python3')
        return py3eval('get_bracket_delta(' . a:lnum . ')')
    endif

    " VIML FALLBACK ALREADY COUNTS SINGLE LINE IMBALANCE
    return s:GetBracketDepthVimL(a:lnum)
endfunction

" -------------------------------------------------------------------
" VIML FALLBACK BRACKET COUNTER
" -------------------------------------------------------------------
" COUNTS BRACKET IMBALANCE ON SINGLE LINE (STRIPPED OF STRINGS)
" RETURNS: POSITIVE IF MORE OPENS THAN CLOSES, 0 OTHERWISE
" -------------------------------------------------------------------
function! s:GetBracketDepthVimL(lnum)
    let line = getline(a:lnum)
    let clean = s:StripStringsAndComments(line)

    let n_open = 0
    let n_open = n_open + s:CountChar(clean, '(')
    let n_open = n_open + s:CountChar(clean, '[')
    let n_open = n_open + s:CountChar(clean, '{')

    let n_close = 0
    let n_close = n_close + s:CountChar(clean, ')')
    let n_close = n_close + s:CountChar(clean, ']')
    let n_close = n_close + s:CountChar(clean, '}')

    let diff = n_open - n_close
    return diff > 0 ? diff : 0
endfunction

" -------------------------------------------------------------------
" SUBROUTINE 6: TERMINAL STATEMENT DETECTOR
" -------------------------------------------------------------------
" CHECKS IF A LINE (ALREADY STRIPPED OF STRINGS/COMMENTS) ENDS
" WITH A TERMINAL STATEMENT: RETURN, BREAK, CONTINUE, PASS, RAISE
"
" THESE STATEMENTS INDICATE THE END OF A LOGICAL BLOCK PATH.
" LIKE WHEN THE DESCENT ENGINE CUTS OFF - YOU KNOW THE NEXT
" PHASE IS DIFFERENT.
" -------------------------------------------------------------------
function! s:IsTerminalStatement(line_clean)
    let stripped = substitute(a:line_clean, '^\s*', '', '')
    let stripped = substitute(stripped, '\s*$', '', '')

    " BARE KEYWORDS
    if stripped =~ '^\(return\|break\|continue\|pass\|raise\)$'
        return 1
    endif

    " KEYWORDS WITH ARGUMENTS
    if stripped =~ '^\(return\|raise\)\s\+'
        return 1
    endif

    return 0
endfunction

" -------------------------------------------------------------------
" SUBROUTINE 7: BLOCK OPENER FINDER (REVISION 4.0)
" -------------------------------------------------------------------
" FINDS THE MATCHING OPENER FOR CONTINUATION KEYWORDS:
"   - ELSE/ELIF  -> IF, ELIF, FOR, WHILE, TRY
"   - EXCEPT/FINALLY -> TRY
"   - CASE -> MATCH (PYTHON 3.10+)
"
" ALGORITHM:
" THE CREW MIGHT TYPE ELSE: AT ANY INDENT. WE MUST FIND THE RIGHT
" OPENER TO ALIGN WITH. THE PRINCIPLE:
"
"   - IF KEYWORD IS AT INDENT X, FIND CLOSEST OPENER WITH INDENT >= X
"   - THIS MEANS IF ELSE IS AT 0, WE FIND THE OUTERMOST VALID OPENER
"   - IF ELSE IS AT 8, WE FIND AN OPENER AT 8 OR MORE (INNER BLOCKS)
"
" THIS IS LIKE TRACKING BACK THROUGH ORBITAL MECHANICS TO FIND
" THE LAUNCH POINT. COMPLEX BUT NECESSARY.
"
" RETURNS: INDENT LEVEL OF MATCHING OPENER, OR -1 IF NOT FOUND
" -------------------------------------------------------------------
function! s:FindBlockOpener(lnum, cline)
    " DETERMINE WHAT WE ARE LOOKING FOR
    if a:cline =~ '^\s*else\>'
        " ELSE CAN MATCH: IF, ELIF, FOR, WHILE, TRY
        let openers = '\(if\|elif\|for\|while\|try\)\>'
    elseif a:cline =~ '^\s*elif\>'
        " ELIF CAN ONLY MATCH: IF, ELIF
        let openers = '\(if\|elif\)\>'
    elseif a:cline =~ '^\s*\(except\|finally\)\>'
        " EXCEPT/FINALLY CAN ONLY MATCH: TRY
        let openers = 'try\>'
    elseif a:cline =~ '^\s*case\>'
        " CASE CAN ONLY MATCH: MATCH (PYTHON 3.10+)
        " NOTE: 'case' IS ONLY A KEYWORD IN MATCH CONTEXT
        " BUT WE TRUST THE CREW KNOWS WHAT THEY'RE DOING
        let openers = 'match\>'
    else
        " UNKNOWN KEYWORD - ABORT SEARCH
        return -1
    endif

    " THE INDENT WHERE THE KEYWORD CURRENTLY SITS
    let cur_indent = indent(a:lnum)

    " WE SEEK THE OPENER WITH SMALLEST INDENT >= CUR_INDENT
    " ALSO TRACK CLOSEST OPENER AS FALLBACK
    let best_match_indent = -1
    let closest_match_indent = -1
    let min_indent_seen = 999999

    let search_line = a:lnum - 1

    while search_line > 0
        let line = getline(search_line)

        " SKIP BLANK LINES - THEY TELL US NOTHING
        if line =~ '^\s*$'
            let search_line = search_line - 1
            continue
        endif

        let line_indent = indent(search_line)
        let line_clean = s:StripStringsAndComments(line)

        " TRACK MINIMUM INDENT - FOR DETECTING BLOCK BOUNDARIES
        if line_indent < min_indent_seen
            let min_indent_seen = line_indent
        endif

        " CHECK IF THIS IS AN OPENER
        if line_clean =~ '^\s*' . openers
            " OPENER MUST BE AT OR BELOW MINIMUM INDENT SEEN
            " (NOT NESTED INSIDE ALREADY-CLOSED BLOCKS)
            if line_indent <= min_indent_seen
                " SAVE AS FALLBACK
                if closest_match_indent < 0
                    let closest_match_indent = line_indent
                endif

                " CHECK IF THIS IS BEST MATCH (>= CUR_INDENT, SMALLEST)
                if line_indent >= cur_indent
                    if best_match_indent < 0 || line_indent < best_match_indent
                        let best_match_indent = line_indent
                    endif
                endif
            endif
        endif

        " STOP IF WE HIT INDENT 0 AND HAVE A MATCH
        if line_indent == 0 && (best_match_indent >= 0 || closest_match_indent >= 0)
            break
        endif

        let search_line = search_line - 1
    endwhile

    " RETURN BEST MATCH IF FOUND, ELSE CLOSEST, ELSE -1
    if best_match_indent >= 0
        return best_match_indent
    elseif closest_match_indent >= 0
        return closest_match_indent
    else
        " NO OPENER FOUND - THE CREW IS ON THEIR OWN
        return -1
    endif
endfunction

" ===================================================================
" INITIALIZATION SEQUENCE
" ===================================================================
" CONFIGURE VIM FOR PYTHON INDENTATION GUIDANCE
" THIS IS THE FINAL COUNTDOWN
" ===================================================================

" TELL VIM TO USE OUR GUIDANCE COMPUTER FOR INDENT CALCULATIONS
setlocal indentexpr=UserGetPythonIndent()

" INDENTKEYS: WHICH KEYSTROKES TRIGGER RECALCULATION
"   !^F      - CTRL-F REQUESTS MANUAL RECOMPUTATION
"   o,O      - CREW OPENING NEW LINE (PRIMARY METHOD OF ADVANCE)
"   <:>      - COLON ENTRY (MAY SIGNAL BLOCK START)
"   0),0],0} - CLOSING BRACKETS AT LINE START
"   =else    - ELSE KEYWORD (ALIGNS WITH IF/FOR/WHILE/TRY)
"   =elif    - ELIF KEYWORD (ALIGNS WITH IF)
"   =except  - EXCEPT KEYWORD (ALIGNS WITH TRY)
"   =finally - FINALLY KEYWORD (ALIGNS WITH TRY)
"   =case    - CASE KEYWORD (ALIGNS WITH MATCH, PYTHON 3.10+)
setlocal indentkeys=!^F,o,O,<:>,0),0],0},=else,=elif,=except,=finally,=case

" MARK THIS BUFFER AS HAVING RECEIVED GUIDANCE INITIALIZATION
let b:did_indent = 1

" UNDO SEQUENCE - FOR RETURNING TO EARTH
let b:undo_indent = "setl ai< inde< indk< lisp<"

" ===================================================================
" END OF PROGRAM
" ===================================================================
" THE CREW IS NOW CLEARED FOR PYTHON ENTRY
" MAY YOUR INDENTATION BE TRUE AND YOUR BRACKETS BALANCED
" GODSPEED
" ===================================================================
