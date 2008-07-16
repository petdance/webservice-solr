use Test::More tests => 8;
use strict;
use warnings;
# Tests 1
BEGIN { use_ok( 'WebService::Solr::Optimize' ); }
  
# Test Hash 2
{
    my $expected = '<optimize waitFlush="true" waitSearcher="true" />';
    my %opts =(waitFlush=>'true',waitSearcher=>'true');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got = $optimize->toString;
    ok($got eq $expected, 'true and true');
}
# Test Hash 3
{
    my $expected = '<optimize waitFlush="true" waitSearcher="false" />';
    my %opts =(waitFlush=>'true',waitSearcher=>'false');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got = $optimize->toString;
    ok($got eq $expected, 'true and false');
}
# Test Hash 4
{
    my $expected = '<optimize waitFlush="false" waitSearcher="true" />';
    my %opts =(waitFlush=>'false',waitSearcher=>'true');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got = $optimize->toString;
    ok($got eq $expected, 'false and true');
}
# Test Hash 5
{
    my $expected = '<optimize waitFlush="false" waitSearcher="false" />';
    my %opts =(waitFlush=>'false',waitSearcher=>'false');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got = $optimize->toString;
    ok($got eq $expected, 'false and false');
}
# Test Hash 6
{
    my $expected = '<optimize waitFlush="" waitSearcher="false" />';
    my %opts =(waitFlush=>'',waitSearcher=>'false');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got = $optimize->toString;
    ok($got eq $expected, 'waitFlush missing');
}
# Test Hash 7
{
    my $expected = '<optimize waitFlush="false" waitSearcher="" />';
    my %opts =(waitFlush=>'false',waitSearcher=>'');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got = $optimize->toString;
    ok($got eq $expected, 'waitSearcher missing');
}
# Test Hash 8
{
    my $expected = '<optimize waitFlush="" waitSearcher="" />';
    my %opts =(waitFlush=>'',waitSearcher=>'');
    my $optimize = WebService::Solr::Optimize->new(%opts);
    my $got= $optimize->toString;
    ok($got eq $expected, 'both optimize attributes missing');
}
