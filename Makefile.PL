use inc::Module::Install 0.77;

if( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/WebService/Solr.pm > README' );
}

name 'WebService-Solr';
all_from 'lib/WebService/Solr.pm';

requires 'LWP::UserAgent';
requires 'URI';
requires 'XML::Generator';
requires 'Moose';

test_requires 'Test::More';

tests_recursive;

auto_install;
WriteAll;
