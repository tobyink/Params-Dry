#!/usr/bin/env perl
#*
#* Name: Params/Dry/Types.pm.t
#* Info: Test for Params::Dry::Types
#* Author: Pawel Guspiel (neo77) <neo@cpan.org>
#*

use strict;
use warnings;
use utf8;

binmode STDOUT, ':utf8';
binmode STDERR, ':utf8';

use Test::Most;    # last test to print
use Test::TypeTiny;

use FindBin '$Bin';
use lib $Bin. '/../lib';

use constant PASS => 1;    # pass test
use constant FAIL => 0;    # test fail

my $tb = Test::Most->builder;
$tb->failure_output( \*STDERR );
$tb->todo_output( \*STDERR );
$tb->output( \*STDOUT );

sub test_function {
    my %p_ = @_;

    my $p_function_name   = $p_{'function_name'};
    my $p_function        = $p_{'function'};
    my $p_function_params = $p_{'function_params'} || [];
    my $p_value           = $p_{'value'};
    my $p_expected        = $p_{'expected'};

    my $type_constraint = $p_function->($p_function_params);

    local $Test::Builder::Level = $Test::Builder::Level + 1;
    $p_expected
        ? should_pass($p_value, $type_constraint)
        : should_fail($p_value, $type_constraint);
}

use_ok('Params::Dry::Types');

#*----------
#*  String
#*----------
test_function(
    function_name   => 'String',
    function        => \&Params::Dry::Types::String,
    function_params => undef,
    value           => 'Plepleple',
    expected        => PASS,
);
test_function(
    function_name   => 'String[5]',
    function        => \&Params::Dry::Types::String,
    function_params => [5],
    value           => 'Plep',
    expected        => PASS,
);
test_function(
    function_name   => 'String[5]',
    function        => \&Params::Dry::Types::String,
    function_params => [5],
    value           => 'PlePl',
    expected        => PASS,
);
test_function(
    function_name   => 'String[5]',
    function        => \&Params::Dry::Types::String,
    function_params => [5],
    value           => 'PlePle',
    expected        => FAIL,
);
test_function(
    function_name   => 'String[5]',
    function        => \&Params::Dry::Types::String,
    function_params => [5],
    value           => 'PlePź',
    expected        => PASS,
);
test_function(
    function_name   => 'String',
    function        => \&Params::Dry::Types::String,
    function_params => undef,
    value           => [],
    expected        => FAIL,
);

#*----------
#*  Int
#*----------
test_function(
    function_name   => 'Int',
    function        => \&Params::Dry::Types::Int,
    function_params => undef,
    value           => 'Plepleple',
    expected        => FAIL,
);
test_function(
    function_name   => 'Int',
    function        => \&Params::Dry::Types::Int,
    function_params => undef,
    value           => '10',
    expected        => PASS,
);
test_function(
    function_name   => 'Int',
    function        => \&Params::Dry::Types::Int,
    function_params => undef,
    value           => '10.01',
    expected        => FAIL,
);
test_function(
    function_name   => 'Int',
    function        => \&Params::Dry::Types::Int,
    function_params => undef,
    value           => '+10',
    expected        => PASS,
);
test_function(
    function_name   => 'Int',
    function        => \&Params::Dry::Types::Int,
    function_params => undef,
    value           => '-10',
    expected        => PASS,
);
test_function(
    function_name   => 'Int[3]',
    function        => \&Params::Dry::Types::Int,
    function_params => [3],
    value           => '101',
    expected        => PASS,
);
test_function(
    function_name   => 'Int[3]',
    function        => \&Params::Dry::Types::Int,
    function_params => [3],
    value           => '1012',
    expected        => FAIL,
);
test_function(
    function_name   => 'Int[3]',
    function        => \&Params::Dry::Types::Int,
    function_params => [3],
    value           => '+101',
    expected        => PASS,
);
test_function(
    function_name   => 'Int',
    function        => \&Params::Dry::Types::Int,
    function_params => undef,
    value           => [],
    expected        => FAIL,
);

