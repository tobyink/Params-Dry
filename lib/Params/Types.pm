#!/usr/bin/perl
#*
#* Name: Params::Types
#* Info: Types definitions module
#* Author: Pawel Guspiel <merlin@panth-net.com>
#*
#* This module keeps validation functions. You can of course add your modules which inherites from this and will add additional checks
#*
package Params::Types;

    use strict;
    use warnings;

    # --- version ---
    our $VERSION = 1.0_0;

    #=------------------------------------------------------------------------ { use, constants }

    use Scalar::Util 'blessed';

    use constant PASS     =>    1; # pass test
    use constant FAIL     =>    0; # test fail

    #=------------------------------------------------------------------------ { export }

    use Exporter;	# to export _ rq and opt
    our @ISA = qw(Exporter);

    our @EXPORT_OK = qw(PASS FAIL);

    our %EXPORT_TAGS = (
        const => [ qw(PASS FAIL) ],
    );

    #=------------------------------------------------------------------------ { module public functions }

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
        (ref($_[0]) or $_[0] !~ /^[+\-]?(\d+)$/) and return FAIL;
        $_[1] and $1 and length $1 > $_[1] and return FAIL;
        PASS;
    }

    #=--------
    #  Float
    #=--------
    #* float type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Float {
        (ref($_[0]) or $_[0] !~ /^[+\-]?(\d+(?:\.\d+)?)$/) and return FAIL;
        $_[1] and $1 and length $1 > $_[1] and return FAIL;
        PASS;
    }

    #=-------
    #  Bool
    #=-------
    #* Bool type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Bool {
        return PASS if !ref($_[0]) and ("$_[0]" eq '0' or "$_[0]" eq 1);
        FAIL;
    }

    #=---------
    #  Object
    #=---------
    #* Object type check, Object - just object, or Object(APos::core) check if is APos::core type
    #* RETURN: PASS if test pass otherwise FAIL
    sub Object {
        my $class = blessed($_[0]);
        return FAIL if !$class; # not an object    
        return FAIL if $_[1] and ($_[1] ne $class);
        PASS;
    }

    #=------
    #  Ref
    #=------
    #* ref type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Ref {
        my $ref = ref($_[0]) or return FAIL;
        
        return FAIL if $_[1] and $ref ne $_[1];
        PASS;
    }


    #=---------
    #  Scalar
    #=---------
    #* scalar type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Scalar {
        Ref($_[0],'SCALAR');
    }

    #=--------
    #  Array
    #=--------
    #* array type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Array {
        Ref($_[0],'ARRAY');
    }

    #=-------
    #  Hash
    #=-------
    #* array type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Hash {
        Ref($_[0],'HASH');
    }

    #=-------
    #  Code
    #=-------
    #* array type check
    #* RETURN: PASS if test pass otherwise FAIL
    sub Code {
        Ref($_[0],'CODE');
    }

0115&&0x4d;

#+ End of Params::Types
