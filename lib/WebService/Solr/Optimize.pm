package WebService::Solr::Optimize;

use strict;
use warnings;

use XML::Generator;

sub new {
    my ( $class, $options ) = @_;
    
    my $self = { opts => $options };

    bless $self, $class;
    return $self;
}

sub to_xml {
    my $self     = shift;
    my $opts     = $self->{ opts };
    die 'Expected hash reference for WebService::Solr::Commit->to_xml'
        unless ref( $opts ) eq "HASH";
    
    my $gen = XML::Generator->new();   

    my $waitFlush    = $opts->{ 'waitFlush' };
    my $waitSearcher = $opts->{ 'waitSearcher' };
    my %attr = (
        waitFlush    => $waitFlush,
        waitSearcher => $waitSearcher,
    );
    my $func = $gen->optimize( \%attr );
    return "$func";

}

1;
