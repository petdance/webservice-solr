package WebService::Solr;

use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use base qw( Class::Accessor::Fast );

use WebService::Solr::Commit;
use WebService::Solr::Optimize;
use WebService::Solr::Delete;
use WebService::Solr::CoreQueryParameters;
use LWP::UserAgent;
use URI;
use HTTP::Request;
use HTTP::Headers;

__PACKAGE__->mk_accessors( 'url', 'agent' );

our $VERSION = '0.01';

sub new {
    my ( $class, $url, $options ) = @_;
    $url ||= 'http://localhost:8983/solr/';

    $options ||= {};
    $options->{ url } = $url;
    $options->{ agent } = LWP::UserAgent->new;

    return $class->SUPER::new( $options );
}

sub add_documents {
    my ( $self, $arrDocuments, $opts ) = @_;

    # Default value of allowDups
    my $allowDups      = 'false';
    my $xml            = '';
    my $document       = '';
    my $url            = $self->get_url;
    my $documentHolder = '';
    my $gen            = XML::Generator->new();
    if ( $opts->{ 'allowDups' } ) {
        $allowDups = $opts->{ 'allowDups' };
    }
    foreach $document ( @$arrDocuments ) {
        $documentHolder = $documentHolder . $document;
    }
    $xml = $gen->add( { allowDups => $allowDups }, $documentHolder );
    my $ua = $self->agent;
    my $h  = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );

    my $request
        = HTTP::Request->new( 'POST', "$url" . "update/", $h, "$xml" );
    my $response = $ua->request( $request );

    if ( $response->is_success ) {
        return $response->content;
    }
    else {
        die $response->status_line;
    }

}

sub commit {
    my ( $self, $commitParams ) = @_;
    my $url = $self->url;
    my $ua  = $self->agent;
    my $h   = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );
    my $commit   = WebService::Solr::Commit->new( $commitParams );
    my $xml      = $commit->to_xml;
    my $request  = HTTP::Request->new( 'POST', "$url" . "update/", $h, $xml );
    my $response = $ua->request( $request );

    if ( $response->is_success ) {
        return $response->content;
    }
    else {
        die $response->status_line;
    }
}

sub optimize {
    my ( $self, $optParams ) = @_;
    my $url = $self->url;
    my $ua  = $self->agent;
    my $h   = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );
    my $optimize = WebService::Solr::Optimize->new( $optParams );
    my $xml      = $optimize->to_xml;
    my $request  = HTTP::Request->new( 'POST', "$url" . "update/", $h, $xml );
    my $response = $ua->request( $request );

    if ( $response->is_success ) {
        return $response->content;
    }
    else {
        die $response->status_line;
    }
}

sub delete_documents {
    my ( $self, $delParams ) = @_;
    my $delete = WebService::Solr::Delete->new( $delParams );
    my $xml;
    if ( $delParams->{ 'id' } ) {
        $xml = $delete->delete_by_id;
    }
    if ( $delParams->{ 'query' } ) {
        $xml = $delete->delete_by_query;
    }
    my $url = $self->url;
    my $ua  = $self->agent;
    my $h   = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );
    my $request = HTTP::Request->new( 'POST', "$url" . "update/", $h, $xml );
    my $response = $ua->request( $request );

    if ( $response->is_success ) {
        return $response->content;
    }
    else {
        die $response->status_line;
    }
}

sub get_core_query {
    my ( $self, $coreParams ) = @_;

# qt = standard, dismax, partitioned, inStock, spellchecker, /search, /elevate, /update, /analysis
# wt = standard, xslt
    my $query = "";
    my $url   = $self->url;

    if ( $coreParams->{ 'qt' } ) {
        $query = $query . "qt=" . $coreParams->{ 'qt' } . "&";
    }
    if ( $coreParams->{ 'wt' } ) {
        $query = $query . "wt=" . $coreParams->{ 'wt' } . "&";
    }
    if ( $coreParams->{ 'echoHandler' } ) {
        $query = $query . "echoHandler=" . $coreParams->{ 'echoHandler' } . "&";
    }
    if ( $coreParams->{ 'echoParams' } ) {
        # values are : none, explicit, or all
        $query = $query . "echoParams=" . $coreParams->{ 'echoParams' } . "&";
    }
    return "$url" . "select/" . "?" . "$query";
}

