#!/usr/bin/env python3
"""run vim under a pseudo-terminal, then kill it or quit it.

usage: pty_vim.py SECONDS kill|quit -- VIM-ARGS...
       KEYS='1.5:r' pty_vim.py ...   sends the keys after that many seconds

swap file behaviour can't be tested with -es: SwapExists, the ATTENTION
dialog and the hit-enter prompts all need a real tty. this gives vim one,
collects what it printed for SECONDS, then either SIGKILLs it (leaves a
stale swap behind, like the os killing iVim) or sends <Esc>:qa!<CR>.
the captured screen text goes to stdout, escape sequences stripped.

the binary comes from $VIM (default: vim), so an old build can be tested:
    VIM=/path/to/vim-8.1.2110/src/vim VIMRUNTIME=/path/to/runtime ...
"""
import fcntl
import os
import pty
import struct
import termios
import re
import select
import signal
import sys
import time

secs = float(sys.argv[1])
mode = sys.argv[2]
args = sys.argv[4:]

keys = os.environ.get('KEYS')      # "SECONDS:keys"
key_at, key_str = (float(keys.split(':', 1)[0]), keys.split(':', 1)[1]) if keys else (None, '')

pid, fd = pty.fork()
if pid == 0:
    os.environ['TERM'] = 'xterm'
    os.execvp(os.environ.get('VIM', 'vim'), ['vim'] + args)
# tall enough that vim's ATTENTION message doesn't stop at -- More --
fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack('HHHH', 50, 120, 0, 0))

out = b''
start = time.time()
end = start + secs
while time.time() < end:
    if key_at is not None and time.time() - start >= key_at:
        os.write(fd, key_str.encode())
        key_at = None
    r, _, _ = select.select([fd], [], [], 0.2)
    if r:
        try:
            out += os.read(fd, 65536)
        except OSError:
            break

if mode == 'kill':
    os.kill(pid, signal.SIGKILL)
else:
    try:
        os.write(fd, b'\x1b:qa!\r')
        time.sleep(0.5)
        out += os.read(fd, 65536)
    except OSError:
        pass
try:
    os.waitpid(pid, 0)
except ChildProcessError:
    pass

txt = out.decode('utf-8', 'replace')
txt = re.sub(r'\x1b\[[0-9;?]*[A-Za-z]|\x1b[()][A-Z0-9]|\x1b[=>]|\r', '', txt)
print(txt)
