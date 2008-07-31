use Test::More tests => 5;
use strict;
use warnings;
# Test 1
BEGIN { use_ok( 'WebService::Solr::CoreQueryParameters' ); }

my $params = {qt=>"standard",wt=>"standard",echoHandler=>"true",echoParams=> "all",}; 
my $str = CoreQueryParameters->new($params);

# Test 2
{   
    my $got = $str->getQueryType;
    my $expected = 'qt=standard';
    ok($got eq $expected, 'Query Type value');
} 

# Test 3

{   
    my $got = $str->getWriterType;
    my $expected = 'wt=standard';
    ok($got eq $expected, 'Writer Type value' );
}

# Test 4
 
{   
    my $got = $str->getEchoHandler;
    my $expected = 'echoHandler=true';
    ok($got eq $expected, 'Echo Handler value');
} 

# test 5

{   
    my $got = $str->getEchoParams;
    my $expected = 'echoParams=all';
    ok($got eq $expected, 'Echo Params value');
} 




