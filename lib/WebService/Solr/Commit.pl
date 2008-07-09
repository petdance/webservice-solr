package Commit;
use XML::Generator;
use Tie::IxHash;
# Inheriting from Update package
use base qw(Update);
use strict;
use warnings;

sub new {
    my ( $class, %options ) = @_;
    my $self = {
        opts => \%options
    };
        
        bless $self, $class;
        return $self;
}

sub toString {
    my $self = shift;
    my $opts = $self->{opts};
    my %optshash = %$opts;
    my $gen = XML::Generator->new(':pretty');
    tie my %attr, 'Tie::IxHash';
    my $waitFlush  = $optshash{'waitFlush'};  
    my $waitSearcher = $optshash{'waitSearcher'};
    %attr = (waitFlush => $waitFlush, 
             waitSearcher => $waitSearcher,
           );
    my $func = $gen->commit(\%attr); 
    #print $gen->commit(\%attr);   
    return $func;   
     
}
package main;
my %options = ( waitFlush =>'true', waitSearcher=>'true' );
my $c = Commit->new( %options );
my $t = $c->toString;
print $t;
