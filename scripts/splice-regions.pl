use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

open(my $f1, "<:encoding(UTF-8)", "gwangju-regions-shell.html") or die $!;
local $/; my $shell = <$f1>; close $f1;

open(my $f2, "<:encoding(UTF-8)", "gwangju-regions-cards.html.part") or die $!;
my $cards = <$f2>; close $f2;

die "placeholder not found\n" unless $shell =~ /__CARDS__/;
$shell =~ s/__CARDS__/$cards/;

open(my $out, ">:encoding(UTF-8)", "gwangju-regions.html") or die $!;
print $out $shell;
close $out;
print "spliced. final length " . length($shell) . "\n";
