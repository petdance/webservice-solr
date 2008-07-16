use Test::More tests => 8;
use strict;
use warnings;
# Tests 1
BEGIN { use_ok( 'WebService::Solr::Commit' ); }
  
# Test Hash 2
{
    my $expected = '<commit waitFlush="true" waitSearcher="true" />';
    my %opts =(waitFlush=>'true',waitSearcher=>'true');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got = $commit->toString;
    ok($got eq $expected, 'true and true');
}
# Test Hash 3
{
    my $expected = '<commit waitFlush="true" waitSearcher="false" />';
    my %opts =(waitFlush=>'true',waitSearcher=>'false');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got = $commit->toString;
    ok($got eq $expected, 'true and false');
}
# Test Hash 4
{
    my $expected = '<commit waitFlush="false" waitSearcher="true" />';
    my %opts =(waitFlush=>'false',waitSearcher=>'true');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got = $commit->toString;
    ok($got eq $expected, 'false and true');
}
# Test Hash 5
{
    my $expected = '<commit waitFlush="false" waitSearcher="false" />';
    my %opts =(waitFlush=>'false',waitSearcher=>'false');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got = $commit->toString;
ok($got eq $expected, 'false and false');
}
# Test Hash 6
{
    my $expected = '<commit waitFlush="" waitSearcher="false" />';
    my %opts =(waitFlush=>'',waitSearcher=>'false');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got = $commit->toString;
    ok($got eq $expected, 'waitFlush missing');
}
# Test Hash 7
{
    my $expected = '<commit waitFlush="false" waitSearcher="" />';
    my %opts =(waitFlush=>'false',waitSearcher=>'');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got = $commit->toString;
    ok($got eq $expected, 'waitSearcher missing');
}
# Test Hash 8
{
    my $expected = '<commit waitFlush="" waitSearcher="" />';
    my %opts =(waitFlush=>'',waitSearcher=>'');
    my $commit = WebService::Solr::Commit->new(%opts);
    my $got= $commit->toString;
    ok($got eq $expected, 'both commit attributes missing');
}





