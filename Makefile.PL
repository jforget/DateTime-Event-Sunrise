use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'DateTime::Event::Sunrise',
    'VERSION_FROM'	=> 'lib/DateTime/Event/Sunrise.pm', # finds $VERSION
    'ABSTRACT'		=> 'Perl DateTime extension for computing the sunrise/sunset on a given day',
    'PREREQ_PM'		=> { 'DateTime::Set'    => '0.16',
                             'DateTime'         => '0.21',
                             'POSIX'            => '0',     # how can I find the minimum version without trying all of them? At least mention the dependency.
                             'Math::Trig'       => '0',
                             'Carp'             => '0',
                             'Params::Validate' => '0',
                             'Set::Infinite'    => '0',
                           },
    'AUTHOR'		=> [ 'Ron Hill <rkhill@firstlight.net>', 'Jean Forget <JFORGET@cpan.org>' ],
    'LICENSE'		=> 'perl',
    'BUILD_REQUIRES'    => { 'Test::More'         => '0',   # should be 'TEST_REQUIRES', except that ExtUtils::MakeMaker 6.5705 does not accept it
                             'DateTime::Duration' => '0',
                             'DateTime::Span'     => '0',
                             'DateTime::SpanSet'  => '0',
                           },
);
