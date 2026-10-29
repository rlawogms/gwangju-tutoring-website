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

# 1. visible FAQ
repl(
  q{    <details class="faq-item">
      <summary>전국 어디서나 신청할 수 있나요?</summary>
      <div class="faq-answer">네, 광역시·도부터 시·구·군·읍·면·동 단위까지 전국 모든 지역에서 매칭이 가능합니다. 비대면 화상 수업은 지역에 상관없이 원하는 선생님과 수업할 수 있습니다.</div>
    </details>},
  q{    <details class="faq-item">
      <summary>전남광주 전 지역 어디서나 신청할 수 있나요?</summary>
      <div class="faq-answer">네, 광주광역시 5개 구와 전라남도 22개 시·군, 총 27개 지역 전체에서 매칭이 가능합니다. 비대면 화상 수업은 지역에 상관없이 원하는 선생님과 수업할 수 있습니다.</div>
    </details>},
  "faq-visible"
);

# 2. popup form branding
repl(
  q{from_name: '전과목 일대일 과외 방문 팝업 상담 신청',},
  q{from_name: '전남광주 전과목 일대일 과외 방문 팝업 상담 신청',},
  "popup-from-name"
);
repl(
  q{subject: '[전과목 일대일 과외] 📋 방문 팝업 상담 신청이 접수됐습니다',},
  q{subject: '[전남광주 전과목 일대일 과외] 📋 방문 팝업 상담 신청이 접수됐습니다',},
  "popup-subject"
);

