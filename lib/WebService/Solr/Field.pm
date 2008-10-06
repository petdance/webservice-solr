package WebService::Solr::Field;

use Moose;

has 'name' => ( is => 'rw', isa => 'Str' );

has 'value' => ( is => 'rw', isa => 'Str' );

has 'boost' => ( is => 'rw', isa => 'Maybe[Num]' );

require XML::Generator;

sub BUILDARGS {
    my ( $self, $name, $value, $opts ) = @_;
    $opts ||= {};

    return { name => $name, value => $value, %$opts };
}

sub to_xml {
    my $self = shift;
    my $gen  = XML::Generator->new( ':std' );
    my %attr = ( $self->boost ? ( boost => $self->boost ) : () );

    return $gen->field( { name => $self->name, %attr }, $self->value );
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WebService::Solr::Field - A field object

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new( $name => $value, \%options )

=head2 BUILDARGS( )

=head2 to_xml( )

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers E<lt>kirk.beers@nald.caE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