#*----------
#*  Float
#*----------
test_function(
    function_name   => 'Float',
    function        => \&Params::Dry::Types::Float,
    function_params => undef,
    value           => 'Plepleple',
    expected        => FAIL,
);
test_function(
    function_name   => 'Float',
    function        => \&Params::Dry::Types::Float,
    function_params => undef,
    value           => '10',
    expected        => PASS,
);
test_function(
    function_name   => 'Float',
    function        => \&Params::Dry::Types::Float,
    function_params => undef,
    value           => '10.01',
    expected        => PASS,
);
test_function(
    function_name   => 'Float',
    function        => \&Params::Dry::Types::Float,
    function_params => undef,
    value           => '+10',
    expected        => PASS,
);
test_function(
    function_name   => 'Float',
    function        => \&Params::Dry::Types::Float,
    function_params => undef,
    value           => '-10',
    expected        => PASS,
);
test_function(
    function_name   => 'Float[3]',
    function        => \&Params::Dry::Types::Float,
    function_params => [3],
    value           => '101',
    expected        => PASS,
);
test_function(
    function_name   => 'Float[3]',
    function        => \&Params::Dry::Types::Float,
    function_params => [3],
    value           => '1012',
    expected        => FAIL,
);
test_function(
    function_name   => 'Float[3]',
    function        => \&Params::Dry::Types::Float,
    function_params => [3],
    value           => '+101',
    expected        => PASS,
);
test_function(
    function_name   => 'Float',
    function        => \&Params::Dry::Types::Float,
    function_params => undef,
    value           => [],
    expected        => FAIL,
);

#*----------
#*  Bool
#*----------
test_function(
    function_name   => 'Bool',
    function        => \&Params::Dry::Types::Bool,
    function_params => undef,
    value           => 'Plepleple',
    expected        => FAIL,
);
test_function(
    function_name   => 'Bool',
    function        => \&Params::Dry::Types::Bool,
    function_params => undef,
    value           => '1',
    expected        => PASS,
);
test_function(
    function_name   => 'Bool',
    function        => \&Params::Dry::Types::Bool,
    function_params => undef,
    value           => 0,
    expected        => PASS,
);
test_function(
    function_name   => 'Bool',
    function        => \&Params::Dry::Types::Bool,
    function_params => undef,
    value           => [],
    expected        => FAIL,
);

#*----------
#*  Object
#*----------
test_function(
    function_name   => 'Object',
    function        => \&Params::Dry::Types::Object,
    function_params => undef,
    value           => 'Plepleple',
    expected        => FAIL,
);
test_function(
    function_name   => 'Object',
    function        => \&Params::Dry::Types::Object,
    function_params => undef,
    value           => '1',
    expected        => FAIL,
);
test_function(
    function_name   => 'Object',
    function        => \&Params::Dry::Types::Object,
    function_params => undef,
    value           => [],
    expected        => FAIL,
);
test_function(
    function_name   => 'Object',
    function        => \&Params::Dry::Types::Object,
    function_params => undef,
    value           => ( bless {}, 'Params::Dry::Types' ),
    expected        => PASS,
);

#*-----------------------------------
#*  Ref (Scalar, Array, Hash, Code)
#*-----------------------------------
test_function(
    function_name   => 'Ref',
    function        => \&Params::Dry::Types::Ref,
    function_params => undef,
    value           => 'Plepleple',
    expected        => FAIL,
);
test_function(
    function_name   => 'Ref',
    function        => \&Params::Dry::Types::Ref,
    function_params => undef,
    value           => ['Plepleple'],
    expected        => PASS,
);
test_function(
    function_name   => 'Ref(ARRAY)',
    function        => \&Params::Dry::Types::Ref,
    function_params => ['ARRAY'],
    value           => ['Plepleple'],
    expected        => PASS,
);
test_function(
    function_name   => 'Ref(HASH)',
    function        => \&Params::Dry::Types::Ref,
    function_params => ['HASH'],
    value           => ['Plepleple'],
    expected        => FAIL,
);
test_function(
    function_name   => 'Array',
    function        => \&Params::Dry::Types::Array,
    function_params => undef,
    value           => ['Plepleple'],
    expected        => PASS,
);
test_function(
    function_name   => 'Hash',
    function        => \&Params::Dry::Types::Hash,
    function_params => undef,
    value           => { 'Plepleple' => 1 },
    expected        => PASS,
);
test_function(
    function_name   => 'Code',
    function        => \&Params::Dry::Types::Code,
    function_params => undef,
    value           => sub { 'Plepleple' },
    expected        => PASS,
);
test_function(
    function_name   => 'Scalar',
    function        => \&Params::Dry::Types::Scalar,
    function_params => undef,
    value           => \'Plepleple',
    expected        => PASS,
);

ok( 'yes', 'yes' );

done_testing();