# 3. SITE_SEARCH_INDEX: drop fabricated teacher entries (teachers.html not copied to this site),
#    fix regions.html -> gwangju-regions.html, fix 전국 wording
{
  my $start_marker = q(var SITE_SEARCH_INDEX = [);
  my $end_marker = q(];
function renderSiteSearch() {);
  my $start_pos = index($c, $start_marker);
  my $end_pos = index($c, $end_marker);
  if ($start_pos == -1 || $end_pos == -1) {
    print "WARN [site-search-index]: markers not found (start=$start_pos end=$end_pos)\n";
  } else {
    my $replacement = q(var SITE_SEARCH_INDEX = [
  { title: '학원도 함께 보기', desc: '과외보다 학원이 맞다면, 소수정예 보습학원 와와학습코칭센터를 찾아보세요', url: 'academy-finder.html', kw: '근처 학원 찾기 학원 vs 과외 소수정예 학원' },
  { title: '개설 과목 - 국어', desc: '문학·비문학 독해, 논술 및 서술형 대비', url: '#subjects', kw: '국어 과목 문학 비문학 독해 논술 서술형' },
  { title: '개설 과목 - 영어', desc: '회화·문법·독해·내신 목표별 집중 수업', url: '#subjects', kw: '영어 과목 회화 문법 독해 내신' },
  { title: '개설 과목 - 수학', desc: '개념 완성부터 심화까지 단계별 맞춤 커리큘럼', url: '#subjects', kw: '수학 과목 개념 내신 수능' },
  { title: '개설 과목 - 과학', desc: '물리·화학·생명·지구과학 개념·내신 집중 대비', url: '#subjects', kw: '과학 과목 물리 화학 생명 지구과학' },
  { title: '개설 과목 - 사회', desc: '역사·지리·일반사회 개념 학습', url: '#subjects', kw: '사회 과목 역사 지리 일반사회' },
  { title: '수업 방식 안내', desc: '대면 방문 수업과 비대면 화상 수업 안내', url: '#about', kw: '수업 방식 대면 비대면 화상 방문' },
  { title: '수강료 안내', desc: '대면·비대면 수업 시간당 수강료 확인', url: '#tuition', kw: '수강료 비용 가격 시간당 요금' },
  { title: '학부모 후기', desc: '후기가 곧 업데이트됩니다', url: 'reviews.html', kw: '후기 리뷰 평가 학부모 만족도' },
  { title: '무료 상담 신청', desc: '전화 또는 온라인 폼으로 상담 신청', url: 'consult.html', kw: '상담 신청 문의 전화 매칭' },
  { title: '전남광주 지역별 학교 찾아보기', desc: '광주·전남 27개 시군구 지역별 학교 정보 확인', url: 'gwangju-regions.html', kw: '전남광주 지역 학교 구 시 군 확인 광산구 남구 동구 북구 서구 목포 여수 순천' },
  { title: '검정고시 대비 과외', desc: '초졸·중졸·고졸 검정고시 과목별 집중 대비', url: '검정고시-과외.html', kw: '검정고시 과외 초졸 중졸 고졸 준비' },
  { title: '국제학교 학생 맞춤 과외', desc: '영어·한국어·한국사·수학·과학 맞춤 지도', url: '국제학교-과외.html', kw: '국제학교 과외 외국인학교 영어 한국어 한국사' },
  { title: '자주 묻는 질문', desc: '과외비, 전직교사 매칭, 전남광주 지역 신청 가능 여부 등 FAQ', url: '#faq', kw: 'FAQ 자주 묻는 질문 과외비 전직교사 문의' },
  { title: '1:1 과외 활용 가이드', desc: '첫 수업 활용법, 방문·화상 선택 기준, 선생님 매칭까지', url: 'news.html', kw: '과외 가이드 첫 수업 방문 화상 선생님 매칭' },
  { title: '입시뉴스 - 첫 수업 확인사항', desc: '진단 수업에서 학습 수준, 성향, 선생님 궁합 확인법', url: 'news/첫수업-확인사항.html', kw: '첫 수업 진단 학습 수준 선생님 궁합' },
  { title: '입시뉴스 - 방문·화상 과외 비교', desc: '대면 방문 수업과 비대면 화상 수업 중 선택 기준', url: 'news/방문과외-화상과외-비교.html', kw: '방문 과외 화상 과외 비교 선택' },
  { title: '입시뉴스 - 성적 급락 시 과외 대응', desc: '취약 부분에 바로 집중할 수 있는 1:1 과외의 신속한 대응', url: 'news/성적급락-과외-대응.html', kw: '성적 급락 과외 대응 빠른 매칭' },
  { title: '입시뉴스 - 선생님 궁합 상담', desc: '학습 궁합이 안 맞을 때 담당 매니저와 상의하는 방법', url: 'news/선생님-궁합-상담.html', kw: '선생님 궁합 재매칭 상담' },
  { title: '입시뉴스 - 검정고시 과외 활용법', desc: '학습 공백 진단부터 시험일 역산 계획까지 검정고시 과외 활용법', url: 'news/검정고시-과외활용.html', kw: '검정고시 과외 활용 시험일 역산' },
  { title: '입시뉴스 - 과외비 책정 기준', desc: '비대면·대면 수업 시간당 과외비 기준 안내', url: 'news/과외비-기준.html', kw: '과외비 시간당 비용 기준 시세' },
  { title: '입시뉴스 - 국제학교 과외 활용법', desc: '한국어·한국사 보완부터 국내 교육과정 차이 좁히기까지', url: 'news/국제학교-과외-활용법.html', kw: '국제학교 과외 한국어 한국사 보완' },
  { title: '입시뉴스 - 중간고사 과외 시작 타이밍', desc: '시험 범위 발표 전후 과목별 과외 시작 타이밍', url: 'news/중간고사-과외-시작타이밍.html', kw: '중간고사 과외 시작 타이밍 시험범위' },
  { title: '입시뉴스 - 레벨테스트 확인사항', desc: '학습 수준 진단부터 선생님 매칭까지 이어지는 과정', url: 'news/레벨테스트-확인사항.html', kw: '레벨테스트 확인 진단 선생님 매칭' },
  { title: '입시뉴스 - 가을 학습 슬럼프 극복', desc: '2학기 중반 학습 의욕 저하를 과외로 극복하는 방법', url: 'news/가을학습슬럼프-과외극복.html', kw: '가을 슬럼프 학습 의욕 극복' },
  { title: '입시뉴스 - 성적표 받은 후 상담', desc: '점수보다 원인을 파악하는 과외 상담 질문', url: 'news/성적표받은후-과외상담.html', kw: '성적표 상담 질문 원인 파악' },
  { title: '입시뉴스 - 예비 고1 과외 준비', desc: '중3 2학기부터 준비해두면 좋은 과목별 포인트', url: 'news/예비고1-과외준비.html', kw: '예비고1 고등학교 준비 과목' },
  { title: '입시뉴스 - 9월 모의평가 과외 상담', desc: '9월 모의평가 성적표를 받은 후 과외 상담에서 확인할 것', url: 'news/9월모의평가-과외상담.html', kw: '9월 모의평가 성적표 과외 상담' },
  { title: '입시뉴스 - 고3 2학기 과외 마무리', desc: '수시·수능 준비가 겹치는 고3 2학기를 과외로 관리하는 법', url: 'news/고3-2학기-과외마무리.html', kw: '고3 2학기 과외 마무리 수시 수능' },
  { title: '입시뉴스 - 예비 고2 과외 준비', desc: '고1 성적을 바탕으로 준비하는 예비 고2 과외 시작 시기', url: 'news/예비고2-과외준비.html', kw: '예비고2 고등학교 준비 과목' },
  { title: '입시뉴스 - 고1 2학기 과외 준비', desc: '고1 2학기 중간고사, 과외에서 점검할 것', url: 'news/고1-2학기-과외준비.html', kw: '고1 2학기 과외 준비 중간고사' },
  { title: '입시뉴스 - 수시 지원 후 과외 상담', desc: '수시 원서 접수 후 발표까지 과외 상담에서 확인할 것', url: 'news/수시지원후-과외상담.html', kw: '수시 지원 후 과외 상담 발표' },
  { title: '입시뉴스 - 다음 학기 과외 계획', desc: '다음 학기 과외 계획을 세우기 좋은 시기', url: 'news/다음학기-과외계획.html', kw: '다음 학기 과외 계획 시기' },
  { title: '입시뉴스 - 내신 수능 과외 병행', desc: '학년별·전형별 내신·수능 준비 비중', url: 'news/내신수능-과외병행.html', kw: '내신 수능 병행 우선순위' },
  { title: '입시뉴스 - 정시 지원 전략 과외 준비', desc: '9월 모의평가 분석, 대학별 반영 비율 확인', url: 'news/정시지원전략-과외준비.html', kw: '정시 지원 전략 준비 모의평가' },
  { title: '입시뉴스 - 과목 수 선택 가이드', desc: '과외 시작 시 과목 수를 정하는 기준', url: 'news/과목수-선택가이드.html', kw: '과목 수 선택 병행' }
];
function renderSiteSearch() {);
    substr($c, $start_pos, ($end_pos + length($end_marker)) - $start_pos) = $replacement;
  }
}

open(OUT, ">:encoding(UTF-8)", $path) or die $!;
print OUT $c;
close OUT;
print "stage5 done. length $orig_len -> " . length($c) . "\n";
