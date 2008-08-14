use strict;
use warnings;
use Test::More tests => 8;
use XML::Simple;

BEGIN {
    use_ok( 'WebService::Solr::Commit' );
}

my @tests = (
    { waitFlush => 'true',  waitSearcher => 'true' },
    { waitFlush => 'true',  waitSearcher => 'false' },
    { waitFlush => 'false', waitSearcher => 'true' },
    { waitFlush => 'false', waitSearcher => 'false' },
    { waitFlush => '',      waitSearcher => 'false' },
    { waitFlush => 'false', waitSearcher => '' },
    { waitFlush => '',      waitSearcher => '' },
);

{
    cmp_xml( $_ ) for @tests;
}

sub cmp_xml {
    my ( $opts ) = @_;
    my $obj = WebService::Solr::Commit->new( $opts );
    my $got = XMLin( $obj->to_xml, KeepRoot => 1 );

    is_deeply( $got, { commit => $opts } );
}
