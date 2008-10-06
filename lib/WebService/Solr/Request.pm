package WebService::Solr::Request;

use Moose;

sub content_type {
    return 'text/xml; charset=utf-8';
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
