package CoreQueryParameters;
use strict;
use warnings;

sub new {
    my ( $class, $params ) = @_;
    my $self = { params => $params, };
    bless $self, $class;
    return $self;
}

sub get_query_type {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'qt' } ) {
        $qStr = 'qt=' . $params->{ 'qt' };
    }
    return $qStr;
}

sub get_writer_type {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'wt' } ) {
        $qStr = 'wt=' . $params->{ 'wt' };
    }
    return $qStr;
}

sub get_echo_handler {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'echoHandler' } ) {
        $qStr = 'echoHandler=' . $params->{ 'echoHandler' };
    }
    return $qStr;
}

sub get_echo_params {
    my ( $self ) = @_;
    my $params   = $self->{ params };
    my $qStr     = '';
    if ( $params->{ 'echoParams' } ) {
        $qStr = 'echoParams=' . $params->{ 'echoParams' };
    }
    return $qStr;
}
1;
