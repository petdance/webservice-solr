use Test::More tests=>4;
use strict;
use warnings;

# Test 1

BEGIN { use_ok( 'WebService::Solr::SolrUrl' ); }

my $commonParams = {
    domain=>'localhost',
    port=>'8080',
};

my $url = WebService::Solr::SolrUrl->new($commonParams);

# Test 2

{   
    my $got = $url->updateUrl();
    my $expected = 'http://localhost:8080/solr/update/';
    ok($got eq $expected, 'Update url failed');
}  
# Test 3

{   
    my $got = $url->selectUrl();
    my $expected = 'http://localhost:8080/solr/select/';
    ok($got eq $expected, 'Select url failed');
}
  
# Test 4

{   
    my $got = $url->solrUrl();
    my $expected = 'http://localhost:8080/solr/';
    ok($got eq $expected, 'Solr url failed');
}  
