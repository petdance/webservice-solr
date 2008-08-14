use Test::More tests => 17;
use strict;
use warnings;

# Test 1

BEGIN { use_ok( 'WebService::Solr::SimpleFacetParameters' ); }

my $params = {
    "facet"                  => "true",
    "facet.field"            => "id",
    "facet.query"            => "price:[*+TO+500]",
    "facet.prefix"           => "xx",
    "facet.sort"             => "true",
    "facet.limit"            => "-1",
    "facet.offset"           => "2",
    "facet.mincount"         => "facet.mincount",
    "facet.missing"          => "true",
    "facet.enum.cache.minDf" => "25",
    "facet.date"             => "timestamp",
    "facet.date.start"       => "NOW/DAY-5DAYS",
    "facet.date.end"         => "NOW/DAY2B1DAY",
    "facet.date.gap"         =>  "2B1DAY",
    "facet.date.hardened"    => "true",
    "facet.date.other"       => "facet.date.other"
};
my $sfp = WebService::Solr::SimpleFacetParameters->new( $params );

# Test 2
{
    my $got      = $sfp->get_facet;
    my $expected = 'facet=true';
    ok( $got eq $expected, 'facet enabled failed' );
}

# Test 3
{
    my $got      = $sfp->get_facet_field;
    my $expected = "facet.field=id";
    ok( $got eq $expected, "facet.field test failed" );
}

# Test 4
{
    my $got      = $sfp->get_facet_query;
    my $expected = "facet.query=price:[*+TO+500]";
    ok( $got eq $expected, 'facet query failed' );
}

# Test 5
{
    my $got      = $sfp->get_facet_prefix;
    my $expected = "facet.prefix=xx";
    ok( $got eq $expected, "facet.prefix test failed" );
}

# Test 6
{
    my $got      = $sfp->get_facet_sort;
    my $expected = "facet.sort=true";
    ok( $got eq $expected, 'facet enabled' );
}

# Test 7
{
    my $got      = $sfp->get_facet_limit;
    my $expected = "facet.limit=-1";
    ok( $got eq $expected, "facet.limit test failed" );
}

# Test 8
{
    my $got      = $sfp->get_facet_offset;
    my $expected = "facet.offset=2";
    ok( $got eq $expected, 'facet.offset failed' );
}

# Test 9
{
    my $got      = $sfp->get_facet_min_count;
    my $expected = "facet.mincount";
    ok( $got eq $expected, 'facet.mincount failed' );
}

# Test 10
{
    my $got      = $sfp->get_facet_missing;
    my $expected = "facet.missing=true";
    ok( $got eq $expected, "facet.missing failed" );
}

# Test 11
{
    my $got      = $sfp->get_facet_enum_cache_min_df;
    my $expected = "facet.enum.cache.minDf=25";
    ok( $got eq $expected, "facet.field test success" );
}

# Test 12
{
    my $got      = $sfp->get_facet_date;
    my $expected = "facet.date=timestamp";
    ok( $got eq $expected, 'facet enabled' );
}

# Test 13
{
    my $got      = $sfp->get_facet_date_start;
    my $expected = "facet.date.start=NOW/DAY-5DAYS";
    ok( $got eq $expected, 'facet.date.start failed' );
}

# Test 14
{
    my $got      = $sfp->get_facet_date_end;
    my $expected = "facet.date.end=NOW/DAY2B1DAY";
    ok( $got eq $expected, 'facet.date.end failed' );
}

# Test 15
{
    my $got      = $sfp->get_facet_date_gap;
    my $expected = "facet.date.gap=2B1DAY";
    ok( $got eq $expected, "facet.date.gap test failed" );
}

# Test 16
{
    my $got      = $sfp->get_facet_date_hardened;
    my $expected = "facet.date.hardened=true";
    ok( $got eq $expected, "facet.date.hardened test failed" );
}

# Test 17
{
    my $got      = $sfp->get_facet_date_other;
    my $expected = "facet.date.other";
    ok( $got eq $expected, "facet.date.other test failed" );
}

