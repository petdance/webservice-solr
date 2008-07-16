use Test::More tests => 8;
use strict;
use warnings;
# Tests 1
BEGIN { use_ok( 'WebService::Solr::Optimize' ); }
  
# Test Hash 2
{
    my $expected_1 = '<optimize waitFlush="true" waitSearcher="true" />';
    my %opts1 =(waitFlush=>'true',waitSearcher=>'true');
    my $optimize_1 = WebService::Solr::Optimize->new(%opts1);
    my $got_1 = $optimize_1->toString;
    ok($got_1 eq $expected_1, 'true and true');
}
# Test Hash 3
{
    my $expected_2 = '<optimize waitFlush="true" waitSearcher="false" />';
    my %opts2 =(waitFlush=>'true',waitSearcher=>'false');
    my $optimize_2 = WebService::Solr::Optimize->new(%opts2);
    my $got_2 = $optimize_2->toString;
    ok($got_2 eq $expected_2, 'true and false');
}
# Test Hash 4
{
    my $expected_3 = '<optimize waitFlush="false" waitSearcher="true" />';
    my %opts3 =(waitFlush=>'false',waitSearcher=>'true');
    my $optimize_3 = WebService::Solr::Optimize->new(%opts3);
    my $got_3 = $optimize_3->toString;
    ok($got_3 eq $expected_3, 'false and true');
}
# Test Hash 5
{
    my $expected_4 = '<optimize waitFlush="false" waitSearcher="false" />';
    my %opts4 =(waitFlush=>'false',waitSearcher=>'false');
    my $optimize_4 = WebService::Solr::Optimize->new(%opts4);
    my $got_4 = $optimize_4->toString;
    ok($got_4 eq $expected_4, 'false and false');
}
# Test Hash 6
{
    my $expected_5 = '<optimize waitFlush="" waitSearcher="false" />';
    my %opts5 =(waitFlush=>'',waitSearcher=>'false');
    my $optimize_5 = WebService::Solr::Optimize->new(%opts5);
    my $got_5 = $optimize_5->toString;
    ok($got_5 eq $expected_5, 'waitFlush missing');
}
# Test Hash 7
{
    my $expected_6 = '<optimize waitFlush="false" waitSearcher="" />';
    my %opts6 =(waitFlush=>'false',waitSearcher=>'');
    my $optimize_6 = WebService::Solr::Optimize->new(%opts6);
    my $got_6 = $optimize_6->toString;
    ok($got_6 eq $expected_6, 'waitSearcher missing');
}
# Test Hash 8
{
    my $expected_7 = '<optimize waitFlush="" waitSearcher="" />';
    my %opts7 =(waitFlush=>'',waitSearcher=>'');
    my $optimize_7 = WebService::Solr::Optimize->new(%opts7);
    my $got_7= $optimize_7->toString;
    ok($got_7 eq $expected_7, 'both optimize attributes missing');
}
