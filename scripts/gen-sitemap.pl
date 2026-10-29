use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";
use Encode;

my $today = "2026-10-29";
my $domain = "https://gwangju-tutoring.co.kr";

my @top = (
  ["/", "1.0"],
  ["/consult.html", "0.8"],
  ["/gwangju-regions.html", "0.9"],
  ["/gwangju-academy-finder.html", "0.8"],
  ["/reviews.html", "0.7"],
  ["/news.html", "0.7"],
  ["/검정고시-과외.html", "0.6"],
  ["/국제학교-과외.html", "0.6"],
);

my @news = sort glob("news/*.html");

sub enc_path {
  my ($p) = @_;
  my $bytes = Encode::encode_utf8($p);
  $bytes =~ s/([^\x21-\x7E]|[%?#\[\]])/sprintf("%%%02X", ord($1))/ge;
  return $bytes;
}

open(my $out, ">:encoding(UTF-8)", "sitemap.xml") or die $!;
print $out qq{<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n};
for my $t (@top) {
  my ($path, $prio) = @$t;
  my $loc = $domain . enc_path($path);
  print $out qq{  <url>\n    <loc>$loc</loc>\n    <lastmod>$today</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>$prio</priority>\n  </url>\n};
}
for my $f (@news) {
  my $loc = $domain . '/' . enc_path($f);
  print $out qq{  <url>\n    <loc>$loc</loc>\n    <lastmod>$today</lastmod>\n    <changefreq>monthly</changefreq>\n    <priority>0.5</priority>\n  </url>\n};
}
print $out qq{</urlset>\n};
close $out;
print "sitemap written: " . (scalar(@top) + scalar(@news)) . " urls\n";
