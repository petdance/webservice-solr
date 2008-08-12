package WebService::Solr::Optimize;

use strict;
use warnings;

use XML::Generator;

sub new {
    my ( $class, %options ) = @_;
    my $self = { opts => \%options };

    bless $self, $class;
    return $self;
}

sub to_xml {
    my $self     = shift;
    my $opts     = $self->{ opts };
    my %optshash = %$opts;
    my $gen      = XML::Generator->new( ':pretty' );
    my $waitFlush    = $optshash{ 'waitFlush' };
    my $waitSearcher = $optshash{ 'waitSearcher' };
    my %attr = (
        waitFlush    => $waitFlush,
        waitSearcher => $waitSearcher,
    );
    my $func = $gen->optimize( \%attr );
    return "$func";

}

1;
