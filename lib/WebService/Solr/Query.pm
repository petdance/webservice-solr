package WebService::Solr::Query;

use Moose;

use overload q("") => 'stringify';

my $escape_chars = quotemeta( '+-&|!(){}[]^"~*?:\\' );

has 'query' =>
    ( is => 'ro', isa => 'HashRef', default => sub { {} }, auto_deref => 1 );

sub BUILDARGS {
    my $class = shift;

    if ( @_ == 1 ) {
        return { query => $_[ 0 ] };
    }

    return $class->SUPER::BUILDARGS( @_ );
}

sub stringify {
    my $self = shift;

    my $out   = '';
    my %query = $self->query;

    for my $key ( sort keys %query ) {
        my $field = $key eq '-default' ? '' : $key;
        my @values = '"' . $self->escape( $query{ $key } ) . '"';
        if ( ref $query{ $key } eq 'ARRAY' ) {
            @values = map { qq("$_") }
                map { $self->escape( $_ ) } @{ $query{ $key } };
        }
        elsif ( ref $query{ $key } eq 'HASH' ) {
            my ( $op, $params ) = %{ $query{ $key } };
            $op =~ s{^-(.+)}{_op_$1};
            ( $field, @values ) = ( $self->$op( $field, $params ) );
        }

        $field .= ':' unless $key eq '-default';
        $out .= join( ' ', map { qq($field$_) } @values );
        $out .= ' ';
    }

    $out =~ s{\s+$}{};
    return $out;
}

sub _op_range {
    my ( $self, $key ) = ( shift, shift );
    my @vals = @{ shift() };
    return $key, "[$vals[ 0 ] TO $vals[ 1 ]]";
}

*_op_range_inc = \&_op_range;

sub _op_range_exc {
    my ( $self, $key ) = ( shift, shift );
    my @vals = @{ shift() };
    return $key, "{$vals[ 0 ] TO $vals[ 1 ]}";
}

sub _op_boost {
    my ( $self, $key ) = ( shift, shift );
    my ( $val, $boost ) = @{ shift() };
    $val = $self->escape( $val );
    return $key, qq("$val"^$boost);
}

sub _op_fuzzy {
    my ( $self, $key ) = ( shift, shift );
    my ( $val, $distance ) = @{ shift() };
    $val = $self->escape( $val );
    return $key, qq($val~$distance);
}

sub _op_proximity {
    my ( $self, $key ) = ( shift, shift );
    my ( $val, $distance ) = @{ shift() };
    $val = $self->escape( $val );
    return $key, qq("$val"~$distance);
}

sub _op_require {
    my ( $self, $key, $value ) = @_;
    return "+$key", '"' . $self->escape( $value ) . '"';
}

sub _op_prohibit {
    my ( $self, $key, $value ) = @_;
    return "-$key", '"' . $self->escape( $value ) . '"';
}

sub escape {
    my ( $self, $text ) = @_;
    $text =~ s{([$escape_chars])}{\\$1}g;
    return $text;
}

sub unescape {
    my ( $self, $text ) = @_;
    $text =~ s{\\([$escape_chars])}{$1}g;
    return $text;
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WebService::Solr::Query - Abstract query syntax for Solr queries

=head1 ACCESSORS

=over 4

=item * query - stores the original query structure

=back

=head1 METHODS

=head1 new( \%query )

Creates a new query object with the given hashref.

=head1 stringify( )

Converts the supplied structure into a Solr/Lucene query.

=head1 escape( $value )

The following values must be escaped in a search value:

    + - & | ! ( ) { } [ ] ^ " ~ * ? : \

=head1 unescape( $value )

Unescapes values escaped in C<escape()>.

=head1 SEE ALSO

=over 4

=item * L<WebService::Solr>

=back

=head1 AUTHORS

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008-2009 National Adult Literacy Database

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
