#!perl

use strict; use warnings;
use WWW::SearchWikipedia;
use Test::More tests => 6;

my ($search);

eval { $search = WWW::SearchWikipedia->new(locale => 'enn'); };
like($@, qr/Attribute \(locale\) does not pass the type constraint/);

eval { $search = WWW::SearchWikipedia->new(format => 'jsson'); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $search = WWW::SearchWikipedia->new(debug => 'fallse'); };
like($@, qr/Attribute \(debug\) does not pass the type constraint/);

eval { $search = WWW::SearchWikipedia->new({locale => 'enn'}); };
like($@, qr/Attribute \(locale\) does not pass the type constraint/);

eval { $search = WWW::SearchWikipedia->new({format => 'jsson'}); };
like($@, qr/Attribute \(format\) does not pass the type constraint/);

eval { $search = WWW::SearchWikipedia->new({debug => 'fallse'}); };
like($@, qr/Attribute \(debug\) does not pass the type constraint/);