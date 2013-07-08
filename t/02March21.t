use strict;
use POSIX qw(floor ceil);
use Test::More;
use DateTime;
use DateTime::Event::Sunrise;

my @tests = split "\n", <<'TEST';
2.33  48.83 1 20 18:04:48
2.33  48.83 1 21 18:06:19
2.33  48.83 1 22 18:07:50
92.33 48.83 0 20 12:03:17
92.33 48.83 0 21 12:04:48
92.33 48.83 0 22 12:06:19
TEST

plan (tests => scalar @tests);

foreach (@tests) {
  my ($lon, $lat, $iter, $dd, $res) = split ' ', $_;
  my $sunset = DateTime::Event::Sunrise->sunset(longitude => $lon,
                                                 latitude  => $lat,
                                                 iteration => $iter,
                                                );
  my  $day =  DateTime->new(year => 2008, month => 3, day => $dd, time_zone => 'UTC');

  is ($sunset->next($day)->strftime("%H:%M:%S"), $res);

}


