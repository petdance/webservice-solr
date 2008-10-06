use strict;
use warnings;

use Test::More tests => 10;
use Test::Mock::LWP::UserAgent;

use XML::Simple;

$Mock_ua->mock(
    request => sub {
        _test_req( @{ $_[ 1 ]->new_args } );
        return HTTP::Response->new;
    }
);

use_ok( 'WebService::Solr' );
my $solr = WebService::Solr->new( undef, { autocommit => 0 } );
isa_ok( $solr, 'WebService::Solr' );

my $expect;

{
    $expect = { doc => { field => { name => 'foo', content => 'bar' } } };
    $solr->add( { foo => 'bar' } );
    $solr->update( { foo => 'bar' } );
}

sub _test_req {
    is( $_[ 2 ]->path, '/solr/update', 'add() path' );
    is_deeply( { $_[ 2 ]->query_form }, { wt => 'json' }, 'add() params' );
    is_deeply(
        $_[ 3 ],
        [ 'Content_Type', 'text/xml; charset=utf-8' ],
        'add() headers'
    );
    my $struct = XMLin( $_[ 4 ], KeepRoot => 1 );
    is_deeply( $struct, { add => $expect }, 'add/update xml' );
}
