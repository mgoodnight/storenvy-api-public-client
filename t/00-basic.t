#!/usr/bin/env perl

use strict; use warnings;

use Test::Most;
use LWP::UserAgent;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Storenvy::API::Public::Client;

my $sub_domain = $ENV{STORENVY_SUBDOMAIN} || 'PLACEHOLDER';

use_ok('Storenvy::API::Public::Client');
require_ok('Storenvy::API::Public::Client');
dies_ok { Storenvy::API::Public::Client->new() } "Dies on missing required attributes.";

my $client = Storenvy::API::Public::Client->new(sub_domain => $sub_domain);
isa_ok($client, 'Storenvy::API::Public::Client');

foreach my $method ( map { chomp $_; $_; } <DATA> ) {
    can_ok('Storenvy::API::Public::Client', $method);
}

ok defined($client->ua), "We built our UserAgent.";
isa_ok($client->ua, 'LWP::UserAgent');

dies_ok { $client->_set_username('foobar') } "Dies when trying to modify a read-only attribute (username)";
dies_ok { $client->_set_api_url('http://mgoodnight.com') } "Dies when trying to modify a read-only attribute (api_url).";
dies_ok { $client->_set_ua(LWP::UserAgent->new()) } "Dies when trying to modify a read-only attribute (ua).";

done_testing;

__DATA__
api_url
_build_api_url
sub_domain
ua
last_query_response
last_query_error
_query
get_store_info
get_store_products
get_product
get_store_collections
get_collection
