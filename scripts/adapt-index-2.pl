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

# JSON-LD EducationalOrganization
repl(
  q{"name": "전과목 일대일 맞춤 과외",
  "alternateName": ["전국 어디서나 일대일 맞춤 과외", "전과목 1:1 맞춤 과외", "전과목 1:1 과외"],},
  q{"name": "전남광주 전과목 일대일 맞춤 과외",
  "alternateName": ["전남광주 일대일 맞춤 과외", "광주 전과목 1:1 맞춤 과외", "전남 전과목 1:1 과외"],},
  "json-ld-name"
);
repl(
  q{"description": "국어·영어·수학·과학·사회 전 과목, 전국 시·구·군·읍·면·동 어디서나 대면·비대면 일대일 맞춤 과외 매칭 서비스",},
  q{"description": "국어·영어·수학·과학·사회 전 과목, 광주광역시·전라남도 27개 시·군·구 어디서나 대면·비대면 일대일 맞춤 과외 매칭 서비스",},
  "json-ld-desc"
);
repl(
  q{"areaServed": "KR",
  "aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.9",
    "bestRating": "5",
    "reviewCount": "184"
  }
},
  q{"areaServed": "광주광역시·전라남도"
},
  "json-ld-arearated"
);

# FAQ json-ld
repl(
  q{"name": "전국 어디서나 신청할 수 있나요?",
      "acceptedAnswer": { "@type": "Answer", "text": "네, 광역시·도부터 시·구·군·읍·면·동 단위까지 전국 모든 지역에서 매칭이 가능합니다. 비대면 화상 수업은 지역에 상관없이 원하는 선생님과 수업할 수 있습니다." }},
  q{"name": "전남광주 전 지역 어디서나 신청할 수 있나요?",
      "acceptedAnswer": { "@type": "Answer", "text": "네, 광주광역시 5개 구와 전라남도 22개 시·군, 총 27개 지역 전체에서 매칭이 가능합니다. 비대면 화상 수업은 지역에 상관없이 원하는 선생님과 수업할 수 있습니다." }},
  "faq-json-ld"
);

# hero
repl(
  q{  <div class="hero-badge">✦ 전국 어디서나, 대면·비대면 모두 가능</div>
  <h1>우리 아이만을 위한<br><span>일대일 맞춤 과외</span>, 전국 어디서나</h1>},
  q{  <div class="hero-badge">✦ 광주·전남 27개 시군구 전 지역, 대면·비대면 모두 가능</div>
  <h1>우리 아이만을 위한<br><span>일대일 맞춤 과외</span>, 전남광주 전 지역에서</h1>},
  "hero"
);

# stats-row
repl(
  q{<div class="stat-item"><span class="stat-num">전국</span><div class="stat-label">광역시·시·구·군·읍·면</div></div>},
  q{<div class="stat-item"><span class="stat-num">전남광주</span><div class="stat-label">27개 시·군·구 전 지역</div></div>},
  "stats-row"
);

open(OUT, ">:encoding(UTF-8)", $path) or die $!;
print OUT $c;
close OUT;
print "stage2 done. length $orig_len -> " . length($c) . "\n";
