use Test::More tests=>6;
use strict;
use warnings;

# Test 1

BEGIN { use_ok( 'WebService::Solr::Document' ); }

# Test 2 

BEGIN { use_ok( 'WebService::Solr::Field' ); }

# Test Data all attributes with values. 

my %fields1 = (name=>'id',value=>'1',boost=>'1.6');
my %fields2 = (name=>'sku',value=>'A6B9A',boost=>'1.0');
my %fields3 = (name=>'manu',value=>'The Bird Book',boost=>'7.1');
my %fields4 = (name=>'weight',value=>'4.0',boost=>'3.2');
my %fields5 = (name=>'name',value=>'Sally Jesse Raphael',boost=>'');

# No name present 

my %fields6 = (name=>'',value=>'Sally Jesse Raphael',boost=>'7.1');

# No value present

my %fields7 = (name=>'name',value=>'',boost=>'7.1');

# No name and value present

my %fields8 = (name=>'',value=>'',boost=>'7.1');

# No attribute values present.

my %fields9 = (name=>'',value=>'',boost=>'');

my $f1 = WebService::Solr::Field->new(\%fields1);
my $f2 = WebService::Solr::Field->new(\%fields2);
my $f3 = WebService::Solr::Field->new(\%fields3);
my $f4 = WebService::Solr::Field->new(\%fields4);
my $f5 = WebService::Solr::Field->new(\%fields5);
my $f6 = WebService::Solr::Field->new(\%fields6);
my $f7 = WebService::Solr::Field->new(\%fields7);
my $f8 = WebService::Solr::Field->new(\%fields8);
my $f9 = WebService::Solr::Field->new(\%fields9);

# Test 3
{
    my @fields1 =($f1,$f2,$f3,$f4,$f5);
    my %params1 =(boost=>'3.0');
    my $document1 = WebService::Solr::Document->new();
    my $got = $document1->to_xml(\@fields1,\%params1);
    like( $got, qr{<doc boost="3.0">\s*<field boost="1.6" name="id">1</field>\s*<field boost="1.0" name="sku">A6B9A</field>\s*<field boost="7.1" name="manu">The Bird Book</field>\s*<field boost="3.2" name="weight">4.0</field>\s*<field boost="1.0" name="name">Sally Jesse Raphael</field>\s*</doc>}s, 'xml add fields to document' );
}
# Test 4
{
    my @fields1 =($f1,$f2,$f3,$f4,$f6);
    my %params1 =(boost=>'3.0');
    my $document1 = WebService::Solr::Document->new();
    my $got='';  
    eval{
        $got=$document1->to_xml(\@fields1,\%params1);
    };
    ok($@,'The name attribute is missing a value! '); 
}

# Test 5 
{
my @fields1 =($f1,$f2,$f3,$f4,$f7);
    my %params1 =(boost=>'3.0');
    my $document1 = WebService::Solr::Document->new();
    my $got='';  
    eval{
        $got=$document1->to_xml(\@fields1,\%params1);
    };
    ok($@,'The value attribute is missing a value! '); 
}
# Test 6
{
my @fields1 =($f1,$f2,$f3,$f4,$f8);
    my %params1 =(boost=>'3.0');
    my $document1 = WebService::Solr::Document->new();
    my $got='';  
    eval{
        $got=$document1->to_xml(\@fields1,\%params1);
    };
    ok($@,'The name and value attribute are missing values! '); 
}
