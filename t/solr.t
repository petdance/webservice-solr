use Test::More tests => 25;
use strict;
use warnings;
our $solr = WebService::Solr->new('http://localhost:8080/solr/');
BEGIN { 
    use_ok( 'WebService::Solr::Commit' ); 
    use_ok( 'WebService::Solr::Optimize');
    use_ok( 'WebService::Solr::Delete' );
    use_ok( 'WebService::Solr::Field' );
    use_ok( 'WebService::Solr::Document' );
    use_ok( 'WebService::Solr');
}


# Create Document 1
# -----------------

my %fields1 = (name=>'id',value=>'1',boost=>'1.6');
my %fields2 = (name=>'sku',value=>'A6B9A',boost=>'1.0');
my %fields3 = (name=>'manu',value=>'The Bird Book',boost=>'7.1');
my %fields4 = (name=>'weight',value=>'4.0',boost=>'3.2');
my %fields5 = (name=>'name',value=>'Sally Jesse Raphael',boost=>'');
my $f1 = WebService::Solr::Field->new(\%fields1);
my $f2 = WebService::Solr::Field->new(\%fields2);
my $f3 = WebService::Solr::Field->new(\%fields3);
my $f4 = WebService::Solr::Field->new(\%fields4);
my $f5 = WebService::Solr::Field->new(\%fields5);
my @fields1 =($f1,$f2,$f3,$f4,$f5);
my %params1 =(boost=>'3.0');
my $document1 = WebService::Solr::Document->new(\%params1);
my $doc1 = $document1->to_xml(\@fields1);

# Create Document 2
#-----------------

my %fields6 = (name=>'id',value=>'2',boost=>'3.6');
my %fields7 = (name=>'sku',value=>'AB3B6',boost=>'1.3');
my %fields8 = (name=>'manu',value=>'The Mammal Book',boost=>'7.1');
my %fields9 = (name=>'weight',value=>'5.6',boost=>'5.2');
my %fields10 = (name=>'name',value=>'Jose Cuervo',boost=>'3.0');
my $f6 = WebService::Solr::Field->new(\%fields6);
my $f7 = WebService::Solr::Field->new(\%fields7);
my $f8 = WebService::Solr::Field->new(\%fields8);
my $f9 = WebService::Solr::Field->new(\%fields9);
my $f10 = WebService::Solr::Field->new(\%fields10);
my @fields2 =($f6,$f7,$f8,$f9,$f10);
my %params2 =(boost=>'2.3');
my $document2 = WebService::Solr::Document->new(\%params2);
my $doc2 = $document2->to_xml(\@fields2);

# Create Document 3
#-------------------

my %fields11 = (name=>'id',value=>'3',boost=>'5.8');
my %fields12 = (name=>'sku',value=>'ZZ306',boost=>'4.2');
my %fields13 = (name=>'manu',value=>'The Reptile Book',boost=>'7.1');
my %fields14 = (name=>'weight',value=>'8.0',boost=>'6.5');
my %fields15 = (name=>'name',value=>'Capt Gerry',boost=>'3.0');
my $f11 = WebService::Solr::Field->new(\%fields11);
my $f12 = WebService::Solr::Field->new(\%fields12);
my $f13 = WebService::Solr::Field->new(\%fields13);
my $f14 = WebService::Solr::Field->new(\%fields14);
my $f15 = WebService::Solr::Field->new(\%fields15);
my @fields3 =($f11,$f12,$f13,$f14,$f15);
my %params3 =(boost=>'2.3');
my $document3 = WebService::Solr::Document->new(\%params3);
my $doc3 = $document3->to_xml(\@fields3);

{   
    my %param =(allowDups=>'false');
    my @arrDocs =($doc1,$doc2,$doc3);
    my $expected =qr{<int name="status">0</int>}s;
    my $got = $solr->add_documents(\@arrDocs,\%param);
    like( $got, $expected, 'Add Documents Test allowDups = false' );
}

# Solr delete subroutine test id
{
    my %p =(id=>'32');
    
    my $got=$solr->delete_documents(\%p); 
    my $expected = qr{<int name="status">0</int>}s; 
    like( $got, $expected, 'delete documents id failed' );
}
# Solr delete subroutine test query
{
    my %p =(query=>'id:6');
    my $got=$solr->delete_documents(\%p); 
    my $expected = qr{<int name="status">0</int>}s; 
    like( $got, $expected, 'delete documents query failed' );
}

# Solr delete subroutine both id and query

{
    my %p =(query=>'name:DDR',id=>'1234');
    my $got;
    eval{
         $got=$solr->delete_documents(\%p);
    };
    ok($@,'Both id and query present for delete_by_id');    
}

# Solr delete subroutine both id and query

{
    my %p =(query=>'name:DDR',id=>'1234');
    my $got;
    eval{
         $got=$solr->delete_by_query;
    };
    ok($@,'Both id and query present for delete_documents');    
}

# Solr commit subroutine test
{
my @tests = (
    { waitFlush => 'true',  waitSearcher => 'true' },
    { waitFlush => 'true',  waitSearcher => 'false' },
    { waitFlush => 'false', waitSearcher => 'true' },
    { waitFlush => 'false', waitSearcher => 'false' },
    { waitFlush => '',      waitSearcher => 'false' },
    { waitFlush => 'false', waitSearcher => '' },
    { waitFlush => '',      waitSearcher => '' },
);

{
    cmp_xml_commit( $_ ) for @tests;
}

sub cmp_xml_commit {
    my ( $opts ) = @_;
    my $got = $solr->commit( $opts );
    my $expected = qr{<int name="status">0</int>}s;
    like( $got, $expected, 'Commit Tests' );
    }
}
# Solr optimize subroutine test
{
my @tests = (
    { waitFlush => 'true',  waitSearcher => 'true' },
    { waitFlush => 'true',  waitSearcher => 'false' },
    { waitFlush => 'false', waitSearcher => 'true' },
    { waitFlush => 'false', waitSearcher => 'false' },
    { waitFlush => '',      waitSearcher => 'false' },
    { waitFlush => 'false', waitSearcher => '' },
    { waitFlush => '',      waitSearcher => '' },
);

{
    cmp_xml_optimize( $_ ) for @tests;
}

sub cmp_xml_optimize{
    my ( $opts ) = @_;
    my $got = $solr->optimize( $opts );
    my $expected =qr{<int name="status">0</int>}s;
    like( $got, $expected, 'Optimize Tests' );
    }

}
