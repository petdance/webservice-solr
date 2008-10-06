package WebService::Solr::Request::AddDocument;

use Moose;

require XML::Generator;
use WebService::Solr::Document;

extends 'WebService::Solr::Request::Update';

has 'docs' =>
    ( is => 'rw', isa => 'ArrayRef', auto_deref => 1, default => sub { [] } );

sub BUILDARGS {
    my ( $self, @docs ) = @_;
    return { docs => [ _parse_docs( @docs ) ] };
}

sub _parse_docs {
    my @docs = @_;
    my @new_docs;

    for ( @docs ) {
        push @new_docs, $_ if blessed $_;
        push @new_docs,
            WebService::Solr::Document->new( ref $_ eq 'HASH' ? %$_ : @$_ );
    }

    return @new_docs;
}

sub add_docs {
    my ( $self, @docs ) = @_;

    $self->docs( $self->docs, _parse_docs( @docs ) );
}

sub to_xml {
    my ( $self ) = @_;
    my $gen = XML::Generator->new( ':std' );
    $gen->add( {}, map { $_->to_xml } $self->docs );
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
