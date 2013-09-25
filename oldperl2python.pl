#!/usr/bin/perl -w


use warnings;
use strict;

# each variable is a key, value is meaningless,
#	just use to test existence of variables.
my %variables;
my $line;

extractVariables();


while ($line = <>) {

	chomp($line);

	#replace ; with nothing
	$line =~ s/;//;

	# translate #! line 
	if ($line =~ /^#!/ && $. == 1) {					# $. - the current input line number of the last filehandle that was read.
		print "#!/usr/bin/python2.7 -u\n";

	# Blank & comment lines can be passed unchanged
	} elsif ($line =~ /^\s*#/ || $line =~ /^\s*$/) {
		print "$line\n";

	# Capture variable declarations
	} elsif ($line =~ /^\$(.*)/ or $line =~ /^my \$(.*)/) {

		#add the names to the hash so we know whether to put ""s 
		#	in python print statement or not (ie printing string or variable?)
		#my @variable = split (' =',$1);
		#$variables{$variable[0]}++;

		$line =~ s/\$//;
		$line =~ s/^my //;
		print "$line\n";

	# Python's print adds a new-line character by default
	# so we need to delete it from the Perl print statement
	} elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {
		
		$line = $1;

		if ($line =~ /\$\w+/) {
			$line =~ s/\$//;
		}

		if (defined($variables{$line})) {
			$line = "print $line";
		} else {
			$line = "print \"$line\"";
		}

		print "$line\n";

	# Lines we can't translate are turned into comments
	} else {
		print "#$line\n";
	}
}


sub extractVariables() {
	while (my $line = <>) {
		print "Checking $line to extract variables...\n";
		
		if ($line =~ /.*\$(.*)/ or $line =~ /.* my \$(.*)/) {

		#add the names to the hash so we know whether to put ""s 
		#	in python print statement or not (ie printing string or variable?)
		my @variable = split (' =',$1);
		$variables{$variable[0]}++;
		print "Added $variable[0] to the hash.\n";
		}
	}
}
