package WebService::Solr::Update;
use warnings;
use strict;

sub new{
    my ($class)= @_;
    my $self = {};
    bless $self,$class;
    return $self;    
}
sub response_format{
    my $self = shift; 
    return 'xml';
}
sub handler{
    my $self = shift;
    return 'update';
}
1;
