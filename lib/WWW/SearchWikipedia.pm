package WWW::SearchWikipedia;

use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use namespace::clean;

use Carp;
use Data::Dumper;

use Readonly;
use HTTP::Request;
use LWP::UserAgent;

=head1 NAME

WWW::SearchWikipedia - Interface to Search Wikipedia API.

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';
Readonly my $BASE_URL => 'http://api.wikilocation.org/';
Readonly my $LOCALE   => 
{
    'ar'  => 1,
    'bg'  => 1,
    'ca'  => 1,
    'cs'  => 1,
    'da'  => 1,
    'de'  => 1,
    'en'  => 1,
    'eo'  => 1,
    'es'  => 1,
    'fa'  => 1,
    'fi'  => 1,
    'fr'  => 1,
    'he'  => 1,
    'hu'  => 1,
    'id'  => 1,
    'it'  => 1,
    'ja'  => 1,
    'ko'  => 1,
    'lt'  => 1,
    'ms'  => 1,
    'nl'  => 1,
    'no'  => 1,
    'pl'  => 1,
    'pt'  => 1,
    'ro'  => 1,
    'ru'  => 1,
    'sk'  => 1,
    'sl'  => 1,
    'sr'  => 1,
    'sv'  => 1,
    'tr'  => 1,
    'uk'  => 1,
    'vi'  => 1,
    'vo'  => 1,
    'war' => 1,
    'zh'  => 1,
};

=head1 DESCRIPTION

A very lightweight wrapper for the Search Wikipedia REST API provided by wikilocation.org.

=cut

type 'DecimalDegreeFormat' => where { defined($_) && (/^\-?\d+\.?\d+$/) };
type 'Limit'   => where { defined($_) && (/^\d*$/) && ($_ <= 50) };
type 'Radius'  => where { defined($_) && (/^\d+\.?\d+$/) && ($_ <= 20000) };
type 'Locale'  => where { defined($_) && exists($LOCALE->{lc($_)}) };
type 'Format'  => where { defined($_) && (/\bxml\b|\bjson\b/i) };
type 'Boolean' => where { defined($_) && (/\btrue\b|\bfalse\b/i) };

has  'locale'  => (is => 'ro', isa => 'Locale',  default => 'en');
has  'format'  => (is => 'ro', isa => 'Format',  default => 'json');
has  'debug'   => (is => 'ro', isa => 'Boolean', default => 'false');
has  'browser' => (is => 'ro', isa => 'LWP::UserAgent', default => sub { return LWP::UserAgent->new(agent => 'Mozilla/5.0'); });

=head1 CONSTRUCTOR

    +--------+----------+--------------------------------------------------------------------+
    | Key    | Required | Description                                                        |
    +--------+----------+--------------------------------------------------------------------+
    | locale |    No    | Use this parameter in order to search for article from a different | 
    |        |          | wikipedia.org locale. Default is 'en'.                             | 
    | format |    No    | The desired output format, either 'json' / 'xml'. Default is json. |
    | debug  |    No    | If set to true then it will suppress the application/x-json header |
    |        |          | on any returned json stream. Default is false.                     |
    +--------+----------+--------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::SearchWikipedia;
    
    my ($search);
    
    $search = WWW::SearchWikipedia->new();
    # or
    $search = WWW::SearchWikipedia->new(locale => 'en', format => 'xml', debug => 'true');
    # or
    $search = WWW::SearchWikipedia->new(locale => 'en');
    # or
    $search = WWW::SearchWikipedia->new({locale => 'en', format => 'xml', debug => 'true'});
    # or
    $search = WWW::SearchWikipedia->new({locale => 'en'});

=head1 LOCALES    

Supported locales listed here with articles count:

    +---------------------+
    | Locale | Articles   |
    +--------+------------+
    |   ar   | 6,478      |
    |   bg   | 18,281     |
    |   ca   | 130,711    |
    |   cs   | 7          |
    |   da   | 54,053     |
    |   de   | 354,629    |
    |   en   | 1,116,511  |
    |   eo   | 46,399     |
    |   es   | 197,825    |
    |   fa   | 18,845     |
    |   fi   | 16,865     |
    |   fr   | 299,472    |
    |   he   | 1          |
    |   hu   | 26,403     |
    |   id   | 17,003     |
    |   it   | 152,168    |
    |   ja   | 64,246     |
    |   ko   | 8,691      |
    |   lt   | 33,706     |
    |   ms   | 24,877     |
    |   nl   | 456,858    |
    |   no   | 44,028     |
    |   pl   | 173,171    |
    |   pt   | 142,149    |
    |   ro   | 23,603     |
    |   ru   | 196,198    |
    |   sk   | 5,664      |
    |   sl   | 9,825      |
    |   sr   | 53,245     |
    |   sv   | 33,738     |
    |   tr   | 9,867      |
    |   uk   | 103,305    |
    |   vi   | 72,188     |
    |   vo   | 94,470     |
    |   war  | 99         |
    |   zh   | 20,412     |
    +--------+------------+

