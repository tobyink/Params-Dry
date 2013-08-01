#!/usr/bin/env perl
#*
#* Name: Params/Dry.pm.t
#* Info: Test for Params::Dry module
#* Author: Pawel Guspiel (neo77) <neo@cpan.org>
#*

use strict;
use warnings;
use utf8;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

use Test::Most;    # last test to print

use FindBin '$Bin';
use lib $Bin. '/../lib';

use constant PASS => 1;    # pass test
use constant FAIL => 0;    # test fail

my $tb = Test::Most->builder;
$tb->failure_output( \*STDERR );
$tb->todo_output( \*STDERR );
$tb->output( \*STDOUT );

#=----------------
#  initial tests
#=----------------
#* check long and short public functions
{
    use_ok( 'Params::Dry', ':short' );
    map { can_ok( 'Params::Dry', $_ ) } qw(
      rq
      op
      typedef
      __
      no_more
    );

    use_ok( 'Params::Dry', ':long' );
    map { can_ok( 'Params::Dry', $_ ) } qw(
      param_rq
      param_op
      typedef
      __
      no_more
    );
}

#=----------------------
#  _error
#=----------------------
{
    dies_ok( sub { _error('any') }, '_error function dies' );
}

#=--------------------
#  __check_parameter
#=--------------------
{

    # --- check internal syntax ---
    dies_ok( sub { __check_parameter( undef, 'client', 'zz', 1 ) }, 'no parameter name (undef)' );
    dies_ok( sub { __check_parameter( '',    'client', 'zz', 1 ) }, 'no parameter name' );

    typedef( 'client', 'String[20]' );
    __( test => 'dupa' );
    ok( Params::Dry::__check_parameter( 'test', 'client', '', 0 ) eq 'dupa', 'check correct parameter' );
    __( test => undef );
    ok( Params::Dry::__check_parameter( 'test', 'client', 'default', 0 ) eq 'default', 'check correct parameter' );
    __( test => 'x' x 30 );
    dies_ok( sub { Params::Dry::__check_parameter( 'test', 'client', '', 0 ) }, "to long (doesn't pass validation)" );

    dies_ok( sub { Params::Dry::__check_parameter( 'test', 'client_invalid', '', 0 ) }, 'not defined type' );
    dies_ok( sub { Params::Dry::__check_parameter( 'test', 'client',         '', 1 ) }, 'required but empty' );

    use Data::Dumper;

    # --- detect type (set explicite or get it from name?)
    __( client => 'test' );
    ok( Params::Dry::__check_parameter( 'client', 1, '', 0 ) eq 'test', 'detect correct type from param name' );

    # --- check effective parameter definition for used name (if exists) and if user is not trying to replace name-type with new one (to keep clean naminigs)
    __( client => 'test' );
    dies_ok( sub { Params::Dry::__check_parameter( 'client', 'String[1]', '', 0 ) }, 'try to redefine existing type (fail)' );
    lives_ok( sub { Params::Dry::__check_parameter( 'client', 'String[20]', '', 0 ) }, 'redefine existing type with the same values' );

    # --- use ad-hoc types
    lives_ok( sub { Params::Dry::__check_parameter( 'test', 'client',     '', 0 ) }, 'try to redefine existing type (fail)' );
    lives_ok( sub { Params::Dry::__check_parameter( 'test', 'String[20]', '', 0 ) }, 'redefine existing type with the same values' );

    # --- define own type
    {
        package MyTypes::Super;
        use Type::Library -base;
        use Type::Utils;
        declare "String",
            as Params::Dry::Types::String(),
            where { /Super/ },
            constraint_generator => Params::Dry::Types::String()->constraint_generator;
    }

    __( test => 'Super A' );
    lives_ok( sub { Params::Dry::__check_parameter( 'test', 'MyTypes::Super::String[10]', '', 0 ) }, 'is Super' );
    __( test => 'Super A' . 'x' x 10 );
    dies_ok( sub { Params::Dry::__check_parameter( 'test', 'MyTypes::Super::String[10]', '', 0 ) }, 'is Super but to long' );
    __( test => 'Duper A' );
    dies_ok( sub { Params::Dry::__check_parameter( 'test', 'MyTypes::Super::String[10]', '', 0 ) }, 'No Super (wrong value)' );

    # cleaning
    %Params::Dry::Internal::current_params = ();
    @Params::Dry::Internal::params_stack   = ();
}

#=------------
#  op and rq
#=------------
{
    my @params = ();

    *__check_parameter_old = *Params::Dry::__check_parameter;

    {
        no warnings 'redefine';
        *Params::Dry::__check_parameter = sub {
            @params = @_;
        };
    }

    op( 'test', 'client', 'default_value' );
    is_deeply( \@params, [ 'test', 'client', 'default_value', 0, __PACKAGE__ ], 'op call parameters' );
    rq( 'test2', 'client_bis', 'default2_value' );
    is_deeply( \@params, [ 'test2', 'client_bis', 'default2_value', 1, __PACKAGE__ ], 'rq call parameters' );

    *Params::Dry::__check_parameter = *__check_parameter_old
}

#=----------
#  typedef
#=----------
{
    my $name = typedef( 'client', 'String[20]' );
    ok( $name eq 'client', 'returned type name by typedef' );
    typedef( 'client_bis', 'client' );
    dies_ok( sub { typedef( 'client', 'String[10]' ) }, 'unsuccessful try to redefine client type' );
    lives_ok( sub { typedef( 'client', 'String[20]' ) }, 'successful try to redefine client type with the same type value' );

    lives_ok( sub { typedef( 'client_bis', 'String[20]' ) }, 'successful try to redefine client_bis type to grand parent type' );
}

#=--------
#  __
#=--------
#* self test, current_params, params stack
{
    my $self = __( 'self', test => 1 );
    ok( $self eq 'self', 'self is returned by __' );
    is_deeply( $Params::Dry::Internal::current_params, { test => 1 }, 'current params hash' );
    $self = __( test => 2, bleble => {} );
    ok( !defined $self, 'self is not returned by __ in case of hash only call' );
    is_deeply( $Params::Dry::Internal::current_params, { test => 2, bleble => {} }, 'current params hash (2 call)' );

    is_deeply( \@Params::Dry::Internal::params_stack, [ { test => 1 }, { test => 2, bleble => {} } ], 'params stack' );
}

#=----------
#  no_more
#=----------
#* parameter stack popping
{
    no_more();
    is_deeply( \@Params::Dry::Internal::params_stack, [ { test => 1 }, ], 'params stack (popping)' );
    no_more();
    is_deeply( \@Params::Dry::Internal::params_stack, [], 'params stack (popping again)' );
    no_more();
    is_deeply( \@Params::Dry::Internal::params_stack, [], 'params stack (popping from empty stack)' );
}

ok( 'yes', 'yes' );
done_testing();

