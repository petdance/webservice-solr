use strict;
use warnings;

use Test::More tests => 6;
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

my ( $expect_path, $expect_params );

{
    $expect_path = '/solr/select';
    $expect_params = { wt => 'json', q => 'foo' };
    is $solr->last_response, undef, "The last_response attribute hasn't been set yet";
    $solr->search( 'foo' );
    isa_ok $solr->last_response, 'WebService::Solr::Response';
}

sub _test_req {
    is( $_[ 0 ]->path, $expect_path, ' search() path ' );
    is_deeply( { $_[ 0 ]->query_form }, $expect_params, ' search() params ' );
}
