#!/usr/bin/perl -w


use warnings;
use strict;
use diagnostics;

my $debugOn = 1;	#set to 1 to turn debug messages on.


sub debug($);
sub removeSemiColons(\@);
sub extractVariables(\@);
sub findImports(\@);
sub convertSysCalls(\@);
sub convertPerl2Python(\@);


sub addHashBang;
sub addCommentLine($);
sub addPrintStatement($);
sub addComplicatedPrint($);
sub addVariableDec($);
sub addArray($);
sub addComment($);
sub addConditional($);
sub addSTDIN($);
sub addElsif($);
sub addChomp($);
sub addResub($);
sub addFor($);
sub addForeach($);
sub addPostIncOrDec($);
sub addNextOrLast($);
sub addChomp($);
sub addPush($);
sub addJoin($);
sub addSplit($);

sub convertStringConcat($);
sub willBeUsedAsInt($);

# TESTING
sub printAllVars;

my @output;
my %variables;
my %imports;

my $tab = "    ";

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

removeSemiColons(@perl);
extractVariables(@perl);
findImports(@perl);
convertSysCalls(@perl);
convertPerl2Python(@perl);
print @output;

#printAllVars;

close PERL;


sub convertPerl2Python(\@) {
	my $array_ref = shift;
	my @code = @$array_ref;

	my $insideConditional = 0;


	#NB: Changing $line changes @original_array!
	# We iterate over the file line by line.
	foreach my $line (@$array_ref){

		chomp($line);
		if ($line =~ /\w/) {
			push (@output, $tab) foreach (1..$insideConditional);
		}


		
		# delete leading whitespace.
		$line =~ s/^\s*//;

		if ($line =~ /^#!/) {
			addHashBang;
		}

		# Add comments with Python comment indicator.
		elsif ($line !~ /^#!/ && $line =~ /^\s*#/ || $line =~ /^\s*$/) {
			addCommentLine($line);
		}

		# Add variable declarations.
		elsif ($line !~ /.*=~.*/ && $line =~ /^\$\w*\s*=\s*/ || $line =~ /^my \$\w*\s*=\s*/) {
			addVariableDec($line);
		}

		# Array declarations
		elsif ($line !~ /.*push.*/ && $line =~ /[^\(]@\w+.*/ || 
				$line =~ /^\s*\@\w+\s*=\s*\(\'?\"?\w+/ || 
					$line =~ /^\s*\@\w+/) { 
			addArray($line);
		}

		# Check for prompt prints
		elsif ($line =~ /.*print "(>) "/ && defined($imports{sys}) ||
			   $line =~ /.*print \"(.*:)\s*\"/ && defined($imports{sys})) { 
			push(@output, "sys.stdout.write(\"$1 \")\n");
		}

		# Add print statements.
		elsif (!($line =~ /.*'$'.*/) && $line =~ /^\s*print\s*\"(.*)\\n\"[\s;]*$/
				|| $line =~ /\s*print\s*\"([^\$].*)\"/) { 
			addPrintStatement($1);
		}

		# If the print statement is more complicated than 
		#	just "print $variable" or "print string" we handle
		#	it differently.
		elsif ($line =~ /^\s*print\s*\$/ || $line =~ /\".*\$(\w+).*/ 
				|| $line =~ /print\s*join/) { 

			addComplicatedPrint($line);
		}
		

		# Start of conditional statement
		elsif ($line =~ /^\s*if.*{\s*$/i || 
			   $line =~ /^\s*while.*{\s*$/i) {
			$insideConditional++;
			addConditional($line);
		}

		# Handle elsifs differently to normal conditionals
		elsif ($line =~ /^\s*}\s*elsif\s*\(.*\)\s*{/) {
			addElsif($line);
		}

		# We see <STDIN>
		elsif ($line =~ "<STDIN>") {
			addSTDIN($line);
		}

		# Closing brace
		elsif ($line =~ /^\s*}\s*$/) {
			$insideConditional--;
		}

		#Closing brace with else
		elsif ($line =~ /^\s*}\s*else\s*{/) {
			pop(@output);
			push(@output, "else:\n");
		}

		# we be chomping here
		elsif ($line =~ /\s*chomp\s*\(?\$\w+\)?/i) {
			addChomp($line);
		}

		# regex SUB (eg line =~ s/[aeiou]//g;)
		elsif ($line =~ /\s*\w+\s*=~\s*s\/\[?\]?.*\/.*\/[ig]?/i) {
			addResub($line);
		}

		# foreach
		elsif ($line =~ /.*foreach.*/) {
			$insideConditional++;
			addForeach($line);
		}

		elsif ($line =~ /for.*\(/) {
			addFor($line);
		}

		# $a++ or $a--
		elsif ($line =~ /\s*\w+\+\+/ || $line =~ /\s*\w+\-\-/) {
			addPostIncOrDec($line);
		}

		# last or next
		elsif ($line =~ /\s*last\s*/ || $line =~ /\s*next\s*/) {
			addNextOrLast($line);
		}

		# push
		elsif ($line =~ /\s*push\s*\(/) {
			addPush($line);
		}

		#Handle blank lines
		elsif ($line =~ /^\s+$/) {
			push(@output, "\n");
		}

		# If we don't know what to do, add the line as a 
		#	comment
		else {
			addComment($line);
			#debug($line);
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

		# Remove any extra trailing newline characters
		if ($line =~ /\\n\\n\"$/) { 
			$line =~ s/\\n//;
		}
		
		if ($line =~ /.*\$(\w*)\s*=\s*(.*)/ or $line =~ /.* my \$(\w*)\s*=\s*(.*)/) {

		#add the names to the hash so we know whether to put ""s 
		#	in python print statement or not (ie printing string or variable?)
			my @variable = split (' =',$1);
			if (!defined($variables{$variable[0]})) {
	
				my $assignment = $2;
				$assignment =~ s/\"//g;
				$variables{$variable[0]} = $assignment;
			}
		} elsif ($line =~ /\s*foreach\s*\$(\w+).*/) {
			$variables{$1} = 1;
		}

		# Don't forget arrays now!
		elsif ($line =~ /[^\(]@(\w+).*/ || $line =~ /my @(\w+).*/ 
				|| $line =~ /@(\w+)\s*=\s*\((.*)\)/) {
			if (defined($2)) {
				$variables{$1} = $2;
			} else {
				$variables{$1}++;
			}
		}

		# treat sys.argv[.*] as a defined variable
		if ($line =~ /.*argv\[\$?(\w+)\].*/i) {
			$variables{"sys.argv[$1]"}++;
		}
	}
}

# Checks the supplied code for common libraries.
# Currently supports the following libraries:
#	fileinput
#	re
#	sys
sub findImports(\@) {
	my $array_ref = shift;

	#NB: Changing $line changes @original_array!
	foreach my $line (@$array_ref){
		
		#unix filter -> fileinput
		if ($line =~ /\<\>/) {
			$imports{fileinput}++;
		} 	
		#system access -> sys
		if ($line =~ /((open)|(close)|(STDIN)|(STDOUT)|(STDERR)|(\&1)|(\&2)|(ARGV)|while <>)/) {
			$imports{sys}++;
		}
		#regex -> re
		if ($line =~ /\=\~/ ||
			 $line =~ /.*split\s*\(\//) {
			$imports{re}++;
		}		
	}

	my $num_imports = keys %imports;
	my $counter;

	if (defined($imports{fileinput}) ||
		defined($imports{sys}) ||
		defined($imports{re})) {
			push(@output, "import");
	}

	foreach my $key (keys %imports) {
		$counter++;
		if ($counter == $num_imports) {
			push(@output, " $key");
		} else {
			push(@output, " $key,");
		}
	}

	if (defined($imports{fileinput}) ||
		defined($imports{sys}) ||
		defined($imports{re})) {
		push(@output, "\n");
	}
}


sub convertSysCalls(\@) {
	my $array_ref = shift;

	#NB: Changing $line changes @original_array!
	foreach my $line (@$array_ref){
		$line =~ s/\<STDIN\>/sys.stdin.readline()/g;
		$line =~ s/ARGV/sys.argv/g;
	}
}

sub removeSemiColons(\@) {
	my $array_ref = shift;

	#NB: Changing $line changes @original_array!
	foreach my $line (@$array_ref){
		# Replace any occurance of ';' with nothing.
		$line =~ s/;//;
	}
}



sub addCommentLine($) {
	my $comment = shift;
	$comment.="\n";
	push(@output, $comment);
}

sub addPrintStatement($) {
	my $line = shift;

	if ($line =~ /\w+\s*\$\w+/ || ($line =~ /.*\$.*/ && $line =~ /.*\s*.*/)
		&& $line !~ /.*sys\.argv.*/) {
		addComplicatedPrint($line);
	
	} else {
	
		if ($line =~ /\\n$/) {
			$line =~ s/\\n//;
		}

		if ($line =~ /\$\w+/) {
				$line =~ s/\$//g;
			}

		if ($line =~ /ARGV\[(.*)\]/ ||
			$line =~ /sys.argv\[(.*)\]/) {
			$line = "print sys.argv[$1 + 1]";
		}
		elsif (defined($variables{$line})) {
			$line = "print $line";
		} else {
			$line = "print \"$line\"";
		}

		push(@output, "$line\n");
	}
}

sub addComplicatedPrint($) {
	my $line = shift;
	$line =~ s/print //;
	
	if ($line =~ /\s*join\(/) {
		$line =~ /\s*join\((.*),\s*(.*)\)/;
		push(@output, "print $1.join($2\[1:])");
	
	} else {

		$line =~ s/\\n//;
		$line =~ s/\$//g;
		$line =~ s/\"//g;
		$line =~ s/,//g;

		my @toPrint;

		if ($line !~ /.*argv.*/) {
			@toPrint = split(/([ -+*])/, $line);
		} else {
			@toPrint = $line;	
		}


		push(@output, "print ");

		foreach my $x (@toPrint) {

			# Spaces can go straight on
			if ($x =~ /^\s*$/) { 
				push(@output, "$x");
			}
			# printing a defined variable
			elsif (defined($variables{$x})) { 
				# start of print statement
				if ($output[-1] eq "print ") { 
					push(@output, "$x");
				}
				# if the statement contains the end of a string
				elsif ($output[-1] =~ /\w+\s*\"/) { 
					push(@output, ", $x, ");
				}
				# a variable following a maths operator
				elsif ($output[-1] =~ /[\+\-\*\/]/ ||
					   $output[-3] =~ /[\+\-\*\/]/) { 
					push(@output, "$x");
				}
				# following another variable
				elsif ($output[-1] =~ /\w+,?/ ||
					($output[-1] =~ /^\s*$/ && $output[-2] =~ /\w+/)) { 
					$output[-1] =~ s/ // if $output[-1] =~ /^\s*$/;
					push(@output, ", $x");
				}
			
			# if we're printing a string component
			} else { 
				# Start of print statement
				if ($output[-1] eq "print ") { 
					push(@output, "\"$x\"");
				}
				# Middle of string
				elsif ($output[-1] =~ /\w+\s*\"/ ||
					   ($output[-1] =~ /\s*/ && $output[-2] =~ /\w+\s*\"/)) {
					$output[-1] =~ s/\"$// if $output[-1] =~ /\w+\s*\"/;
					$output[-2] =~ s/\"$// if $output[-2] =~ /\w+\s*\"/;
					push(@output, "$x \"");
				}
				# maths operators
				elsif ((defined($variables{$output[-1]}) || 
					    defined($variables{$output[-2]}) ||
					    defined($variables{$output[-3]}))
						&& $x =~ /[\+\-\*\/]/) { 
					
					push(@output, $x);
				}
				# following a variable
				elsif ($output[-1] =~ /\w+,/ ||
					   ($output[-1] =~ /\s*/ && $output[-2] =~ /\w+/)) {
					$output[-1] =~ s/^\s*$//;
					push(@output, ", \"$x\"");
				}
			}
		}
	}
	push(@output, "\n");

}

# If a variable is defined as one thing, and then 
#	assigned to something different, we need to 
#	cast it.
sub addVariableDec($) {
	my $line = shift;

	$line =~ /^\$(.*)/ or $line =~ /^my \$(.*)/;
	$line =~ s/\$//g;
	$line =~ s/^my //;
	
	my @assignment = split(' = ', $line);
#debug($line);
#debug($variables{$assignment[0]});
#debug("$assignment[0]");
#debug("$assignment[1]");
#printAllVars;
	if ($line =~ /.*\..*/) {
		$line = convertStringConcat($line);
	}


	if ($line =~ /=\s*join\s*\(/) {
		addJoin($line);
	}

	elsif ($line =~ /=\s*split\s*\(/) {
		addSplit($line);
	}


	elsif (defined($variables{$assignment[0]})) {
		# Check what type it is HAS been declared previously
		#	against what is being assigned to it now.
		# Case 1: HAS been assigned an int, IS being assigned an int.
		if ($variables{$assignment[0]} =~  /^\s*\d+\s*/ &&
			$assignment[1] =~  /^\s*\d+\s*/) {
			push(@output, "$line\n");
		# Case 2: HAS been assigned an int, IS being assigned a string.
		} elsif ($variables{$assignment[0]} =~  /^\s*\d+\s*/ &&
			$assignment[1] =~  /^\s*\w+\s*/) { 
			my $values = $assignment[1];
			$values =~ s/\+//;
			$values =~ s/\-//;
			my @values = split(' ', $values);
			# If there's more than one value being assigned to it, just assume 
			#	the word must be a variable.
			if (@values > 1) { 
				push(@output, "$line\n");
				} else {
					push(@output, "$assignment[0] = int($assignment[1])\n") ;
				}
		# Case 3: HAS been assigned a string, IS being assigned a string
		} elsif ($variables{$assignment[0]} =~  /^\s*\w+\s*/ &&
			$assignment[1] =~  /^\s*\"\w+\"\s*/) {
			push(@output, "$line\n"); 
		# Case 4: assigned to STDIN
		} elsif ($variables{$assignment[0]} =~ /<STDIN>/){
			if (willBeUsedAsInt($assignment[0])) {
				push(@output, "$assignment[0] = int(sys.stdin.readline())\n");
			} else {
				push(@output, "$assignment[0] = sys.stdin.readline()\n");
			}
		} else {
			push(@output, "$line\n");
		}
	# HAS NOT been assigned anything
	} else {
		push(@output, "##$line\n");
	}
}

sub addArray($) {
	my $line = shift;

	# @ARGV may get caught here
	if ($line =~ /.*\@sys.argv.*/) {
		$line=~ s/\@//;
		my @line = $line;
		convertPerl2Python(@line);
	}

	if ($line =~ /.*=\s*split/) {
		addSplit($line);
	}
	# Array declaration
	elsif ($line =~ /[^\(]@\w+.*/) {
		$line =~ s/my //;
		$line =~ s/@//;
		$line .= " = []";
		push(@output, "$line\n");

	} elsif ($line =~ /^\s*\@\s*(\w+)\s*$/) {
		$line =~ s/\@//;
		$line .= " = []";
		push(@output, "$line\n");

	# Assigning values to an array
	} elsif ($line =~ /@\w+\s*=\s*\(\'?\"?\w+/) {
		$line =~ s/@//;
		$line =~ tr/\(\)/\[\]/;
		push(@output, "$line\n");
	}

}

sub addComment($) {
	my $line = "#";
	$line.=shift;

	push(@output, "$line\n");
}

sub addConditional($) {
	my $line = shift;
#debug($line);	
	$line =~ s/\(//;
	$line =~ s/\)//;
	$line =~ s/\{//;
	$line =~ s/\$//g;
	$line =~ s/\s*$//;
	
	$line =~ s/&&/and/;
	$line =~ s/\|\|/or/;
	$line =~ s/!/not / if $line !~ /!=/;

	$line =~ s/eq/==/;

	# Handle "while line = <>" first
	if ($line =~ /\s*while\s*(\w+)\s*=\s*<>/ ) {
		push(@output, "for $1 in sys.stdin:\n");
	# All other conditionals:
	# while line = sys.stdin.readline()
	# for line in sys.stdin:
	} elsif ($line =~ /\s*while (\w+)\s*=\s*sys\.stdin\.readline\(\)/){
		push(@output, "for $1 in sys.stdin:\n");		
	} else {
		
		push(@output, "$line:\n");
	}
}

sub addElsif($) {
	my $protasis = shift;
	$protasis =~ s/\(//;
	$protasis =~ s/\)//;
	$protasis =~ s/\{//;
	$protasis =~ s/\}//;
	$protasis =~ s/\$//;
	$protasis =~ s/\s*$//;
	$protasis =~ s/^\s*//;
	$protasis =~ s/elsif//;
	#remove one level of indentation
	pop(@output);
	push(@output, "elif$protasis:\n");
}


sub addChomp($) {
	my $line = shift;
	$line =~ /\s*chomp\s*\(?\$?(\w+)\)?/;
	push(@output, "$1 = $1.rstrip()\n");
}


# Translates a = s/x/y/ to a= re.sub(r'x', 'y', a)
#	re.sub(pattern, repl, string, count=0, flags=0)
sub addResub($) {
	my $line = shift;
	$line =~ /\s*\$?(\w+)\s*=~\s*s\/(\[?]?.*)\/(.*)\/(g?)/;

	if ($4 ne "g") {
		push(@output, "$1 = re.sub(r\'$2\', \'$3\', $1, 1)\n");
	} else {
		push(@output, "$1 = re.sub(r\'$2\', \'$3\', $1)\n");
	}
}

#for x in xrange(100):
sub addFor($) {

	my $line = shift;
	debug($line);

}


# foreach $i (0..4) {
# for i in range(0, 5):
# Translates 'foreach a (b..c)' to 'for a in xrange()
sub addForeach($) {
	my $line = shift;	
	
	# Case: foreach(a..b):
	if ($line =~ /.*\.\..*/) {
		$line =~ s/\$//;
		$line =~ s/{//;	
		$line =~ /\s*foreach\s*(\w+)\s*\((.*)\.\.(.*)\)/;

		my $capture1 = $1;
		my $capture2 = $2;
		my $capture3 = $3;

		if ($capture3 =~ /\$#sys.ARGV/i) {
			push(@output, "for $capture1 in xrange(len(sys.argv) - 1):\n");
		} else {
			$capture3++;		
			push(@output, "for $capture1 in xrange($capture2, $capture3):\n");
		}
	}

	# Case 2: Some kind of (simple) iteration over an array
	elsif ($line =~ /\s*foreach\s*\$(\w+)\s*\(@\w+\)/) {
		$line =~ s/{//;
		$line =~ s/foreach (\$\w+)/for $1 in/;
		$line =~ s/\$//;
		$line =~ s/\@//;
		$line =~ s/\(//;
		$line =~ s/\)//;
		$line =~ s/\s*$//;
		$line .= ":";
		push(@output, "$line\n");
	}
	
}

sub addPostIncOrDec($) {
	my $line = shift;
	$line =~ /\s*(\w+)(.*)/;
	my @incOrDec = split('', $2);

	push(@output, "$1 $incOrDec[0]= 1\n");
}

sub addNextOrLast($) {
	my $line =shift;
	$line =~ s/last/break/;
	$line =~ s/next/continue/;
	push(@output, "$line\n");
}

# Python treats arrays differently.
# Appending a list to another list puts the list INSIDE the other list
sub addPush($) {
	my $line = shift;

	
	$line =~ /\s*push\s*\((.+)\s*,\s*(.+)\s*\)/;

	my $first = $1;
	my $second = $2;

	# If it's a string we will use append
	if ($2 =~ /^\s*\".*/) {
		$first =~ s/\@//g;
		push(@output, "$first.append($second)\n");
	}
	# If it's another list we will use extend
	elsif ($2 =~ /^\s*\@/) {
		$first =~ s/\@//g;
		$second =~ s/\@//g;
		push(@output, "$first.extend($second)\n");
	}
}

# list = join(', ', @healthy_things)
# list = ", ".join(healthy_things)
sub addJoin($) {
	my $line = shift;

	$line =~ s/\@//;
	$line =~ /\s*(\w+)\s*=\s*join\(([\'\"].*[\'\"]),\s*(.*)\)/;
	push(@output, "$1 = $2.join($3)\n");
}

# Python has different ways to split string:
#	str.split for spliting on a string
#	re.split for splitting on a regex
sub addSplit($) {
	my $line = shift;

	$line =~ s/my //;
	$line =~ s/@//;
	$line =~ s/\$//;

	$line =~ /(\w+)\s*=\s*split\((.*), (.*)\)/;

	my ($list, $splitOn, $toSplit) = ($1, $2, $3);

	# splitting on a regex:
	if ($splitOn =~ /^\/.*\/$/) {
		push(@output, "$list = re.split(\'$splitOn\', $toSplit)\n");
	}
	# splitting on a string
	elsif ($splitOn =~ /^[\"\'].*[\"\']$/) {
		push(@output, "$list = $toSplit.split($splitOn)\n")
	}
}

sub convertStringConcat($) {
	my $line = shift;	
	my @string = split('', $line);

	my @variable = split(' ', $line);

	my $numQuotes = 0;

	foreach my $x (@string) {		
		if ($x =~ "\"") {
			$numQuotes++;
		}
		if ($numQuotes%2 == 0 && $variables{$variable[0]} !~ /\d+/) {
			$x =~ s/\./+/;
		}
	}		

	$line = join('', @string);
	return $line;
}

# used to determine whether a given variable is likely
#	to be used as an int or not.
sub willBeUsedAsInt($) {

	my $var = '$';
	$var .= shift;

	my $usedAsInt ;

	foreach my $line (@perl) {

		if ($line =~ /.*\Q$var\E\s*[=<>\*]*.*\d+/i) {
			$usedAsInt = 1;
			last;
		}
	}
	return $usedAsInt;
}


sub printAllVars {
	print("ALL VARIABLES:\n");
	while( my( $key, $value ) = each %variables ){
    print "$key:$value\n";
	}
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
