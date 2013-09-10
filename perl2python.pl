#!/usr/bin/perl -w

# written by andrewt@cse.unsw.edu.au September 2013
# as a starting point for COMP2041/9041 assignment 
# http://cgi.cse.unsw.edu.au/~cs2041/13s2/assignments/perl2python

use warnings;
use strict;

while (my $line = <>) {
	
	# translate #! line 
	if ($line =~ /^#!/ && $. == 1) {					# $. - the current input line number of the last filehandle that was read.
		print "#!/usr/bin/python2.7 -u\n";

	# Blank & comment lines can be passed unchanged
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		print $line;

	# Python's print adds a new-line character by default
	# so we need to delete it from the Perl print statement
	} elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {
		print "print \"$1\"\n";

	# Lines we can't translate are turned into comments
	} else {
		print "#$line\n";
	}
}