#!/usr/bin/perl -w
# logical operators: || && ! and or not

print "Logical Operator test\n";
$a = 11;
$b = 10;

if ($a > $b && $b < 100) {
	$answer = "yes";
} else {
	$answer = "no";
}
print "$answer\n";

$c = 0;

if ($a && $c) {
	print "Nothing to see here...\n";
} else {
	print "Didn't see anything...\n";
}

if (!$c) {
	print "But we will see this!\n";
}

if ($a and $c || $b) {
	print "and has lower precedence than ||\n";
}

if ($a && $c or $c) {
	print "&& has higher precedence than or\n";
}

if ($a and not $c) {
	print "not not not and and and\n";
}