#!/usr/bin/perl -w
# last and next in perl = break and continue in python

$a = 0;

while ($a < 10) {
	$a++;
	if ($a == 5) {
		next;
	}
	print "$a\n";
	if ($a == 7) {
		last;
	}
}