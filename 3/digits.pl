#!/usr/bin/perl -w
# Perl script to convert [01234] to < and [6789] to >.
# Aidan Barrington UNSW COMP2041 2013 S2

while ($line =  <>) {
$line =~ s/[01234]/</gi;
$line =~ s/[6789]/>/gi;
print "$line";
}
