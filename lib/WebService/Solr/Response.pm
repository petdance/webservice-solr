package WebService::Solr::Response;

use Moose;

require Class::MOP;
use XML::XPath;

has 'raw_response' => ( is => 'ro', isa => 'Object' );

has 'status_code' => ( is => 'rw', isa => 'Int' );

has 'status_message' => ( is => 'rw', isa => 'Int' );

sub make_response {
    my ( $self, $req, $http_res ) = @_;
    ( my $class = ref $req ) =~ s{Request}{Response};
    Class::MOP::load_class( $class );
    return $class->new( raw_response => $http_res );
}

sub BUILD {
    my ( $self, $args ) = @_;
    my $res = $args->{ raw_response };

    my $xpath = XML::XPath->new( xml => $res->content );
    my $status = $xpath->findvalue(
        '/response/lst[@name="responseHeader"]/int[@name="status"]' );
    $self->status_code( "$status" );
    $self->status_message( "$status" );
}

sub ok {
    return shift->status_code == 0;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
