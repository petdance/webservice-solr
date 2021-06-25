#!perl
use strict;
use warnings;
use WebService::Solr;
use JSON::XS ();
use JSON::PP (); # for is_bool()
use Getopt::Long;

my $verbose;
my $server = $ENV{SOLR_SERVER};
my $donothing;

GetOptions("v" => \$verbose,
           "n" => \$donothing,
           "s=s" => \$server,
           "h|help" => \&usage);

my $schemaname = shift
  or die "No schemafile.xml provided\n";

open my $sf, "<:raw", $schemaname
  or die "Cannot open $schemaname: $!\n";
my $schemajson = do { local $/; <$sf> };
close $sf;

my $j = JSON::XS->new;
my $newschema = $j->decode($schemajson);

my $ws = WebService::Solr->new($server)
  or die;

$ws->ping
  or die "Cannot contact Solr server\n";

++$|;
print "Fetching schema\n" if $verbose;
my $oldschema = $ws->schema
  or die "Cannot fetch schema\n";

my @add_types;
my @replace_types;
my @delete_types;
my %oldtypes = map { $_->{name} => $_ } @{$oldschema->{fieldTypes}};
for my $type (@{$newschema->{fieldTypes}}) {
    my $old = delete $oldtypes{$type->{name}};
    if ($old) {
        unless ( eq_deeply($old, $type) ) {
            push @replace_types, $type;
            print "Replacing type $type->{name}\n" if $verbose;
        }
    }
    else {
        push @add_types, $type;
        print "Adding type $type->{type}\n" if $verbose;
    }
}
push @delete_types, map { $_->{name} } values %oldtypes;
print "Deleting types @delete_types\n" if $verbose && @delete_types;

my @add_fields;
my @replace_fields;
my @delete_fields;
my %oldfields = map { $_->{name} => $_ } @{$oldschema->{fields}};
for my $field (@{$newschema->{fields}}) {
    my $old = delete $oldfields{$field->{name}};
    if ($old) {
        unless ( eq_deeply($old, $field) ) {
            push @replace_fields, $field;
            print "Replacing field $field->{name}\n" if $verbose;
        }
    }
    else {
        push @add_fields, $field;
        print "Adding field $field->{name}\n" if $verbose;
    }
}
push @delete_fields, map { $_->{name} } values %oldfields;
print "Deleting fields @delete_fields\n" if $verbose && @delete_fields;

my @add_dynamics;
my @replace_dynamics;
my @delete_dynamics;
my %olddynamic = map { $_->{name} => $_ } @{$oldschema->{dynamicFields}};
for my $dynamic (@{$newschema->{dynamicFields}}) {
    my $old = delete $olddynamic{$dynamic->{name}};
    if ($old) {
        unless ( eq_deeply($old, $dynamic) ) {
            push @replace_dynamics, $dynamic;
            print "Replacing dynamic field $dynamic->{name}\n" if $verbose;
        }
    }
    else {
        push @add_dynamics, $dynamic;
        print "Adding dynamic field $dynamic->{name}\n" if $verbose;
    }
}
push @delete_dynamics, map { $_->{name} } values %olddynamic;
print "Deleting dynamic fields @delete_dynamics\n" if $verbose && @delete_dynamics;

my @add_copy;
my @delete_copy;
my %oldcopy = map {; "$_->{source}\0$_->{dest}" => $_ } @{$oldschema->{copyFields}};
for my $copy (@{$newschema->{copyFields}}) {
    my $old = delete $oldcopy{"$copy->{source}\0$copy->{dest}"};
    if ($old) {
        unless ( eq_deeply($old, $copy) ) {
            push @delete_copy, +{ source => $copy->{source}, dest => $copy->{dest} };
            push @add_copy, $copy;
            print "Replacing copy $copy->{source} => $copy->{dest}\n" if $verbose;
        }
    }
    else {
        push @add_copy, $copy;
        print "Adding copy $copy->{source} => $copy->{dest}\n" if $verbose;
    }
}
# don't report replacements as deletions
my @temp = map {; +{ source => $_->{source}, dest => $_->{dest} } } values %oldcopy;
push @delete_copy, @temp;
if ($verbose && @temp) {
    print "Deleting copy $_->{source} => $_->{dest}\n"
      for values @temp;
}

if ($donothing) {
    print "But doing nothing as requested\n";
}
else {
    my @req;
    push @req, delete_copy => \@delete_copy
      if @delete_copy;
    push @req, add_type => \@add_types
      if @add_types;
    push @req, replace_type => @replace_types
      if @replace_types;
    push @req, add_field => \@add_fields
      if @add_fields;
    push @req, replace_field => \@replace_fields
      if @replace_fields;
    push @req, delete_field => \@delete_fields
      if @delete_fields;
    push @req, add_dynamic => \@add_dynamics
      if @add_dynamics;
    push @req, replace_dynamic => \@replace_dynamics
      if @replace_dynamics;
    push @req, delete_dynamic => \@delete_dynamics
      if @delete_dynamics;
    push @req, add_copy => \@add_copy
      if @add_copy;
    push @req, delete_type => \@delete_types
      if @delete_types;
    if (@req) {
        my $res = $ws->edit_schema(\@req);
        unless ($res) {
            print STDERR "** Failed to edit schema:\n\n";
            my $details = $ws->last_response->content->{error}{details};
            for my $inst (@$details) {
                my ($key) = grep !/^errorMessages$/, keys %$inst;
                my $what;
                if ($key =~ /copy/) {
                    $what = "$key $inst->{$key}{source} -> $inst->{$key}{dest}";
                }
                else {
                    $what = "$key $inst->{$key}{name}";
                }
                for my $msg (@{$inst->{errorMessages}}) {
                    # some messages include the newline, some don't
                    $msg =~ s/\n\z//;
                    print STDERR "$what:\n  $msg\n";
                }
            }
            use Data::Dumper;
            #die Dumper($ws->last_response->content);
            exit 1;
        }
    }
    else {
        print "Nothing to do, the schema matches\n";
    }
}

sub usage {
    print <<'EOS';
Usage: deploy_schema.pl [options] schemafile.json
Options:

  -v   Report everything you do.
  -n   Work out what to do, but don't do it.
  -s url
       Base url for the Solr server (defaults to $SOLR_SERVER
  -h   Display this help.
EOS
    exit;
}

# trying to avoid a dep not needed for the module itself here
sub eq_deeply {
    my ($l, $r) = @_;

    if (ref $l) {
        if (ref $r) {
            if (ref $l ne ref $r) {
                return 0;
            }
            if (ref $l eq 'ARRAY') {
                return 0 if @$l != @$r;
                for my $i (0 .. $#$l) {
                    eq_deeply($l->[$i], $r->[$i])
                      or return;
                }
                return 1;
            }
            elsif (ref $l eq 'HASH') {
                return 0 if keys %$l != keys %$r;
                my %keycheck = map { $_ => 1 } keys %$l;
                delete @keycheck{keys %$r};
                return 0 if keys %keycheck;
                for my $key (keys %$l) {
                    eq_deeply($l->{$key}, $r->{$key})
                      or return 0;
                }
                return 1;
            }
            elsif (JSON::PP::is_bool($l)) {
                return $l+0 == $r+0;
            }
            else {
                die "Unexpected reference type ".ref($l)."\n";
            }
        }
        else {
            return 0;
        }
    }
    elsif (ref $r) {
        # one's ref while the other isn't
        return 0;
    }
    else {
        return $l eq $r;
    }
}
