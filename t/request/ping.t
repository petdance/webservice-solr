use strict;
use warnings;

use Test::More tests => 3;
use Test::Mock::LWP::UserAgent;

$Mock_ua->mock(
    get => sub {
        _test_req( $_[ 1 ] );
        return HTTP::Response->new;
    }
);

use_ok( 'WebService::Solr' );
my $solr = WebService::Solr->new();
isa_ok( $solr, 'WebService::Solr' );

my $expect;

{
    $expect = 'http://localhost:8983/solr/admin/ping?wt=json';
    $solr->ping();
}

sub _test_req {
    is( $_[ 0 ], $expect, 'ping() url' );
}
