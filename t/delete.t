use Test::More tests=>6;
use strict;
use warnings;
# Test 1
BEGIN { use_ok( 'WebService::Solr::Delete' ); }

# Test 2
{
    my %p =(id=>'1234');
    my $f = WebService::Solr::Delete->new(%p);
    my $got=$f->delete_by_id; 

    like( $got, qr{<delete>\s*<id>1234</id>\s*</delete>}, 'xml id ok' );
}

# Test 3 
BEGIN { use_ok( 'WebService::Solr::Delete' ); }
{
    my %p =(query=>'name:DDR');
    my $f = WebService::Solr::Delete->new(%p);
    my $got=$f->delete_by_query; 

    like( $got, qr{<delete>\s*<query>name:DDR</query>\s*</delete>}, 'xml query ok' );
}

# Test 4
{
    my %p =(query=>'name:DDR',id=>'1234');
    my $f;
    my $got;
    eval{
         $f = WebService::Solr::Delete->new(%p);   
         $got=$f->delete_by_id;
    };
    ok($@,'Both id and query present for delete_by_id');    
}
# Test 5
{
    my %p =(query=>'name:DDR',id=>'1234');
    my $f;
    my $got;
    eval{
         $f = WebService::Solr::Delete->new(%p);   
         $got=$f->delete_by_query;
    };
    ok($@,'Both id and query present for delete_by_query');    
}
