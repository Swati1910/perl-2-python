#!/usr/bin/perl -w

# Script to automate testing of perl2python
# 	tests up to the given level, or all levels if no arg given.
# Probably should have done this in shell but the assignment is in
# 	Perl...

use warnings;
use strict;

foreach (@ARGV) {
	die "Usage: $0 n" if ($_ =~ /[a-z]/i);
}

my $level = $ARGV[$#ARGV];

# run all tests in the lowest level first, 
# then move up.


foreach (0..$level) {

	print "Running tests at level $_...\n";

	#get all .pl files in ./$_
	my @files = glob($_ . "/*.pl");

	foreach my $f (@files) {

		my $temp=time()."_".rand();

		print "\tChecking $f...\n";

		if (defined("$_/$f")) {
			system "perl perl2python.pl $f > $temp";
		} else {
				die "$! Could not open $_/$f";
		}

		my $pyFile = $f;
		$pyFile =~ s/.pl/.py/;

		if (my $diff = `diff $temp $pyFile`) {
			print $diff;
			unlink $temp;
			die "\t\tTest failed on $f\n";
		} else {
			print "\t\t$f OK\n";
		}

		unlink $temp;

	}


}