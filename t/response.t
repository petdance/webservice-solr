use strict;
use warnings;

### XXX Whitebox tests!
use Test::More tests => 5;

use Data::Dumper;
use HTTP::Headers;
use HTTP::Response;

my $Class = 'WebService::Solr::Response';
use_ok( $Class );

# $r = HTTP::Response->new( $code, $msg, $header, $content )
my $SolrResponse = HTTP::Response->new(
    200 => 'OK',
    HTTP::Headers->new,
    q[{"responseHeader":{"status":0,"QTime":24,"params":{"rows":"2","sort":"created_dt desc","wt":"json","start":"4","q":"foo"}},"response":{"numFound":10,"start":4,"docs":[{"name":["foo1"]},{"name":["foo2"]}]}}],
);

my $Obj;
subtest 'Create tests' => sub {
    ok( $SolrResponse, 'Created dummy Solr response' );

    $Obj = $Class->new( $SolrResponse );
    ok( $Obj, "   Created $Class object from $SolrResponse" );
    isa_ok( $Obj, $Class  );
};

subtest 'Check accessors' => sub {
    ok( $Obj, 'Testing accessors' );

    for my $acc (
        qw[status_code status_message is_success is_error content docs pager pageset]
        )
    {
        ok( $Obj->can( $acc ),  "   Obj->can( $acc )" );
        ok( defined $Obj->$acc, "       Value = " . $Obj->$acc );
    }
};

subtest 'Check docs' => sub {
    for my $doc ( $Obj->docs ) {
        ok( $doc, "Testing $doc" );
        isa_ok( $doc, 'WebService::Solr::Document' );

        like( $doc->value_for( 'name' ),
            qr/foo/, "   Name = " . $doc->value_for( 'name' ) );
    }
};

subtest 'Check pagers' => sub {
    for my $pager ( $Obj->pager, $Obj->pageset,
        $Obj->pageset( mode => 'fixed' ) )
    {
        ok( $pager, "Pager retrieved: $pager" );
        is( $pager->total_entries,    10, "   Total entries = 10" );
        is( $pager->entries_per_page, 2,  "   Entries per page = 2" );
        is( $pager->first_page,       1,  "   First page = 1" );
        is( $pager->last_page,        5,  "   Last page = 5" );
        is( $pager->current_page,     3,  "   Current page = 2" );
    }
};

subtest 'Special case: 0 rows' => sub {
    my $http_response = HTTP::Response->new(
        200 => 'OK',
        HTTP::Headers->new,
        q[{"responseHeader":{"status":0,"QTime":1,"params":{"facet.mincount":"1","q":"*:*","facet.field":"tags","wt":"json","rows":"0"}},"response":{"numFound":220,"start":0,"docs":[]}}],
    );

    my $solr_response = $Class->new( $http_response );
    ok( !defined $solr_response->pager,   '0 rows, undef pager' );
    ok( !defined $solr_response->pageset, '0 rows, undef pageset' );
};

done_testing();
