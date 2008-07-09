package Delete;
use XML::Generator;
# Inheriting from Update package
use base qw(Update);
use strict;
use warnings;

sub new {
    my ( $class, %options ) = @_;
    if ($options{'id'} && $options{'query'}){
        die "Must delete by id OR query, not both";
    }
    my $self = {
        opts => \%options
    };
         
        bless $self, $class;
        return $self;
}
sub delete_by_id{
    my $self = shift;
    my $opts = $self->{opts};
    my %optshash = %$opts;
    my $gen = XML::Generator->new(':pretty');
    my $id ='';
    
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
my %options = (query =>'office:Bridgewater');
my $d = Delete->new( %options );
my $t = $d->delete_by_query;
print $t;
