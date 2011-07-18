#!perl

use strict; use warnings;
use WWW::SearchWikipedia;
use Test::More tests => 15;

my $search = WWW::SearchWikipedia->new();
eval { $search->article() };
like($@, qr/Mandatory parameters 'lat', 'lng' missing/);

eval { $search->article(lat => 51.500688) };
like($@, qr/Mandatory parameter 'lng' missing/);

eval { $search->article(lng => -0.124411) };
like($@, qr/Mandatory parameter 'lat' missing/);

eval { $search->article(lat => 51.500688, lng => -0.124411, radius => -10) };
like($@, qr/The 'radius' parameter \(\"\-10\"\)/);

eval { $search->article(lat => 51.500688, lng => -0.124411, radius => 20001) };
like($@, qr/The 'radius' parameter \(\"20001\"\)/);

eval { $search->article(lat => 51.500688, lng => -0.124411, limit => -1) };
like($@, qr/The 'limit' parameter \(\"\-1\"\)/);

eval { $search->article(lat => 51.500688, lng => -0.124411, limit => 51) };
like($@, qr/The 'limit' parameter \(\"51\"\)/);

eval { $search->article(lat => 51.500688, lng => -0.124411, offset => 'a') };
like($@, qr/The 'offset' parameter \(\"a\"\)/);

eval { $search->article({lat => 51.500688}) };
like($@, qr/Mandatory parameter 'lng' missing/);

eval { $search->article({lng => -0.124411}) };
like($@, qr/Mandatory parameter 'lat' missing/);

eval { $search->article({lat => 51.500688, lng => -0.124411, radius => -10}) };
like($@, qr/The 'radius' parameter \(\"\-10\"\)/);

eval { $search->article({lat => 51.500688, lng => -0.124411, radius => 20001}) };
like($@, qr/The 'radius' parameter \(\"20001\"\)/);

eval { $search->article({lat => 51.500688, lng => -0.124411, limit => -1}) };
like($@, qr/The 'limit' parameter \(\"\-1\"\)/);

eval { $search->article({lat => 51.500688, lng => -0.124411, limit => 51}) };
like($@, qr/The 'limit' parameter \(\"51\"\)/);

eval { $search->article({lat => 51.500688, lng => -0.124411, offset => 'a'}) };
like($@, qr/The 'offset' parameter \(\"a\"\)/);