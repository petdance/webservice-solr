#!perl
use Test::More;

use strict;
use warnings;

use WebService::Solr;

plan skip_all => '$ENV{SOLR_SERVER} not set' unless $ENV{ SOLR_SERVER };

my $solr = WebService::Solr->new( $ENV{ SOLR_SERVER } );
isa_ok( $solr, 'WebService::Solr' );

my $schema = $solr->schema;

$schema
  or plan skip_all => '$ENV{SOLR_SERVER} too old for schema API?';

is(ref $schema->{fields}, 'ARRAY', 'got a fields array');
is(ref $schema->{fieldTypes}, 'ARRAY', 'got a types array');
is(ref $schema->{copyFields}, 'ARRAY', 'got a copyFields array');
is(ref $schema->{dynamicFields}, 'ARRAY', 'got a dynamicFields array');
ok(!ref $schema->{uniqueKey}, "uniqueKey isn't an array");

done_testing();
