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

is ($tmp_rise->datetime, '2000-06-19T05:43:21', 'current sunrise');
is ($tmp_set->datetime,  '2000-06-19T20:03:08', 'current sunset');

is ( $sunrise->current( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T05:43:21', 'current sunrise unchanged');
is ( $sunset->current( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T20:03:08', 'current sunset unchanged');

is ( $sunrise->next( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T05:43:31', 'next sunrise');
is ( $sunset->next( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T20:03:24', 'next sunset');

is ( $sunrise->previous( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T05:43:11', 'previous sunrise');
is ( $sunset->previous( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T20:02:52', 'previous sunset');

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
ok( $tmp_set1->start->datetime eq '2000-06-20T05:43:31');
ok( $tmp_set1->end->datetime eq '2000-06-20T20:03:24');

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
Aberdeen, Scotland 57 9 N 2 9 W sunrise: 03:12 sunset: 21:08
Adelaide, Australia 34 55 S 138 36 E sunrise: 06:52 sunset: 16:41
Algiers, Algeria 36 50 N 3 0 E sunrise: 04:29 sunset: 19:10
Amsterdam, Netherlands 52 22 N 4 53 E sunrise: 03:18 sunset: 20:06
Ankara, Turkey 39 55 N 32 55 E sunrise: 04:19 sunset: 19:20
Asuncion, Paraguay 25 15 S 57 40 W sunrise: 07:35 sunset: 18:09
Athens, Greece 37 58 N 23 43 E sunrise: 04:02 sunset: 18:50
Auckland, New_Zealand 36 52 S 174 45 E sunrise: 06:33 sunset: 16:11
Bangkok, Thailand 13 45 N 100 30 E sunrise: 04:51 sunset: 17:47
Barcelona, Spain 41 23 N 2 9 E sunrise: 04:18 sunset: 19:28
Beijing, China 39 55 N 116 25 E sunrise: 03:45 sunset: 18:46
Belem, Brazil 1 28 S 48 29 W sunrise: 06:14 sunset: 18:16
Belfast, Northern_Ireland 54 37 N 5 56 W sunrise: 03:47 sunset: 21:03
Belgrade, Yugoslavia 44 52 N 20 32 E sunrise: 03:51 sunset: 19:27
Berlin, Germany 52 30 N 13 25 E sunrise: 02:43 sunset: 19:32
Birmingham, England 52 25 N 1 55 W sunrise: 03:45 sunset: 20:33
Bogota, Colombia 4 32 N 74 15 W sunrise: 06:47 sunset: 19:10
Bombay, India 19 0 N 72 48 E sunrise: 04:32 sunset: 17:48
Bordeaux, France 44 50 N 0 31 W sunrise: 04:16 sunset: 19:51
Bremen, Germany 53 5 N 8 49 E sunrise: 02:58 sunset: 19:54
Brisbane, Australia 27 29 S 153 8 E sunrise: 06:36 sunset: 17:01
Bristol, England 51 28 N 2 35 W sunrise: 03:53 sunset: 20:30
Brussels, Belgium 50 52 N 4 22 E sunrise: 03:28 sunset: 19:59
Bucharest, Romania 44 25 N 26 7 E sunrise: 03:31 sunset: 19:03
Budapest, Hungary 47 30 N 19 5 E sunrise: 03:46 sunset: 19:44
Buenos_Aires, Argentina 34 35 S 58 22 W sunrise: 08:00 sunset: 17:50
Cairo, Egypt 30 2 N 31 21 E sunrise: 04:53 sunset: 18:58
Calcutta, India 22 34 N 88 24 E sunrise: 04:22 sunset: 17:53
Canton, China 23 7 N 113 15 E sunrise: 04:42 sunset: 18:15
Cape_Town, South_Africa 33 55 S 18 22 E sunrise: 06:51 sunset: 16:45
Caracas, Venezuela 10 28 N 67 2 W sunrise: 06:07 sunset: 18:52
Cayenne, French_Guiana 4 49 N 52 18 W sunrise: 06:18 sunset: 18:43
Chihuahua, Mexico 28 37 N 106 5 W sunrise: 05:07 sunset: 19:05
Chongqing, China 29 46 N 106 34 E sunrise: 04:53 sunset: 18:57
Copenhagen, Denmark 55 40 N 12 34 E sunrise: 02:25 sunset: 19:57
Cordoba, Argentina 31 28 S 64 10 W sunrise: 07:15 sunset: 17:21
Dakar, Senegal 14 40 N 17 28 W sunrise: 05:41 sunset: 18:41
Darwin, Australia 12 28 S 130 51 E sunrise: 05:36 sunset: 17:00
Djibouti, Djibouti 11 30 N 43 3 E sunrise: 04:45 sunset: 17:33
Dublin, Ireland 53 20 N 6 15 W sunrise: 03:56 sunset: 20:56
Durban, South_Africa 29 53 S 30 53 E sunrise: 06:51 sunset: 17:04
Edinburgh, Scotland 55 55 N 3 10 W sunrise: 03:26 sunset: 21:02
Frankfurt, Germany 50 7 N 8 41 E sunrise: 03:15 sunset: 19:38
Georgetown, Guyana 6 45 N 58 15 W sunrise: 06:39 sunset: 19:10
Glasgow, Scotland 55 50 N 4 15 W sunrise: 03:31 sunset: 21:05
Guatemala_City, Guatemala 14 37 N 90 31 W sunrise: 05:34 sunset: 18:33
Guayaquil, Ecuador 2 10 S 79 56 W sunrise: 06:21 sunset: 18:21
Hamburg, Germany 53 33 N 10 2 E sunrise: 02:50 sunset: 19:52
Havana, Cuba 23 8 N 82 23 W sunrise: 05:44 sunset: 19:18
Helsinki, Finland 60 10 N 25 0 E sunrise: 01:54 sunset: 20:49
Hobart, Tasmania 42 52 S 147 19 E sunrise: 06:41 sunset: 15:42
Iquique, Chile 20 10 S 70 7 W sunrise: 07:14 sunset: 18:09
Irkutsk, Russia 52 30 N 104 20 E sunrise: 02:39 sunset: 19:29
Jakarta, Indonesia 6 16 S 106 48 E sunrise: 06:01 sunset: 17:47
Johannesburg, South_Africa 26 12 S 28 4 E sunrise: 05:54 sunset: 16:24
Kingston, Jamaica 17 59 N 76 49 W sunrise: 05:32 sunset: 18:45
Kinshasa, Congo 4 18 S 15 17 E sunrise: 06:04 sunset: 17:56
La_Paz, Bolivia 16 27 S 68 22 W sunrise: 07:00 sunset: 18:09
Leeds, England 53 45 N 1 30 W sunrise: 03:35 sunset: 20:40
Lima, Peru 12 0 S 77 2 W sunrise: 06:27 sunset: 17:52
Lisbon, Portugal 38 44 N 9 9 W sunrise: 05:12 sunset: 20:04
Liverpool, England 53 25 N 3 0 W sunrise: 03:43 sunset: 20:44
London, England 51 32 N 0 5 W sunrise: 03:42 sunset: 20:21
Lyons, France 45 45 N 4 50 E sunrise: 03:50 sunset: 19:33
Madrid, Spain 40 26 N 3 42 W sunrise: 04:44 sunset: 19:48
Manchester, England 53 30 N 2 15 W sunrise: 03:39 sunset: 20:41
Manila, Philippines 14 35 N 120 57 E sunrise: 05:28 sunset: 18:27
Marseilles, France 43 20 N 5 20 E sunrise: 03:58 sunset: 19:22
Mazatlan, Mexico 23 12 N 106 25 W sunrise: 05:20 sunset: 18:54
Mecca, Saudi_Arabia 21 29 N 39 45 E sunrise: 04:39 sunset: 18:05
Melbourne, Australia 37 47 S 144 58 E sunrise: 06:35 sunset: 16:08
Mexico_City, Mexico 19 26 N 99 7 W sunrise: 05:59 sunset: 19:17
Milan, Italy 45 27 N 9 10 E sunrise: 03:34 sunset: 19:15
Montevideo, Uruguay 34 53 S 56 10 W sunrise: 07:52 sunset: 17:40
Moscow, Russia 55 45 N 37 36 E sunrise: 02:44 sunset: 20:17
Munich, Germany 48 8 N 11 35 E sunrise: 03:13 sunset: 19:17
Nagasaki, Japan 32 48 N 129 57 E sunrise: 04:12 sunset: 18:31
Nagoya, Japan 35 7 N 136 56 E sunrise: 04:38 sunset: 19:09
Nairobi, Kenya 1 25 S 36 55 E sunrise: 05:32 sunset: 17:35
Nanjing_Nanking, China 32 3 N 118 53 E sunrise: 03:58 sunset: 18:13
Naples, Italy 40 50 N 14 15 E sunrise: 03:31 sunset: 18:37
Newcastle-on-Tyne, England 54 58 N 1 37 W 03:27 sunset: 20:49
Odessa, Ukraine 46 27 N 30 48 E sunrise: 04:04 sunset: 19:52
Osaka, Japan 34 32 N 135 30 E sunrise: 04:45 sunset: 19:13
Oslo, Norway 59 57 N 10 42 E sunrise: 01:53 sunset: 20:44
Panama_City, Panama 8 58 N 79 32 W sunrise: 06:00 sunset: 18:39
Paramaribo, Suriname 5 45 N 55 15 W  sunrise: 06:29 sunset: 18:56
Paris, France 48 48 N 2 20 E sunrise: 03:47 sunset: 19:57
Perth, Australia 31 57 S 115 52 E sunrise: 06:16 sunset: 16:19
Plymouth, England 50 25 N 4 5 W sunrise: 04:04 sunset: 20:31
Port_Moresby, Papua_New_Guinea 9 25 S 147 8 E sunrise: 05:25 sunset: 17:00
Prague, Czech_Republic 50 5 N 14 26 E sunrise: 02:52 sunset: 19:15
Rangoon, Myanmar 16 50 N 96 0 E sunrise: 05:03 sunset: 18:11
Reykjavik, Iceland 64 4 N 21 58 W sunrise: 01:57 sunset: 23:01
Rio_de_Janeiro, Brazil 22 57 S 43 12 W sunrise: 07:32 sunset: 18:16
Rome, Italy 41 54 N 12 27 E sunrise: 03:35 sunset: 18:48
Salvador, Brazil 12 56 S 38 27 W sunrise: 06:54 sunset: 18:16
Santiago, Chile 33 28 S 70 45 W sunrise: 07:46 sunset: 17:42
St_Petersburg, Russia 59 56 N 30 18 E sunrise: 02:35 sunset: 21:25
Sao_Paulo, Brazil 23 31 S 46 31 W sunrise: 06:47 sunset: 17:28
Shanghai, China 31 10 N 121 28 E sunrise: 04:50 sunset: 19:00
Singapore, Singapore 1 14 N 103 55 E sunrise: 05:00 sunset: 17:11
Sofia, Bulgaria 42 40 N 23 20 E sunrise: 03:48 sunset: 19:07
Stockholm, Sweden 59 17 N 18 3 E sunrise: 02:31 sunset: 21:07
Sydney, Australia 34 0 S 151 0 E sunrise: 07:01 sunset: 16:54
Tananarive, Madagascar 18 50 S 47 33 E sunrise: 06:21 sunset: 17:21
Teheran, Iran 35 45 N 51 45 E sunrise: 04:17 sunset: 18:52
Tokyo, Japan 35 40 N 139 45 E sunrise: 04:25 sunset: 18:59
Tripoli, Libya 32 57 N 13 12 E sunrise: 03:59 sunset: 18:18
Venice, Italy 45 26 N 12 20 E sunrise: 03:22 sunset: 19:02
Veracruz, Mexico 19 10 N 96 10 W sunrise: 05:47 sunset: 19:05
Vienna, Austria 48 14 N 16 20 E sunrise: 03:54 sunset: 19:58
Vladivostok, Russia 43 10 N 132 0 E sunrise: 03:32 sunset: 18:55
Warsaw, Poland 52 14 N 21 0 E sunrise: 03:14 sunset: 20:00
Wellington, New_Zealand 41 17 S 174 47 E sunrise: 06:46 sunset: 15:58
Zurich, Switzerland 47 21 N 8 31 E sunrise: 03:29 sunset: 19:26


1;

