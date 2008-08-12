package WebService::Solr::Optimize;

use strict;
use warnings;

use XML::Generator;
use Tie::IxHash;

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
    tie my %attr, 'Tie::IxHash';
    my $waitFlush    = $optshash{ 'waitFlush' };
    my $waitSearcher = $optshash{ 'waitSearcher' };
    %attr = (
        waitFlush    => $waitFlush,
        waitSearcher => $waitSearcher,
    );
    my $func = $gen->optimize( \%attr );
    return "$func";

}

1;
