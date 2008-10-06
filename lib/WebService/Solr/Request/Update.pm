package WebService::Solr::Request::Update;

use Moose;

extends 'WebService::Solr::Request';

sub handler {
    'update';
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
