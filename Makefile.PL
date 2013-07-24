use 5.006;
use strict;
use warnings FATAL => 'all';
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Params::Dry',
    AUTHOR           => q{Pawel Guspiel <neo@cpan.org>},
    VERSION_FROM     => 'lib/Params/Dry.pm',
    ABSTRACT_FROM    => 'lib/Params/Dry.pm',
        LICENSE          => 'Artistic_2_0',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.010,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
        'Test::Most' => 0,
    },
    PREREQ_PM => {
        'Carp' => 0,
        'Exporter' => 0,
        'Scalar::Util' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Params-*' },
);
