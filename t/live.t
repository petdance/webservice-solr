use Test::More;

use strict;
use warnings;

plan skip_all => '$ENV{SOLR_SERVER} not set' unless $ENV{ SOLR_SERVER };
plan tests => 3;

use_ok( 'WebService::Solr' );

my $solr = WebService::Solr->new( $ENV{ SOLR_SERVER } );
isa_ok( $solr, 'WebService::Solr' );

my $r = $solr->ping;
ok( $r, 'ping()' );

