use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my @gwangju_gu = ('광산구','남구','동구','북구','서구');
my @jeonnam_si = ('강진군','고흥군','곡성군','광양시','구례군','나주시','담양군','목포시','무안군','보성군','순천시','신안군','여수시','영광군','영암군','완도군','장성군','장흥군','진도군','함평군','해남군','화순군');

my $f = "gwangju-regions.html";
open(my $fh, "<:encoding(UTF-8)", $f) or die $!;
local $/; my $c = <$fh>; close $fh;
my $orig_len = length($c);

for my $gu (@gwangju_gu) {
  $c =~ s/광주광역시 \Q$gu\E(?=[\s<])/전남광주 $gu/g;
  $c =~ s/광주 \Q$gu\E(?=[\s<])/전남광주 $gu/g;
}
for my $si (@jeonnam_si) {
  $c =~ s/전라남도 \Q$si\E(?=[\s<])/전남광주 $si/g;
  $c =~ s/전남 \Q$si\E(?=[\s<])/전남광주 $si/g;
}

open(my $out, ">:encoding(UTF-8)", $f) or die $!;
print $out $c;
close $out;
print "done. length $orig_len -> " . length($c) . "\n";
