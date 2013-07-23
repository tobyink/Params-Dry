#!/usr/bin/env perl
#*
#* Name: Params.pm.t
#* Info: Test for Params.pm.t
#* Author: Pawel Guspiel (neo77) <neo@cpan.org>
#*

use strict;
use warnings;

use Test::Most;                      # last test to print

ok('yes','yes');
done_testing();
__END__
typedef 'client', 'String[20]';
typedef 'sma', 'client';

sub trip {
    my $self = __@_;
    my $p_c = rq 'c', 'String[20]', 'bloccc';
    nomore;

    $p_c;

}
sub test {
    my $self = __@_;

    my $p_o = rq 'sma', 'String[20]', 'blox';
    my $p_ob = rq 'sma', DEFAULT_TYPE, trip(c => 'azul');
    my $p_or = rq 'smart', 'String[20]', 'blox';
#    nomore;

    print $p_o, $p_ob, $p_or;
}

test(smart => '10');
#my $rbo = rq 'sma', DEFAULT_TYPE, 'blox'; # warning

