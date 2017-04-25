package WebService::Solr;

use Moo;

use Types::Standard qw(InstanceOf Object Bool HashRef Maybe);
use Scalar::Util qw(blessed);
use Encode qw(encode);
use URI;
use LWP::UserAgent;
use WebService::Solr::Response;
use HTTP::Request;
use HTTP::Headers;
use XML::Easy::Element;
use XML::Easy::Content;
use XML::Easy::Text ();
use Carp qw(confess);

has 'url' => (
    is      => 'ro',
    isa     => InstanceOf['URI'],
    default => sub { URI->new( 'http://localhost:8983/solr' ) }
);

has 'agent' =>
    ( is => 'ro', isa => Object, default => sub { LWP::UserAgent->new } );

has 'autocommit' => ( is => 'ro', isa => Bool, default => 1 );

has 'default_params' => (
    is         => 'ro',
    isa        => HashRef,
    default    => sub { { wt => 'json' } }
);

around default_params => sub {
    my ($orig, $self, @args) = @_;
    my $ret = $self->$orig(@args);
    return wantarray ? %$ret : $ret;
};

has 'last_response' => (
    is  => 'rw',
    isa => Maybe[InstanceOf['WebService::Solr::Response']],
);

our $VERSION = '0.42';

sub BUILDARGS {
    my ( $self, $url, $options ) = @_;
    $options ||= {};

    if ( $url ) {
        $options->{ url } = ref $url ? $url : URI->new( $url );
    }

    if ( exists $options->{ default_params } ) {
        $options->{ default_params }
            = { %{ $options->{ default_params } }, wt => 'json', };
    }

    return $options;
}

sub add {
    my ( $self, $doc, $params ) = @_;
    my @docs = ref $doc eq 'ARRAY' ? @$doc : ( $doc );

    my @elements = map {
        (   '',
            blessed $_
            ? $_->to_element
            : WebService::Solr::Document->new(
                ref $_ eq 'HASH' ? %$_ : @$_
                )->to_element
            )
    } @docs;

    $params ||= {};
    my $e
        = XML::Easy::Element->new( 'add', $params,
        XML::Easy::Content->new( [ @elements, '' ] ),
        );
    my $xml = XML::Easy::Text::xml10_write_element( $e );

    my $response = $self->_send_update( $xml );
    return $response->ok;
}

sub update {
    return shift->add( @_ );
}

sub commit {
    my ( $self, $params ) = @_;
    $params ||= {};
    my $e        = XML::Easy::Element->new( 'commit', $params, [ '' ] );
    my $xml      = XML::Easy::Text::xml10_write_element( $e );
    my $response = $self->_send_update( $xml, {}, 0 );
    return $response->ok;
}

sub rollback {
    my ( $self ) = @_;
    my $response = $self->_send_update( '<rollback/>', {}, 0 );
    return $response->ok;
}

sub optimize {
    my ( $self, $params ) = @_;
    $params ||= {};
    my $e        = XML::Easy::Element->new( 'optimize', $params, [ '' ] );
    my $xml      = XML::Easy::Text::xml10_write_element( $e );
    my $response = $self->_send_update( $xml, {}, 0 );
    return $response->ok;
}

sub delete {
    my ( $self, $options ) = @_;

    my $xml = '';
    for my $k ( keys %$options ) {
        my $v = $options->{ $k };
        $xml .= join(
            '',
            map {
                XML::Easy::Text::xml10_write_element(
                    XML::Easy::Element->new( $k, {}, [ $_ ] ) )
                } ref $v ? @$v : $v
        );
    }

    my $response = $self->_send_update( "<delete>${xml}</delete>" );
    return $response->ok;
}

sub delete_by_id {
    my ( $self, $id ) = @_;
    return $self->delete( { id => $id } );
}

sub delete_by_query {
    my ( $self, $query ) = @_;
    return $self->delete( { query => $query } );
}

sub ping {
    my ( $self ) = @_;
    $self->last_response( WebService::Solr::Response->new(
        $self->agent->get( $self->_gen_url( 'admin/ping' ) ) ) );
    return $self->last_response->is_success;
}

sub search {
    my ( $self, $query, $params ) = @_;
    $params ||= {};
    $params->{ 'q' } = $query;
    return $self->generic_solr_request( 'select', $params );
}

sub auto_suggest {
    shift->generic_solr_request( 'autoSuggest', @_ );
}

sub generic_solr_request {
    my ( $self, $path, $params ) = @_;
    $params ||= {};
    return $self->last_response(
        WebService::Solr::Response->new(
            $self->agent->post(
                $self->_gen_url( $path ),
                Content_Type => 'application/x-www-form-urlencoded; charset=utf-8',
                Content => { $self->default_params, %$params } ) ) );
}

sub _gen_url {
    my ( $self, $handler ) = @_;

    my $url = $self->url->clone;
    $url->path( $url->path . "/$handler" );
    return $url;
}

sub _send_update {
    my ( $self, $xml, $params, $autocommit ) = @_;
    $autocommit = $self->autocommit unless defined $autocommit;

    $params ||= {};
    my $url = $self->_gen_url( 'update' );
    $url->query_form( { $self->default_params, %$params } );
    my $req = HTTP::Request->new(
        POST => $url,
        HTTP::Headers->new( Content_Type => 'text/xml; charset=utf-8' ),
        '<?xml version="1.0" encoding="UTF-8"?>' . encode( 'utf8', "$xml" )
    );

    my $http_response = $self->agent->request( $req );
    if ( $http_response->is_error ) {
        confess($http_response->status_line . ': ' . $http_response->content);
    }

    $self->last_response( WebService::Solr::Response->new( $http_response ) );

    $self->commit if $autocommit;

    return $self->last_response;
}

