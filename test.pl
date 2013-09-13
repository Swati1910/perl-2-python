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

		my $temp="$f.py".time();

		print "\tChecking $f...\n";

		if (defined("$_/$f")) {
			system "perl perl2python.pl $f > $temp";
		} else {
				die "$! Could not open $_/$f";
		}

		my $pyFile = $f;
		$pyFile =~ s/.pl/.py/;

		print ("\tChecking program against desired program...");
		if (my $diff = `diff $temp $pyFile`) {
			system "gedit $f $temp $pyFile";
			unlink $temp;
			die "\t\tTest failed on $f\n";
		} else {
			print "\t\t$f OK\n";
		}
		unlink $temp;

		
		print "\tChecking program output...";
		system "perl $f > perl.output";
		system "python $pyFile > python.output";
		
		if (my $diff = `diff perl.output python.output`) {
			system "gedit perl.output python.output";
			unlink "perl.output";
			unlink "python.output";
			die "\t\tTest failed on output of $f\n";
		} else {
			print "\t\t$f output OK\n";
		}
		unlink "perl.output";
		unlink "python.output";
	}


}