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

# 1. region-groups giant section -> compact 전남광주 chip summary
{
  my $start_marker = q{<section class="section">
  <div class="accent-line"></div>
  <h2 class="section-title">전국 어디서나 매칭 가능</h2>};
  my $end_marker = q{</section>

<section class="section-bg">
  <div class="accent-line"></div>
  <h2 class="section-title">왜 저희 과외를 선택해야 할까요</h2>};
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker);
  if ($start_pos == -1 || $end_pos == -1 || $end_pos < $start_pos) {
    print "WARN [region-section]: markers not found (start=$start_pos end=$end_pos)\n";
  } else {
    my @gwangju = ('광산구','남구','동구','북구','서구');
    my @jeonnam = ('강진군','고흥군','곡성군','광양시','구례군','나주시','담양군','목포시','무안군','보성군','순천시','신안군','여수시','영광군','영암군','완도군','장성군','장흥군','진도군','함평군','해남군','화순군');
    my $gwangju_chips = join("\n", map { qq{        <a href="gwangju-regions.html#card-$_" class="region-chip" style="text-decoration:none;">$_</a>} } @gwangju);
    my $jeonnam_chips = join("\n", map { qq{        <a href="gwangju-regions.html#card-$_" class="region-chip" style="text-decoration:none;">$_</a>} } @jeonnam);
    my $replacement = qq{<section class="section">
  <div class="accent-line"></div>
  <h2 class="section-title">전남광주 전 지역 매칭 가능</h2>
  <div class="section-sub">광주광역시 5개 구, 전라남도 22개 시·군, 총 27개 지역 어디서나 맞춤 수업을 진행할 수 있습니다</div>
  <div class="region-groups">
    <div class="region-group" style="flex:1 1 100%;">
      <div class="region-group-title">광주광역시</div>
      <div class="region-chips">
$gwangju_chips
      </div>
    </div>
    <div class="region-group" style="flex:1 1 100%;">
      <div class="region-group-title">전라남도</div>
      <div class="region-chips">
$jeonnam_chips
      </div>
    </div>
  </div>
  <div class="region-note">💡 대면 수업은 지역별 선생님 배정 상황에 따라 매칭 가능 여부가 달라질 수 있으며, 비대면 화상 수업은 전남광주 전 지역에서 동일하게 진행 가능합니다.</div>
  <div class="region-more-wrap">
    <a href="gwangju-regions.html" class="region-more-btn">우리 동네·학교 찾아보기 <i class="ti ti-chevron-right"></i></a>
  </div>
}; # trailing </section> intentionally kept from original end_marker split below
    substr($c, $start_pos, $end_pos - $start_pos) = $replacement;
  }
}

# 2. features-grid card
repl(
  q{    <div class="feature-card">
      <div class="feature-icon-wrap"><i class="ti ti-map-pin"></i></div>
      <div class="feature-title">전국 어디서나 매칭</div>
      <div class="feature-text">광역시부터 읍·면 단위까지, 전국 모든 지역에서 학생 조건에 맞는 선생님을 찾아드립니다.</div>
    </div>},
  q{    <div class="feature-card">
      <div class="feature-icon-wrap"><i class="ti ti-map-pin"></i></div>
      <div class="feature-title">전남광주 전 지역 매칭</div>
      <div class="feature-text">광주광역시·전라남도 27개 시군구 어디서나, 학생 조건에 맞는 선생님을 찾아드립니다.</div>
    </div>},
  "features-grid"
);

open(OUT, ">:encoding(UTF-8)", $path) or die $!;
print OUT $c;
close OUT;
print "stage3 done. length $orig_len -> " . length($c) . "\n";
