package WebService::Solr::Delete;
use XML::Generator;
use strict;
use warnings;
sub new {
    my ( $class, %options ) = @_;
    if ($options{'id'} && $options{'query'}){
        die "Must delete by id OR query, not both";
    }
#    print "Here it is : ";
    my $self = {
        opts => \%options
    };
         
        bless $self, $class;
        return $self;

}
1;
sub response_format{
    my $self = shift; 
    return 'xml';
}
sub handler{
    my $self = shift;
    return 'update';
}
sub delete_by_id{
    my $self = shift;
    my $opts = $self->{opts};
     die "Expected hash reference for WebService::Solr::Delete->delete_by_id " unless ref($opts) eq "HASH";
    my %optshash = %$opts;
    my $gen = XML::Generator->new(':pretty');
    my $id ='';
    
#    print "The # of items in the hash is keys(%opthash)"."\n";

    if ($optshash{'id'}||die "An id must be provided for deletion! "){
        $id  = $optshash{'id'}; 
    }
    
    return $gen->delete(
        $gen->id($id),
    );
     
}

sub delete_by_query{
    my $self = shift;
    my $opts = $self->{opts};
    my %optshash = %$opts;
    my $gen = XML::Generator->new(':pretty');
    my $query ='';
    
    if ($optshash{'query'}||die "A query must be provided for deletion! "){
        $query  = $optshash{'query'}; 
    }
    $gen->delete($gen->query($query),);  
}
