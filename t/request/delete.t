use strict;
use warnings;

use Test::More tests => 18;
use Test::Mock::LWP;

use XML::Simple;
use HTTP::Headers;

$Mock_ua->mock(
    request => sub {
        _test_req( @{ $_[ 1 ]->new_args } );
        return HTTP::Response->new;
    }
);
$Mock_response->mock( is_error => sub { return 0 } );

use_ok( 'WebService::Solr' );
my $solr = WebService::Solr->new( undef, { autocommit => 0 } );
isa_ok( $solr, 'WebService::Solr' );

my $expect;

{
    $expect = { id => 1234 };
    $solr->delete_by_id( 1234 );
}

{
    $expect = { query => 'name:DDR' };
    $solr->delete_by_query( 'name:DDR' );
}

{
    $expect = { query => 'foo', id => 13 };
    $solr->delete( $expect );
}

{
    $expect = { query => [ qw( foo bar ) ], id => [ 13, 42 ] };
    $solr->delete( $expect );
}

sub _test_req {
    is( $_[ 2 ]->path, '/solr/update', 'delete() path' );
    is_deeply( { $_[ 2 ]->query_form }, { wt => 'json' }, 'delete() params' );
    is(
        $_[ 3 ]->header( 'Content_Type' ),
        'text/xml; charset=utf-8',
        'delete() headers'
    );
    my $struct = XMLin( $_[ 4 ], KeepRoot => 1 );
    is_deeply( $struct, { delete => $expect }, 'delete() xml' );
}
