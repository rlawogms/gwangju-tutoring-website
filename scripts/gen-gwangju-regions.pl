#!/usr/bin/perl
use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";
use JSON::PP;

open(F, "<:encoding(UTF-8)", "school-data.js") or die $!;
local $/; my $c = <F>;
close F;
$c =~ s/^window\.SCHOOL_DATA\s*=\s*//;
$c =~ s/;\s*$//;
my $data = JSON::PP->new->utf8(0)->decode($c);

my @gwangju_gu = ('광산구','남구','동구','북구','서구');
my @jeonnam_si = ('강진군','고흥군','곡성군','광양시','구례군','나주시','담양군','목포시','무안군','보성군','순천시','신안군','여수시','영광군','영암군','완도군','장성군','장흥군','진도군','함평군','해남군','화순군');

my %typeLabel = (e=>'초등학교', m=>'중학교', h=>'고등학교', o=>'기타');
my %typeOrder = (e=>0, m=>1, h=>2, o=>3);
my @SUBJECTS = ('국어','영어','수학','과학','사회');

sub abbr_of {
  my ($n) = @_;
  if ($n =~ /^(.+)초등학교$/) { return "$1초"; }
  if ($n =~ /^(.+)중학교$/)   { return "$1중"; }
  if ($n =~ /^(.+)고등학교$/) { return "$1고"; }
  return $n;
}

sub gen_card {
  my ($region_label, $full_region_name, $gun, $key) = @_;
  my $schools = $data->{$key} || [];
  my $cnt = scalar(@$schools);

  my %seen; my @dongs;
  for my $s (@$schools) {
    my $d = $s->{d};
    next unless $d;
    next if $seen{$d}++;
    push @dongs, $d;
  }

  my %byType;
  for my $s (@$schools) { push @{$byType{$s->{t}}}, $s; }

  my $dongChips = join('', map { qq{<span class="dong-tag">$_</span>} } @dongs[0..($#dongs < 11 ? $#dongs : 11)]);
  my $dongMore = scalar(@dongs) > 12 ? sprintf(' <span class="dong-tag dong-more">외 %d개 동</span>', scalar(@dongs) - 12) : '';

  # data-search: dense, grounded per-school keyword blob
  my @terms = ($gun, $region_label, $gun, @dongs);
  for my $s (@$schools) {
    my $full = $s->{n};
    my $abbr = abbr_of($full);
    push @terms, $full, "$full"."과외";
    if ($abbr ne $full) {
      push @terms, $abbr, "$abbr"."과외";
      for my $subj (@SUBJECTS) { push @terms, "$abbr$subj"."과외"; }
    }
    for my $subj (@SUBJECTS) { push @terms, "$full$subj"."과외"; }
  }
  push @terms, "$region_label $gun 과외", "$region_label $gun 일대일과외", "$region_label $gun 비대면과외", "$region_label $gun 방문과외";
  for my $subj (@SUBJECTS) { push @terms, "$region_label $gun $subj"."과외"; }
  my $dataSearch = join(' ', @terms);
  $dataSearch =~ s/"/&quot;/g;

  my $schoolListHtml = '';
  for my $t (sort { $typeOrder{$a} <=> $typeOrder{$b} } keys %byType) {
    next unless $typeLabel{$t};
    my @names = sort map { $_->{n} } @{$byType{$t}};
    $schoolListHtml .= qq{<div class="school-type-group"><div class="school-type-label">$typeLabel{$t} (} . scalar(@names) . qq{)</div><div class="school-list">} . join('', map { qq{<span class="school-item">$_</span>} } @names) . qq{</div></div>};
  }

  my $card = qq{
    <div id="card-$gun" class="center-card" data-name="$gun" data-search="$dataSearch">
      <div class="card-front">
        <div class="card-top-row">
          <div class="center-brand brand-wawa">$region_label $gun</div>
        </div>
        <div class="center-name">$full_region_name $gun</div>
        <div class="center-reg">관할 학교 $cnt\개 기준 서비스 가능 지역</div>
        <div class="center-addr filled">$dongChips$dongMore</div>
        <button type="button" class="school-details-btn" onclick="openRegionModal('$key')"><i class="ti ti-chevron-right"></i> 이 지역 학교 목록 보기</button>
        <a href="consult.html" class="detail-btn"><i class="ti ti-message-circle-2"></i> 이 지역 과외 상담 신청</a>
      </div>
    </div>};
  return $card;
}

my @cards;
my $total = 0;
for my $gun (@gwangju_gu) {
  my $key = "전남광주통합특별시(광주)|$gun";
  $total += scalar(@{$data->{$key} || []});
  push @cards, gen_card('광주', '광주광역시', $gun, $key);
}
for my $gun (@jeonnam_si) {
  my $key = "전남광주통합특별시(전남)|$gun";
  $total += scalar(@{$data->{$key} || []});
  push @cards, gen_card('전남', '전라남도', $gun, $key);
}

my $cardsHtml = join("\n", @cards);
open(my $out, ">:encoding(UTF-8)", "gwangju-regions-cards.html.part") or die $!;
print $out $cardsHtml;
close $out;

print "Total schools: $total\n";
print "Cards generated: " . scalar(@cards) . "\n";
