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
    my $d1 = "*_$f1";
    my $t1 = "testt" . time() . "_" . int(rand(10000));

    # clone some text field
    my ($textt1, $textt2) = grep $_->{name} =~ /^text/, @{$schema->{fieldTypes}};

    ok($solr->edit_schema([ addfield => { name => $f1, type => $textt1->{name} } ]),
       "add a field");
    ok($solr->edit_schema([ deletefield => { name => $f1 } ]),
       "delete it again");
    my %mydef = ( %$textt1, name => $t1 );
    use Data::Dumper;
    ok($solr->edit_schema([ add_type => \%mydef ]),
       "create a field type")
      or diag Dumper($solr->last_response->content);
    %mydef = ( %$textt2, name => $t1 );
    ok($solr->edit_schema([ replace_type => \%mydef ]),
       "replace a field type")
      or diag Dumper($solr->last_response->content);
    ok($solr->edit_schema([ add_field => { name => $f1, type => $t1 } ]),
       "add field with the new type");
    ok($solr->edit_schema([ delete_field => { name => $f1 } ]),
       "add field with the new type");
    ok($solr->edit_schema([ delete_type => { name => $t1 } ]),
       "and delete the type")
      or diag Dumper($solr->last_response->content);

    ok($solr->edit_schema([ add_field =>
			      [
				  +{ name => $f1, type => $textt1->{name} },
                                  +{ name => $f2, type => $textt1->{name} },
				  +{ name => $f3, type => $textt2->{name} },
			      ]
			  ]),
       "add multiple fields");

    ok($solr->edit_schema([ replace_field => { name => $f2, type => $textt2->{name} } ]),
       "replace a field");

    ok($solr->edit_schema([ add_copy => { source => $f1, dest => [ $f2, $f3 ] } ]),
       "add copy fields");

    ok($solr->edit_schema([ delete_copy => { source => $f1, dest => [ $f2, $f3 ] } ]),
       "delete the copy fields");

    ok($solr->edit_schema([ delete_field => [ $f1, $f2, $f3 ] ]),
       "delete multiple fields");

    ok($solr->edit_schema([ add_dynamic_field => { name => $d1, type => $textt1->{name} } ]),
       "add dynamic field");

    ok($solr->edit_schema([ replace_dynamic_field => { name => $d1, type => $textt2->{name} } ]),
       "replace dynamic field");
    ok($solr->edit_schema([ delete_dynamic_field => $d1 ]),
       "delete dynamic field");

  SKIP:
    {
        eval { require JSON::PP; 1 }
          or skip "No JSON::PP", 2;
        %mydef = (
            %$textt1,
            name => $t1,
            indexed => JSON::PP::true(),
            stored => JSON::PP::false()
           );
        ok($solr->edit_schema([ add_type => \%mydef ]),
           "create a field type (customize with bools)")
          or diag Dumper($solr->last_response->content);
        ok($solr->edit_schema([ delete_type => $t1 ]),
           "and remove it again");
    }
}

done_testing();
