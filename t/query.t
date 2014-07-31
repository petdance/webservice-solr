use Test::More tests => 8;

use strict;
use warnings;

use WebService::Solr::Query;
use Data::Dumper;

local $Data::Dumper::Sortkeys=1; # To make sure output is deterministic.

subtest 'Unescapes' => sub {
    is( WebService::Solr::Query->escape( '(1+1):2' ),
        '\(1\+1\)\:2', 'escape' );
    is( WebService::Solr::Query->unescape( '\(1\+1\)\:2' ),
        '(1+1):2', 'unescape' );
};

subtest 'Select All' => sub {
    my $string_select_all_via_new = sprintf( "%s", WebService::Solr::Query->new( { '*' => \'*' } ) );
    is( $string_select_all_via_new, '(*:*)', 'the new method select_all stringifies like this (*:*)' );
    my $string_select_all = sprintf( "%s", WebService::Solr::Query->select_all() ) ;    
    is( $string_select_all_via_new, $string_select_all_via_new, 'the select_all method stringifies the same' );  
    is_deeply(         WebService::Solr::Query->new( { '*' => \'*' } ),
                WebService::Solr::Query->select_all(),
                'select_all: The objects returned by both methods are identical' );
};

subtest 'Basic queries' => sub {
    # default field
    _check( query => { -default => 'space' }, expect => '("space")' );
    _check(
        query => { -default => [ 'star trek', 'star wars' ] },
        expect => '(("star trek" OR "star wars"))'
    );

    # scalarref pass-through
    _check( query => { '*' => \'*' }, expect => '(*:*)' );

    # field
    _check(
        query  => { title => 'Spaceballs' },
        expect => '(title:"Spaceballs")'
    );
    _check(
        query => { first => 'Roger', last => 'Moore' },
        expect => '(first:"Roger" AND last:"Moore")'
    );
    _check(
        query => { first => [ 'Roger', 'Dodger' ] },
        expect => '((first:"Roger" OR first:"Dodger"))'
    );
    _check(
        query => { first => [ 'Roger', 'Dodger' ], last => 'Moore' },
        expect => '((first:"Roger" OR first:"Dodger") AND last:"Moore")'
    );
    _check(
        query => [ { first => [ 'Roger', 'Dodger' ] }, { last => 'Moore' } ],
        expect => '((first:"Roger" OR first:"Dodger") OR last:"Moore")'
    );

    _check(
        query => {
            first    => [ 'Roger',     'Dodger' ],
            -default => [ 'star trek', 'star wars' ]
        },
        expect =>
            '(("star trek" OR "star wars") AND (first:"Roger" OR first:"Dodger"))'
    );
};

subtest 'Basic query with escape' => sub {
    _check( query => { -default => 'sp(a)ce' }, expect => '("sp\(a\)ce")' );
    _check(
        query  => { title => 'Spaceb(a)lls' },
        expect => '(title:"Spaceb\(a\)lls")'
    );
};

subtest 'Simple ops' => sub {
    # range (inc)
    _check(
        query  => { title => { -range => [ 'a', 'z' ] } },
        expect => '(title:[a TO z])'
    );
    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -range => [ 'a', 'z' ] }
        },
        expect => '((first:"Roger" OR first:"Dodger") AND title:[a TO z])'
    );

    # range (exc)
    _check(
        query  => { title => { -range_exc => [ 'a', 'z' ] } },
        expect => '(title:{a TO z})'
    );
    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -range_exc => [ 'a', 'z' ] }
        },
        expect => '((first:"Roger" OR first:"Dodger") AND title:{a TO z})'
    );

    # boost
    _check(
        query  => { title => { -boost => [ 'Space', '2.0' ] } },
        expect => '(title:"Space"^2.0)'
    );
    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -boost => [ 'Space', '2.0' ] }
        },
        expect => '((first:"Roger" OR first:"Dodger") AND title:"Space"^2.0)'
    );

    # proximity
    _check(
        query => { title => { -proximity => [ 'space balls', '10' ] } },
        expect => '(title:"space balls"~10)'
    );
    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -proximity => [ 'space balls', '10' ] }
        },
        expect =>
            '((first:"Roger" OR first:"Dodger") AND title:"space balls"~10)'
    );

    # fuzzy
    _check(
        query  => { title => { -fuzzy => [ 'space', '0.8' ] } },
        expect => '(title:space~0.8)'
    );
    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -fuzzy => [ 'space', '0.8' ] }
        },
        expect => '((first:"Roger" OR first:"Dodger") AND title:space~0.8)'
    );
};

