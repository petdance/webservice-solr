package WebService::Solr::Request::Commit;

use Moose;

require XML::Generator;

extends 'WebService::Solr::Request::Update';

has 'waitSearcher' => ( is => 'ro', isa => 'Bool', default => 1 );

has 'waitFlush' => ( is => 'ro', isa => 'Bool', default => 1 );

sub to_xml {
    my ( $self ) = @_;
    my $gen = XML::Generator->new( ':std' );
    $gen->commit(
        {   waitSearcher => $self->waitSearcher ? 'true' : 'false',
            waitFlush    => $self->waitFlush    ? 'true' : 'false'
        }
    );
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
