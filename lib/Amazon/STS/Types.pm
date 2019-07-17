package Amazon::STS::Types;

use Moose::Util::TypeConstraints;
use URI;

subtype 'Amazon::STS::EndpointURL',
    as 'URI';

coerce 'Amazon::STS::EndpointURL',
    from 'Str',
    via { URI->new($_); };
1;