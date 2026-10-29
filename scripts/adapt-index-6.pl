#!/usr/bin/perl
use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my $path = "index.html";
open(F, "<:encoding(UTF-8)", $path) or die $!;
local $/; my $c = <F>; close F;
my $orig_len = length($c);

sub cut_between {
  my ($start_marker, $end_marker_incl, $label) = @_;
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker_incl, $start_pos);
  if ($start_pos == -1 || $end_pos == -1) {
    print "WARN [$label]: markers not found (start=$start_pos end=$end_pos)\n";
    return;
  }
  my $cut_end = $end_pos + length($end_marker_incl);
  substr($c, $start_pos, $cut_end - $start_pos) = '';
}

# 1. CSS for school modal/dong-chip (no longer needed; gwangju-regions.html has its own)
cut_between(
  q(.school-backdrop {),
  q(.school-empty { font-size: 13px; color: #999; text-align: center; padding: 20px 0; }
),
  "css-school-modal"
);

# 2. modal HTML block
cut_between(
  q(<div class="school-backdrop" id="schoolBackdrop" onclick="closeRegionModal()"></div>),
  q(  <div id="schoolModalBody"></div>
</div>
),
  "html-school-modal"
);

# 3. modal JS block + school-data.js script tag (unused without the modal)
cut_between(
  q(<script>
  var TYPE_LABELS = { e: '초등학교', m: '중학교', h: '고등학교', o: '특수·기타학교' };),
  q(</script>
<script src="school-data.js"></script>
),
  "js-school-modal"
);

# 4. wmRegion select: full nationwide optgroup list -> 전남광주 27개 시군구 only
{
  my $start_marker = q(<select id="wmRegion" required>
          <option value="" disabled selected>지역 선택</option>);
  my $end_marker = q(</optgroup>
        </select>);
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker, $start_pos);
  if ($start_pos == -1 || $end_pos == -1) {
    print "WARN [wmRegion-select]: markers not found (start=$start_pos end=$end_pos)\n";
  } else {
    my @gwangju = ('광산구','남구','동구','북구','서구');
    my @jeonnam = ('강진군','고흥군','곡성군','광양시','구례군','나주시','담양군','목포시','무안군','보성군','순천시','신안군','여수시','영광군','영암군','완도군','장성군','장흥군','진도군','함평군','해남군','화순군');
    my $opts = join("\n", map { qq{          <option>광주광역시 $_</option>} } @gwangju);
    $opts .= "\n" . join("\n", map { qq{          <option>전라남도 $_</option>} } @jeonnam);
    my $replacement = qq{<select id="wmRegion" required>
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
print "stage6 done. length $orig_len -> " . length($c) . "\n";
