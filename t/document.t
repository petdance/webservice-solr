use Test::More tests => 23;

use strict;
use warnings;

BEGIN {
    use_ok( 'WebService::Solr::Document' );
    use_ok( 'WebService::Solr::Field' );
}

my @fields = (
    [ id     => 1,               { boost => 1.6 } ],
    [ sku    => 'A6B9A',         { boost => '1.0' } ],
    [ manu   => 'The Bird Book', { boost => '7.1' } ],
    [ weight => '4.0',           { boost => 3.2 } ],
    [ name   => 'Sally Jesse Raphael' ],
);

my @field_objs = map { WebService::Solr::Field->new( @$_ ) } @fields;

{
    my $expect = join( '',
        '<doc boost="3.0">',
        '<field boost="1.6" name="id">1</field>',
        '<field boost="1.0" name="sku">A6B9A</field>',
        '<field boost="7.1" name="manu">The Bird Book</field>',
        '<field boost="3.2" name="weight">4.0</field>',
        '<field name="name">Sally Jesse Raphael</field>',
        '</doc>' );

    {
        my $doc = WebService::Solr::Document->new( @fields[ 0 .. 4 ] );
        isa_ok( $doc, 'WebService::Solr::Document' );
        $doc->boost( '3.0' );
        is( $doc->to_xml, $expect, 'to_xml(), array refs' );
    }

    {
        my $doc = WebService::Solr::Document->new( @field_objs[ 0 .. 4 ] );
        isa_ok( $doc, 'WebService::Solr::Document' );
        $doc->boost( '3.0' );
        is( $doc->to_xml, $expect, 'to_xml(), objs' );
    }

    {
        my $doc = WebService::Solr::Document->new();
        isa_ok( $doc, 'WebService::Solr::Document' );
        $doc->boost( '3.0' );
        $doc->add_fields( @field_objs[ 0 .. 4 ] );
        is( $doc->to_xml, $expect, 'to_xml(), add_fields()' );
    }

    {
        my $doc = WebService::Solr::Document->new(
            $field_objs[ 0 ],
            @fields[ 1 .. 3 ],
            $field_objs[ 4 ]
        );
        isa_ok( $doc, 'WebService::Solr::Document' );
        $doc->boost( '3.0' );
        is( $doc->to_xml, $expect, 'to_xml(), mixed' );
    }
}

{
    my $doc = WebService::Solr::Document->new( key => 'value' );
    isa_ok( $doc, 'WebService::Solr::Document' );
    is( $doc->to_xml,
        '<doc><field name="key">value</field></doc>',
        'to_xml(), key=>val'
    );
}

{
    my $doc
        = WebService::Solr::Document->new( key => 'value', $field_objs[ 0 ] );
    isa_ok( $doc, 'WebService::Solr::Document' );
    is( $doc->to_xml,
        '<doc><field name="key">value</field><field boost="1.6" name="id">1</field></doc>',
        'to_xml(), key=>val + obj'
    );
}

{
    my $doc
        = WebService::Solr::Document->new( $field_objs[ 0 ], key => 'value' );
    isa_ok( $doc, 'WebService::Solr::Document' );
    is( $doc->to_xml,
        '<doc><field boost="1.6" name="id">1</field><field name="key">value</field></doc>',
        'to_xml(), obj + key=>val'
    );
}

{
    my $doc = WebService::Solr::Document->new( @field_objs[ 0 .. 4 ],
        $field_objs[ 1 ] );
    isa_ok( $doc, 'WebService::Solr::Document' );

    {
        my @values = $doc->values_for( 'id' );
        is_deeply( \@values, [ 1 ], 'values_for() -- single value' );
    }

    {
        my @values = $doc->values_for( 'sku' );
        is_deeply(
            \@values,
            [ 'A6B9A', 'A6B9A' ],
            'values_for() -- multi-value'
        );
    }

    {
        my @values = $doc->values_for( 'dne' );
        is_deeply( \@values, [], 'values_for() -- no values' );
    }
}

{
    my $doc = WebService::Solr::Document->new( x => [ 1, 2, 3 ] );
    isa_ok( $doc, 'WebService::Solr::Document' );
    is( scalar @{ $doc->fields }, 3, 'arrayref of values to fields' );
}

{
    my $doc = WebService::Solr::Document->new( @fields[ 0 .. 4 ] );
    is_deeply([ sort($doc->field_names) ], [ qw(id manu name sku weight)], 'field_names');
}
