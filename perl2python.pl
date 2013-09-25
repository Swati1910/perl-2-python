#!/usr/bin/perl -w


use warnings;
use strict;

my $debugOn = 0;	#set to 1 to turn debug messages on.


sub debug($);
sub extractVariables(\@);
sub hashBang(\@);
sub convertPerl2Python(\@);

sub addCommentLine($);
sub addPrintStatement($);
sub addVariableDec($);

my @output;
my %variables;


# We begin by reading the entire file into 
#	an array.
open PERL, $ARGV[0] or die "Could not open file $ARGV[0]: $!\n";

my @perl = <PERL>;


extractVariables(@perl);
hashBang(@perl);
convertPerl2Python(@perl);
print @output;

close PERL;


sub convertPerl2Python(\@) {
	my $array_ref = shift;
	my @code = @$array_ref;

	#NB: Changing $line changes @original_array!
	# We iterate over the file line by line.
	foreach my $line (@$array_ref){

		chomp($line);

		# Replace any occurance of ';' with nothing.
		$line =~ s/;//;

		# Add comments with Python comment indicator.
		if ($line !~ /^#!/ && $line =~ /^\s*#/ || $line =~ /^\s*$/) {
			addCommentLine($line);
		}

		# Add variable declarations.
		elsif ($line =~ /^\$\w*/ || $line =~ /^my \w*/) {
			addVariableDec($line);
		}

		# Add print statements.
		elsif ($line =~ /^\s*print\s*"(.*)\\n"[\s;]*$/) {
			addPrintStatement($1);
		}
		
		
	}

}

sub hashBang(\@) {
	my $array_ref = shift;
	
	#NB: Changing $line changes @original_array!
	if (@$array_ref[0] =~ /^#!/) {
		unshift(@output, "#!/usr/bin/python2.7 -u\n");
	}
}

sub extractVariables(\@) {
	my $array_ref = shift;

	#NB: Changing $line changes @original_array!
	foreach my $line (@$array_ref){
		
		if ($line =~ /.*\$(\w*)/ or $line =~ /.* my \$(\w*)/) {

		#add the names to the hash so we know whether to put ""s 
		#	in python print statement or not (ie printing string or variable?)
			my @variable = split (' =',$1);
			$variables{$variable[0]}++;
			debug("Added $variable[0] to the hash.");
		}
	}
}

sub addCommentLine($) {
	my $comment = shift;
	$comment.="\n";
	push(@output, $comment);
}

sub addPrintStatement($) {
	my $line = shift;

	if ($line =~ /\$\w+/) {
			$line =~ s/\$//;
		}

	if (defined($variables{$line})) {
		$line = "print $line";
	} else {
		$line = "print \"$line\"";
	}
	push(@output, "$line\n");
}


sub addVariableDec($) {
	my $line = shift;
	
	$line =~ /^\$(.*)/ or $line =~ /^my \$(.*)/;
	$line =~ s/\$//g;
	$line =~ s/^my //;
	
	push(@output, "$line\n");
}


sub debug($) {
	my $toPrint = shift;
	print "LOG: $toPrint\n" if $debugOn;
}

sub default(\@) {
	
	my $array_ref = shift;
	
	#NB: Changing $line changes @original_array!
	foreach my $line (@$array_ref){
		my $a = "1";
	}
}