sub get_common_query {
    my ( $self, $commonParams ) = @_;
    my $query = '';
    my $url   = $self->url;

    #
    # sort start rows fq fl debugQuery explainOther
    #
    if ( $commonParams->{ 'q' } ) {
        $query = $query . "q=" . $commonParams->{ 'q' } . "&";
    }
    if ( $commonParams->{ 'start' } ) {
        $query = $query . "start=" . $commonParams->{ 'start' } . "&";
    }
    if ( $commonParams->{ 'rows' } ) {
        $query = $query . "rows=" . $commonParams->{ 'rows' } . "&";
    }
    if ( $commonParams->{ 'fq' } ) {
        $query = $query . "fq=" . $commonParams->{ 'fq' } . "&";
    }
    if ( $commonParams->{ 'fl' } ) {
        $query = $query . "fl=" . $commonParams->{ 'fl' } . "&";
    }
    if ( $commonParams->{ 'debugQuery' } ) {
        $query = $query . $commonParams->{ 'debugQuery' } . "&";
    }

#
# This parameter allows clients to specify a Lucene query to identify a set of documents.
# If non-blank, the explain info of each document which matches this query, relative the
# main query (specified  by the q parameter) will be returned along with the rest of the debugging information.
#
# The default value is blank (i.e. no extra explain info will be returned)
#
    if ( $commonParams->{ 'explainOther' } ) {
        $query = $query . "explainOther" . $commonParams->{ 'explainOther' }."&";
    }
    return $query;
}

sub get_facet_query {
    my ( $self, $facetParams ) = @_;
    my $query = '';
    my $url   = $self->url;

    if ( $facetParams->{ 'facet' } ) {
        $query = $query . 'facet' . $facetParams->{ 'facet' } . "&";
    }
    if ( $facetParams->{ 'facet.field' } ) {
        $query
            = $query . 'facet.field' . $facetParams->{ 'facet.field' } . "&";
    }
    if ( $facetParams->{ 'facet.query' } ) {
        $query
            = $query . 'facet.query' . $facetParams->{ 'facet.query' } . "&";
    }
    if ( $facetParams->{ 'facet.prefix' } ) {
        $query
            = $query . 'facet.prefix' . $facetParams->{ 'facet.prefix' } . "&";
    }
    if ( $facetParams->{ 'facet.sort' } ) {
        $query
            = $query . "facet.sort" . $facetParams->{ 'facet.sort' } . "&";
    }
    if ( $facetParams->{ 'facet.limit' } ) {
        $query
            = $query . 'facet.limit' . $facetParams->{ 'facet.limit' } . "&";
    }
    if ( $facetParams->{ 'facet.offset' } ) {
        $query
            = $query . 'facet.offset' . $facetParams->{ 'facet.offset' } . "&";
    }
    if ( $facetParams->{ 'facet.mincount' } ) {
        $query
            = $query . 'facet.mincount' . $facetParams->{ 'facet.mincount' } . "&";
    }
    if ( $facetParams->{ 'facet.missing' } ) {
        $query
            = $query . 'facet.missing' . $facetParams->{ 'facet.missing' } . "&";
    }
    if ( $facetParams->{ 'facet.enum.cache.minDf' } ) {
        $query
            = $query . 'facet.enum.cache.minDf' . $facetParams->{ 'facet.enum.cache.minDf' } . "&";
    }
    if ( $facetParams->{ 'facet.date' } ) {
        $query
            = $query . 'facet.date' . $facetParams->{ 'facet.date' } . "&";
    }
    if ( $facetParams->{ 'facet.date.start' } ) {
        $query
            = $query . 'facet.date.start' . $facetParams->{ 'facet.date.start' } . "&";
    }
    if ( $facetParams->{ 'facet.date.end' } ) {
        $query
            = $query . 'facet.date.end' . $facetParams->{ 'facet.date.end' } . "&";
    }
    if ( $facetParams->{ 'facet.date.gap' } ) {
        $query
            = $query . 'facet.date.gap' . $facetParams->{ 'facet.date.gap' } . "&";
    }
    if ( $facetParams->{ 'facet.date.hardened' } ) {
        $query
            = $query . 'facet.date.hardened' . $facetParams->{ 'facet.date.hardened' } . "&";
    }
    if ( $facetParams->{ 'facet.date.other' } ) {
        $query
            = $query . 'facet.date.other' . $facetParams->{ 'facet.date.other' } . "&";
    }
}1;
