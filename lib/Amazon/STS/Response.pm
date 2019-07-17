package Amazon::STS::Response;

use strict;
use Moose;
use XML::Simple;

has response => (
    is       => 'ro',
    required => 1,
);
has _response_href => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    my $xml_decoded = XMLin( $self->content, KeepRoot => 0 );
    $self->_response_href($xml_decoded);
}

sub content {
    return shift->response->decoded_content;
}

sub as_hashref {
    return shift->_response_href;
}

sub is_success {
    return shift->response->is_success;
}

1;
