use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

sub repl {
  my ($c, $old, $new, $label) = @_;
  my $count = () = $$c =~ /\Q$old\E/g;
  if ($count != 1) { print "WARN [$label]: found $count occurrences (expected 1)\n"; return; }
  $$c =~ s/\Q$old\E/$new/;
}

# ---- 검정고시-과외.html ----
{
  my $f = "검정고시-과외.html";
  open(my $fh, "<:encoding(UTF-8)", $f) or die $!;
  local $/; my $c = <$fh>; close $fh;

  repl(\$c,
    q{<title>검정고시 합격까지 1:1 맞춤 과외 - 초졸·중졸·고졸</title>},
    q{<title>전남광주 검정고시 합격까지 1:1 맞춤 과외 - 초졸·중졸·고졸</title>},
    "ged-title");
  repl(\$c,
    q{<meta name="description" content="초졸·중졸·고졸 검정고시, 합격까지 일대일로 맞춤 지도해드립니다. 국어·영어·수학·사회·과학·한국사·도덕 과목별 집중 대비, 대면·비대면 중 편한 방식으로 시작하세요." />},
    q{<meta name="description" content="광주광역시·전라남도 거주 학생도 초졸·중졸·고졸 검정고시, 합격까지 일대일로 맞춤 지도해드립니다. 국어·영어·수학·사회·과학·한국사·도덕 과목별 집중 대비, 대면·비대면 중 편한 방식으로 시작하세요." />},
    "ged-desc");
  repl(\$c,
    q{<meta name="keywords" content="검정고시 과외, 검정고시 일대일 과외, 고졸 검정고시, 중졸 검정고시, 초졸 검정고시, 검정고시 준비, 검정고시 일정, 검정고시 과목별 과외, 비대면 화상 과외, 대면 과외, 비대면 화상 수업, 대면 수업" />},
    q{<meta name="keywords" content="전남광주 검정고시 과외, 광주 검정고시 과외, 전남 검정고시 과외, 검정고시 일대일 과외, 고졸 검정고시, 중졸 검정고시, 초졸 검정고시, 검정고시 준비, 검정고시 일정, 검정고시 과목별 과외, 비대면 화상 과외, 대면 과외" />},
    "ged-keywords");
  repl(\$c,
    q{<meta property="og:title" content="검정고시 대비 과외 - 전과목 일대일 맞춤 과외" />},
    q{<meta property="og:title" content="전남광주 검정고시 대비 과외 - 전과목 일대일 맞춤 과외" />},
    "ged-og-title");
  repl(\$c,
    q{<meta property="og:description" content="초졸·중졸·고졸 검정고시를 준비하는 학생을 위한 일대일 맞춤 과외. 과목별 집중 대비, 대면·비대면 선택 가능합니다." />},
    q{<meta property="og:description" content="광주·전남 지역 초졸·중졸·고졸 검정고시를 준비하는 학생을 위한 일대일 맞춤 과외. 과목별 집중 대비, 대면·비대면 선택 가능합니다." />},
    "ged-og-desc");
  repl(\$c,
    q{<div class="stats-bar-item"><span class="stats-bar-num">전국</span><span class="stats-bar-label">방문·화상 과외</span></div>},
    q{<div class="stats-bar-item"><span class="stats-bar-num">전남광주</span><span class="stats-bar-label">방문·화상 과외</span></div>},
    "ged-stats");
  repl(\$c,
    q{    <details class="faq-item">
      <summary>일대일 과외는 어떤 방식으로 진행되나요?</summary>},
    q{    <details class="faq-item">
      <summary>전남광주 지역에서도 검정고시 과외가 가능한가요?</summary>
      <p>네, 검정고시는 광주광역시교육청·전라남도교육청에서 시행하는 국가 공인 시험으로, 거주 지역과 무관하게 응시할 수 있습니다. 방문 대면 수업은 선생님 배정 상황에 따라 달라질 수 있지만, 비대면 화상 수업은 전남광주 전 지역에서 동일하게 진행 가능합니다.</p>
    </details>
    <details class="faq-item">
      <summary>일대일 과외는 어떤 방식으로 진행되나요?</summary>},
    "ged-faq-insert");

  open(my $out, ">:encoding(UTF-8)", $f) or die $!;
  print $out $c;
  close $out;
  print "검정고시-과외.html done\n";
}

# ---- 국제학교-과외.html ----
{
  my $f = "국제학교-과외.html";
  open(my $fh, "<:encoding(UTF-8)", $f) or die $!;
  local $/; my $c = <$fh>; close $fh;

  repl(\$c,
    q{<title>국제학교 영어·한국사 맞춤 과외 - 전국 화상 수업 가능</title>},
    q{<title>전남광주 국제학교 영어·한국사 맞춤 과외 - 화상 수업 가능</title>},
    "intl-title");
  repl(\$c,
    q{<meta name="keywords" content="국제학교 과외, 국제학교 일대일 과외, 국제학교 영어 과외, 국제학교 한국어 과외, 국제학교 한국사 과외, 외국인학교 과외, IB 과외, IB Chinese 과외, IB 중국어 과외, AP 과외, AP Physics 과외, 국제학교 맞춤과외, 해외국제학교 과외, 비대면 국제학교 과외, 국제학교 수학 과외, 비대면 화상 과외, 대면 과외, 비대면 화상 수업, 대면 수업, 대구 국제학교 과외, 동대문구 국제학교 과외" />},
    q{<meta name="keywords" content="전남광주 국제학교 과외, 광주 국제학교 과외, 전남 국제학교 과외, 국제학교 일대일 과외, 국제학교 영어 과외, 국제학교 한국어 과외, 국제학교 한국사 과외, 외국인학교 과외, IB 과외, AP 과외, 국제학교 맞춤과외, 비대면 국제학교 과외, 비대면 화상 과외, 대면 과외" />},
    "intl-keywords");
  repl(\$c,
    q{<meta property="og:title" content="국제학교 학생 맞춤 과외 - 전과목 일대일 맞춤 과외" />},
    q{<meta property="og:title" content="전남광주 국제학교 학생 맞춤 과외 - 전과목 일대일 맞춤 과외" />},
    "intl-og-title");

  repl(\$c,
    q{  <div class="subject-tags">
    <span class="subject-tag">서울·경기</span>
    <span class="subject-tag">인천</span>
    <span class="subject-tag">대전</span>
    <span class="subject-tag">대구</span>
    <span class="subject-tag">부산</span>
    <span class="subject-tag">광주</span>
    <span class="subject-tag">울산·경남</span>
    <span class="subject-tag">세종</span>
    <span class="subject-tag">해외 소재 국제학교</span>
  </div>},
    q{  <div class="subject-tags">
    <span class="subject-tag" style="background:#0D2B6B;color:#fff;">광주</span>
    <span class="subject-tag" style="background:#0D2B6B;color:#fff;">전남</span>
    <span class="subject-tag">서울·경기</span>
    <span class="subject-tag">인천</span>
    <span class="subject-tag">대전</span>
    <span class="subject-tag">대구</span>
    <span class="subject-tag">부산</span>
    <span class="subject-tag">울산·경남</span>
    <span class="subject-tag">세종</span>
    <span class="subject-tag">해외 소재 국제학교</span>
  </div>},
    "intl-tags");

  open(my $out, ">:encoding(UTF-8)", $f) or die $!;
  print $out $c;
  close $out;
  print "국제학교-과외.html done\n";
}
