package WebService::Solr::Request::Ping;

use Moose;

extends 'WebService::Solr::Request';

sub handler {
    'admin/ping';
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
