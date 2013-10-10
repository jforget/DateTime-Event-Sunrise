#
#     Test script for DateTime::Event::Sunrise
#     Copyright (C) 2003, 2004, 2013 Ron Hill and Jean Forget
#
#     This program is distributed under the same terms as Perl 5.16.3:
#     GNU Public License version 1 or later and Perl Artistic License
#
#     You can find the text of the licenses in the F<LICENSE> file or at
#     L<http://www.perlfoundation.org/artistic_license_1_0>
#     and L<http://www.gnu.org/licenses/gpl-1.0.html>.
#
#     Here is the summary of GPL:
#
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 1, or (at your option)
#     any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software Foundation,
#     Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
#
use strict;
use POSIX qw(floor ceil);
use Test::More;
use DateTime;
use DateTime::Duration;
use DateTime::Span;
use DateTime::SpanSet;
use DateTime::Event::Sunrise;

my $fudge = 25;
my @data = data();
plan tests => 14 + 2 * @data;
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

is ($tmp_rise->datetime, '2000-06-19T05:42:07', 'current sunrise');
is ($tmp_set->datetime,  '2000-06-19T20:04:49', 'current sunset');

is ( $sunrise->current( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T05:42:07', 'current sunrise unchanged');
is ( $sunset->current( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T20:04:49', 'current sunset unchanged');

is ( $sunrise->next( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T05:42:19', 'next sunrise');
is ( $sunset->next( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T20:05:03', 'next sunset');

is ( $sunrise->previous( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T05:41:56', 'previous sunrise');
is ( $sunset->previous( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T20:04:33', 'previous sunset');

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
ok( $tmp_set1->start->datetime eq '2000-06-20T05:42:19');
ok( $tmp_set1->end->datetime eq '2000-06-20T20:05:03');

use vars qw($long $lat $offset);

my $dt3 = DateTime->new(
  year  => 2003,
  month => 6,
  day   => 21,
);

for  (@data) {
/(\w+),\s+(\w+)\s+(\d+)\s+(\d+)\s+(\w)\s+(\d+)\s+(\d+)\s+(\w)\s+sunrise:\s+(\d+:\d+:\d+)\s+sunset:\s+(\d+:\d+:\d+)/;
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
        $offset = DateTime::TimeZone::offset_as_string( ceil( $long / 15 ) * 60 * 60 );
    }
    elsif ( $long > 0 ) {
        $offset = DateTime::TimeZone::offset_as_string( floor( $long / 15 ) * 60 * 60 );
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

    my $tmp_rise = $sunrise->current($cloned_date);
    my $tmp_set  = $sunset->current($cloned_date);

    my $tmp_rise_lo = $tmp_rise->clone->add(seconds => - $fudge)->hms;
    my $tmp_rise_hi = $tmp_rise->clone->add(seconds =>   $fudge)->hms;
    my $tmp_set_lo  = $tmp_set ->clone->add(seconds => - $fudge)->hms;
    my $tmp_set_hi  = $tmp_set ->clone->add(seconds =>   $fudge)->hms;

print "$tmp_rise_lo $9 $tmp_rise_hi -- $tmp_set_lo $10 $tmp_set_hi\n";
    ok(($tmp_rise_lo lt $9) and ($9 lt $tmp_rise_hi));
    ok(($tmp_set_lo lt $10) and ($10 lt $tmp_set_hi));

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

sub data {
  return split "\n", <<'DATA';
Aberdeen,            Scotland             57  9 N   2  9 W sunrise: 03:09:23 sunset: 21:11:10
Adelaide,            Australia            34 55 S 138 36 E sunrise: 06:51:34 sunset: 16:42:49
Algiers,             Algeria              36 50 N   3  0 E sunrise: 04:27:32 sunset: 19:11:48
Amsterdam,           Netherlands          52 22 N   4 53 E sunrise: 03:15:41 sunset: 20:08:35
Ankara,              Turkey               39 55 N  32 55 E sunrise: 04:18:12 sunset: 19:21:46
Asuncion,            Paraguay             25 15 S  57 40 W sunrise: 07:34:11 sunset: 18:10:34
Athens,              Greece               37 58 N  23 43 E sunrise: 04:01:13 sunset: 18:52:21
Auckland,            New_Zealand          36 52 S 174 45 E sunrise: 06:32:10 sunset: 16:12:58
Bangkok,             Thailand             13 45 N 100 30 E sunrise: 04:50:18 sunset: 17:48:55
Barcelona,           Spain                41 23 N   2  9 E sunrise: 04:16:19 sunset: 19:29:50
Beijing,             China                39 55 N 116 25 E sunrise: 03:44:09 sunset: 18:47:43
Belem,               Brazil                1 28 S  48 29 W sunrise: 06:13:24 sunset: 18:17:52
Belfast,             Northern_Ireland     54 37 N   5 56 W sunrise: 03:44:19 sunset: 21:06:30
Belgrade,            Yugoslavia           44 52 N  20 32 E sunrise: 03:49:44 sunset: 19:29:19
Berlin,              Germany              52 30 N  13 25 E sunrise: 02:40:44 sunset: 19:35:15
Birmingham,          England              52 25 N   1 55 W sunrise: 03:42:35 sunset: 20:36:06
Bogota,              Colombia              4 32 N  74 15 W sunrise: 06:46:03 sunset: 19:11:24
Bombay,              India                19  0 N  72 48 E sunrise: 04:30:58 sunset: 17:49:53
Bordeaux,            France               44 50 N   0 31 W sunrise: 04:14:05 sunset: 19:53:24
Bremen,              Germany              53  5 N   8 49 E sunrise: 02:55:32 sunset: 19:57:16
Brisbane,            Australia            27 29 S 153  8 E sunrise: 06:35:40 sunset: 17:02:26
Bristol,             England              51 28 N   2 35 W sunrise: 03:50:49 sunset: 20:33:12
Brussels,            Belgium              50 52 N   4 22 E sunrise: 03:26:21 sunset: 20:02:03
Bucharest,           Romania              44 25 N  26  7 E sunrise: 03:29:12 sunset: 19:05:11
Budapest,            Hungary              47 30 N  19  5 E sunrise: 03:44:17 sunset: 19:46:23
Buenos_Aires,        Argentina            34 35 S  58 22 W sunrise: 07:58:41 sunset: 17:51:40
Cairo,               Egypt                30  2 N  31 21 E sunrise: 04:52:29 sunset: 19:00:02
Calcutta,            India                22 34 N  88 24 E sunrise: 04:21:14 sunset: 17:54:48
Canton,              China                23  7 N 113 15 E sunrise: 04:40:39 sunset: 18:16:34
Cape_Town,           South_Africa         33 55 S  18 22 E sunrise: 06:50:00 sunset: 16:46:24
Caracas,             Venezuela            10 28 N  67  2 W sunrise: 06:06:36 sunset: 18:53:06
Cayenne,             French_Guiana         4 49 N  52 18 W sunrise: 06:17:44 sunset: 18:44:05
Chihuahua,           Mexico               28 37 N 106  5 W sunrise: 05:05:43 sunset: 19:06:25
Chongqing,           China                29 46 N 106 34 E sunrise: 04:52:13 sunset: 18:58:28
Copenhagen,          Denmark              55 40 N  12 34 E sunrise: 02:22:36 sunset: 20:00:11
Cordoba,             Argentina            31 28 S  64 10 W sunrise: 07:14:08 sunset: 17:22:37
Dakar,               Senegal              14 40 N  17 28 W sunrise: 05:40:31 sunset: 18:42:35
Darwin,              Australia            12 28 S 130 51 E sunrise: 05:35:17 sunset: 17:01:06
Djibouti,            Djibouti             11 30 N  43  3 E sunrise: 04:44:19 sunset: 17:34:35
Dublin,              Ireland              53 20 N   6 15 W sunrise: 03:54:13 sunset: 20:59:08
Durban,              South_Africa         29 53 S  30 53 E sunrise: 06:50:09 sunset: 17:06:05
Edinburgh,           Scotland             55 55 N   3 10 W sunrise: 03:23:37 sunset: 21:05:04
Frankfurt,           Germany              50  7 N   8 41 E sunrise: 03:13:06 sunset: 19:40:46
Georgetown,          Guyana                6 45 N  58 15 W sunrise: 06:38:08 sunset: 19:11:17
Glasgow,             Scotland             55 50 N   4 15 W sunrise: 03:28:36 sunset: 21:08:45
Guatemala_City,      Guatemala            14 37 N  90 31 W sunrise: 05:32:51 sunset: 18:34:44
Guayaquil,           Ecuador               2 10 S  79 56 W sunrise: 06:20:26 sunset: 18:22:28
Hamburg,             Germany              53 33 N  10  2 E sunrise: 02:47:41 sunset: 19:55:24
Havana,              Cuba                 23  8 N  82 23 W sunrise: 05:43:16 sunset: 19:19:15
Helsinki,            Finland              60 10 N  25  0 E sunrise: 01:49:57 sunset: 20:53:22
Hobart,              Tasmania             42 52 S 147 19 E sunrise: 06:40:09 sunset: 15:44:29
Iquique,             Chile                20 10 S  70  7 W sunrise: 07:13:41 sunset: 18:10:41
Irkutsk,             Russia               52 30 N 104 20 E sunrise: 02:37:02 sunset: 19:31:32
Jakarta,             Indonesia             6 16 S 106 48 E sunrise: 06:00:31 sunset: 17:48:18
Johannesburg,        South_Africa         26 12 S  28  4 E sunrise: 05:53:13 sunset: 16:25:33
Kingston,            Jamaica              17 59 N  76 49 W sunrise: 05:31:33 sunset: 18:46:26
Kinshasa,            Congo                 4 18 S  15 17 E sunrise: 06:03:13 sunset: 17:57:51
La_Paz,              Bolivia              16 27 S  68 22 W sunrise: 06:59:35 sunset: 18:10:47
Leeds,               England              53 45 N   1 30 W sunrise: 03:32:30 sunset: 20:42:51
Lima,                Peru                 12  0 S  77  2 W sunrise: 06:26:06 sunset: 17:53:36
Lisbon,              Portugal             38 44 N   9  9 W sunrise: 05:10:19 sunset: 20:06:14
Liverpool,           England              53 25 N   3  0 W sunrise: 03:40:41 sunset: 20:46:40
London,              England              51 32 N   0  5 W sunrise: 03:40:26 sunset: 20:23:34
Lyons,               France               45 45 N   4 50 E sunrise: 03:48:56 sunset: 19:35:45
Madrid,              Spain                40 26 N   3 42 W sunrise: 04:42:58 sunset: 19:49:59
Manchester,          England              53 30 N   2 15 W sunrise: 03:37:08 sunset: 20:44:12
Manila,              Philippines          14 35 N 120 57 E sunrise: 05:26:55 sunset: 18:28:41
Marseilles,          France               43 20 N   5 20 E sunrise: 03:56:31 sunset: 19:24:09
Mazatlan,            Mexico               23 12 N 106 25 W sunrise: 05:19:16 sunset: 18:55:32
Mecca,               Saudi_Arabia         21 29 N  39 45 E sunrise: 04:38:08 sunset: 18:07:10
Melbourne,           Australia            37 47 S 144 58 E sunrise: 06:33:53 sunset: 16:09:33
Mexico_City,         Mexico               19 26 N  99  7 W sunrise: 05:57:52 sunset: 19:18:32
Milan,               Italy                45 27 N   9 10 E sunrise: 03:32:50 sunset: 19:17:10
Montevideo,          Uruguay              34 53 S  56 10 W sunrise: 07:50:40 sunset: 17:42:05
Moscow,              Russia               55 45 N  37 36 E sunrise: 02:41:49 sunset: 20:20:41
Munich,              Germany              48  8 N  11 35 E sunrise: 03:11:21 sunset: 19:19:19
Nagasaki,            Japan                32 48 N 129 57 E sunrise: 04:10:58 sunset: 18:32:38
Nagoya,              Japan                35  7 N 136 56 E sunrise: 04:36:42 sunset: 19:11:01
Nairobi,             Kenya                 1 25 S  36 55 E sunrise: 05:31:40 sunset: 17:36:18
Nanjing_Nanking,     China                32  3 N 118 53 E sunrise: 03:57:12 sunset: 18:14:56
Naples,              Italy                40 50 N  14 15 E sunrise: 03:29:48 sunset: 18:39:32
Newcastle_on_Tyne,   England              54 58 N   1 37 W sunrise: 03:24:33 sunset: 20:51:44
Odessa,              Ukraine              46 27 N  30 48 E sunrise: 04:02:04 sunset: 19:54:51
Osaka,               Japan                34 32 N 135 30 E sunrise: 04:44:04 sunset: 19:15:07
Oslo,                Norway               59 57 N  10 42 E sunrise: 01:49:45 sunset: 20:47:59
Panama_City,         Panama                8 58 N  79 32 W sunrise: 05:59:19 sunset: 18:40:24
Paramaribo,          Suriname              5 45 N  55 15 W sunrise: 06:27:54 sunset: 18:57:31
Paris,               France               48 48 N   2 20 E sunrise: 03:45:10 sunset: 19:59:31
Perth,               Australia            31 57 S 115 52 E sunrise: 06:15:03 sunset: 16:21:13
Plymouth,            England              50 25 N   4  5 W sunrise: 04:02:36 sunset: 20:33:25
Port_Moresby,        Papua_New_Guinea      9 25 S 147  8 E sunrise: 05:24:42 sunset: 17:01:25
Prague,              Czech_Republic       50  5 N  14 26 E sunrise: 02:50:17 sunset: 19:17:35
Rangoon,             Myanmar              16 50 N  96  0 E sunrise: 05:02:26 sunset: 18:12:48
Reykjavik,           Iceland              64  4 N  21 58 W sunrise: 01:49:54 sunset: 23:09:13
Rio_de_Janeiro,      Brazil               22 57 S  43 12 W sunrise: 07:31:33 sunset: 18:17:27
Rome,                Italy                41 54 N  12 27 E sunrise: 03:33:17 sunset: 18:50:27
Salvador,            Brazil               12 56 S  38 27 W sunrise: 06:53:26 sunset: 18:17:34
Santiago,            Chile                33 28 S  70 45 W sunrise: 07:45:23 sunset: 17:44:03
St_Petersburg,       Russia               59 56 N  30 18 E sunrise: 02:31:32 sunset: 21:29:22
Sao_Paulo,           Brazil               23 31 S  46 31 W sunrise: 06:45:59 sunset: 17:29:34
Shanghai,            China                31 10 N 121 28 E sunrise: 04:49:07 sunset: 19:02:20
Singapore,           Singapore             1 14 N 103 55 E sunrise: 04:59:02 sunset: 17:12:51
Sofia,               Bulgaria             42 40 N  23 20 E sunrise: 03:46:59 sunset: 19:09:40
Stockholm,           Sweden               59 17 N  18  3 E sunrise: 02:27:53 sunset: 21:11:02
Sydney,              Australia            34  0 S 151  0 E sunrise: 06:59:35 sunset: 16:55:34
Tananarive,          Madagascar           18 50 S  47 33 E sunrise: 06:20:22 sunset: 17:22:31
Teheran,             Iran                 35 45 N  51 45 E sunrise: 04:15:41 sunset: 18:53:36
Tokyo,               Japan                35 40 N 139 45 E sunrise: 04:23:52 sunset: 19:01:19
Tripoli,             Libya                32 57 N  13 12 E sunrise: 03:57:38 sunset: 18:20:06
Venice,              Italy                45 26 N  12 20 E sunrise: 03:20:14 sunset: 19:04:26
Veracruz,            Mexico               19 10 N  96 10 W sunrise: 05:46:36 sunset: 19:06:11
Vienna,              Austria              48 14 N  16 20 E sunrise: 03:51:53 sunset: 20:00:47
Vladivostok,         Russia               43 10 N 132  0 E sunrise: 03:30:24 sunset: 18:56:47
Warsaw,              Poland               52 14 N  21  0 E sunrise: 03:12:01 sunset: 20:03:19
Wellington,          New_Zealand          41 17 S 174 47 E sunrise: 06:45:05 sunset: 15:59:47
Zurich,              Switzerland          47 21 N   8 31 E sunrise: 03:27:14 sunset: 19:27:58
DATA
}
