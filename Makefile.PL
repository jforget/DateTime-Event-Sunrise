use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'DateTime::Event::Sunrise',
    'VERSION_FROM'	=> 'lib/DateTime/Event/Sunrise.pm', # finds $VERSION
    'ABSTRACT'		=> 'Perl DateTime extension for computing the sunrise/sunset on a given day',
    'PREREQ_PM'		=> { 'DateTime::Set' => '0.16',
                             'DateTime' => '0.21' 
                           },
    'AUTHOR'		=> [ 'Ron Hill <rkhill@firstlight.net>', 'Jean Forget <JFORGET@cpan.org>' ],
    'LICENSE'		=> 'perl',
);
