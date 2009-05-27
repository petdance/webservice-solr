package WebService::Solr::Query;

use Moose;

use overload q("") => 'stringify';

my $escape_chars = quotemeta( '+-&|!(){}[]^"~*?:\\' );

has 'query' => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

sub BUILDARGS {
    my $class = shift;

    if ( @_ == 1 && ref $_[ 0 ] && ref $_[ 0 ] eq 'ARRAY' ) {
        return { query => $_[ 0 ] };
    }

    return { query => \@_ };
}

sub stringify {
    my $self = shift;

    return $self->_dispatch_struct( $self->query );
}

sub _dispatch_struct {
    my ( $self, $struct ) = @_;

    my $method = '_struct_' . ref $struct;

    return $self->$method( $struct );
}

sub _struct_HASH {
    my ( $self, $struct ) = @_;

    my @clauses;

    for my $k ( keys %$struct ) {
        my $v = $struct->{ $k };

        if ( $k =~ m{^-(.+)} ) {
            my $method = "_op_$1";
            push @clauses, $self->$method( $v );
        }
        else {
            push @clauses, $self->_dispatch_value( $k, $v );
        }
    }

    return join( ' AND ', @clauses );
}

sub _struct_ARRAY {
    my ( $self, $struct ) = @_;
    return
          '('
        . join( ' OR ', map { $self->_dispatch_struct( $_ ) } @$struct )
        . ')';
}

sub _dispatch_value {
    my ( $self, $k, $v ) = @_;

    my $method = '_value_' . ( ref $v || 'SCALAR' );
    return $self->$method( $k, $v );
}

sub _value_SCALAR {
    my ( $self, $k, $v ) = @_;
    $v = $self->escape( $v );
    my $r = qq($k:"$v");
    $r =~ s{^:}{};
    return $r;
}

sub _value_HASH {
    my ( $self, $k, $v ) = @_;

    my @clauses;

    for my $op ( keys %$v ) {
        my $struct = $v->{ $op };
        $op =~ s{^-(.+)}{_op_$1};
        push @clauses, $self->$op( $k, $struct );
    }

    return join( ' AND ', @clauses );
}

sub _value_ARRAY {
    my ( $self, $k, $v ) = @_;

    return
        '('
        . join( ' OR ', map { $self->_value_SCALAR( $k, $_ ) } @$v ) . ')';
}

sub _op_default {
    my ( $self, $v ) = @_;
    return $self->_dispatch_value( '', $v );
}

sub _op_range {
    my ( $self, $k ) = ( shift, shift );
    my @v = @{ shift() };
    return "$k:[$v[ 0 ] TO $v[ 1 ]]";
}

*_op_range_inc = \&_op_range;

sub _op_range_exc {
    my ( $self, $k ) = ( shift, shift );
    my @v = @{ shift() };
    return "$k:{$v[ 0 ] TO $v[ 1 ]}";
}

sub _op_boost {
    my ( $self, $k ) = ( shift, shift );
    my ( $v, $boost ) = @{ shift() };
    $v = $self->escape( $v );
    return qq($k:"$v"^$boost);
}

sub _op_fuzzy {
    my ( $self, $k ) = ( shift, shift );
    my ( $v, $distance ) = @{ shift() };
    $v = $self->escape( $v );
    return qq($k:$v~$distance);
}

sub _op_proximity {
    my ( $self, $k ) = ( shift, shift );
    my ( $v, $distance ) = @{ shift() };
    $v = $self->escape( $v );
    return qq($k:"$v"~$distance);
}

sub _op_require {
    my ( $self, $k, $v ) = @_;
    $v = $self->escape( $v );
    return qq(+$k:"$v");
}

sub _op_prohibit {
    my ( $self, $k, $v ) = @_;
    $v = $self->escape( $v );
    return qq(-$k:"$v");
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
