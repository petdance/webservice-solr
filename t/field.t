use Test::More tests => 9;

use strict;
use warnings;

use WebService::Solr::Field;

{
    my $f = WebService::Solr::Field->new( id => '0001' );
    my $expected = '<field name="id">0001</field>';
    is( $f->to_xml, $expected, 'to_xml(), default attrs' );
}

{
    my $f = WebService::Solr::Field->new( id => '0001', { boost => 3 } );
    my $expected = '<field boost="3" name="id">0001</field>';
    is( $f->to_xml, $expected, 'to_xml(), all attrs' );
}

{
    my $f = WebService::Solr::Field->new( id => '0001', { boost => 3.1 } );
    my $expected = '<field boost="3.1" name="id">0001</field>';
    is( $f->to_xml, $expected, 'to_xml(), all attrs, float for boost' );
}

{
    my $f = eval { WebService::Solr::Field->new( undef() => '0001' ) };
    ok( !defined $f, 'name required' );
    ok( $@,          'name required' );
}

{
    my $f = eval { WebService::Solr::Field->new( id => undef ) };
    ok( !defined $f, 'value required' );
    ok( $@,          'value required' );
}

# XML escaping

{
    my $f = WebService::Solr::Field->new( foo => 'This & That' );
    my $expected = '<field name="foo">This &#x26; That</field>';
    is( $f->to_xml, $expected, 'to_xml(), escaped (1)' );
}

{
    my $f = WebService::Solr::Field->new( foo => 'This &amp; That' );
    my $expected = '<field name="foo">This &#x26;amp; That</field>';
    is( $f->to_xml, $expected, 'to_xml(), escaped (2)' );
}

