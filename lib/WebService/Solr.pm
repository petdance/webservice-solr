package WebService::Solr;
use strict;
use warnings;
use base qw(Class::Accessor::Fast);
use WebService::Solr::Commit;
use WebService::Solr::Optimize;
use WebService::Solr::Delete;
use WebService::Solr::Field;
use LWP::UserAgent;
use URI;
use HTTP::Request;
use HTTP::Headers;
use XML::Simple qw(:strict);
use Data::Dumper;
__PACKAGE__->mk_accessors('url', 'agent');

our $VERSION = '0.01';

sub new {
    my ( $class, $url, $options ) = @_;
    $url ||= 'http://localhost:8983/solr/';
    $options ||= {};
    $options->{ url } = URI->new( $url );
    $options->{ agent } ||= LWP::UserAgent->new;
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
    my $url = $self->url->clone;
        
    my $path = $url->path."select/";
    $url->path($path);
    $url->query_form($params);
    print "url: $url \n";
    keys %$params;
    my $ua  = $self->agent;
    my $h   = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );
    
    my $response = $ua->get($url->as_string);
if ($response->is_success) {
    my $resp_content = $response->content;  # or whatever
    my $resp = XMLin($resp_content,ForceArray=>1,KeyAttr=>{'id','inStock','includes','manu','name','popularity','price','sku','timestamp','weight','cat','features'});
    my $result = $resp->{'result'};
# docs is an array 
my $docs = $result->[0]->{'doc'};
my $i = 0; 
my $j = 0;
my $k = 0;
my (@doc_holder,@arr_hash,$sub_array);
my ($h,$v);
# doc is a hash
my %fields;
for my $doc(@$docs){
    for my $vals (values %$doc){
        for my $field (@$vals){
            my $name = delete $field->{name};
            my ($vals) = values %$field;
            my @vals = ref $vals ? @$vals : ($vals);
            #$fields{$name}={$vals};        
        }
    
    }

}    
    
    #print Dumper $resp;
    return $resp;
    }else {
    die $response->status_line;
    }
}
