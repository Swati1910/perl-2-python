#!/usr/bin/perl -w

# arithmetic operators: + - * / % **
# nb: ** is exponentiation and binds even 
#	more tightly than unary minus, so -2**4 is -(2**4), not (-2)**4.

$x = 20;
$y = 22.2;

$z = $x + $y;

print "$z\n";

$a = $z - $x;

print "$a\n";

$b = $x * $a;

print "$b\n";
$b = $b * $a;

my $l = $b/100;

print "$l\n";

my $starStared = $x**2;
print "$starStared\n";

my $total = $x-$y+$l/$b%$starStared;
print "$total\n";