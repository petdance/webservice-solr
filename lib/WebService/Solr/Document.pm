package WebService::Solr::Document;
use Solr::Field;
use XML::Generator;
use XML::Generator escape => 'always';
use Tie::IxHash;
use Data::Dumper;
use warnings;
use strict;

sub new {

    # Thus far only accepts fields for a single document.
    # AddDocuments
    my ( $class, $params ) = @_;
    my $self = {
        params => $params,

    };
    bless $self, $class;
    return $self;
}

sub to_xml {

    # Creates one document for the array of fields.
    my ( $self, $fields ) = @_;
    my $params = $self->{ params };
    my $field;
    my $fieldHolder = '';
    foreach $field ( @$fields ) {
        $fieldHolder = $fieldHolder . "" . $field;
    }

    my $boost = '';

    if ( $params->{ 'boost' } ) {
        $boost = $params->{ 'boost' };
    }
    else {
        $boost = '1.0';
    }
    my $gen = XML::Generator->new();
    my $xmlString = $gen->doc( { boost => $boost }, $fieldHolder );
    return "$xmlString";

}
1;
