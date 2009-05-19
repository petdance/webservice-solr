package WebService::Solr::Query;

use Moose;

use overload q("") => 'stringify';

my $escape_chars = quotemeta('+-&|!(){}[]^"~*?:\\');

has 'query' => ( is => 'ro', isa => 'HashRef', default => sub{ {} }, auto_deref => 1 );

sub BUILDARGS {
    my $class = shift;

    if ( @_ == 1 ) {
      return { query => $_[0] };
    }

    return $class->SUPER::BUILDARGS(@_);
}

sub stringify {
    my $self = shift;

    my $out = '';
    my %query = $self->query;

    for my $key ( sort keys %query ) {
        my @values = '"' . $self->escape($query{$key}) . '"';
        if( ref $query{$key} eq 'ARRAY' ) {
            @values = map { qq("$_") } map { $self->escape( $_ ) } @{ $query{$key} };
        }
        elsif( ref $query{$key} eq 'HASH' ) {
            my( $op, $params ) = %{ $query{$key} };
            $op =~ s{^-(.+)}{_op_$1};
            @values = ( $self->$op( $params ) );
        }

        $out .= join( ' ', map { qq($key:$_) } @values );
        $out .= ' ';
    }

    $out =~ s{\s+$}{};
    return $out;
}

sub _op_range {
    my $self = shift;
    my @vals = @{ shift() };
    return "[$vals[ 0 ] TO $vals[ 1 ]]";
}

*_op_range_inc = \&_op_range;

sub _op_range_exc {
    my $self = shift;
    my @vals = @{ shift() };
    return "{$vals[ 0 ] TO $vals[ 1 ]}";
}

sub _op_boost {
    my $self = shift;
    my( $val, $boost ) = @{ shift() };
    $val = $self->escape( $val );
    return qq("$val"^$boost);
}
 
sub _op_fuzzy {
    my $self = shift;
    my( $val, $distance ) = @{ shift() };
    $val = $self->escape( $val );
    return qq($val~$distance);
}
 
sub _op_proximity {
    my $self = shift;
    my( $val, $distance ) = @{ shift() };
    $val = $self->escape( $val );
    return qq("$val"~$distance);
}

sub escape {
    my( $self, $text ) = @_;
    $text =~ s{([$escape_chars])}{\\$1}g;
    return $text;
}
 
sub unescape {
    my( $self, $text ) = @_;
    $text =~ s{\\([$escape_chars])}{$1}g;
    return $text;
}
 
no Moose;

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

WebService::Solr::Query - Abstract query syntax for Solr queries

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
