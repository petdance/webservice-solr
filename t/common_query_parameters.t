use Test::More tests => 8;
use strict;
use warnings;
# Test 0
BEGIN { use_ok( 'WebService::Solr::CommonQueryParameters' ); }

my $params={"sort"=>"score",start=>"1",rows=>"10",fq=>"manu:c*",fl=>"popularity manu name",debugQuery=>"debugQuery",explainOther=>"not blank",};
my $cqp = WebService::Solr::CommonQueryParameters->new($params);

# Test 1
{   
    my $got = $cqp->get_sort;
    my $expected = 'sort=score';
    ok($got eq $expected, 'Sort value');
}   
# Test 2
{   
    my $got = $cqp->get_start;
    my $expected = 'start=1';
    ok($got eq $expected, 'Start value');
}
# Test 3
{
    my $got = $cqp->get_rows;
    my $expected = 'rows=10';
    ok($got eq $expected, 'Rows value');
}
# Test 4
{
    my $got = $cqp->get_field_query;
    my $expected = 'fq=manu:c*';
    ok($got eq $expected, 'Field Query value');
}
# Test 5
{
    my $got = $cqp->get_field_list;
    my $expected = 'fl=popularity manu name';
    ok($got eq $expected, 'Field List value');
}
# Test 6
{
    my $got = $cqp->get_debug_query;
    my $expected = 'debugQuery';
    ok($got eq $expected, 'Debug Query value');
}
# Test 7
{
    my $got = $cqp->get_explain_other;
    my $expected = 'explainOther=not blank';
    ok($got eq $expected, 'Explain Other value');
}