=head1 METHODS

=head2 article()

Find nearby Wikipedia articles based on a specific latitude and longitude.

    +--------+----------+--------------------------------------------------------------------+
    | Key    | Required | Description                                                        | 
    +--------+----------+--------------------------------------------------------------------+
    | lat    |    Yes   | Latitude in decimal degree format.                                 |
    | lng    |    Yes   | Longitude in decimal degree format.                                |
    | radius |    No    | The radius (in metres) to search within. There is a maximum radius | 
    |        |          | of 20km and it will default to 250m if no radius is supplied.      |
    | limit  |    No    | The number of results you want to return. There is a maximum limit | 
    |        |          | of 50 results although you can paginate. This will default to 50   |
    |        |          | if no lower figure is sent.                                        |
    | offset |    No    | The offset from the first result returned. There is no maximum for |
    |        |          | this parameter. The default is 0.                                  | 
    | type   |    No    | The type of article you are interested in.There are various options| 
    |        |          | for this so best to look at some results and then filter from there| 
    |        |          | (you could filter by a type of "river" or "landmark"). The default |
    |        |          | is no filter.                                                      |
    +--------+----------+--------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::SearchWikipedia;
    
    my $search = WWW::SearchWikipedia->new();
    print $search->article({lat => 51.500688, lng => -0.124411, limit => 1}) . "\n";

=cut

sub article
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'lat'    => { isa => 'DecimalDegreeFormat',  required => 1 },
                'lng'    => { isa => 'DecimalDegreeFormat',  required => 1 },
                'radius' => { isa => 'Radius', default => 250   },
                'limit'  => { isa => 'Limit',  default => 50    },
                'offset' => { isa => 'Num',    default => 0     },
                'type'   => { isa => 'Str',    default => undef },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);
                
    my $url = sprintf("%s/articles?lat=%s&lng=%s&radius=%s&limit=%s&offset=%s&format=%s&locale=%s&debug=%s", 
        $BASE_URL, $param{lat}, $param{lng}, $param{radius}, $param{limit}, $param{offset}, 
        $self->{format}, $self->{locale}, $self->{debug});
    return $self->_process($url);        
}

=head2 gowalla()

Find Wikipedia articles  based  on a Gowalla spot ID. The spot ID can be found by going to the
spot on the Gowalla website ( e.g. http://gowalla.com/spots/22087 ) and then taking the digits
from the end of the URL (in this case "22087").
This method will return not  only an "articles" array (which lists the Wikipedia entries along 
with their distance  from the  Gowalla spot) but also a "spot" array giving some basic details 
from Gowalla such as lat/lng, name, and the radius.

    +-------+----------+---------------------------------------------------------------------+
    | Key   | Required | Description                                                         | 
    +-------+----------+---------------------------------------------------------------------+
    | id    |   Yes    | The Gowalla spot ID.                                                |
    | exact |   No     | Defaults to false. If set to true it will only return articles with | 
    |       |          | the exact same name as the Gowalla spot.                            | 
    +-------+----------+---------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::SearchWikipedia;
    
    my $search = WWW::SearchWikipedia->new();
    print $search->gowalla(id => 22087) . "\n";

=cut

sub gowalla
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'id'    => { isa => 'Num',     required => 1       },
                'exact' => { isa => 'Boolean', default  => 'false' },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);
                
    my $url = sprintf("%s/gowalla/%d?exact=%s&format=%s&locale=%s&debug=%s", 
        $BASE_URL, $param{id}, $param{exact},
        $self->{format}, $self->{locale}, $self->{debug});
    return $self->_process($url);        
}

=head2 foursquare()