subtest 'Ops with escape' => sub {
    _check(
        query => { title => { -boost => [ 'Sp(a)ce', '2.0' ] } },
        expect => '(title:"Sp\(a\)ce"^2.0)'
    );
    _check(
        query => { title => { -proximity => [ 'sp(a)ce balls', '10' ] } },
        expect => '(title:"sp\(a\)ce balls"~10)'
    );
    _check(
        query => { title => { -fuzzy => [ 'sp(a)ce', '0.8' ] } },
        expect => '(title:sp\(a\)ce~0.8)'
    );
};

subtest 'Require and prohibit' => sub {
    _check(
        query  => { title => { -require => 'star' } },
        expect => '(+title:"star")'
    );
    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -require => 'star' }
        },
        expect => '((first:"Roger" OR first:"Dodger") AND +title:"star")'
    );

    _check(
        query  => { title => { -prohibit => 'star' } },
        expect => '(-title:"star")'
    );
    _check(
        query  => { default => { -prohibit => 'foo' } },
        expect => '(-default:"foo")'
    );

    _check(
        query => {
            first => [ 'Roger', 'Dodger' ],
            title => { -prohibit => 'star' }
        },
        expect => '((first:"Roger" OR first:"Dodger") AND -title:"star")'
    );
    _check(
        query => {
            title => [ -and => { -prohibit => 'star' }, { -prohibit => 'wars' } ],
        },
        expect => '(((-title:"star") AND (-title:"wars")))'
    );
    _check(
        query => {
            first => [ 'Bob' ],
            title => [ -and => { -prohibit => 'star' }, { -prohibit => 'wars' } ],
        },
        expect => '((first:"Bob") AND ((-title:"star") AND (-title:"wars")))'
    );
};

subtest 'Nested and/or operators' => sub {
    _check(
        query => {
            title =>
                [ -and => { -require => 'star' }, { -require => 'wars' } ],
        },
        expect => q[(((+title:"star") AND (+title:"wars")))],
    );

    _check(
        query => {
            title => [
                -or => { -range_exc => [ 'a', 'c' ] },
                { -range_exc => [ 'e', 'k' ] }
            ],
        },
        expect => q[(((title:{a TO c}) OR (title:{e TO k})))],
    );
};

done_testing();

sub _check {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    my %t = @_;

    my $expect = $t{expect};
    return subtest $expect => sub {
        plan tests => 5;
        note(explain($t{query}));
        my $q = WebService::Solr::Query->new( $t{ query } );
        isa_ok( $q, 'WebService::Solr::Query' );

        # GitHub issue #22 is a bug where calling $q->stringify modified
        # the query in place, and so subsequent calls to $q->stringify
        # would blow up.  Here, we try it twice to make sure they match.
        # Then, we compare the objects before and after.

        my $before_dump = Dumper( $q );

        my @tries;
        for my $try ( 1..2 ) {
            eval {
                my $str = $q->stringify;
                is( $str, $expect, "Stringify matches on try #$try" );
                push( @tries, $str );
            } or fail( "Try #$try fails with $@" );
        }
        is( $tries[0], $tries[1], 'Both stringifies are the same' );

        my $after_dump = Dumper( $q );

        is( $after_dump, $before_dump, 'Before/after dumps of the object are the same' );
    };
}
