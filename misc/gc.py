#!/usr/bin/env python
import os, sys, string, subprocess, socket

fields = string.split (sys.stdin.read (), '\x00')

while len (fields) > 1:
    opath, atime = fields[0:2]
    fields = fields[2:]
    if not os.path.exists (opath):
        try:
            npath = subprocess.check_output (
                "locate -b -l 1 -e '/%s$'" % opath,
                shell = True
            )
        except:
            npath = ""
        if npath:
            npath = npath[:-1]
            sys.stdout.write (opath + "\000" + npath + "\000")
        else:
            sys.stdout.write (opath + "\000\000")

sys.stdout.flush ()
socket.fromfd (sys.stdout.fileno (),
               socket.AF_UNIX,
               socket.SOCK_STREAM).shutdown (socket.SHUT_RDWR)
sys.stderr.write ("gc.py done\n")
os._exit (0)