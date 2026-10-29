#!/usr/bin/perl
use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my $path = "reviews.html";
open(F, "<:encoding(UTF-8)", $path) or die $!;
local $/; my $c = <F>; close F;
my $orig_len = length($c);

sub repl {
  my ($old, $new, $label) = @_;
  my $count = () = $c =~ /\Q$old\E/g;
  if ($count != 1) { print "WARN [$label]: found $count occurrences (expected 1)\n"; return; }
  $c =~ s/\Q$old\E/$new/;
}

$c =~ s/\n?<meta name="naver-site-verification"[^>]*\/>\n?//;
$c =~ s/\n?<meta name="google-site-verification"[^>]*\/>\n?//;

repl(
  q{<title>학부모가 직접 남긴 후기 184건 ★4.9 - 전과목 일대일 과외</title>},
  q{<title>학부모 후기 - 전남광주 전과목 일대일 과외</title>},
  "title"
);
repl(
  q{<meta name="description" content="평점 4.9/5.0, 학부모 실제 후기 184건+를 그대로 확인하세요. 국어·영어·수학·과학·사회 과목별, 대면·비대면 방식별 수강 후기를 지금 바로 검색해보실 수 있습니다." />},
  q{<meta name="description" content="전남광주 전과목 일대일 과외의 학부모 후기를 소개합니다. 국어·영어·수학·과학·사회 과목별, 대면·비대면 방식별 수강 후기를 확인해보세요." />},
  "meta-desc"
);
repl(
  q{<meta name="keywords" content="과외 후기, 전과목 과외 후기, 일대일 과외 후기, 학부모 후기, 방문 과외 후기, 화상 과외 후기, 수학과외, 영어과외, 국어과외, 과학과외, 사회과외, 비대면 화상 과외, 대면 과외, 비대면 화상 수업, 대면 수업" />},
  q{<meta name="keywords" content="전남광주 과외 후기, 광주 과외 후기, 전남 과외 후기, 일대일 과외 후기, 학부모 후기" />},
  "meta-keywords"
);
repl(
  q{<meta property="og:title" content="전과목 일대일 과외 후기 - 학부모 실제 후기 ★4.9 (184건+)" />},
  q{<meta property="og:title" content="학부모 후기 - 전남광주 전과목 일대일 과외" />},
  "og-title"
);
repl(
  q{<meta property="og:description" content="평점 4.9/5.0, 실제 학부모 후기 184건+를 과목별·수업방식별로 확인하세요." />},
  q{<meta property="og:description" content="전남광주 전과목 일대일 과외의 학부모 후기를 소개합니다." />},
  "og-description"
);

# drop EducationalOrganization json-ld w/ fake aggregateRating (no real review data for new site)
{
  my $start_marker = q(<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "EducationalOrganization",);
  my $end_marker = q("aggregateRating": {
    "@type": "AggregateRating",
    "ratingValue": "4.9",
    "bestRating": "5",
    "reviewCount": "184"
  }
}
</script>
);
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker, $start_pos);
  if ($start_pos == -1 || $end_pos == -1) {
    print "WARN [org-json-ld]: markers not found (start=$start_pos end=$end_pos)\n";
  } else {
    my $cut_end = $end_pos + length($end_marker);
    substr($c, $start_pos, $cut_end - $start_pos) = '';
  }
}

repl(
  q{<a href="index.html" class="navbar-brand"><img src="favicon.svg" alt="전과목 일대일 과외"><span>전과목 일대일 과외</span></a>},
  q{<a href="index.html" class="navbar-brand"><img src="favicon.svg" alt="전남광주 전과목 일대일 과외"><span>전남광주 전과목 일대일 과외</span></a>},
  "navbar-brand"
);
repl(
  q{    <a href="academy-finder.html" class="nav-link">학원도 함께 보기</a>
    <a href="검정고시-과외.html" class="nav-link">검정고시 과외</a>
    <a href="국제학교-과외.html" class="nav-link">국제학교 과외</a>
    <a href="regions.html" class="nav-link">지역 및 지역 학교 확인하기</a>
    <a href="news.html" class="nav-link">입시뉴스</a>
    <a href="teachers.html" class="nav-link">선생님</a>
    <a href="reviews.html" class="nav-link active">후기</a>},
  q{    <a href="gwangju-academy-finder.html" class="nav-link">학원도 함께 보기</a>
    <a href="검정고시-과외.html" class="nav-link">검정고시 과외</a>
    <a href="국제학교-과외.html" class="nav-link">국제학교 과외</a>
    <a href="gwangju-regions.html" class="nav-link">지역별 과외 안내</a>
    <a href="news.html" class="nav-link">입시뉴스</a>
    <a href="reviews.html" class="nav-link active">후기</a>},
  "navbar-links"
);

# feed header + all review cards -> honest placeholder (no real review data for new site yet)
{
  my $start_marker = q{<section class="feed-header">
  <h1 class="feed-title">학부모 실제 <span class="feed-accent">후기</span><span class="feed-count">184건+</span></h1>
  <p class="feed-notice"><i class="ti ti-info-circle"></i> ★ 4.9 / 5.0, 실제 매칭받은 학부모님들이 남겨주신 후기입니다.</p>
</section>};
  my $end_marker = q{</div>
</section>

<section class="cta-section" id="consult">};
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker, $start_pos);
  if ($start_pos == -1 || $end_pos == -1) {
    print "WARN [feed-section]: markers not found (start=$start_pos end=$end_pos)\n";
  } else {
    my $replacement = q{<section class="feed-header">
  <h1 class="feed-title">학부모 <span class="feed-accent">후기</span></h1>
  <p class="feed-notice"><i class="ti ti-info-circle"></i> 전남광주 지역 후기가 곧 업데이트됩니다.</p>
</section>

<section class="feed-section">
  <div style="background:#F5F7FB;border-radius:12px;padding:40px 24px;text-align:center;color:#888;font-size:14px;line-height:1.8;max-width:640px;margin:0 auto;">
    아직 등록된 후기가 없습니다.<br>첫 수업을 시작하시면 가장 먼저 소개해드릴게요.
  </div>
</section>

<section class="cta-section" id="consult">};
    my $cut_end = $end_pos + length($end_marker);
    substr($c, $start_pos, $cut_end - $start_pos) = $replacement;
  }
}

open(OUT, ">:encoding(UTF-8)", $path) or die $!;
print OUT $c;
close OUT;
print "reviews done. length $orig_len -> " . length($c) . "\n";
