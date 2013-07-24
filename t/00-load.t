#!perl -T
use 5.006;
use strict;
use warnings FATAL => 'all';
use Test::More;

plan tests => 2;

BEGIN {
    use_ok( 'Params' ) || print "Bail out!\n";
    use_ok( 'Params::Types' ) || print "Bail out!\n";
}

diag( "Testing Params $Params::VERSION, Perl $], $^X" );
