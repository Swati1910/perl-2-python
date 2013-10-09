#!/usr/bin/perl -w

# regex demo

$word = "1234abc5678def";

$word =~ s/[0-9]//;
print "$word\n";

$word =~ s/[0-9]//g;
print "$word\n";