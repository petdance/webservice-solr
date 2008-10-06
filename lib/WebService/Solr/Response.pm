package WebService::Solr::Response;

use Moose;
use WebService::Solr::Document;

use JSON::XS ();

has 'raw_response' => (
    is      => 'ro',
    isa     => 'Object',
    handles => [ qw( status_code status_message is_success is_error ) ]
);

has 'content' => ( is => 'rw', isa => 'HashRef', lazy_build => 1 );

has 'docs' =>
    ( is => 'rw', isa => 'ArrayRef', auto_deref => 1, lazy_build => 1 );

has 'pager' => ( is => 'rw', isa => 'Data::Page', lazy_build => 1 );

sub BUILDARGS {
    my ( $self, $res ) = @_;
    return { raw_response => $res };
}

sub _build_content {
    my $self = shift;
    my $content = $self->raw_response->content;
    return {} unless $content;
    return JSON::XS::decode_json( $content );
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
    my $total = $struct->{ response }->{ numFound };
    my $rows  = $struct->{ responseHeader }->{ params }->{ rows } || 10;
    my $start = $struct->{ response }->{ start };

    my $pager = Data::Page->new;
    $pager->total_entries( $total );
    $pager->entries_per_page( $rows );
    $pager->current_page( $start / ( $rows - 1 ) + 1 );
    return $pager;
}

sub solr_status {
    return shift->content->{ responseHeader }->{ status };
}

sub ok {
    my $status = shift->solr_status;
    return defined $status && $status == 0;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WebService::Solr::Response - Parse responses from Solr

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new( $response )

=head2 BUILDARGS( )

=head2 solr_status( )

=head2 ok( )

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers E<lt>kirk.beers@nald.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

