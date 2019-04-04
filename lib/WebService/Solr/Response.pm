package WebService::Solr::Response;

use Moo;

use Types::Standard qw(Object HashRef Maybe InstanceOf ArrayRef);
use WebService::Solr::Document;
use Data::Page;
use Data::Pageset;
use JSON::XS ();

has 'raw_response' => (
    is      => 'ro',
    isa     => Object,
    handles => {
        status_code    => 'code',
        status_message => 'message',
        is_success     => 'is_success',
        is_error       => 'is_error'
    },
);

has 'content' =>
    ( is => 'lazy', isa => HashRef );

has 'docs' =>
    ( is => 'lazy', isa => ArrayRef );

around docs => sub {
    my ($orig, $self, @args) = @_;
    my $ret = $self->$orig(@args);
    return wantarray ? @$ret : $ret;
};

has 'pager' =>
    ( is => 'lazy', isa => Maybe[InstanceOf['Data::Page']] );

has '_pageset_slide' =>
    ( is => 'rw', isa => Maybe[InstanceOf['Data::Pageset']], predicate => 1 );

has '_pageset_fixed' =>
    ( is => 'rw', isa => Maybe[InstanceOf['Data::Pageset']], predicate => 1 );

has 'params' =>
    ( is => 'lazy', isa => HashRef );

sub BUILDARGS {
    my ( $self, $res ) = @_;
    return { raw_response => $res };
}

sub _build_content {
    my $self    = shift;
    my $content = $self->raw_response->content;
    return {} unless $content;
    my $rv = eval { JSON::XS::decode_json( $content ) };

    ### JSON::XS throw an exception, but kills most of the content
    ### in the diagnostic, making it hard to track down the problem
    die "Could not parse JSON response: $@ $content" if $@;

    return $rv;
}

sub _build_docs {
    my $self   = shift;
    my $struct = $self->content;

    return unless exists $struct->{ response }->{ docs };

    return [ map { WebService::Solr::Document->new( %$_ ) }
            @{ $struct->{ response }->{ docs } } ];
}

sub _build_pager {
    my $self   = shift;
    my $struct = $self->content;

    return unless exists $struct->{ response }->{ numFound };

    my $rows = $struct->{ responseHeader }->{ params }->{ rows };
    $rows = 10 unless defined $rows;

    # do not generate a pager for queries explicitly requesting no rows
    return if $rows == 0;

    my $pager = Data::Page->new;
    $pager->total_entries( $struct->{ response }->{ numFound } );
    $pager->entries_per_page( $rows );
    $pager->current_page( $struct->{ response }->{ start } / $rows + 1 );
    return $pager;
}

sub pageset {
    my $self = shift;
    my %args = @_;

    my $mode = $args{ 'mode' } || 'fixed';
    my $meth = "_pageset_" . $mode;
    my $pred = "_has" . $meth;

    ### use a cached version if possible
    return $self->$meth if $self->$pred;

    my $pager = $self->_build_pageset( @_ );

    ### store the result
    return $self->$meth( $pager );
}

sub _build_pageset {
    my $self   = shift;
    my $struct = $self->content;

    return unless exists $struct->{ response }->{ numFound };

    my $rows = $struct->{ responseHeader }->{ params }->{ rows };
    $rows = 10 unless defined $rows;

    # do not generate a pager for queries explicitly requesting no rows
    return if $rows == 0;

    my $pager = Data::Pageset->new(
        {   total_entries    => $struct->{ response }->{ numFound },
            entries_per_page => $rows,
            current_page     => $struct->{ response }->{ start } / $rows + 1,
            pages_per_set    => 10,
            mode => 'fixed',    # default, or 'slide'
            @_,
        }
    );

    return $pager;
}

sub _build_params {
    return shift->content->{ responseHeader }->{ params };
}

