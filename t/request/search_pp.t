use strict;
use warnings;

use Test::More tests => 5;
use Test::Mock::LWP;

use WebService::Solr;

$Mock_ua->mock(
    post => sub {
        my $mock = shift;
        my $uri  = shift;
        my $params = { @_ };
        _test_req( $uri, $params );
        return HTTP::Response->new;
    }
);
$Mock_response->mock( is_error => sub { return 0 } );

my $solr = WebService::Solr->new(undef, { PP => 1 } );
isa_ok( $solr, 'WebService::Solr' );

my ( $expect_path, $expect_params );

{
    $expect_path = '/solr/select';
    $expect_params = { q => 'foo', wt => 'json' };
    is $solr->last_response, undef, "The last_response attribute hasn't been set yet";
    $solr->search( 'foo' );
    isa_ok $solr->last_response, 'WebService::Solr::Response';
}

sub _test_req {
    my( $uri, $params ) = @_;
    is( $uri->path, $expect_path, 'search() path' );
    is_deeply( $params->{ Content }, $expect_params, 'search() params in post content' );
}
