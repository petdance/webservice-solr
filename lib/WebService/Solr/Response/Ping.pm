package WebService::Solr::Response::Ping;

use Moose;

use XML::XPath;

extends 'WebService::Solr::Response';

has 'ping_status' => ( is => 'rw', isa => 'Str' );

sub BUILD {
    my ( $self, $args ) = @_;

    super;

    my $res = $args->{ raw_response };
    return if !$res->is_success;

    my $xpath = XML::XPath->new( xml => $res->content );
    my $status = $xpath->findvalue( '/response/str[@name="status"]' );
    $self->ping_status( "$status" );
}

sub ok {
    return shift->ping_status eq 'OK' ? 1 : 0;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
