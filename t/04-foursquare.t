#!perl

use strict; use warnings;
use WWW::SearchWikipedia;
use Test::More tests => 7;

my $search = WWW::SearchWikipedia->new();
eval { $search->foursquare() };
like($@, qr/Mandatory parameter 'id' missing/);

eval { $search->foursquare(id => 123456, radius => -10) };
like($@, qr/The 'radius' parameter \(\"\-10\"\)/);

eval { $search->foursquare(id => 123456, radius => 20001) };
like($@, qr/The 'radius' parameter \(\"20001\"\)/);

eval { $search->foursquare(id => 123456, exact => 'fallse') };
like($@, qr/The \'exact\' parameter \(\"fallse\"\)/);

eval { $search->foursquare({id => 123456, radius => -10}) };
like($@, qr/The 'radius' parameter \(\"\-10\"\)/);

eval { $search->foursquare({id => 123456, radius => 20001}) };
like($@, qr/The 'radius' parameter \(\"20001\"\)/);

eval { $search->foursquare({id => 123456, exact => 'fallse'}) };
like($@, qr/The \'exact\' parameter \(\"fallse\"\)/);