Find Wikipedia articles based on a  Foursquare venue ID. The venue ID can be found by going to
the spot on the Foursquare website ( e.g. http://foursquare.com/venue/141395 ) and then taking
the digits from the end of the URL (in this case "141395").
This method will return not only an "articles" array ( which lists the Wikipedia entries along 
with their distance from the Foursquare venue )  but  also  a "venue"  array giving some basic 
details from Foursquare such as lat/lng and name.The radius will be either the default of 250m 
or the radius you defined as a parameter.

    +--------+----------+--------------------------------------------------------------------+
    | Key    | Required | Description                                                        |
    +--------+----------+--------------------------------------------------------------------+
    | id     |   Yes    | The Foursquare venue ID.                                           |
    | radius |   No     | The radius (in metres) to search within. There is a maximum radius |
    |        |          | of 5km and it will default to 250m if no radius is supplied.       |
    | exact  |   No     | Defaults to false. If set to true it will only return articles with|
    |        |          | the exact same name as the Foursquare venue.                       |
    +--------+----------+--------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::SearchWikipedia;
    
    my $search = WWW::SearchWikipedia->new();
    print $search->foursquare(id => 141395) . "\n";

=cut

sub foursquare
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'id'     => { isa => 'Num',     required => 1       },
                'radius' => { isa => 'Radius',  default  => 250     },
                'exact'  => { isa => 'Boolean', default  => 'false' },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);
                
    my $url = sprintf("%s/foursquare/%d?exact=%s&radius=%s&format=%s&locale=%s&debug=%s", 
        $BASE_URL, $param{id}, $param{exact}, $param{radius}, 
        $self->{format}, $self->{locale}, $self->{debug});
    return $self->_process($url);        
}

=head2 woeid()

Find Wikipedia articles based on a Yahoo! WOEID.A WOEID is a unique, non-repetitive identifier
for any geolocational object from a famous landmark to a continent.
This method will return not only an "articles" array ( which lists the Wikipedia entries along 
with their distance from the "centroid" ) but  also  a "woeid" array giving some basic details 
from Yahoo! such as lat/lng & name.The radius will be either the default of 250m or the radius
you defined as a parameter.

    +--------+----------+--------------------------------------------------------------------+
    | Key    | Required | Description                                                        |
    +--------+----------+--------------------------------------------------------------------+
    | id     |   Yes    | The Yahoo! WOEID.                                                  |
    | radius |   No     | The radius (in metres) to search within. There is a maximum radius |
    |        |          | of 5km and it will default to 250m if no radius is supplied.       |
    | exact  |   No     | Defaults to false. If set to true it will only return articles with|
    |        |          | the exact same name as the WOEID name.                             |
    +--------+----------+--------------------------------------------------------------------+

    use strict; use warnings;
    use WWW::SearchWikipedia;
    
    my $search = WWW::SearchWikipedia->new();
    print $search->woeid(id => 22474116) . "\n";

=cut

sub woeid
{
    my $self  = shift;
    my %param = validated_hash(\@_,
                'id'     => { isa => 'Num',     required => 1       },
                'radius' => { isa => 'Radius',  default  => 250     },
                'exact'  => { isa => 'Boolean', default  => 'false' },
                MX_PARAMS_VALIDATE_NO_CACHE => 1);

    my $url = sprintf("%s/woeid/%d?exact=%s&radius=%s&format=%s&locale=%s&debug=%s", 
        $BASE_URL, $param{id}, $param{exact}, $param{radius}, 
        $self->{format}, $self->{locale}, $self->{debug});
    return $self->_process($url);        
}

sub _process
{
    my $self = shift;
    my $url  = shift;
    
    my ($browser, $request, $response, $content);
    $browser = $self->browser;
    $browser->env_proxy;
    $request  = HTTP::Request->new(GET => $url);
    $response = $browser->request($request);
    croak("ERROR: Couldn't fetch data [$url]:[".$response->status_line."]\n")
        unless $response->is_success;
    $content  = $response->content;
    croak("ERROR: No data found.\n") unless defined $content;
    return $content;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any  bugs  or  feature requests to C<bug-www-searchwikipedia at rt.cpan.org>, or
through the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WWW-SearchWikipedia>.
I will be notified and then you'll automatically be notified of progress on your bug as I make
changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WWW::SearchWikipedia

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WWW-SearchWikipedia>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WWW-SearchWikipedia>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WWW-SearchWikipedia>

=item * Search CPAN

L<http://search.cpan.org/dist/WWW-SearchWikipedia/>

=back

=head1 ACKNOWLEDGEMENT

Ben Dodson (author of WikiLocation REST API).

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Moose; # Keywords are removed from the WWW::SearchWikipedia package
no Moose::Util::TypeConstraints;

1; # End of WWW::SearchWikipedia