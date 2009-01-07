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

our $VERSION = '0.03';

sub BUILDARGS {
    my ( $self, $url, $options ) = @_;
    $options ||= {};

    if ( $url ) {
        $options->{ url } = ref $url ? $url : URI->new( $url );
    }

    if( exists $options->{ default_params } ) {
        $options->{ default_params } = {
            %{ $options->{ default_params } },
            wt => 'json',
        }
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

    my $solr = WebService::Solr->new;
    $solr->add( @docs );
    $solr->commit;
    
    my $response = $solr->search( $query );
    for my $doc ( $response->docs ) {
        print $doc->value_for( $id );
    }

=head1 DESCRIPTION



=head1 ACCESSORS

=over 4

=item * url - the webservice base url

=item * agent - a user agent object

=item * autocommit - a boolean value for automatic commit() after add/update/delete

=item * default_params - a hashref of parameters to send on every request

=back

=head1 METHODS

=head2 new( $url, \%options )

Creates a new WebService::Solr instance. If C<$url> is omitted, then
C<http://localhost:8983/solr> is used as a default. Available options are
listed in the L<ACCESSORS|/"ACCESSORS"> section.

=head2 BUILDARGS( @args )

A Moose override to allow our custom constructor.

=head2 add( $doc|\@docs, \%options )

Adds a number of documents to the index. Returns true on success, false
otherwise. A document can be a L<WebService::Solr::Document> object or a
structure that can be passed to C<WebService::Solr::Document-E<gt>new>. Available
options as of Solr 1.3 are:

=over 4

=item * allowDups (default: false) - Allow duplicate entries

=back

=head2 update( $doc|\@docs, \%options )

Alias for C<add()>.

=head2 delete_by_id( $id )

Deletes all documents matching the id specified. Returns true on success,
false otherwise.

=head2 delete_by_query( $query )

Deletes documents matching C<$query>. Returns true on success, false
otherwise.

=head2 search( $query, \%options )

Searches the index given a C<$query>. Returns a L<WebService::Solr::Response>
object. All key-value pairs supplied in C<\%options> are serialzied in the
request URL.

=head2 commit( \%options )

Sends a commit command. Returns true on success, false otherwise. You must do
a commit after an add, update or delete. You can turn autocommit on to have
the library do it for you:

    my $solr = WebService::Solr->new( undef, { autocommit => 1 } );
    $solr->add( $doc ); # will not automatically call commit()

Options as of Solr 1.3 include:

=over 4

=item * maxSegments (default: 1)

=item * waitFlush (default: true)

=item * waitSearcher (default: true)

=back

=head2 optimize( \%options )

Sends an optimize command. Returns true on success, false otherwise.

Options as of Solr 1.3 are the same as C<commit()>.

=head2 ping( )

Sends a basic ping request. Returns true on success, false otherwise.

=head1 SEE ALSO

=over 4

=item * http://lucene.apache.org/solr/

=item * L<Solr> - an alternate library

=back

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers E<lt>kirk.beers@nald.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

