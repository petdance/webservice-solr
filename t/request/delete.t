use strict;
use warnings;

use Test::More tests => 9;

BEGIN {
    use_ok( 'WebService::Solr::Request::Delete' );
}

{
    my $r = WebService::Solr::Request::Delete->new( id => '1234' );
    isa_ok( $r, 'WebService::Solr::Request::Delete' );
    is( $r->to_xml, '<delete><id>1234</id></delete>', 'delete by id' );
}

{
    my $r = WebService::Solr::Request::Delete->new( query => 'name:DDR' );
    isa_ok( $r, 'WebService::Solr::Request::Delete' );
    is( $r->to_xml, '<delete><query>name:DDR</query></delete>', 'delete by query' );
}

{
    my $r = eval { WebService::Solr::Request::Delete->new; };
    ok( !defined $r, 'new() failed' );
    like( $@, qr/Either a query or an id must be specified/, 'error: no query or id' );
}

{
    my $r = eval { WebService::Solr::Request::Delete->new( query => 'name:DDR', id => 1234 ); };
    ok( !defined $r, 'new() failed' );
    like( $@, qr/Both a query and an id cannot be specified simultaneously/, 'error: both query and id' );
}
