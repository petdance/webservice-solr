package WebService::Solr::SimpleFacetParameters;
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
# Unless the facet param is true then none of these variables matter
# facet must be true to turn on faceting.
sub getFacet{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{'facet'}){
       $Str = 'facet='.$params->{'facet'};     
    }
    return $Str;
}
sub getFacet_Query{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{'facet.query'}){
       $Str = 'facet.query='.$params->{'facet.query'};     
    }
    return $Str;
}
sub getFacet_Field{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.field"}){
       $Str = "facet.field=".$params->{"facet.field"};     
    }
    return $Str;
}
sub getFacet_Prefix{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.prefix"}){
       $Str = "facet.prefix=".$params->{"facet.prefix"};     
    }
    return $Str;
}
sub getFacet_Sort{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.sort"}){
       $Str = "facet.sort=".$params->{"facet.sort"};     
    }
    return $Str;
}
sub getFacet_Limit{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.limit"}){
       $Str = "facet.limit=".$params->{"facet.limit"};     
    }
    return $Str;
}
sub getFacet_Offset{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.offset"}){
       $Str = "facet.offset=".$params->{"facet.offset"};     
    }
    return $Str;
}
sub getFacet_MinCount{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.mincount"}){
       $Str = $params->{"facet.mincount"};     
    }
    return $Str;
}
sub getFacet_Missing{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.missing"}){
       $Str = "facet.missing=".$params->{"facet.missing"};     
    }
    return $Str;
}
sub getFacet_Enum_Cache_MinDf{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.enum.cache.minDf"}){
       $Str = "facet.enum.cache.minDf=".$params->{"facet.enum.cache.minDf"};     
    }
    return $Str;
}
# When using Date Faceting, facet.date, facet.date.start, facet.date.end, facet.date.gap params are all mandatory
sub getFacet_Date{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.date"}){
       $Str = "facet.date=".$params->{"facet.date"};     
    }
    return $Str;
}
sub getFacet_Date_Start{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.date.start"}){
       $Str = "facet.date.start=".$params->{"facet.date.start"};     
    }
    return $Str;
}
sub getFacet_Date_End{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.date.end"}){
       $Str = "facet.date.end=".$params->{"facet.date.end"};     
    }
    return $Str;
}
sub getFacet_Date_Gap{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.date.gap"}){
       $Str = "facet.date.gap=".$params->{"facet.date.gap"};     
    }
    return $Str;
}
sub getFacet_Date_Hardened{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.date.hardened"}){
       $Str = "facet.date.hardened=".$params->{"facet.date.hardened"};     
    }
    return $Str;
}
sub getFacet_Date_Other{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.date.other"}){
       $Str = $params->{"facet.date.other"};     
    }
    return $Str;
}
sub getFacet_Zeros{
    my ($self) =@_;
    my $params = $self->{params};
    my $Str ='';
    if($params->{"facet.zeros"}){
       $Str = "facet.zeros=".$params->{"facet.zeros"};     
    }
    return $Str;
}
1;
