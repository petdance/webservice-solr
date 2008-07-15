package WebService::Solr::AddDocuments;
use strict;
use warnings;
require XML::Generator;
sub new {
    my ( $class, %options ) = @_;
    my $self = {
        opts => \%options
    };
        
        bless $self, $class;
        return $self;
}
# Base code for adding documents. Will require input and loops for practical use but this works! :-)
    my $gen = XML::Generator->new(':pretty');
    # Set the attributes to their default values. 
    my $allowDups = 'false';
    my $fieldBoost ='1.0';
    my $docBoost ='1.0';
    # Look into how one would determine which field would have boost on it ? Maybe all ?
    my $xml = $gen->add({allowDups => $allowDups },
                 $gen->doc(
                        {docBoost => $docBoost },
                        $gen->field({ name=>'employeeId', boost=>$fieldBoost}, 1500),
                        $gen->field({ name=>'office', boost=>$fieldBoost}, 'Bridgewater'),
                        $gen->field({ name=>'skills', boost=>$fieldBoost}, 'Perl'),
                        $gen->field({ name=>'skills', boost=>$fieldBoost}, 'Java')   
                 )     
              );
    print $xml."\n";
