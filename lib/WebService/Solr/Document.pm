package WebService::Solr::Document;

use Moose;

use WebService::Solr::Field;
require XML::Generator;

has 'fields' => (
    is         => 'rw',
    isa        => 'ArrayRef[Object]',
    default    => sub { [] },
    auto_deref => 1
);

has 'boost' => ( is => 'rw', isa => 'Maybe[Num]' );

sub BUILDARGS {
    my ( $class, @fields ) = @_;

    return { fields => [ _parse_fields( @fields ) ] };
}

sub add_fields {
    my ( $self, @fields ) = @_;
    $self->fields( [ $self->fields, _parse_fields( @fields ) ] );
}

sub _parse_fields {
    my @fields = @_;
    my @new_fields;

    # handle field objects, array refs and normal k => v pairs
    while ( my $f = shift @fields ) {
        if ( blessed $f ) {
            push @new_fields, $f;
            next;
        }
        elsif ( ref $f ) {
            push @new_fields, WebService::Solr::Field->new( @$f );
            next;
        }

        my $v = shift @fields;
        my @values = ( ref $v and !blessed $v )? @$v : ( "$v" );
        push @new_fields, map { WebService::Solr::Field->new( $f => $_ ) } @values;
    }

    return @new_fields;
}

sub values_for {
    my ( $self, $key ) = @_;
    return map { $_->value } grep { $_->name eq $key } $self->fields;
}

sub to_xml {
    my $self = shift;
    my $gen  = XML::Generator->new( ':std' );
    my %attr = ( $self->boost ? ( boost => $self->boost ) : () );

    return $gen->doc( \%attr, map { $_->to_xml } $self->fields );
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WebService::Solr::Document - A document object

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new( @fields|\@fields )

=head2 BUILDARGS( )

=head2 add_fields( @fields|\@fields )

=head2 values_for( $name )

=head2 to_xml( )

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers E<lt>kirk.beers@nald.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

