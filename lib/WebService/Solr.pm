package WebService::Solr;

use strict;
use warnings;

use WebService::Solr::Commit;
use WebService::Solr::Optimize;
use WebService::Solr::Delete;
use WebService::Solr::CoreQueryParameters;
use LWP::UserAgent;
use URI;
use HTTP::Request;
use HTTP::Headers;

our $VERSION = '0.01';

sub new {
    my ( $class, $url ) = @_;
    $url ||= 'http://localhost:8983/solr/';
    my $self = { url => URI->new( $url ), };
    bless $self, $class;
    return $self;
}

sub get_url {
    my ( $self ) = @_;
    my $url = $self->{ url };
    return $url;
}

sub add_documents {
    my ( $self, $arrDocuments, $opts ) = @_;

    # Default value of allowDups
    my $allowDups      = 'false';
    my $xml            = '';
    my $document       = '';
    my $documentHolder = '';
    my $gen            = XML::Generator->new();
    if ( $opts->{ 'allowDups' } ) {
        $allowDups = $opts->{ 'allowDups' };
    }
    foreach $document ( @$arrDocuments ) {
        $documentHolder = $documentHolder.$document;
    }
    $xml = $gen->add( { allowDups => $allowDups }, $documentHolder );
    my $url = $self->get_url;
    my $ua = LWP::UserAgent->new;
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
    my $url = $self->get_url;
    my $ua  = LWP::UserAgent->new;
    my $h   = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );
    my $commit   = WebService::Solr::Commit->new( $commitParams );
    my $xml      = $commit->to_xml;
    my $request  = HTTP::Request->new( 'POST', "$url"."update/", $h, $xml );
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
    my $url = $self->get_url;
    my $ua  = LWP::UserAgent->new;
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
    my $url = $self->get_url;
    my $ua  = LWP::UserAgent->new;
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
sub get_core_query{
    my ($self,$coreParams) = @_;
    # qt = standard, dismax, partitioned, inStock, spellchecker, /search, /elevate, /update, /analysis
    # wt = standard, xslt
    my $query = "";
    if($coreParams->{'qt'}){
        $query = $query."qt=".$coreParams->{'qt'}."&"; 
    }
    if($coreParams->{'wt'}){
        $query = $query."wt=".$coreParams->{'wt'}."&";
    }
    if($coreParams->{'echoHandler'}){
        $query = $query."echoHandler=".$coreParams->{'echoHandler'}."&";
    }
    if($coreParams->{'echoParams'}){
        # values are : none, explicit, or all
        $query = $query."echoParams=".$coreParams->{'echoParams'}."&";
    }
    
}
sub get_common_query{
    my ($self,$commonParameters) = @_;
}
sub get_facet_query{
    my ($self,$facetParameters) = @_;
}
1;
