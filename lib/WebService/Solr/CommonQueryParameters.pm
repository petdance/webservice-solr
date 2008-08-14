package WebService::Solr::CommonQueryParameters;
use strict;
use warnings;

sub new {
    my ( $class, $params ) = @_;
    my $self = { params => $params, };
    bless $self, $class;
    return $self;
}

sub get_sort {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'sort' } ) {
        $qStr = 'sort=' . $params->{ 'sort' };
    }
    return $qStr;
}

sub get_start {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'start' } ) {
        $qStr = 'start=' . $params->{ 'start' };
    }
    return $qStr;
}

sub get_rows {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'rows' } ) {
        $qStr = 'rows=' . $params->{ 'rows' };
    }
    return $qStr;
}

sub get_field_query {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'fq' } ) {
        $qStr = 'fq=' . $params->{ 'fq' };
    }
    return $qStr;
}

sub get_field_list {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'fl' } ) {
        $qStr = 'fl=' . $params->{ 'fl' };
    }
    return $qStr;
}

sub get_debug_query {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'debugQuery' } ) {
        $qStr = $params->{ 'debugQuery' };
    }
    return $qStr;
}

sub get_explain_other {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'explainOther' } ) {
        $qStr = 'explainOther=' . $params->{ 'explainOther' };
    }
    return $qStr;
}
1;
