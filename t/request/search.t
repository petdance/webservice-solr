use strict;
use warnings;

use Test::More tests => 7;
use Test::Mock::LWP;

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

use_ok( 'WebService::Solr' );
my $solr = WebService::Solr->new();
isa_ok( $solr, 'WebService::Solr' );

my ( $expect_path, $expect_url, $expect_params );

{
    $expect_path = '/solr/select';
    $expect_url = { wt => 'json' };
    $expect_params = { q => 'foo' };
    is $solr->last_response, undef, "The last_response attribute hasn't been set yet";
    $solr->search( 'foo' );
    isa_ok $solr->last_response, 'WebService::Solr::Response';
}

sub _test_req {
    my( $uri, $params ) = @_;
    is( $uri->path, $expect_path, 'search() path' );
    is_deeply( { $uri->query_form }, $expect_url, 'search() params not in uri' );
    is_deeply( $params->{ Content }, $expect_params, 'search() params in post content' );
}
