use Test::More tests => 9;
# Tests 1 and 2
BEGIN { use_ok( 'WebService::Solr::Commit' ); }
  require_ok( 'WebService::Solr::Commit' );
# Test Hash 3
my %opts1 =(waitFlush=>'true',waitSearcher=>'true');
my $commit_1 = WebService::Solr::Commit->new(%opts1);
my $got_1 = $commit_1->toString;

# Test Hash 4
my %opts2 =(waitFlush=>'true',waitSearcher=>'false');
my $commit_2 = WebService::Solr::Commit->new(%opts2);
my $got_2 = $commit_2->toString;

# Test Hash 5
my %opts3 =(waitFlush=>'false',waitSearcher=>'true');
my $commit_3 = WebService::Solr::Commit->new(%opts3);
my $got_3 = $commit_3->toString;

# Test Hash 6
my %opts4 =(waitFlush=>'false',waitSearcher=>'false');
my $commit_4 = WebService::Solr::Commit->new(%opts4);
my $got_4 = $commit_4->toString;

# Test Hash 7
my %opts5 =(waitFlush=>'',waitSearcher=>'false');
my $commit_5 = WebService::Solr::Commit->new(%opts5);
my $got_5 = $commit_5->toString;

# Test Hash 8
my %opts6 =(waitFlush=>'false',waitSearcher=>'');
my $commit_6 = WebService::Solr::Commit->new(%opts6);
my $got_6 = $commit_6->toString;

# Test Hash 9
my %opts7 =(waitFlush=>'',waitSearcher=>'');
my $commit_7 = WebService::Solr::Commit->new(%opts7);
my $got_7= $commit_7->toString;

my $expected_1 = '<commit waitFlush="true" waitSearcher="true" />';
my $expected_2 = '<commit waitFlush="true" waitSearcher="false" />';
my $expected_3 = '<commit waitFlush="false" waitSearcher="true" />';
my $expected_4 = '<commit waitFlush="false" waitSearcher="false" />';
my $expected_5 = '<commit waitFlush="" waitSearcher="false" />';
my $expected_6 = '<commit waitFlush="false" waitSearcher="" />';
my $expected_7 = '<commit waitFlush="" waitSearcher="" />';

ok($got_1 eq $expected_1, 'true and true');
ok($got_2 eq $expected_2, 'true and false');
ok($got_3 eq $expected_3, 'false and true');
ok($got_4 eq $expected_4, 'false and false');
ok($got_5 eq $expected_5, 'waitFlush missing');
ok($got_6 eq $expected_6, 'waitSearcher missing');
ok($got_7 eq $expected_7, 'both commit attributes missing');

