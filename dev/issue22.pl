#!perl

# Exercises GitHub issue 22 https://github.com/bricas/webservice-solr/issues/22

use warnings;
use strict;

use lib 'lib';

use Carp::Always;
use WebService::Solr::Query;

my $q = WebService::Solr::Query->new( { title => [ -and => { -prohibit => 'star' }, { -prohibit => 'wars' } ] } );

print "Calling the first stringify\n";
{use Data::Dumper; local $Data::Dumper::Sortkeys=1; warn Dumper( 'q#1' => $q )}
my $str1 = $q->stringify;
{use Data::Dumper; local $Data::Dumper::Sortkeys=1; warn Dumper( 'q#2' => $q )}
print "Result #1: $str1\n";

print "Calling the second stringify\n";
my $str2 = $q->stringify;
print "Result #2: $str2\n";
