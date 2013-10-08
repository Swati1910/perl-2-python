#!/usr/bin/perl -w
# bitwise operators: | ^ & << >> ~

use integer;
# doesn't matter if python doesn't translate 'use integer'

$a = 115;
$b = 13;

$c = $a & $b;
print "$c\n";

$c = $a | $b;
print "$c\n";

$c = $a ^ $b;
print "$c\n";

$c = ~$a;
print "$c\n";

$c = $a << 2;
print "$c\n";

$c = $a >> 2;
print "$c\n";