no Moo;

1;

__END__

=head1 NAME

WebService::Solr - Module to interface with the Solr (Lucene) webservice

=head1 SYNOPSIS

    my $solr = WebService::Solr->new;
    $solr->add( @docs );

    my $response = $solr->search( $query );
    for my $doc ( $response->docs ) {
        print $doc->value_for( $id );
    }

=head1 DESCRIPTION

WebService::Solr is a client library for Apache Lucene's Solr; an
enterprise-grade indexing and searching platform.

=head1 ACCESSORS

=over 4

=item * url - the webservice base url

=item * agent - a user agent object

=item * autocommit - a boolean value for automatic commit() after add/update/delete (default: enabled)

=item * default_params - a hashref of parameters to send on every request

=item * last_response - stores a WebService::Solr::Response for the last request

=back

=head1 HTTP KEEP-ALIVE

Enabling HTTP Keep-Alive is as simple as passing your custom user-agent to the
constructor.

    my $solr = WebService::Solr->new( $url,
        { agent => LWP::UserAgent->new( keep_alive => 1 ) }
    );

Visit L<LWP::UserAgent>'s documentation for more information and available
options.

=head1 METHODS

=head2 new( $url, \%options )

Creates a new WebService::Solr instance. If C<$url> is omitted, then
C<http://localhost:8983/solr> is used as a default. Available options are
listed in the L<ACCESSORS|/"ACCESSORS"> section.

=head2 BUILDARGS( @args )

A Moo override to allow our custom constructor.

=head2 add( $doc|\@docs, \%options )

Adds a number of documents to the index. Returns true on success, false
otherwise. A document can be a L<WebService::Solr::Document> object or a
structure that can be passed to C<WebService::Solr::Document-E<gt>new>. Available
options as of Solr 1.4 are:

=over 4

=item * overwrite (default: true) - Replace previously added documents with the same uniqueKey

=item * commitWithin (in milliseconds) - The document will be added within the specified time

=back

=head2 update( $doc|\@docs, \%options )

Alias for C<add()>.

=head2 delete( \%options )

Deletes documents matching the options provided. The delete operation currently
accepts C<query> and C<id> parameters. Multiple values can be specified as
array references.

    # delete documents matching "title:bar" or uniqueId 13 or 42
    $solr->delete( {
        query => 'title:bar',
        id    => [ 13, 42 ],
    } );

=head2 delete_by_id( $id )

Deletes all documents matching the id specified. Returns true on success,
false otherwise.

=head2 delete_by_query( $query )

Deletes documents matching C<$query>. Returns true on success, false
otherwise.

=head2 search( $query, \%options )

Searches the index given a C<$query>. Returns a L<WebService::Solr::Response>
object. All key-value pairs supplied in C<\%options> are serialized in the
request URL.

If filter queries are needed, create WebService::Solr::Query objects
and pass them into the C<%options>.  For example, if you were searching
a database of books for a subject of "Perl", but wanted only paperbacks
and a copyright year of 2011 or 2012:

    my $query = WebService::Solr::Query->new( { subject => 'Perl' } );
    my %options = (
        fq => [
            WebService::Solr::Query->new( { binding => 'Paperback' } ),
            WebService::Solr::Query->new( { year => [ 2011, 2012 ] } ),
        ],
    );

    my $response = $solr->search( $query, \%options );

The filter queries are typically added when drilling down into search
results and selecting a facet to drill into.

In order to enable facets, the option C<facet =E<gt> "on"> must be passed.
Facet options are detailed in the wiki (https://wiki.apache.org/solr/SimpleFacetParameters).

=head2 auto_suggest( \%options )

Get suggestions from a list of terms for a given field. The Solr wiki has
more details about the available options (http://wiki.apache.org/solr/TermsComponent)

=head2 commit( \%options )

Sends a commit command. Returns true on success, false otherwise. You must do
a commit after an add, update or delete. By default, autocommit is enabled. 
You may disable autocommit to allow you to issue commit commands manually:

    my $solr = WebService::Solr->new( undef, { autocommit => 0 } );
    $solr->add( $doc ); # will not automatically call commit()
    $solr->commit;

Options as of Solr 1.4 include:

=over 4

=item * maxSegments (default: 1) - Optimizes down to at most this number of segments

=item * waitFlush (default: true) - Block until index changes are flushed to disk

=item * waitSearcher (default: true) - Block until a new searcher is opened

=item * expungeDeletes (default: false) - Merge segments with deletes away

=back

=head2 rollback( )

This method will rollback any additions/deletions since the last commit.

=head2 optimize( \%options )

Sends an optimize command. Returns true on success, false otherwise.

Options as of Solr 1.4 are the same as C<commit()>.

=head2 ping( )

Sends a basic ping request. Returns true on success, false otherwise.

=head2 generic_solr_request( $path, \%query )

Performs a simple C<GET> request appending C<$path> to the base URL
and using key-value pairs from C<\%query> to generate the query string. This
should allow you to access parts of the Solr API that don't yet have their
own correspondingly named function (e.g. C<dataimport> ).

=head1 SEE ALSO

=over 4

=item * http://lucene.apache.org/solr/

=item * L<Solr> - an alternate library

=back

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2017 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
