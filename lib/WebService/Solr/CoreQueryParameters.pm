package CoreQueryParameters;
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
sub getQueryType{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'qt'}){
       $qStr = 'qt='.$params->{'qt'};     
    }
    return $qStr;
}
sub getWriterType{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'wt'}){
       $qStr = 'wt='.$params->{'wt'};     
    }
    return $qStr;
}
sub getEchoHandler{
   my ($self) =@_;
   my $params = $self->{params};
   my $qStr ='';
   if($params->{'echoHandler'}){
       $qStr = 'echoHandler='.$params->{'echoHandler'};     
   }
   return $qStr; 
}
sub getEchoParams{
    my ($self) =@_;
    my $params = $self->{params};
    my $qStr ='';
    if($params->{'echoParams'}){
       $qStr = 'echoParams='.$params->{'echoParams'};     
    }
    return $qStr;
}
1;
