#!/usr/bin/perl -w

my @fruitbox;
my @veggiebox;

@fruitbox = ('dragonfruit', 'canistel', 'durian', 'salak', 'pulasan');
@veggiebox = ('fiddle heads', 'oca', 'romanesco', 'kohlrabi');

print "WTF is: \n";
foreach $x (@fruitbox) {
	print "$x\n";
}

print "WTF is: \n";
foreach $x (@veggiebox) {
	print "$x\n";
}

print "Oh, I forgot some normal things!\n";

push(@fruitbox, "apple");
push(@veggiebox, "carrot");

@healthy_things;
push (@healthy_things, @fruitbox);
push (@healthy_things, @veggiebox);

my $list = join(', ', @healthy_things);

print "Now I have $list ok\n";
