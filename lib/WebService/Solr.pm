package WebService::Solr;

use Moose;

use URI;
use LWP::UserAgent;
use WebService::Solr::Request::AddDocument;
use WebService::Solr::Request::Commit;
use WebService::Solr::Request::Delete;
use WebService::Solr::Request::Optimize;
use WebService::Solr::Request::Ping;
use WebService::Solr::Response;
use HTTP::Request;

has 'url' => (
    is      => 'ro',
    isa     => 'URI',
    default => sub { URI->new( 'http://localhost:8983/solr' ) }
);

has 'agent' =>
    ( is => 'ro', isa => 'Object', default => sub { LWP::UserAgent->new } );

has 'autocommit' => ( is => 'ro', isa => 'Bool', default => 1 );

our $VERSION = '0.01';

sub BUILDARGS {
    my ( $self, $url, $options ) = @_;
    $options ||= {};

    if ( $url ) {
        $options->{ url } = ref $url ? $url : URI->new( $url );
    }

    return $options;
}

sub add {
    my ( $self, $doc ) = @_;
    my @docs = ref $doc eq 'ARRAY' ? @$doc : ( $doc );
    my $response
        = $self->send( WebService::Solr::Request::AddDocument->new( @docs ) );
    $self->commit if $self->autocommit;
    return $response->success;
}

sub update {
    return shift->add( @_ );
}

sub commit {
    my ( $self, %options ) = @_;
    my $response
        = $self->send( WebService::Solr::Request::Commit->new( %options ) );
    return $response->success;
}

sub optimize {
    my ( $self ) = @_;
    my $response = $self->send( WebService::Solr::Request::Optimize->new );
    return $response->success;
}

sub delete {
    my ( $self, $id ) = @_;
    my $response
        = $self->send( WebService::Solr::Request::Delete->new( id => $id ) );
    $self->commit if $self->autocommit;
    return $response->success;
}

sub delete_by_query {
    my ( $self, $query ) = @_;
    my $response = $self->send(
        WebService::Solr::Request::Delete->new( query => $query ) );
    $self->commit if $self->autocommit;
    return $response->success;
}

sub ping {
    my ( $self ) = @_;
    my $response = $self->send( WebService::Solr::Request::Ping->new );
    return $response->success;
}

sub send {
    my ( $self, $request ) = @_;
    my $xml = $request->can( 'to_xml' ) ? $request->to_xml : '';
    my $http_req = HTTP::Request->new(
        POST => $self->url . '/' . $request->handler,
        [ Content_Type => $request->content_type ], "$xml"
    );

    #use Data::Dumper; die Dumper $http_req;
    my $http_res = $self->agent->request( $http_req );

    #use Data::Dumper; die Dumper $http_res;
    return WebService::Solr::Response->new( $request, $http_res );
}

1;

__END__

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

sub make_query {
    my ( $self, $params ) = @_;
    my $url = $self->url->clone;
    my $path = $url->path . "select/";
    $url->path( $path );
    $url->query_form( $params );
    print "url: $url \n";
    keys %$params;
    my $ua = $self->agent;
    my $h  = HTTP::Headers->new(
        Content_Type => 'text/xml;',
        Content_Base => $url
    );

    my @final_documents;
    my $response = $ua->get( $url->as_string );

    if ( $response->is_success ) {
        my $resp_content = $response->content;    # or whatever
        my $resp         = XMLin(
            $resp_content,
            ForceArray => 1,
        # KeyAttr should match the schema.xml list of allowed fields.
            KeyAttr    => {
                'id',        'inStock',    'includes', 'manu',
                'name',      'popularity', 'price',    'sku',
                'timestamp', 'weight',     'cat',      'features',
                'nameSort',  'alphaNameSort', 'includes' , 'word',
                'text',      'manu_exact',    
            }
        );
        my $response= $resp->{'response'};
        my $result = $resp->{ 'result' };
        use Data::Dumper; print Dumper $result;
        # docs is an array
        my $docs = $result->[ 0 ]->{ 'doc' };
        
        # doc is a hash

        for my $doc ( @$docs ) {
            my %doc_out;
            my @documents;
            for my $vals ( values %$doc ) {

                #==== @vals separate the fields in groups of type =======";
                # An array of str, int, bool, float, arr, date and
                for my $field ( @$vals ) {
                    my $name     = delete $field->{ name };
                    my ( $vals ) = values %$field;
                    my @vals     = ref $vals ? @$vals : ( $vals );
                    $doc_out{ $name } = $vals;
                }
            }
            push( @final_documents, \%doc_out );
        }
       return @final_documents;
    }
    else {
        die $response->status_line;
    }
}
1;
