use Test::More 'no_plan';

use strict;
use warnings;

BEGIN {
    use_ok( 'WebService::Solr::Query' );
}

{ # (un)escape
    is( WebService::Solr::Query->escape( '(1+1):2' ), '\(1\+1\)\:2', 'escape' );
    is( WebService::Solr::Query->unescape( '\(1\+1\)\:2' ), '(1+1):2', 'unescape' );
}

{ # basic queries
    # default field
    _check( query => { -default => 'space' }, expect => '"space"' );
    _check( query => { -default => [ 'star trek', 'star wars' ] }, expect => '"star trek" "star wars"' );

    # field
    _check( query => { title => 'Spaceballs' }, expect => 'title:"Spaceballs"' );
    _check( query => { first => 'Roger', last => 'Moore' }, expect => 'first:"Roger" last:"Moore"' );
    _check( query => { first => [ 'Roger', 'Dodger' ] }, expect => 'first:"Roger" first:"Dodger"' );
    _check( query => { first => [ 'Roger', 'Dodger' ], last => 'Moore' }, expect => 'first:"Roger" first:"Dodger" last:"Moore"' );

    _check( query => { first => [ 'Roger', 'Dodger' ], -default => [ 'star trek', 'star wars' ] }, expect => '"star trek" "star wars" first:"Roger" first:"Dodger"' );
}

{ # basic query with escape
    _check( query => { title => 'Spaceb(a)lls' }, expect => 'title:"Spaceb\(a\)lls"' );
}

{ # simple ops
    # range (inc)
    _check( query => { title => { -range => [ 'a', 'z' ] } }, expect => 'title:[a TO z]' );
    _check( query => { first => [ 'Roger', 'Dodger' ], title => { -range => [ 'a', 'z' ] } }, expect => 'first:"Roger" first:"Dodger" title:[a TO z]' );

    # range (exc)
    _check( query => { title => { -range_exc => [ 'a', 'z' ] } }, expect => 'title:{a TO z}' );
    _check( query => { first => [ 'Roger', 'Dodger' ], title => { -range_exc => [ 'a', 'z' ] } }, expect => 'first:"Roger" first:"Dodger" title:{a TO z}' );

    # boost
    _check( query => { title => { -boost => [ 'Space', '2.0' ] } }, expect => 'title:"Space"^2.0' );
    _check( query => { first => [ 'Roger', 'Dodger' ], title => { -boost => [ 'Space', '2.0' ] } }, expect => 'first:"Roger" first:"Dodger" title:"Space"^2.0' );

    # proximity
    _check( query => { title => { -proximity => [ 'space balls', '10' ] } }, expect => 'title:"space balls"~10' );
    _check( query => { first => [ 'Roger', 'Dodger' ], title => { -proximity => [ 'space balls', '10' ] } }, expect => 'first:"Roger" first:"Dodger" title:"space balls"~10' );

    # fuzzy
    _check( query => { title => { -fuzzy => [ 'space', '0.8' ] } }, expect => 'title:space~0.8' );
    _check( query => { first => [ 'Roger', 'Dodger' ], title => { -fuzzy => [ 'space', '0.8' ] } }, expect => 'first:"Roger" first:"Dodger" title:space~0.8' );
}

{ # ops with escape
    _check( query => { title => { -boost => [ 'Sp(a)ce', '2.0' ] } }, expect => 'title:"Sp\(a\)ce"^2.0' );
    _check( query => { title => { -proximity => [ 'sp(a)ce balls', '10' ] } }, expect => 'title:"sp\(a\)ce balls"~10' );
    _check( query => { title => { -fuzzy => [ 'sp(a)ce', '0.8' ] } }, expect => 'title:sp\(a\)ce~0.8' );
}

sub _check {
    my %t = @_;

    my $q = WebService::Solr::Query->new( $t{ query } );
    isa_ok( $q, 'WebService::Solr::Query' );
    is( $q->stringify, $t{ expect }, $t{ expect } );
}
