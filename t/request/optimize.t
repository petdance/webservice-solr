use strict;
use warnings;

use Test::More tests => 3;

BEGIN {
    use_ok( 'WebService::Solr::Request::Optimize' );
}

{
    my $r = WebService::Solr::Request::Optimize->new;
    isa_ok( $r, 'WebService::Solr::Request::Optimize' );
    is( $r->to_xml, '<optimize />', 'optimize' );
}
