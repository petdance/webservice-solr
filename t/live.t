use Test::More;

use strict;
use warnings;

use WebService::Solr;

plan skip_all => '$ENV{SOLR_SERVER} not set' unless $ENV{ SOLR_SERVER };
plan tests => 2;

my $solr = WebService::Solr->new( $ENV{ SOLR_SERVER } );
isa_ok( $solr, 'WebService::Solr' );

my $r = $solr->ping;
ok( $r, 'ping()' );

done_testing();
