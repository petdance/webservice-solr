package WebService::Solr::Delete;

use strict;
use warnings;

use XML::Generator;

sub new {
    my ( $class, $options ) = @_;
    if ( $options->{ 'id' } && $options->{ 'query' } ) {
        die "Must delete by id OR query, not both";
    }

    #    print "Here it is : ";
    my $self = { opts => $options };

    bless $self, $class;
    return $self;

}

sub delete_by_id {
    my $self = shift;
    my $opts = $self->{ opts };
    die "Expected hash reference for WebService::Solr::Delete->delete_by_id "
        unless ref( $opts ) eq "HASH";
    my $gen = XML::Generator->new();
    my $id  = '';
    if ( $opts->{ 'id' } || die "An id must be provided for deletion! " ) {
        $id = $opts->{ 'id' };
    }

    my $del = $gen->delete( $gen->id( $id ), );
    return "$del";
}

sub delete_by_query {
    my $self = shift;
    my $opts = $self->{ opts };

    #my %optshash = %$opts;
    my $gen   = XML::Generator->new( ':pretty' );
    my $query = '';

    if ( $opts->{ 'query' } || die "A query must be provided for deletion! " )
    {
        $query = $opts->{ 'query' };
    }
    my $del = $gen->delete( $gen->query( $query ), );
    return "$del";
}

1;

