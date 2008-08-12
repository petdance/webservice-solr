use inc::Module::Install 0.77;

if( -e 'MANIFEST.SKIP' ) {
    system( 'pod2text lib/WebService/Solr.pm > README' );
}

name 'WebService-Solr';
all_from 'lib/WebService/Solr.pm';

requires 'XML::Generator';
requires 'LWP::UserAgent';

test_requires 'Test::More';

auto_install;
WriteAll;
