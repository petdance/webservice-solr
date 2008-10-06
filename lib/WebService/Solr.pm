package WebService::Solr;

use Moose;

use URI;
use LWP::UserAgent;
use WebService::Solr::Response;
use HTTP::Request;
use XML::Generator;

has 'url' => (
    is      => 'ro',
    isa     => 'URI',
    default => sub { URI->new( 'http://localhost:8983/solr' ) }
);

has 'agent' =>
    ( is => 'ro', isa => 'Object', default => sub { LWP::UserAgent->new } );

has 'autocommit' => ( is => 'ro', isa => 'Bool', default => 1 );

has 'default_params' => (
    is         => 'ro',
    isa        => 'HashRef',
    auto_deref => 1,
    default    => sub { { wt => 'json' } }
);

our $VERSION = '0.01';

sub BUILDARGS {
    my ( $self, $url, $options ) = @_;
    $options ||= {};

    if ( $url ) {
        $options->{ url } = ref $url ? $url : URI->new( $url );
    }

    return $options;
}

sub add {
    my ( $self, $doc, $params ) = @_;
    my @docs = ref $doc eq 'ARRAY' ? @$doc : ( $doc );

    $params ||= {};
    my $gen = XML::Generator->new( ':std' );

    my $xml = $gen->add(
        $params,
        map {
            if ( blessed $_ ) { $_->to_xml }
            else {
                WebService::Solr::Document->new(
                    ref $_ eq 'HASH' ? %$_ : @$_ )->to_xml;
            }
            } @docs
    );

    my $response = $self->_send_update( $xml );
    return $response->ok;
}

sub update {
    return shift->add( @_ );
}

sub commit {
    my ( $self, $params ) = @_;
    $params ||= {};
    my $gen = XML::Generator->new( ':std' );
    my $response = $self->_send_update( $gen->commit( $params ), {}, 0 );
    return $response->ok;
}

sub optimize {
    my ( $self, $params ) = @_;
    $params ||= {};
    my $gen = XML::Generator->new( ':std' );
    my $response = $self->_send_update( $gen->optimize( $params ), {}, 0 );
    return $response->ok;
}

sub delete_by_id {
    my ( $self, $id ) = @_;
    my $response = $self->_send_update( "<delete><id>$id</id></delete>" );
    return $response->ok;
}

sub delete_by_query {
    my ( $self, $query ) = @_;
    my $response
        = $self->_send_update( "<delete><query>$query</query></delete>" );
    return $response->ok;
}

sub ping {
    my ( $self ) = @_;
    my $response = WebService::Solr::Response->new(
        $self->agent->get( $self->_gen_url( 'admin/ping' ) ) );
    return
        exists $response->content->{ status }
        && $response->content->{ status } eq 'OK';
}

sub search {
    my ( $self, $query, $params ) = @_;
    $params ||= {};
    $params->{ 'q' } = $query;
    my $response = WebService::Solr::Response->new(
        $self->agent->get( $self->_gen_url( 'select', $params ) ) );
    return $response;
}

sub _gen_url {
    my ( $self, $handler, $params ) = @_;
    $params ||= {};

    my $url = $self->url->clone;
    $url->path( $url->path . "/$handler" );
    $url->query_form( { $self->default_params, %$params } );
    return $url;
}

sub _send_update {
    my ( $self, $xml, $params, $autocommit ) = @_;
    $autocommit = $self->autocommit unless defined $autocommit;

    my $url = $self->_gen_url( 'update', $params );
    my $req = HTTP::Request->new(
        POST => $url,
        [ Content_Type => 'text/xml; charset=utf-8' ],
        '<?xml version="1.0" encoding="UTF-8"?>' . $xml
    );

    my $res
        = WebService::Solr::Response->new( $self->agent->request( $req ) );

    $self->commit if $autocommit;

    return $res;
}

1;

__END__

=head1 NAME

WebService::Solr - Module to interface with the Solr (Lucene) webservice

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new( $url, \%options )

=head2 BUILDARGS( )

=head2 add( $doc|\@docs, \%options )

=head2 update( $doc|\@docs, \%options )

=head2 delete_by_id( $id )

=head2 delete_by_query( $query )

=head2 search( $query, \%options )

=head2 commit( \%options )

=head2 optimize( \%options )

=head2 ping( )

=head1 SEE ALSO

=over 4

=item * http://lucene.apache.org/solr/

=back

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers E<lt>kirk.beers@nald.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

