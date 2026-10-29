use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my @files = glob("news/*.html");
for my $f (@files) {
  open(my $fh, "<:encoding(UTF-8)", $f) or die $!;
  local $/; my $c = <$fh>; close $fh;
  my $orig = $c;

  $c =~ s{<a href="\.\./index\.html" class="navbar-brand"><img src="\.\./favicon\.svg" alt="전과목 일대일 과외"><span>전과목 일대일 과외</span></a>}
         {<a href="../index.html" class="navbar-brand"><img src="../favicon.svg" alt="전남광주 전과목 일대일 과외"><span>전남광주 전과목 일대일 과외</span></a>};

  my $old_nav = q(    <a href="../academy-finder.html" class="nav-link">학원도 함께 보기</a>
    <a href="../검정고시-과외.html" class="nav-link">검정고시 과외</a>
    <a href="../국제학교-과외.html" class="nav-link">국제학교 과외</a>
    <a href="../regions.html" class="nav-link">지역 및 지역 학교 확인하기</a>);
  my $new_nav = q(    <a href="../gwangju-academy-finder.html" class="nav-link">학원도 함께 보기</a>
    <a href="../검정고시-과외.html" class="nav-link">검정고시 과외</a>
    <a href="../국제학교-과외.html" class="nav-link">국제학교 과외</a>
    <a href="../gwangju-regions.html" class="nav-link">지역별 과외 안내</a>);
  my $cnt1 = () = $c =~ /\Q$old_nav\E/g;
  if ($cnt1 == 1) { $c =~ s/\Q$old_nav\E/$new_nav/; }
  else { print "WARN [$f] nav block count=$cnt1\n"; }

  my $old_teacher_nav = q(    <a href="../teachers.html" class="nav-link">선생님</a>
);
  $c =~ s/\Q$old_teacher_nav\E//;

  $c =~ s{\s*<a href="\.\./teachers\.html">선생님 소개</a>\n}{\n};

  if ($c ne $orig) {
    open(my $out, ">:encoding(UTF-8)", $f) or die $!;
    print $out $c;
    close $out;
    print "fixed: $f\n";
  }
}
