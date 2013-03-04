use inc::Module::Install 1.06;

perl_version '5.008';

name 'WebService-Solr';
all_from 'lib/WebService/Solr.pm';

requires 'LWP::UserAgent';
requires 'URI' => '1.28';
requires 'Data::Page';
requires 'Data::Pageset';
requires 'XML::Easy';
requires 'JSON::XS';
requires 'Any::Moose' => '0.16'; # 0.16 doesn't force Mouse dep
requires 'Encode';

test_requires 'Test::More' => '0.94', # want note(), explain(), subtest() and done_testing()

test_requires 'XML::Simple';
test_requires 'Test::Mock::LWP' => '0.05';

tests_recursive;

repository 'http://github.com/bricas/webservice-solr';

WriteAll;
