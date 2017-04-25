package WebService::Solr::Document;

use WebService::Solr::Field;
use XML::Easy::Element;
use XML::Easy::Content;
use XML::Easy::Text ();
use Scalar::Util 'blessed';

sub new {
    my ( $class, @fields ) = @_;

    my $self = {
        fields => [ _parse_fields( @fields ) ]
    };

    return bless $self, $class;
}

sub boost {
    my $self = shift;
    $self->{ boost } = $_[ 0 ] if @_;
    return $self->{ boost };
}

sub fields {
    my $self = shift;
    $self->{ fields } = $_[ 0 ] if @_;
    return wantarray ? @{ $self->{ fields } } : $self->{ fields };
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
        my @values = ( ref $v and !blessed $v ) ? @$v : $v;
        push @new_fields,
            map { WebService::Solr::Field->new( $f => "$_" ) } @values;
    }

    return @new_fields;
}

sub field_names {
    my ( $self ) = @_;
    my %names = map { $_->name => 1 } $self->fields;
    return keys %names;
}

sub value_for {
    my ( $self, $key ) = @_;

    for my $field ( $self->fields ) {
        if ( $field->name eq $key ) {
            return $field->value;
        }
    }

    return;
}

sub values_for {
    my ( $self, $key ) = @_;
    return map { $_->value } grep { $_->name eq $key } $self->fields;
}

sub to_element {
    my $self = shift;
    my %attr = ( $self->boost ? ( boost => $self->boost ) : () );

    my @elements = map { ( '' => $_->to_element ) } $self->fields;

    return XML::Easy::Element->new( 'doc', \%attr,
        XML::Easy::Content->new( [ @elements, '' ] ),
    );
}

sub to_xml {
    my $self = shift;

    return XML::Easy::Text::xml10_write_element( $self->to_element );
}

1;

__END__

=head1 NAME

WebService::Solr::Document - A document object

=head1 SYNOPSIS

    my $doc = WebService::Solr::Document->new;
    $doc->add_fields( @fields );
    $doc->boost( 2.0 );
    my $id = $doc->value_for( 'id' );
    my @subjects = $doc->values_for( 'subject' );

=head1 DESCRIPTION

This class represents a basic document object, which is basically
a collection of fields. 

=head1 ACCESSORS

=over 4

=item * fields - an array of fields

=item * boost - a floating-point "boost" value

=back

=head1 METHODS

=head2 new( @fields|\@fields )

Constructs a new document object given C<@fields>. A field can be a
L<WebService::Solr::Field> object, or a structure accepted by
C<WebService::Solr::Field-E<gt>new>.

=head2 BUILDARGS( @args )

A Moose override to allow our custom constructor.

=head2 add_fields( @fields|\@fields )

Adds C<@fields> to the document.

=head2 field_names

Returns a list of field names that are in this document.

=head2 value_for( $name )

Returns the first value for C<$name>.

=head2 values_for( $name )

Returns all values for C<$name>.

=head2 to_element( )

Serializes the object to an XML::Easy::Element object.

=head2 to_xml( )

Serializes the object to xml.

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

Kirk Beers

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2017 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

