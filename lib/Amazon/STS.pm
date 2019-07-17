package Amazon::STS;

use Moose;
use URI::Escape;
use Encode qw(encode);
use POSIX qw(strftime);
use Digest::SHA;
use LWP::UserAgent;
use HTTP::Request;
use HTTP::Date;
use AWS::Signature4;
use Data::Dumper;
use Amazon::STS::Response;
use Amazon::STS::Types;
use Config::AWS ':all';

our $VERSION             = "0.01";
our $URI_SAFE_CHARACTERS = '^A-Za-z0-9-_.~';    # defined by AWS.

has secretKeyId => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_secret_key',
);

has accessKeyId => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_access_key',
);

has region => (
    is        => 'rw',
    isa       => 'Str',
    required  => 0,
    predicate => 'has_region',
);

has profile => (
    is        => 'rw',
    isa       => 'Str',
    predicate => 'has_profile',
);

has ua => (
    is      => 'ro',
    isa     => 'Object',
    default => sub {
        return LWP::UserAgent->new();
    }
);

has endpoint => (
    is      => 'rw',
    isa     => 'Amazon::STS::EndpointURL',
    coerce  => 1,
    lazy    => 1,
    builder => '_build_endpoint'
);

has version => (
    is      => 'rw',
    isa     => 'Str',
    default => '2011-06-15',
);

sub signer {
    my $self = shift;
    AWS::Signature4->new(
        '-access_key' => $self->accessKeyId,
        '-secret_key' => $self->secretKeyId,
    );
}

sub _build_endpoint {
    my $self = shift;

    return sprintf( 'https://sts.%s.amazonaws.com/', $self->region )
      if $self->has_region;

    return 'https://sts.amazonaws.com/';
}

sub BUILD {
    my $self = shift;

    return $self if $self->has_access_key and $self->has_secret_key;

    if ( $self->has_profile ) {
        my $config = read( undef, $self->profile );
        $self->secretKeyId( $config->{'aws_secret_access_key'} );
        $self->accessKeyId( $config->{'aws_access_key_id'} );
        $self->region( $config->{'region'} ) if exists $config->{'region'};
    }
}

sub AUTOLOAD {
    my $self = shift;
    my %args = @_ > 1 ? @_ : ref $_[0] ? %{ $_[0] } : ();

    my $action = our $AUTOLOAD =~ s/\A.*:://smr;
    $args{'Action'} = $action;

    return $self->request( \%args );
}

sub request {
    my $self = shift;
    my $params = shift || {};

    $params->{'Version'} //= $self->version;

    my $req = HTTP::Request->new( POST => $self->endpoint->as_string );
    $req->header( host => $self->endpoint->host );

    my $now       = time;
    my $http_date = strftime( '%Y%m%dT%H%M%SZ', gmtime($now) );
    my $date      = strftime( '%Y%m%d', gmtime($now) );

    $req->protocol('HTTP/1.1');
    $req->header( 'Date' => $http_date );
    $req->header(
        'content-type' => 'application/x-www-form-urlencoded;charset=utf-8' );

    my $escaped_params = $self->_escape_params($params);
    my $payload        = join( '&',
        map { $_ . '=' . $escaped_params->{$_} } keys %{$escaped_params} );

    $req->content($payload);
    $req->header( 'Content-Length', length($payload) );

    my $digest = Digest::SHA::sha256_hex( $req->content );
    $req->header( 'X-Amz-Content-SHA256', $digest );

    $self->signer->sign( $req, 'ap-south-1', $digest );
    my $response = $self->ua->request($req);

    return Amazon::STS::Response->new( response => $response );
}

sub _escape_params {
    my ( $self, $params ) = @_;

    my $escaped_params = {%$params};
    foreach my $key ( keys %{$params} ) {
        my $octets = encode( 'utf-8-strict', $params->{$key} );
        $escaped_params->{$key} = uri_escape( $octets, $URI_SAFE_CHARACTERS );
    }
    return $escaped_params;
}

1;
__END__

=encoding utf-8

=head1 NAME

Amazon::STS - 

=head1 SYNOPSIS

    use Amazon::STS;

=head1 DESCRIPTION

Amazon::STS is ...

=head1 LICENSE

Copyright (C) Prajith Ndz.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Prajith Ndz E<lt>prajithpalakkuda@gmail.comE<gt>

=cut

