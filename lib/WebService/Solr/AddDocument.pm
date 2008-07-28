package WebService::Solr::AddDocument;
use WebService::Solr::Document;
require XML::Generator;
use strict;
use warnings;

sub new {
    my ( $class, $options ) = @_;
    # Accepts a hash of <add></add> tag attribute 'allowDups'.
    my $self = {
        opts => $options
    };
        bless $self, $class;
        return $self;
}

sub addXMLDocument{
    # Accepts a string in xml format of doc and field tags to be 
    # wrapped with an <add></add> tag.  
    my ($self,$strXMLDocs) = @_;
    my $opts = $self->{opts};
    my $allowDups='false';
    my $str = '';
    my $gen = XML::Generator->new(pretty => "\t");
    if($opts->{'allowDups'}){
            $allowDups= $opts->{'allowDups'};
    }
    
 $str = $gen->add({allowDups => $allowDups},
            $strXMLDocs
         );
    return $str;
}
sub addXMLDocuments{
    my ($self,$arrDocuments) = @_;
    my $opts = $self->{opts};
    my $allowDups='false';
    my $str = '';
    my $document='';
    my $documentHolder='';
    my $gen = XML::Generator->new(pretty => "\t");
    if($opts->{'allowDups'}){
            $allowDups= $opts->{'allowDups'};
    }
    foreach $document (@$arrDocuments) {
        $documentHolder = $documentHolder."\n".$document;
     }
    $str = $gen->add({allowDups => $allowDups},$documentHolder);
    return $str;
   
}
1;
