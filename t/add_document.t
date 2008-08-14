use Test::More tests=>7;
use strict;
use warnings;

# Test 1

BEGIN { use_ok( 'WebService::Solr::Document' ); }

# Test 2 

BEGIN { use_ok( 'WebService::Solr::Field' ); }

# Test 3

BEGIN { use_ok( 'WebService::Solr::AddDocument' ); }

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

#Create AddDocument.pm
#------------------ 

# Test 4
# addXMLDocuments allowDups = false
#
{
    my %param =(allowDups=>'false');
    my $addDocument = WebService::Solr::AddDocument->new(\%param);
    my @arrDocs =($doc1,$doc2,$doc3);
    my $got = $addDocument->add_xml_documents(\@arrDocs);

like( $got, qr{<add allowDups="false">\s*<doc boost="3.0">\s*<field boost="1.6" name="id">1</field>\s*<field boost="1.0" name="sku">A6B9A</field>\s*<field boost="7.1" name="manu">The Bird Book</field>\s*<field boost="3.2" name="weight">4.0</field>\s*<field boost="1.0" name="name">Sally Jesse Raphael</field>\s*</doc>\s*<doc boost="2.3">\s*<field boost="3.6" name="id">2</field>\s*<field boost="1.3" name="sku">AB3B6</field>\s*<field boost="7.1" name="manu">The Mammal Book</field>\s*<field boost="5.2" name="weight">5.6</field>\s*<field boost="3.0" name="name">Jose Cuervo</field>\s*</doc>\s*<doc boost="2.3">\s*<field boost="5.8" name="id">3</field>\s*<field boost="4.2" name="sku">ZZ306</field>\s*<field boost="7.1" name="manu">The Reptile Book</field>\s*<field boost="6.5" name="weight">8.0</field>\s*<field boost="3.0" name="name">Capt Gerry</field>\s*</doc>\s*</add>}, 'Add Documents Test allowDups = false' );
}

# Test 5
# addXMLDocuments allowDups = true
#
{
    my %param =(allowDups=>'true');
    my $addDocument = WebService::Solr::AddDocument->new(\%param);
    my @arrDocs =($doc1,$doc2,$doc3);
    my $got = $addDocument->add_xml_documents(\@arrDocs);

like( $got, qr{<add allowDups="true">\s*<doc boost="3.0">\s*<field boost="1.6" name="id">1</field>\s*<field boost="1.0" name="sku">A6B9A</field>\s*<field boost="7.1" name="manu">The Bird Book</field>\s*<field boost="3.2" name="weight">4.0</field>\s*<field boost="1.0" name="name">Sally Jesse Raphael</field>\s*</doc>\s*<doc boost="2.3">\s*<field boost="3.6" name="id">2</field>\s*<field boost="1.3" name="sku">AB3B6</field>\s*<field boost="7.1" name="manu">The Mammal Book</field>\s*<field boost="5.2" name="weight">5.6</field>\s*<field boost="3.0" name="name">Jose Cuervo</field>\s*</doc>\s*<doc boost="2.3">\s*<field boost="5.8" name="id">3</field>\s*<field boost="4.2" name="sku">ZZ306</field>\s*<field boost="7.1" name="manu">The Reptile Book</field>\s*<field boost="6.5" name="weight">8.0</field>\s*<field boost="3.0" name="name">Capt Gerry</field>\s*</doc>\s*</add>}, 'Add Documents Test allowDups = true' );
}

# Test 6
# addXMLDocuments allowDups is blank
#
{
    my %param =(allowDups=>'');
    my $addDocument = WebService::Solr::AddDocument->new(\%param);
    my @arrDocs =($doc1,$doc2,$doc3);
    my $got = $addDocument->add_xml_documents(\@arrDocs);

like( $got, qr{<add allowDups="false">\s*<doc boost="3.0">\s*<field boost="1.6" name="id">1</field>\s*<field boost="1.0" name="sku">A6B9A</field>\s*<field boost="7.1" name="manu">The Bird Book</field>\s*<field boost="3.2" name="weight">4.0</field>\s*<field boost="1.0" name="name">Sally Jesse Raphael</field>\s*</doc>\s*<doc boost="2.3">\s*<field boost="3.6" name="id">2</field>\s*<field boost="1.3" name="sku">AB3B6</field>\s*<field boost="7.1" name="manu">The Mammal Book</field>\s*<field boost="5.2" name="weight">5.6</field>\s*<field boost="3.0" name="name">Jose Cuervo</field>\s*</doc>\s*<doc boost="2.3">\s*<field boost="5.8" name="id">3</field>\s*<field boost="4.2" name="sku">ZZ306</field>\s*<field boost="7.1" name="manu">The Reptile Book</field>\s*<field boost="6.5" name="weight">8.0</field>\s*<field boost="3.0" name="name">Capt Gerry</field>\s*</doc>\s*</add>}, 'Add Documents Test allowDups blank' );
}

# Test 7
# addXMLDocument 
#
{
    my %param =(allowDups=>'true');
    my $addDocument = WebService::Solr::AddDocument->new(\%param);
    my $got = $addDocument->add_xml_document($doc1);

like( $got, qr{<add allowDups="true">\s*<doc boost="3.0">\s*<field boost="1.6" name="id">1</field>\s*<field boost="1.0" name="sku">A6B9A</field>\s*<field boost="7.1" name="manu">The Bird Book</field>\s*<field boost="3.2" name="weight">4.0</field>\s*<field boost="1.0" name="name">Sally Jesse Raphael</field>\s*</doc>\s*</add>}, 'Add Documents Test addXMLDocument' );
}
