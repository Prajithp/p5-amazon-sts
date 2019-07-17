use Data::Dumper;

my $sts = Amazon::STS->new( profile => 'preprod' );

# my $policy ='{"Version": "2012-10-17", "Statement": [{"Effect": "Allow","Action": "*","Resource": "*"}]}';
# my %params = (
#     Name   => 'Prajith',
#     Policy => $policy,
#     DurationSeconds => 1800,
# );

my $p = {
    DurationSeconds => 3600,
    ProviderId      => 'www.amazon.com',
    RoleArn => 'arn:aws:iam::123456789012:role/FederatedWebIdentityRole',
    RoleSessionName => 'app1',
    WebIdentityToken =>
'Atza%7CIQEBLjAsAhRFiXuWpUXuRvQ9PZL3GMFcYevydwIUFAHZwXZXXXXXXXXJnrulxKDHwy87oGKPznh0D6bEQZTSCzyoCtL_8S07pLpr0zMbn6w1lfVZKNTBdDansFBmtGnIsIapjI6xKR02Yc_2bQ8LZbUXSGm6Ry6_BG7PrtLZtj_dfCTj92xNGed-CrKqjG7nPBjNIL016GGvuS5gSvPRUxWES3VYfm1wl7WTI7jn-Pcb6M-buCgHhFOzTQxod27L9CqnOLio7N3gZAGpsp6n1-AJBOCJckcyXe2c6uD0srOJeZlKUm2eTDVMf8IehDVI0r1QOnTV6KzzAI3OY87Vd_cVMQ',
};

my $response = $sts->AssumeRoleWithSAML($p);
print Dumper $response->as_hashref;

