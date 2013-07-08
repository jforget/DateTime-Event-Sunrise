use strict;
use POSIX qw(floor ceil);
use Test::More;
use DateTime;
use DateTime::Duration;
use DateTime::Span;
use DateTime::SpanSet;
use DateTime::Event::Sunrise;

BEGIN { plan tests => 254 }
my $dt = DateTime->new( year   => 2000,
		 month  => 6,
		 day    => 20,
                 time_zone => 'America/Los_Angeles',
                  );
my $dt2 = DateTime->new( year   => 2000,
		 month  => 6,
		 day    => 22,
                 time_zone => 'America/Los_Angeles',
                  );

my $sunrise = DateTime::Event::Sunrise ->sunrise(
                     longitude =>'-118' ,
		     latitude => '33',
                     
);
my $sunset = DateTime::Event::Sunrise ->sunset(
                     longitude =>'-118' ,
		     latitude => '33',
                     );



my $tmp_rise = $sunrise->current($dt);
my $tmp_set  = $sunset->current($dt);

is ($tmp_rise->datetime, '2000-06-19T05:41:56', 'current sunrise');
is ($tmp_set->datetime,  '2000-06-19T20:04:33', 'current sunset');

is ( $sunrise->current( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T05:41:56', 'current sunrise unchanged');
is ( $sunset->current( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T20:04:33', 'current sunset unchanged');

is ( $sunrise->next( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T05:42:07', 'next sunrise');
is ( $sunset->next( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T20:04:49', 'next sunset');

is ( $sunrise->previous( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T05:41:46', 'previous sunrise');
is ( $sunset->previous( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T20:04:16', 'previous sunset');

is ( $sunrise->contains( $tmp_rise ), 
     1, 'is sunrise');
is ( $sunset->contains( $tmp_set ), 
     1, 'is sunset');

is ( $sunrise->contains( $dt ), 
     0, 'is not sunrise');
is ( $sunset->contains( $dt ), 
     0, 'is not sunset');

# I need to check this test, Flavio has changed this as of ver 0.14 od spanset

#my $dt_span = DateTime::Span->new( start =>$dt, end=>$dt2 );
#my $set = $sunrise->intersection($dt_span);
#my $iter = $set->iterator;
#my @res;
#for (0..1) {
#        my $tmp = $iter->next;
#        push @res, $tmp->datetime if defined $tmp;
#}
#my $res = join( ' ', @res );
#ok( $res eq '2000-06-19T05:43:43 2000-06-20T05:43:43');

my $sun = DateTime::Event::Sunrise ->new(
                     longitude =>'-118' ,
		     latitude => '33',
);

my $tmp_set1 = $sun->sunrise_sunset_span($dt);
$tmp_set->set_time_zone('America/Los_Angeles');
ok( $tmp_set1->start->datetime eq '2000-06-20T05:42:07');
ok( $tmp_set1->end->datetime eq '2000-06-20T20:04:49');

use vars qw($long $lat $offset);

my $dt3 = DateTime->new(
  year  => 2003,
  month => 6,
  day   => 21,
);

while (<DATA>) {
/(\w+),\s+(\w+)\s+(\d+)\s+(\d+)\s+(\w)\s+(\d+)\s+(\d+)\s+(\w)\s+sunrise:\s+(\d+:\d+)\s+sunset:\s+(\d+:\d+)/;
    if ( $5 eq 'N' ) {
        $lat = sprintf( "%.3f", ( $3 + ( $4 / 60 ) ) );

    }
    elsif ( $5 eq 'S' ) {
        $lat = sprintf( "%.3f", -( $3 + ( $4 / 60 ) ) );

    }

    if ( $8 eq 'E' ) {
        $long = sprintf( "%.3f", $6 + ( $7 / 60 ) );

    }
    elsif ( $8 eq 'W' ) {
        $long = sprintf( "%.3f", -( $6 + ( $7 / 60 ) ) );

    }

    if ( $long < 0 ) {
        $offset =
          DateTime::TimeZone::offset_as_string( ceil( ( $long / 15 ) ) * 60 *
          60 );
    }
    elsif ( $long > 0 ) {
        $offset =
          DateTime::TimeZone::offset_as_string( floor( ( $long / 15 ) ) * 60 *
          60 );
    }

    my $sunrise = DateTime::Event::Sunrise->sunrise(
      longitude => $long,
      latitude  => $lat,
    );
    my $sunset = DateTime::Event::Sunrise->sunset(
      longitude => $long,
      latitude  => $lat,
    );

    my $cloned_date = $dt3->clone();
    $cloned_date->set_time_zone($offset);

    my $tmp_rise = round_to_min( $sunrise->current($cloned_date) );
    my $tmp_set  = round_to_min( $sunset->current($cloned_date) );
    

    my $sun_rise = $tmp_rise->strftime("%H:%M");
    my $sun_set  = $tmp_set->strftime("%H:%M");

    is( $sun_rise, $9,  "Sunrise for $1, $2" );
    is( $sun_set,  $10, "Sunset for $1, $2" );

}

sub round_to_min {
    my ($tmp_date) = @_;

    if ( $tmp_date->second < '30' ) {
        return ( $tmp_date->truncate( to => 'minute' ) );
    }
    elsif ( $tmp_date->second => '30' ) {
        my $d = DateTime::Duration->new(
          minutes => '1',
        );
        my $new_date = $tmp_date + $d;
        return ( $new_date->truncate( to => 'minute' ) );
    }

}

__DATA__
Aberdeen, Scotland 57 9 N 2 9 W sunrise: 03:09 sunset: 21:11
Adelaide, Australia 34 55 S 138 36 E sunrise: 06:51 sunset: 16:42
Algiers, Algeria 36 50 N 3 0 E sunrise: 04:27 sunset: 19:11
Amsterdam, Netherlands 52 22 N 4 53 E sunrise: 03:15 sunset: 20:08
Ankara, Turkey 39 55 N 32 55 E sunrise: 04:18 sunset: 19:21
Asuncion, Paraguay 25 15 S 57 40 W sunrise: 07:34 sunset: 18:10
Athens, Greece 37 58 N 23 43 E sunrise: 04:01 sunset: 18:52
Auckland, New_Zealand 36 52 S 174 45 E sunrise: 06:32 sunset: 16:13
Bangkok, Thailand 13 45 N 100 30 E sunrise: 04:50 sunset: 17:48
Barcelona, Spain 41 23 N 2 9 E sunrise: 04:16 sunset: 19:29
Beijing, China 39 55 N 116 25 E sunrise: 03:44 sunset: 18:47
Belem, Brazil 1 28 S 48 29 W sunrise: 06:13 sunset: 18:17
Belfast, Northern_Ireland 54 37 N 5 56 W sunrise: 03:44 sunset: 21:06
Belgrade, Yugoslavia 44 52 N 20 32 E sunrise: 03:49 sunset: 19:29
Berlin, Germany 52 30 N 13 25 E sunrise: 02:40 sunset: 19:35
Birmingham, England 52 25 N 1 55 W sunrise: 03:42 sunset: 20:36
Bogota, Colombia 4 32 N 74 15 W sunrise: 06:46 sunset: 19:11
Bombay, India 19 0 N 72 48 E sunrise: 04:31 sunset: 17:49
Bordeaux, France 44 50 N 0 31 W sunrise: 04:14 sunset: 19:53
Bremen, Germany 53 5 N 8 49 E sunrise: 02:55 sunset: 19:57
Brisbane, Australia 27 29 S 153 8 E sunrise: 06:35 sunset: 17:02
Bristol, England 51 28 N 2 35 W sunrise: 03:51 sunset: 20:33
Brussels, Belgium 50 52 N 4 22 E sunrise: 03:26 sunset: 20:01
Bucharest, Romania 44 25 N 26 7 E sunrise: 03:29 sunset: 19:05
Budapest, Hungary 47 30 N 19 5 E sunrise: 03:44 sunset: 19:46
Buenos_Aires, Argentina 34 35 S 58 22 W sunrise: 07:58 sunset: 17:51
Cairo, Egypt 30 2 N 31 21 E sunrise: 04:52 sunset: 19:00
Calcutta, India 22 34 N 88 24 E sunrise: 04:21 sunset: 17:54
Canton, China 23 7 N 113 15 E sunrise: 04:40 sunset: 18:16
Cape_Town, South_Africa 33 55 S 18 22 E sunrise: 06:50 sunset: 16:46
Caracas, Venezuela 10 28 N 67 2 W sunrise: 06:06 sunset: 18:53
Cayenne, French_Guiana 4 49 N 52 18 W sunrise: 06:17 sunset: 18:44
Chihuahua, Mexico 28 37 N 106 5 W sunrise: 05:05 sunset: 19:06
Chongqing, China 29 46 N 106 34 E sunrise: 04:52 sunset: 18:58
Copenhagen, Denmark 55 40 N 12 34 E sunrise: 02:22 sunset: 20:00
Cordoba, Argentina 31 28 S 64 10 W sunrise: 07:14 sunset: 17:22
Dakar, Senegal 14 40 N 17 28 W sunrise: 05:40 sunset: 18:42
Darwin, Australia 12 28 S 130 51 E sunrise: 05:35 sunset: 17:01
Djibouti, Djibouti 11 30 N 43 3 E sunrise: 04:44 sunset: 17:34
Dublin, Ireland 53 20 N 6 15 W sunrise: 03:54 sunset: 20:59
Durban, South_Africa 29 53 S 30 53 E sunrise: 06:50 sunset: 17:06
Edinburgh, Scotland 55 55 N 3 10 W sunrise: 03:23 sunset: 21:04
Frankfurt, Germany 50 7 N 8 41 E sunrise: 03:13 sunset: 19:40
Georgetown, Guyana 6 45 N 58 15 W sunrise: 06:38 sunset: 19:11
Glasgow, Scotland 55 50 N 4 15 W sunrise: 03:28 sunset: 21:08
Guatemala_City, Guatemala 14 37 N 90 31 W sunrise: 05:32 sunset: 18:34
Guayaquil, Ecuador 2 10 S 79 56 W sunrise: 06:20 sunset: 18:22
Hamburg, Germany 53 33 N 10 2 E sunrise: 02:47 sunset: 19:55
Havana, Cuba 23 8 N 82 23 W sunrise: 05:43 sunset: 19:19
Helsinki, Finland 60 10 N 25 0 E sunrise: 01:50 sunset: 20:53
Hobart, Tasmania 42 52 S 147 19 E sunrise: 06:40 sunset: 15:44
Iquique, Chile 20 10 S 70 7 W sunrise: 07:13 sunset: 18:10
Irkutsk, Russia 52 30 N 104 20 E sunrise: 02:37 sunset: 19:31
Jakarta, Indonesia 6 16 S 106 48 E sunrise: 06:00 sunset: 17:48
Johannesburg, South_Africa 26 12 S 28 4 E sunrise: 05:53 sunset: 16:25
Kingston, Jamaica 17 59 N 76 49 W sunrise: 05:31 sunset: 18:46
Kinshasa, Congo 4 18 S 15 17 E sunrise: 06:03 sunset: 17:57
La_Paz, Bolivia 16 27 S 68 22 W sunrise: 06:59 sunset: 18:10
Leeds, England 53 45 N 1 30 W sunrise: 03:32 sunset: 20:42
Lima, Peru 12 0 S 77 2 W sunrise: 06:26 sunset: 17:53
Lisbon, Portugal 38 44 N 9 9 W sunrise: 05:10 sunset: 20:06
Liverpool, England 53 25 N 3 0 W sunrise: 03:40 sunset: 20:46
London, England 51 32 N 0 5 W sunrise: 03:40 sunset: 20:23
Lyons, France 45 45 N 4 50 E sunrise: 03:49 sunset: 19:35
Madrid, Spain 40 26 N 3 42 W sunrise: 04:43 sunset: 19:49
Manchester, England 53 30 N 2 15 W sunrise: 03:37 sunset: 20:44
Manila, Philippines 14 35 N 120 57 E sunrise: 05:27 sunset: 18:28
Marseilles, France 43 20 N 5 20 E sunrise: 03:56 sunset: 19:24
Mazatlan, Mexico 23 12 N 106 25 W sunrise: 05:19 sunset: 18:55
Mecca, Saudi_Arabia 21 29 N 39 45 E sunrise: 04:38 sunset: 18:07
Melbourne, Australia 37 47 S 144 58 E sunrise: 06:33 sunset: 16:09
Mexico_City, Mexico 19 26 N 99 7 W sunrise: 05:57 sunset: 19:18
Milan, Italy 45 27 N 9 10 E sunrise: 03:33 sunset: 19:17
Montevideo, Uruguay 34 53 S 56 10 W sunrise: 07:50 sunset: 17:42
Moscow, Russia 55 45 N 37 36 E sunrise: 02:42 sunset: 20:20
Munich, Germany 48 8 N 11 35 E sunrise: 03:11 sunset: 19:19
Nagasaki, Japan 32 48 N 129 57 E sunrise: 04:11 sunset: 18:32
Nagoya, Japan 35 7 N 136 56 E sunrise: 04:36 sunset: 19:11
Nairobi, Kenya 1 25 S 36 55 E sunrise: 05:31 sunset: 17:36
Nanjing_Nanking, China 32 3 N 118 53 E sunrise: 03:57 sunset: 18:14
Naples, Italy 40 50 N 14 15 E sunrise: 03:29 sunset: 18:39
Newcastle-on-Tyne, England 54 58 N 1 37 W 03:27 sunset: 20:49
Odessa, Ukraine 46 27 N 30 48 E sunrise: 04:02 sunset: 19:54
Osaka, Japan 34 32 N 135 30 E sunrise: 04:44 sunset: 19:15
Oslo, Norway 59 57 N 10 42 E sunrise: 01:50 sunset: 20:47
Panama_City, Panama 8 58 N 79 32 W sunrise: 05:59 sunset: 18:40
Paramaribo, Suriname 5 45 N 55 15 W  sunrise: 06:27 sunset: 18:57
Paris, France 48 48 N 2 20 E sunrise: 03:45 sunset: 19:59
Perth, Australia 31 57 S 115 52 E sunrise: 06:15 sunset: 16:21
Plymouth, England 50 25 N 4 5 W sunrise: 04:02 sunset: 20:33
Port_Moresby, Papua_New_Guinea 9 25 S 147 8 E sunrise: 05:24 sunset: 17:01
Prague, Czech_Republic 50 5 N 14 26 E sunrise: 02:50 sunset: 19:17
Rangoon, Myanmar 16 50 N 96 0 E sunrise: 05:02 sunset: 18:12
Reykjavik, Iceland 64 4 N 21 58 W sunrise: 01:50 sunset: 23:08
Rio_de_Janeiro, Brazil 22 57 S 43 12 W sunrise: 07:31 sunset: 18:17
Rome, Italy 41 54 N 12 27 E sunrise: 03:33 sunset: 18:50
Salvador, Brazil 12 56 S 38 27 W sunrise: 06:53 sunset: 18:17
Santiago, Chile 33 28 S 70 45 W sunrise: 07:45 sunset: 17:44
St_Petersburg, Russia 59 56 N 30 18 E sunrise: 02:31 sunset: 21:29
Sao_Paulo, Brazil 23 31 S 46 31 W sunrise: 06:46 sunset: 17:29
Shanghai, China 31 10 N 121 28 E sunrise: 04:49 sunset: 19:02
Singapore, Singapore 1 14 N 103 55 E sunrise: 04:59 sunset: 17:12
Sofia, Bulgaria 42 40 N 23 20 E sunrise: 03:47 sunset: 19:09
Stockholm, Sweden 59 17 N 18 3 E sunrise: 02:28 sunset: 21:10
Sydney, Australia 34 0 S 151 0 E sunrise: 06:59 sunset: 16:55
Tananarive, Madagascar 18 50 S 47 33 E sunrise: 06:20 sunset: 17:22
Teheran, Iran 35 45 N 51 45 E sunrise: 04:15 sunset: 18:53
Tokyo, Japan 35 40 N 139 45 E sunrise: 04:24 sunset: 19:01
Tripoli, Libya 32 57 N 13 12 E sunrise: 03:57 sunset: 18:20
Venice, Italy 45 26 N 12 20 E sunrise: 03:20 sunset: 19:04
Veracruz, Mexico 19 10 N 96 10 W sunrise: 05:46 sunset: 19:06
Vienna, Austria 48 14 N 16 20 E sunrise: 03:52 sunset: 20:00
Vladivostok, Russia 43 10 N 132 0 E sunrise: 03:30 sunset: 18:56
Warsaw, Poland 52 14 N 21 0 E sunrise: 03:12 sunset: 20:03
Wellington, New_Zealand 41 17 S 174 47 E sunrise: 06:45 sunset: 15:59
Zurich, Switzerland 47 21 N 8 31 E sunrise: 03:27 sunset: 19:27


1;

