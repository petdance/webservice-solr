use Test::More 'no_plan';

use strict;
use warnings;

BEGIN {
    use_ok( 'WebService::Solr::Query' );
}

{ # basic queries
    _check( query => { title => 'Spaceballs' }, expect => 'title:"Spaceballs"' );
    _check( query => { first => 'Roger', last => 'Moore' }, expect => 'first:"Roger" last:"Moore"' );
    _check( query => { first => [ 'Roger', 'Dodger' ] }, expect => 'first:"Roger" first:"Dodger"' );
    _check( query => { first => [ 'Roger', 'Dodger' ], last => 'Moore' }, expect => 'first:"Roger" first:"Dodger" last:"Moore"' );
}

{ # range
    _check( query => { title => { -range => [ 'a', 'z' ] } }, expect => 'title:[a TO z]' );
    _check( query => { first => [ 'Roger', 'Dodger' ], title => { -range => [ 'a', 'z' ] } }, expect => 'first:"Roger" first:"Dodger" title:[a TO z]' );
}

sub _check {
    my %t = @_;

    my $q = WebService::Solr::Query->new( $t{ query } );
    isa_ok( $q, 'WebService::Solr::Query' );
    is( $q->stringify, $t{ expect }, $t{ expect } );
}
