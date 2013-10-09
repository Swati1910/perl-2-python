#!/usr/bin/perl -w
# program to add the numbers 1 to 100

$total = 0;


for ($x=0; $x<100; $x++) { 
	$total += $x;          
}

print "$total\n";