sub grouped_docs {
    my $self = shift;

    return [] unless $self->is_grouped;

    my $params = $self->params;

    # Solr documentation says it uses the first group.field for
    # group.facet when multiple values are given so let's get that one
    my $group_field = shift || (
        ref $params->{ 'group.field' } eq 'Array'
        ? $params->{ 'group.field' }->[0]
        : $params->{ 'group.field' }
    );

    # Solr has three result formats for 'group=true' results depending
    # on other group parameters passed:
    # group.format  group.main  response format
    # ------------  ----------  ---------------
    # simple        false       content->{grouped}->{<group.field>}->{doclist}->{docs}->[]
    # grouped       false       content->{grouped}->{<group.field>}->{groups}->[ {doclist}->{docs}->[] ]
    #    *          true        content->{response}->{docs}->[]

    my $group_main = $params->{ 'group.main' } // 'false';
    my $group_format = $group_main eq 'true'
        ? 'simple'
        : $params->{ 'group.format' } // 'grouped';

    my $docs = [];
    if ( $group_main eq 'true' ) {
        $docs = $self->content->{ response }->{ docs };
    }
    else {
        my $struct = $self->groups($group_field);
        if ( $group_format eq 'simple' ) {
            $docs = $struct->{ doclist }->{ docs };
        }
        else {
            foreach my $group (@{$struct->{ groups }}) {
                map { push @$docs, $_ } @{ $group->{ doclist }->{ docs } };
            }
        }
    }

    my $ret = [ map { WebService::Solr::Document->new( %$_ ) } @$docs ];
    return wantarray ? @$ret : $ret;
}

sub groups {
    return defined $_[1]
        ? $_[0]->content->{ grouped }{ $_[1] }
        : $_[0]->content->{ grouped };
}

sub is_grouped {
    return (shift->params->{ 'group' } || '') eq 'true';
}

sub facet_counts {
    return shift->content->{ facet_counts };
}

sub spellcheck {
    return shift->content->{ spellcheck };
}

sub solr_status {
    return shift->content->{ responseHeader }->{ status };
}

sub ok {
    my $status = shift->solr_status;
    return defined $status && $status == 0;
}

no Moo;

1;

__END__

=head1 NAME

WebService::Solr::Response - Parse responses from Solr

=head1 SYNOPSIS

    my $res = WebService::Solr::Response->new( $http_res );
    for my $doc( $res->docs ) {
        print $doc->value_for( 'id'), "\n";
    }
    my $pager = $res->pager;

=head1 DESCRIPTION

This class encapsulates responses from the Solr Web Service. Typically it is
used when documents are returned from a search query, though it will accept
all responses from the service.

=head1 ACCESSORS

=over 4

=item * raw_response - the raw L<HTTP::Response> object.

=item * content - a hashref of deserialized JSON data from the response.

=item * docs - an array of L<WebService::Solr::Document> objects.

=item * params - a hashref of explict parameters passed to the Solr request.

=item * pager - a L<Data::Page> object for the search results.

=item * pageset - a L<Data::Pageset> object for the search results. Takes the same arguments as C<< Data::Pageset->new >> does. All arguments optional.

=back

=head1 METHODS

=head2 new( $response )

Given an L<HTTP::Response> object, it will parse the returned data as
required.

=head2 BUILDARGS( @args )

A Moo override to allow our custom constructor.

=head2 facet_counts( )

A shortcut to the C<facet_counts> key in the response data.

=head2 is_grouped( )

Check if request parameter C<group> was set to true.

=head2 grouped_docs( [I<group_field>] )

The Solr results structure can differ greatly when using Result Grouping in search. Returns an array of L<WebService::Solr::Document> objects if grouped results were requested.  Documents are from the I<group_field> value. Otherwise, the first passed group.field Solr parameter value will be used.  The complete structure can always be retrieved via L<content> accessor.

=head2 groups( [I<group_field>] )

If Solr Result Grouping is used, data from the response is returned of the I<group_field> value in groups or all groups are returned.

=head2 spellcheck( )

A shortcut to the C<spellcheck> key in the response data.

=head2 solr_status( )

Looks for the status value in the response data.

=head2 ok( )

Calls C<solr_status()> and check that it is equal to 0.

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2017 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

