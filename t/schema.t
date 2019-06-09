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

SKIP:
{
    $ENV{SOLR_TEST_SCHEMA_EDITS}
      or skip "Set SOLR_TEST_SCHEMA_EDITS=1 to test schema changes - maybe destructive", 1;
    my $f1 = "testf" . time() . "_" . int(rand(10000));
    my $f2 = $f1 . "a";
    my $f3 = $f1 . "b";
    my $t1 = "testt" . time() . "_" . int(rand(10000));

    # clone some text field
    my ($textt1, $textt2) = grep $_->{name} =~ /^text/, @{$schema->{fieldTypes}};

    ok($solr->edit_schema([ addfield => { name => $f1, type => $textt1->{name} } ]),
       "add a field");
    ok($solr->edit_schema([ deletefield => { name => $f1 } ]),
       "delete it again");
    my %mydef = ( %$textt1, name => $t1 );
}

done_testing();
