package WebService::Solr::CommonQueryParameters;
use strict;
use warnings;
sub new{
    my ($class, $params) = @_;
    my $self = {
        params => $params,
    };
    bless $self,$class;
    return $self;
}
sub getSort{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'sort'}){
       $qStr = 'sort='.$params->{'sort'};     
    }
    return $qStr;
}
sub getStart{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'start'}){
       $qStr = 'start='.$params->{'start'};     
    }
    return $qStr;
}
sub getRows{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'rows'}){
       $qStr = 'rows='.$params->{'rows'};     
    }
    return $qStr;
}
sub getFieldQuery{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'fq'}){
       $qStr = 'fq='.$params->{'fq'};     
    }
    return $qStr;
}
sub getFieldList{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'fl'}){
       $qStr = 'fl='.$params->{'fl'};     
    }
    return $qStr;
}
sub getDebugQuery{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'debugQuery'}){
       $qStr = $params->{'debugQuery'};     
    }
    return $qStr;
}
sub getExplainOther{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'explainOther'}){
       $qStr = 'explainOther='.$params->{'explainOther'};     
    }
    return $qStr;
}
1;
