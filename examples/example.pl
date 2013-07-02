#!/usr/bin/env perl
#*
#* Name: example.pl
#* Info: just an example of syntax
#* Author: Pawel Guspiel (neo77) <merlin@panth-net.com>
#*
package ParamsTest;

no strict;
use warnings;

our $VERSION = 1.0;

#=------------------------------------------------------------------------( use, constants )

# --- find bin ---
use FindBin qw/$Bin/;
use lib $Bin."/../lib";

use Params::Declare;
use Params qw(:short);
# --- cpan libs ---




#=------------------------------------------------------------------------( typedef definitions )

typedef 'name', 'String[20]';

#=------------------------------------------------------------------------( functions )



sub new(
            ! name:;                            --- name of the user 
            ? second_name : name = *unknown*;   --- second name
            ? details : String = **;    
    ) {
  
  return bless { 
                name        => $p_name,
                second_name => $p_second_name,
                details     => $p_details, 
            }, 'ParamsTest';
}

my $pawel = new(name => 'Pawel', details => 'bzebeze');

use Data::Dumper;
warn Data::Dumper->Dump([\$pawel], ['pawel']);
__END__
            ! name:;                             # this is using default type for required parameter name without default value
            ? second_name : name : *unknown*;   # this is using name typee for optional parameter name with default value set to 'unknown'
            ? details : String = **;            # unlimited string for optional parameter details
    ) {
sub get_name {
    my $self = __@_;

    my $p_first          = rq 'first', 'Bool', 1; # this is using default type for required parameter name without default value

    no_more;
    return +($p_first) ? $self->{'name'} : $self->{'second_name'};
}

sub print_message {
    my $self = __@_;
    
    my $p_name          = rq 'name', DEFAULT_TYPE, $self->get_name; # default value is taken from other function, so no more will be required
    my $p_text          = rq 'text', 'String', ''; # text for the message
    
    print "For: $p_name\n\nText:\n$p_text\n\n";
}

my $pawel = new(name => 'Pawel', details => 'bzebeze');
my $lucja = new(name => 'Lucja', second_name => 'Marta');

print "Message for Gabriela / explicte set in function\n";
$pawel->print_message(name => 'Gabriela', text => 'Some message for you has arrived');

print "Message for Pawel / taken from object\n";
$pawel->print_message( text => 'Some message for you has arrived');
print "Text is missed, and now uncomment no_more in get_name function to mark that all parameters was taken and get data from stack\n";

typedef 'myname', 'name';
print Params::__get_efective_type('myname');


#=------------------------------------------------------------------------( main )




