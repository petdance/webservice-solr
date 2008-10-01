use strict;
use warnings;

use Test::More tests => 11;

BEGIN {
    use_ok( 'WebService::Solr::Request::Commit' );
}

{
    my $r = WebService::Solr::Request::Commit->new;
    isa_ok( $r, 'WebService::Solr::Request::Commit' );
    is( $r->to_xml,
        make_xml( waitFlush => 1, waitSearcher => 1 ),
        'commit (defaults)'
    );
}

{
    for (
        { waitFlush => 1, waitSearcher => 1 },
        { waitFlush => 1, waitSearcher => 0 },
        { waitFlush => 0, waitSearcher => 0 },
        { waitFlush => 0, waitSearcher => 0 },
        )
    {
        my $r = WebService::Solr::Request::Commit->new( %$_ );
        isa_ok( $r, 'WebService::Solr::Request::Commit' );
        is( $r->to_xml, make_xml( %$_ ), 'commit w/ options' );
    }
}

sub make_xml {
    my %opts = @_;
    $opts{ $_ } = $opts{ $_ } ? 'true' : 'false'
        for qw( waitFlush waitSearcher );
    return
        qq(<commit waitFlush="$opts{waitFlush}" waitSearcher="$opts{waitSearcher}" />);
}
