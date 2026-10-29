#!/usr/bin/perl
use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my $path = "index.html";
open(F, "<:encoding(UTF-8)", $path) or die $!;
local $/; my $c = <F>; close F;
my $orig_len = length($c);

sub repl {
  my ($old, $new, $label) = @_;
  my $count = () = $c =~ /\Q$old\E/g;
  if ($count != 1) { print "WARN [$label]: found $count occurrences (expected 1)\n"; return; }
  $c =~ s/\Q$old\E/$new/;
}

# 0. remove naver/google site verification (not valid for new domain)
$c =~ s/\n?<meta name="naver-site-verification"[^>]*\/>\n?//;
$c =~ s/\n?<meta name="google-site-verification"[^>]*\/>\n?//;

# 1. global domain swap (covers canonical, og:url, twitter:image, json-ld urls, web3forms labels)
$c =~ s{https://alltutoring-website\.co\.kr}{https://gwangju-tutoring.co.kr}g;
$c =~ s{alltutoring-website\.co\.kr}{gwangju-tutoring.co.kr}g;

# 2. title/meta description+keywords/og:title/og:description
repl(
  q{<title>전과목 일대일(1:1) 과외 | 후기 184건 4.9점 - 전국 대면·비대면</title>},
  q{<title>전남광주 전과목 일대일(1:1) 과외 | 광주·전남 27개 시군구 - 대면·비대면</title>},
  "title"
);
repl(
  q{<meta property="og:title" content="전과목 일대일 맞춤 과외 - 전국 어디서나, 대면·비대면" />},
  q{<meta property="og:title" content="전남광주 전과목 일대일 맞춤 과외 - 광주·전남 전 지역, 대면·비대면" />},
  "og-title"
);
repl(
  q{<meta property="og:description" content="전과목 일대일 과외, 국어·영어·수학·과학·사회 전 과목을 전국 모든 지역에서 대면·비대면으로" />},
  q{<meta property="og:description" content="전과목 일대일 과외, 국어·영어·수학·과학·사회 전 과목을 광주광역시·전라남도 전 지역에서 대면·비대면으로" />},
  "og-description"
);

# 3. meta description/keywords (find current content dynamically)
$c =~ s{(<meta name="description" content=")[^"]*(" />\n<meta name="keywords" content=")[^"]*("\s*/>)}
       {$1전남광주(광주광역시·전라남도) 27개 시군구 전 지역, 국어·영어·수학·과학·사회 전 과목을 전직교사·현직교사·명문대 출신 선생님과 대면·비대면 중 선택해 일대일로 배우세요.$2전남광주 과외, 광주 과외, 전남 과외, 전남광주 일대일 과외, 광주 수학과외, 광주 영어과외, 전남 수학과외, 전남 영어과외, 전남광주 비대면 과외, 전남광주 방문과외, 전남광주 초등 과외, 전남광주 중등 과외, 전남광주 고등 과외$3}s;

open(OUT, ">:encoding(UTF-8)", $path) or die $!;
print OUT $c;
close OUT;
print "stage1 done. length $orig_len -> " . length($c) . "\n";
