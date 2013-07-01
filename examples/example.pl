#!/usr/bin/env perl
#*
#* Name: example.pl
#* Info: just an example of syntax
#* Author: Pawel Guspiel (neo77) <merlin@panth-net.com>
#*

use strict;
use warnings;

our $VERSION = 1.0;

#=------------------------------------------------------------------------( use, constants )

# --- find bin ---
use FindBin qw/$Bin/;
use lib $Bin."/../";

# --- cpan libs ---



#=------------------------------------------------------------------------( functions )


use Params qw(:short);
use Params::Declare;
#=------------------------------------------------------------------------( main )

#=-------
#  test
#=-------
#* put_description_here
#* RETURN: put_return_value_here
sub test (!test : String[10] = *3,4,1*; ?ima: Int[3] ) { 
    print "aa" 
} 
    #my $self = __@_;

    #my $p_test = rq 'test', 'String', 'as';
#    print "mamy: $p_test\n";

#=----------
#  testing
#=----------
#* put_description_here
#* RETURN: put_return_value_here
sub testing (
    !test : String[5] = *as*; 
    ?lee : Int;
    ?lee : = 5;
    
) 
{
    #my $self = __@_;
    #my $p_test = rq 'test', 'String', 'as';
 #   print "mamy: $p_test\n";
}

test(test=> "2");



