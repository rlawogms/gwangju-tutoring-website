use strict; use warnings;
use utf8; binmode STDOUT, ":encoding(UTF-8)";

my @files = ("news.html", "검정고시-과외.html", "국제학교-과외.html");
for my $f (@files) {
  open(my $fh, "<:encoding(UTF-8)", $f) or die $!;
  local $/; my $c = <$fh>; close $fh;
  my $orig = $c;

  $c =~ s{<a href="index\.html" class="navbar-brand"><img src="favicon\.svg" alt="전과목 일대일 과외"><span>전과목 일대일 과외</span></a>}
         {<a href="index.html" class="navbar-brand"><img src="favicon.svg" alt="전남광주 전과목 일대일 과외"><span>전남광주 전과목 일대일 과외</span></a>};

  $c =~ s{<a href="academy-finder\.html" class="nav-link">학원도 함께 보기</a>}
         {<a href="gwangju-academy-finder.html" class="nav-link">학원도 함께 보기</a>};
  $c =~ s{<a href="regions\.html" class="nav-link">지역 및 지역 학교 확인하기</a>}
         {<a href="gwangju-regions.html" class="nav-link">지역별 과외 안내</a>};
  $c =~ s{\s*<a href="teachers\.html" class="nav-link">선생님</a>\n}{\n};

  # drop dangling teachers.html related-links (news.html only)
  $c =~ s{\s*<a class="news-related" href="teachers\.html">선생님 소개 보기 <i class="ti ti-chevron-right"></i></a>\n}{\n}g;

  if ($c ne $orig) {
    open(my $out, ">:encoding(UTF-8)", $f) or die $!;
    print $out $c;
    close $out;
    print "fixed: $f\n";
  } else {
    print "no change: $f\n";
  }
}
