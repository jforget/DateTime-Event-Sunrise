use strict;
use Test::More;
use DateTime;
use DateTime::Duration;
use DateTime::Span;
use DateTime::SpanSet;
use DateTime::Event::Sunrise;

BEGIN { plan tests => 15 }
my $dt = DateTime->new( year   => 2000,
		 month  => 6,
		 day    => 20,
                  );
my $dt2 = DateTime->new( year   => 2000,
		 month  => 6,
		 day    => 22,
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
$tmp_rise->set_time_zone( 'America/Los_Angeles' );
$tmp_set->set_time_zone('America/Los_Angeles' );

is ($tmp_rise->datetime, '2000-06-19T05:43:00', 'current sunrise');
is ($tmp_set->datetime,  '2000-06-19T20:03:00', 'current sunset');

is ( $sunrise->current( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T05:43:00', 'current sunrise unchanged');
is ( $sunset->current( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-19T20:03:00', 'current sunset unchanged');

is ( $sunrise->next( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T05:43:00', 'next sunrise');
is ( $sunset->next( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-20T20:03:00', 'next sunset');

is ( $sunrise->previous( $tmp_rise )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T05:43:00', 'previous sunrise');
is ( $sunset->previous( $tmp_set )->set_time_zone( 'America/Los_Angeles' )->datetime, 
     '2000-06-18T20:03:00', 'previous sunset');

is ( $sunrise->contains( $tmp_rise ), 
     1, 'is sunrise');
is ( $sunset->contains( $tmp_set ), 
     1, 'is sunset');

is ( $sunrise->contains( $dt ), 
     0, 'is not sunrise');
is ( $sunset->contains( $dt ), 
     0, 'is not sunset');

# "set" test
my $dt_span = DateTime::Span->new( start =>$dt, end=>$dt2 );
my $set = $sunrise->intersection($dt_span);
my $iter = $set->iterator;
my @res;
for (1..2) {
        my $tmp = $iter->next;
        $tmp->set_time_zone('America/Los_Angeles' );
        push @res, $tmp->datetime if defined $tmp;
}
my $res = join( ' ', @res );
ok( $res eq '2000-06-20T05:43:00 2000-06-21T05:43:00');

my $day_set = DateTime::SpanSet->from_sets( start_set => $sunrise, end_set => $sunset );
is ( $day_set->contains( $dt ) ? 'day' : 'night',
     'day', 'build datetime span set' );

my $dur = DateTime::Duration->new( hours => 12 );
is ( $day_set->contains( $dt + $dur ) ? 'day' : 'night',
     'night', 'build datetime span set' );

1;

