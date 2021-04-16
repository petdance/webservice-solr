use strict;
use warnings;

use Test::More tests => 11;
use Test::Mock::LWP;

use XML::Simple;
use HTTP::Headers;

use WebService::Solr;

$Mock_ua->mock(
    request => sub {
        _test_req( @{ $_[ 1 ]->new_args } );
        return HTTP::Response->new;
    }
);
$Mock_response->mock( is_error => sub { return 0 } );

my $solr = WebService::Solr->new( undef, { autocommit => 0, PP=>1 } );
isa_ok( $solr, 'WebService::Solr' );

my $expect;

{
    is $solr->last_response, undef, "The last_response attribute hasn't been set yet";
    $expect = { doc => { field => { name => 'foo', content => 'bar' } } };
    $solr->add( { foo => 'bar' } );
    isa_ok $solr->last_response, 'WebService::Solr::Response';
    $solr->update( { foo => 'bar' } );
}

sub _test_req {
    is( $_[ 2 ]->path, '/solr/update', 'add() path' );
    is_deeply( { $_[ 2 ]->query_form }, { wt => 'json' }, 'add() params' );
    is_deeply(
        $_[ 3 ]->header( 'Content_Type' ),
        'text/xml; charset=utf-8',
        'add() headers'
    );
    my $struct = XMLin( $_[ 4 ], KeepRoot => 1 );
    is_deeply( $struct, { add => $expect }, 'add/update xml' );
}

