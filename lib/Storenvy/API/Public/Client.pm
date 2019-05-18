package Storenvy::API::Public::Client;

# ABSTRACT: Very simple API client module to work with the public API for Storenvy

use strict;
use warnings;

use Moo;
use Furl;
use IO::Socket::SSL qw/SSL_VERIFY_PEER/;
use URI::Escape;

has sub_domain => (
    is => 'rw',
    required => 1
);

has api_url => ( is => 'lazy' );

has ua => (
    is      => 'ro',
    builder => sub {
        return Furl->new(
            timeout  => 300,
            ssl_opts => {
                SSL_verify_mode => SSL_VERIFY_PEER()
            }
        );
    }
);

has last_query_response => (
    is => 'rwp'
);

has last_query_error => (
    is => 'rwp'
);

sub get_store_info {
    my $self = shift;
    my $url = sprintf "%s/store.json", $self->api_url;

    return $self->_query($url);
}

sub get_store_products {
    my ($self, $args) = @_;
    my $url = sprintf "%s/products.json", $self->api_url;

    return $self->_query($url, $args)
}

sub get_product {
    my ($self, $product_id) = @_;
    my $url = sprintf "%s/products/%d.json", $self->api_url, $product_id;
    
    return $self->_query($url);
}

sub get_store_collections {
    my ($self, $args) = @_;
    my $url = sprintf "%s/collections.json", $self->api_url;

    return $self->_query($url, $args);
}

sub get_collection {
    my ($self, $collection_id) = @_;
    my $url = sprintf "%s/collections/%d.json", $self->api_url, $collection_id;
    
    return $self->_query($url);
}

sub _query {
    my ($self, $url, $params) = @_;

    if (keys %$params) {
        $url .= '?';
        $url .= join('&', map {
            "$_=" . URI::Escape::uri_escape_utf8($params->{$_})
        } sort keys %$params);
    }

    my $response = $self->ua->get($url);
    $self->_set_last_query_response($response);
    
    my $content_decoded = $response->decoded_content;
    $self->_set_last_query_error($content_decoded) if !$response->is_success;
    
    return $content_decoded;
}

sub _build_api_url {
    return sprintf "http://%s.storenvy.com", $_[0]->sub_domain;
}

=head1 NAME

    Storenvy v0 Public JSON API Client 

=head1 SYNOPSIS

    use Storenvy::API::Public::Client;

    my $client = Storenvy::API::Public::Client->new({
        sub_domain  => 'my_store'
    });

    my $products = $client->get_store_products;

=head1 DESCRIPTION

    Client module to interface with the public JSON API from Storenvy.

=head2 METHODS

=over

=item C<get_store_info>

    Request a store's details

=item C<get_store_products>

    Request a store's list of products

=item C<get_product>

    Return a specific product

=item C<get_store_collections>

    Return a store's list of collections

=item C<get_collection>

    Return a specific collection

=back

=cut

1;
