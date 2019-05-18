#!/usr/bin/env perl

use strict; use warnings;

use Test::Most;
use Furl;
use FindBin qw/$Bin/;
use lib "$Bin/../lib";
use Storenvy::API::Public::Client;
use JSON qw/decode_json/;

my $sub_domain = $ENV{STORENVY_SUBDOMAIN};
SKIP: {
    skip "Missing Storenvy subdomain environment variable, so we are skipping...", 4 unless ($sub_domain);
    my $client = Storenvy::API::Public::Client->new(sub_domain => $sub_domain);

    my $details_json = $client->get_store_info;
    ok($client->last_query_response->code == 200, "Our response code is OK");
    ok(decode_json($details_json), "Successfully decoded our expected JSON content");

    my $items_json = $client->get_store_products({ page => 1, per_page => 1 });
    ok($client->last_query_response->code == 200, "Our response code is OK");
    ok(decode_json($items_json), "Successfully decoded our expected JSON content");

    SKIP: {
        $items_json = decode_json($items_json);
        skip "No items available to test with, so we are skipping...", 2 unless (scalar(@{$items_json}));

        my $item_json = $client->get_product($items_json->[0]->{id});
        ok($client->last_query_response->code == 200, "Our response code is OK");
        ok(decode_json($item_json), "Successfully decoded our expected JSON content");
    }

    my $collections_json = $client->get_store_collections({ page => 1, per_page => 1});
    ok($client->last_query_response->code == 200, "Our response code is OK");
    ok(decode_json($collections_json), "Successfully decoded our expected JSON content");

    SKIP: {
        $collections_json = decode_json($collections_json);
        skip "No collections available to test with, so we are skipping...", 2 unless (scalar(@{$collections_json->{collections}}));

        my $collection_json = $client->get_collection($collections_json->{collections}->[0]->{id});
        ok($client->last_query_response->code == 200, "Our response code is OK");
        ok(decode_json($collection_json), "Successfully decoded our expected JSON content");
    }
}

done_testing;
