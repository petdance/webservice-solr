package WebService::Solr::Request::Optimize;

use Moose;

require XML::Generator;

extends 'WebService::Solr::Request::Update';

sub to_xml {
    my ( $self ) = @_;
    my $gen = XML::Generator->new( ':std' );
    $gen->optimize;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
