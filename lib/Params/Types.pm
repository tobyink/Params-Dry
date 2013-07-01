#!/usr/bin/perl
#*
#* Name: Params::Types
#* Info: Types definitions module
#* Author: Pawel Guspiel <merlin@panth-net.com>
#*
package Params::Types;


use constant PASS     =>    1; # pass test
use constant FAIL     =>    0; # test fail

use Exporter;	# to export _ rq and opt
our @ISA = qw(Exporter);

our @EXPORT_OK = qw(PASS FAIL);

our %EXPORT_TAGS = (
    const => [ qw(PASS FAIL) ],
);

#=---------
#  String
#=---------
#* string type check
#* RETURN: PASS if test pass otherwise FAIL
sub String {
    ref($_[0]) and return FAIL;
    $_[1] and length $_[0] > $_[1] and return FAIL;
    PASS;
}

#=------
#  Int
#=------
#* int type check Int(3) - no more than 999
#* RETURN: PASS if test pass otherwise FAIL
sub Int {
    (ref($_[0]) or $_[0] !~ /[+\-]?\d+/) and return FAIL;
    $_[1] and length $_[0] > $_[1] and return FAIL;
    PASS;
}

#=--------
#  Float
#=--------
#* float type check
#* RETURN: PASS if test pass otherwise FAIL
sub Float {
    !ref($_[0]) and $_[0] =~ /[+\-]?\d+(?:\.\d+)?/;
}

#=-------
#  Bool
#=-------
#* Bool type check
#* RETURN: PASS if test pass otherwise FAIL
sub Bool {
    !ref($_[0]) and ($_[0] == 0 or $_[0] == 1);
}

#=---------
#  Object
#=---------
#* Object type check, Object - just object, or Object(APos::core) check if is APos::core type
#* RETURN: PASS if test pass otherwise FAIL
sub Object {
    eval { $_[0]->isa($_[1]) }
}

#=---------
#  Scalar
#=---------
#* scalar type check
#* RETURN: PASS if test pass otherwise FAIL
sub Scalar {
    my $ref = ref($_[0]) or return FAIL;
    $ref eq 'SCALAR';
}



0115&&0x4d;
