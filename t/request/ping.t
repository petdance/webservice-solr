use strict;
use warnings;

use Test::More tests => 5;
use Test::Mock::LWP;

$Mock_ua->mock(
    get => sub {
        _test_req( $_[ 1 ] );
        return HTTP::Response->new;
    }
);
$Mock_response->mock( is_error => sub { return 0 } );

use_ok( 'WebService::Solr' );
my $solr = WebService::Solr->new();
isa_ok( $solr, 'WebService::Solr' );

my $expect;

{
    $expect = 'http://localhost:8983/solr/admin/ping?wt=json';
    is $solr->last_response, undef, "The last_response attribute hasn't been set yet";
    $solr->ping();
    isa_ok $solr->last_response, 'WebService::Solr::Response';
}

sub _test_req {
    is( $_[ 0 ], $expect, 'ping() url' );
}
