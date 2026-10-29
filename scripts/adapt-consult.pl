#!/usr/bin/perl
use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my $path = "consult.html";
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
  q{<title>무료 상담 신청 - 담당 매니저가 직접 연락 | 전과목 일대일 과외</title>},
  q{<title>무료 상담 신청 - 담당 매니저가 직접 연락 | 전남광주 전과목 일대일 과외</title>},
  "title"
);
repl(
  q{<meta name="description" content="지금 신청하면 담당 매니저가 직접 연락드립니다. 학생 정보와 희망 지역만 남겨주세요, 전과목 일대일 과외 무료 매칭 상담은 별도 비용이 들지 않습니다." />},
  q{<meta name="description" content="지금 신청하면 담당 매니저가 직접 연락드립니다. 학생 정보와 희망 지역만 남겨주세요, 전남광주 전과목 일대일 과외 무료 매칭 상담은 별도 비용이 들지 않습니다." />},
  "meta-desc"
);
repl(
  q{<meta name="keywords" content="과외 상담 신청, 과외 무료 상담, 과외 매칭 신청, 전과목 일대일 과외 상담" />},
  q{<meta name="keywords" content="전남광주 과외 상담 신청, 광주 과외 무료 상담, 전남 과외 매칭 신청" />},
  "meta-keywords"
);
repl(
  q{<meta property="og:title" content="무료 매칭 상담 신청 - 전과목 일대일 과외" />},
  q{<meta property="og:title" content="무료 매칭 상담 신청 - 전남광주 전과목 일대일 과외" />},
  "og-title"
);
repl(
  q{<meta property="og:description" content="전과목 일대일 과외 무료 매칭 상담 신청. 담당 매니저가 직접 연락드립니다." />},
  q{<meta property="og:description" content="전남광주 전과목 일대일 과외 무료 매칭 상담 신청. 담당 매니저가 직접 연락드립니다." />},
  "og-description"
);
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
    <a href="reviews.html" class="nav-link">후기</a>},
  q{    <a href="gwangju-academy-finder.html" class="nav-link">학원도 함께 보기</a>
    <a href="검정고시-과외.html" class="nav-link">검정고시 과외</a>
    <a href="국제학교-과외.html" class="nav-link">국제학교 과외</a>
    <a href="gwangju-regions.html" class="nav-link">지역별 과외 안내</a>
    <a href="news.html" class="nav-link">입시뉴스</a>
    <a href="reviews.html" class="nav-link">후기</a>},
  "navbar-links"
);

# region select: giant nationwide optgroup list -> 전남광주 27개 시군구 only
{
  my $start_marker = q{<select name="시도" id="regionSelect" required>
        <option value="" disabled selected>지역 선택</option>};
  my $end_marker = q{</optgroup>
      </select>};
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker, $start_pos);
  if ($start_pos == -1 || $end_pos == -1) {
    print "WARN [region-select]: markers not found (start=$start_pos end=$end_pos)\n";
  } else {
    my @gwangju = ('광산구','남구','동구','북구','서구');
    my @jeonnam = ('강진군','고흥군','곡성군','광양시','구례군','나주시','담양군','목포시','무안군','보성군','순천시','신안군','여수시','영광군','영암군','완도군','장성군','장흥군','진도군','함평군','해남군','화순군');
    my $opts = join("\n", map { qq{        <option>광주광역시 $_</option>} } @gwangju);
    $opts .= "\n" . join("\n", map { qq{        <option>전라남도 $_</option>} } @jeonnam);
    my $replacement = qq{<select name="시도" id="regionSelect" required>
        <option value="" disabled selected>지역 선택</option>
$opts
      </select>};
    my $cut_end = $end_pos + length($end_marker);
    substr($c, $start_pos, $cut_end - $start_pos) = $replacement;
  }
}

open(OUT, ">:encoding(UTF-8)", $path) or die $!;
print OUT $c;
close OUT;
print "consult done. length $orig_len -> " . length($c) . "\n";
