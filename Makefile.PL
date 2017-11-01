package main;

require 5.008;

use strict;
use warnings;
use ExtUtils::MakeMaker;

my %parms = (
    NAME                => 'WebService::Solr',
    AUTHOR              => 'Andy Lester <andy@petdance.com>',
    ABSTRACT            => 'Interface to the Solr search engine',
    VERSION_FROM        => 'lib/WebService/Solr.pm',
    LICENSE             => 'perl_5',
    MIN_PERL_VERSION    => 5.008,
    META_MERGE          => {
        resources => {
            homepage    => 'https://github.com/petdance/webservice-solr',
            bugtracker  => 'https://github.com/petdance/webservice-solr/issues',
            repository  => 'git@github.com:petdance/webservice-solr.git',
        },
    },

    PREREQ_PM => {
        'Data::Page'      => 0,
        'Data::Pageset'   => 0,
        'Encode'          => 0,
        'JSON::XS'        => 0,
        'LWP::UserAgent'  => 0,
        'Moo'             => 0,
        'Types::Standard' => '0.008', # InstanceOf type constraint
        'URI'             => '1.28',
        'XML::Easy'       => 0,

        # Testing requirements
        'Test::Mock::LWP' => '0.05',
        'Test::More'      => '0.94', # want note(), explain(), subtest() and done_testing()
        'XML::Simple'     => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);

WriteMakefile( %parms );
