package WebService::Solr::Response::Optimize;

use Moose;

extends 'WebService::Solr::Response::Commit';

no Moose;

__PACKAGE__->meta->make_immutable;

1;
