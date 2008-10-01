package WebService::Solr::Field;

use Moose;

has 'name' => ( is => 'rw', isa => 'Str' );

has 'value' => ( is => 'rw', isa => 'Str' );

has 'boost' => ( is => 'rw', isa => 'Maybe[Num]' );

require XML::Generator;

sub BUILDARGS {
    my ( $self, $name, $value, $opts ) = @_;
    $opts ||= {};

    return { name => $name, value => $value, %$opts };
}

sub to_xml {
    my $self = shift;
    my $gen  = XML::Generator->new( ':std' );
    my %attr = ( $self->boost ? ( boost => $self->boost ) : () );

    return $gen->field( { name => $self->name, %attr }, $self->value );
}

no Moose;

__PACKAGE__->meta->make_immutable;

1;
