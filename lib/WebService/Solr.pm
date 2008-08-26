package WebService::Solr;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use WebService::Solr::Commit;
use WebService::Solr::Optimize;
use WebService::Solr::Delete;
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
    my $url            = $self->url;
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
sub make_query {
    my ( $self, $params ) = @_;
    my $url            = $self->url."select/?";
    my $query = join '&', map{
      "$_=".$params->{$_};
    }
    keys %$params;
    $query = "$url"."$query"."\n";
    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;
    my $response = $ua->get($query);
if ($response->is_success) {
    return $response->content;  # or whatever
 }
 else {
     die $response->status_line;
 }
}
1;
