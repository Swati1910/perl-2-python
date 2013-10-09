#!/usr/bin/python2.7 -u
import fileinput, re
# Perl script to convert [01234] to < and [6789] to >.
# Aidan Barrington UNSW COMP2041 2013 S2

for line in sys.stdin:
    line = re.sub(r'[01234]', '<', line)
    line = re.sub(r'[6789]', '>', line)
    print line
