#!/usr/bin/perl -w
# comparison operators: <, <=, >, >=, <>, !=, ==

$a = 10;
$b = 11;
$c = 11;
$d = 12;

if ($a<$b) {
	if ($d>$a) {
		if ($b==$c) {
			if ($a != $c) {
				if ($a <= $d) {
					if ($c>=$a) {
						print "Success!\n";
					}
				}
			}
		}
	}
}