package WebService::Solr::Request::Delete;

use Moose;

require XML::Generator;

extends 'WebService::Solr::Request::Update';

has 'id' => ( is => 'ro', isa => 'Maybe[Num]' );

has 'query' => ( is => 'ro', isa => 'Maybe[Str]' );

sub BUILDARGS {
    my( $self, %args ) = @_;

    if( !defined $args{ id } and !defined $args{ query } ) {
        die 'Either a query or an id must be specified';
    }
    elsif( defined $args{ id } and defined $args{ query } ) {
        die 'Both a query and an id cannot be specified simultaneously';
    }

    return \%args;
}

sub to_xml {
    my ( $self ) = @_;
    my $method = $self->query ? 'query' : 'id';
    my $gen = XML::Generator->new( ':std' );

    $gen->delete( {}, $gen->$method( {}, $self->$method ) );
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
