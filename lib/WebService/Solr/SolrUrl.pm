package WebService::Solr::SolrUrl;
use strict;
use warnings;

sub new{
    my ($class,$commonParams) = @_;
    my $self={
        comUrlParams=>$commonParams,
    };
    bless $self,$class;
    return $self;
}
sub solrUrl{
    my ($self)=@_;
    my $comParams = $self->{comUrlParams}; 
    my $domain = $comParams->{'domain'};
    my $port = $comParams->{'port'};
    my $url = 'http://'."$domain".':'."$port".'/solr'."/";
   
}
sub updateUrl{
    my ($self)=@_;
    my $updateUrl = $self->solrUrl."update/";
    return $updateUrl;
}
sub selectUrl{
    my ($self)=@_;
    my $selectUrl = $self->solrUrl."select/";
    return $selectUrl;
}
1;
