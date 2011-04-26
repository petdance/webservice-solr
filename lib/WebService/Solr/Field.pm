package WebService::Solr::Field;

use Moose;

has 'name' => ( is => 'rw', isa => 'Str' );

has 'value' => ( is => 'rw', isa => 'Str' );

has 'boost' => ( is => 'rw', isa => 'Maybe[Num]' );

use XML::Easy::Element;
use XML::Easy::Content;
use XML::Easy::Text qw(xml10_write_element);

sub BUILDARGS {
    my ( $self, $name, $value, $opts ) = @_;
    $opts ||= {};

    return { name => $name, value => $value, %$opts };
}

sub to_element {
    my $self = shift;
    my %attr = ( $self->boost ? ( boost => $self->boost ) : () );

    return XML::Easy::Element->new(
        'field',
        { name => $self->name, %attr },
        XML::Easy::Content->new( [ $self->value ] ),
    );
}

sub to_xml {
    my $self = shift;

    return xml10_write_element($self->to_element);
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WebService::Solr::Field - A field object

=head1 SYNOPSIS

    my $field = WebService::Solr::Field->new( foo => 'bar' );

=head1 DESCRIPTION

This class represents a field from a document, which is basically a
name-value pair.

=head1 ACCESSORS

=over 4

=item * name - the field's name

=item * value - the field's value

=item * boost - a floating-point boost value

=back

=head1 METHODS

=head2 new( $name => $value, \%options )

Creates a new field object. Currently, the only option available is a
"boost" value.

=head2 BUILDARGS( @args )

A Moose override to allow our custom constructor.

=head2 to_element( )

Serializes the object to an XML::Easy::Element object.

=head2 to_xml( )

Serializes the object to xml.

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2011 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

