package WebService::Solr::Delete;
use XML::Generator;
use strict;
use warnings;

sub new {
    my ( $class, %options ) = @_;
    if (\%options{'id'} && \options{'query'}){
        die "Must delete by id OR query, not both";
    }
    my $self = {
        opts => \%options
    };
         
        bless $self, $class;
        return $self;
}
1;
sub delete_by_id{
    my $self = shift;
    my $opts = $self->{opts};
     die "Expected hash reference for WebService::Solr::Delete->delete_by_id " unless ref($opts) eq "HASH";
    my %optshash = %$opts;
    my $gen = XML::Generator->new(':pretty');
    my $id ='';
    
    print "The # of items in the hash is keys(%opthash)"."\n";

    if ($optshash{'id'}||die "An id must be provided for deletion! "){
        $id  = $optshash{'id'}; 
    }
    
    print $gen->delete(
        $gen->id($id),
    );
    print "\n";   
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
    print $gen->delete(
        $gen->query($query),
    );  
    print "\n"; 
}
package main;
use strict;
use warnings;
use XML::Generator;
my %opt_3 = (id=>"0001");
my $delete_3 = WebService::Solr::Delete->new(%opt_3);
my $got_3 = WebService::Solr::Delete->delete_by_id;

