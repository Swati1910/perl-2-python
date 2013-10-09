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

my @lunch = split(', ', $list);

print "I'm lazy so here's lunch: \n";
foreach $x (@lunch) {
	print "$x\n";
}

# we can also split on a regex!
@secondList = split(/\s+/, $list);
print "I'm very lazy so here's dinner: \n";
foreach $x (@secondList) {
	print "$x\n";
}