package WebService::Solr::Document;
use strict;
use warnings;
use WebService::Solr::Field;
use XML::Generator escape => 'always';

sub new {

    # Thus far only accepts fields for a single document.
    # AddDocuments
    my ( $class, $fields ) = @_;
    my $self = {
        fields => $fields,
    };
    bless $self, $class;
    return $self;
}
sub to_xml {
    # Creates one document for the array of fields.
    my ( $self, $fields,$doc_params ) = @_;
    my $field;
    my $fieldHolder = '';
    foreach $field ( @$fields ) {
        $fieldHolder = $fieldHolder ."". $field->to_xml;
    }

    my $boost = '';

    if ( $doc_params->{ 'boost' } ) {
        $boost = $doc_params->{ 'boost' };
    }
    else {
        $boost = '1.0';
    }
    my $gen = XML::Generator->new();
    my $xmlString = $gen->doc( { boost => $boost }, $fieldHolder );
    return "$xmlString";

}
1;
