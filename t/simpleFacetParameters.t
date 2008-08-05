use Test::More tests=>17;
use strict;
use warnings; 

# Test 1

BEGIN { use_ok( 'WebService::Solr::SimpleFacetParameters' ); }

my $params={"facet"=>"true","facet.field"=>"id","facet.query"=>"price:[*+TO+500]","facet.prefix"=>"xx","facet.sort"=>"true","facet.limit"=>"-1",
"facet.offset"=>"2","facet.mincount"=>"facet.mincount","facet.missing"=>"true","facet.enum.cache.minDf"=>"25","facet.date"=>"timestamp","facet.date.start"=>"NOW/DAY-5DAYS",
"facet.date.end"=>"NOW/DAY-1DAY","facet.date.gap"=>"NOW+1DAY-3HOURS","facet.date.hardened"=>"true","facet.date.other"=>"facet.date.other" };
my $sfp = WebService::Solr::SimpleFacetParameters->new($params);

# Test 2
{   
    my $got = $sfp->getFacet;
    my $expected = 'facet=true';
    ok($got eq $expected, 'facet enabled failed');
}
# Test 3
{   
    my $got = $sfp->getFacet_Field;
    my $expected = "facet.field=id";
    ok($got eq $expected, "facet.field test failed");
}
# Test 4
{   
    my $got = $sfp->getFacet_Query;
    my $expected = "facet.query=price:[*+TO+500]";
    ok($got eq $expected, 'facet query failed');
}
# Test 5
{   
    my $got = $sfp->getFacet_Prefix;
    my $expected = "facet.prefix=xx";
    ok($got eq $expected, "facet.prefix test failed");
}
# Test 6
{   
    my $got = $sfp->getFacet_Sort;
    my $expected = "facet.sort=true";
    ok($got eq $expected, 'facet enabled');
}
# Test 7
{   
    my $got = $sfp->getFacet_Limit;
    my $expected = "facet.limit=-1";
    ok($got eq $expected, "facet.limit test failed");
}
# Test 8
{   
    my $got = $sfp->getFacet_Offset;
    my $expected = "facet.offset=2";
    ok($got eq $expected, 'facet.offset failed');
}
# Test 9
{   
    my $got = $sfp->getFacet_MinCount;
    my $expected = "facet.mincount";
    ok($got eq $expected, 'facet.mincount failed');
}
# Test 10
{   
    my $got = $sfp->getFacet_Missing;
    my $expected = "facet.missing=true";
    ok($got eq $expected, "facet.missing failed");
}
# Test 11
{   
    my $got = $sfp->getFacet_Enum_Cache_MinDf;
    my $expected = "facet.enum.cache.minDf=25";
    ok($got eq $expected, "facet.field test success");
}
# Test 12
{   
    my $got = $sfp->getFacet_Date;
    my $expected = "facet.date=timestamp";
    ok($got eq $expected, 'facet enabled');
}
# Test 13
{   
    my $got = $sfp->getFacet_Date_Start;
    my $expected = "facet.date.start=NOW/DAY-5DAYS";
    ok($got eq $expected, 'facet.date.start failed');
}
# Test 14
{   
    my $got = $sfp->getFacet_Date_End;
    my $expected = "facet.date.end=NOW/DAY-1DAY";
    ok($got eq $expected, 'facet.date.end failed');
}
# Test 15
{   
    my $got = $sfp->getFacet_Date_Gap;
    my $expected = "facet.date.gap=NOW+1DAY-3HOURS";
    ok($got eq $expected, "facet.date.gap test success");
}
# Test 16
{   
    my $got = $sfp->getFacet_Date_Hardened;
    my $expected = "facet.date.hardened=true";
    ok($got eq $expected, "facet.date.hardened test success");
}
# Test 17
{   
    my $got = $sfp->getFacet_Date_Other;
    my $expected = "facet.date.other";
    ok($got eq $expected, "facet.date.other test success");
}


