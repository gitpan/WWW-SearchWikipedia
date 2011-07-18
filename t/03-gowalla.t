#!perl

use strict; use warnings;
use WWW::SearchWikipedia;
use Test::More tests => 5;

my $search = WWW::SearchWikipedia->new();
eval { $search->gowalla() };
like($@, qr/Mandatory parameter 'id' missing/);

eval { $search->gowalla(id => 'abc') };
like($@, qr/The \'id\' parameter \(\"abc\"\)/);

eval { $search->gowalla(id => 123456, exact => 'fallse') };
like($@, qr/The \'exact\' parameter \(\"fallse\"\)/);

eval { $search->gowalla({id => 'abc'}) };
like($@, qr/The \'id\' parameter \(\"abc\"\)/);

eval { $search->gowalla({id => 123456, exact => 'fallse'}) };
like($@, qr/The \'exact\' parameter \(\"fallse\"\)/);