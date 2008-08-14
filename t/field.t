use Test::More tests=>5;
use strict;
use warnings;

# Test 1

BEGIN { use_ok( 'WebService::Solr::Field' ); }

# Test 2
{
    my %p =(name=>"id",boost=>"3.0",value=>"0001");
    my $f = WebService::Solr::Field->new(\%p);
    my $got=$f->to_xml; 
    my $expected ='<field boost="3.0" name="id">0001</field>';
    ok($got eq $expected, 'Test all attributes');
}
# Test 3
{
    my %p =(name=>"id",boost=>"",value=>"0001");
    my $f = WebService::Solr::Field->new(\%p);
    my $got=$f->to_xml; 
    my $expected ='<field boost="1.0" name="id">0001</field>';
    ok($got eq $expected, 'Test no boost');
}
# Test 4
{
    my %p =(name=>"",boost=>"3.0",value=>"0001");
    my $f = WebService::Solr::Field->new(\%p);
    my $got;
    eval{
         $got=$f->to_xml;
    };
    ok($@,'Test missing field name.');
    
}
# Test 5
{
    my %p =(name=>"id",boost=>"3.0",value=>"");
    my $f = WebService::Solr::Field->new(\%p);
    my $got;
    eval{
         $got=$f->to_xml;
    };
    ok($@,'Test missing field value.');
    
}
