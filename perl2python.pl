#!/usr/bin/perl -w


use warnings;
use strict;

my $debugOn = 0;	#set to 1 to turn debug messages on.


sub debug($);
sub extractVariables(\@);
sub findImports(\@);
sub convertPerl2Python(\@);

sub addHashBang;
sub addCommentLine($);
sub addPrintStatement($);
sub addComplicatedPrint($);
sub addVariableDec($);
sub addComment($);
sub addConditional($);

my @output;
my %variables;


# We begin by reading the entire file into 
#	an array.
open PERL, $ARGV[0] or die "Could not open file $ARGV[0]: $!\n";

my @perl = <PERL>;

# Order is important here.
# Build the new file as follows:
#	1. Hashbang -> not _that_ important as we can easily
#		add to the beginning at anytime.
#	2. Any required imports -> this must be done before
#		code, as it's far more difficult to insert in 
#		the correct place.
#	3. Blank line
#	4. Program code

extractVariables(@perl);
convertPerl2Python(@perl);
print @output;

close PERL;


sub convertPerl2Python(\@) {
	my $array_ref = shift;
	my @code = @$array_ref;

	my $insideConditional = 0;


	#NB: Changing $line changes @original_array!
	# We iterate over the file line by line.
	foreach my $line (@$array_ref){

		chomp($line);

		if (!$insideConditional) {

			# Replace any occurance of ';' with nothing.
			$line =~ s/;//;

			if ($line =~ /^#!/) {
				addHashBang;
			}

			# Add comments with Python comment indicator.
			elsif ($line !~ /^#!/ && $line =~ /^\s*#/ || $line =~ /^\s*$/) {
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

			# If the print statement is more complicated than 
			#	just "print $variable" or "print string" we handle
			#	it differently.
			elsif ($line =~ /^\s*print\s*\$/) {
				addComplicatedPrint($line);
			}
			
			# Start of conditional statement
			elsif ($line =~ /^if.*{$/i || $line =~ /^while.*{$/i) {
				addConditional($line);
				$insideConditional++;
			}

			# If we don't know what to do, add the line as a 
			#	comment
			else {
				addComment($line);
				debug("Don't know what to do with: $line\n");
			}


		# We reach this point if we are inside an if loop.
		#	The condition has already been printed, we just 
		#	need to output the guts of the statement now.
		} elsif ($insideConditional) {
			if ($line !~ /\s*}\s*/) {
				$line =~ s/\s*//;
				push (@output, "    ") foreach (1..$insideConditional);
				my @line = $line;
				convertPerl2Python(@line);
			} else {
				$insideConditional = 0;
			}
		}





	}

}

sub addHashBang {
	unshift(@output, "#!/usr/bin/python2.7 -u\n");
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

sub findImports(\@) {
	my $array_ref = shift;

	#NB: Changing $line changes @original_array!
	foreach my $line (@$array_ref){
		
		if ($line =~ /\s*sys\..*/) {

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
			$line =~ s/\$//g;
		}

	if (defined($variables{$line})) {
		$line = "print $line";
	} else {
		$line = "print \"$line\"";
	}

	push(@output, "$line\n");
}

sub addComplicatedPrint($) {
	my $line = shift;
	$line =~ s/print //;
	my @split = split(',' ,$line);
	
	my $variables = $split[0];
	my $string = $split[1];

	$variables =~ s/\$//g;

	my $printStatement = "print ";
	$printStatement .= $variables;

	if ($string !~ /\"\\n\"/) {
		$printStatement .= " , ";
		$printStatement .= "\"$string\"";
	}

	push(@output, $printStatement);
}

sub addVariableDec($) {
	my $line = shift;
	
	$line =~ /^\$(.*)/ or $line =~ /^my \$(.*)/;
	$line =~ s/\$//g;
	$line =~ s/^my //;
	
	push(@output, "$line\n");
}

sub addComment($) {
	my $line = "#";
	$line.=shift;

	push(@output, "$line\n");
}


sub addConditional($) {
	my $protasis = shift;
	$protasis =~ s/\(//;
	$protasis =~ s/\)//;
	$protasis =~ s/\{//;
	$protasis =~ s/\$//;
	$protasis =~ s/\s*$//;
	push(@output, "$protasis:\n");
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
