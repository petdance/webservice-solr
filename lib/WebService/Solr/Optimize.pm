package Optimize;
use XML::Generator;
use Tie::IxHash;
# Inheriting from Update package
#@ISA = qw(Update);
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

sub to_s {
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
    my $func = $gen->optimize(\%attr); 
    #print $gen->optimize(\%attr);   
    return $func;   
     
}
package main;
my %options = ( waitFlush =>'false', waitSearcher=>'true' );
my $c = Optimize->new( %options );
my $t = $c->to_s;
print $t;
