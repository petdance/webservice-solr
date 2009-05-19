package WebService::Solr::Query;

use Moose;

use overload q("") => 'stringify';

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
        my @values = qq("$query{$key}");
        if( ref $query{$key} eq 'ARRAY' ) {
            @values = map { qq("$_") } @{ $query{$key} };
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
