#* Name: Params::Dry
#* Info: Simple Global Params Management System
#* Author: Pawel Guspiel (neo77) <neo@cpan.org>
#*
#* First. If you can use any function as in natural languague - you will use and understand it even after few months.
#*
#* Second. Your lazy life will be easy, and you will reduce a lot of errors if you will have guarancy that your parameter
#*   for example ,,client'', in whole project means the same ( ex. is defined as string(32) ).
#*
#* Third. You are lazy, so to have this guarancy, you want to set it, in one and only in one place.
#*
#* Yes, DRY principle in its pure form!
#*
#* So all what you can find in this module. 
#*
#* That's all. Easy to use. Easy to manage. Easy to understand.
#*
#* Additional informations
#* 1. I didn't wrote here any special extensions (callbacks, ordered parameter list, evals etc). Params module has to be fast.
#* If there will be any extension in future. It will be in separate module.
#* 2. Ordered parameters list or named parameter list? Named parameter list. For sure.
#* Majority of the time you are spending on READING code, not writing it. So for sure named parameter list is better.
#*

package Params::Dry;
    
    use strict;
    use warnings;

    use 5.10.0;

    # --- version ---
    our $VERSION = 1.06;

    #=------------------------------------------------------------------------ { use, constants }

    use Carp;                   # confess
    use Params::Dry::Types;     # to mark that will reserving this namespace (build in types)

    use constant DEFAULT_TYPE => 1;        # default check (for param_op)
    use constant TRUE         => 1;        # true
    use constant FALSE        => 0;        # and false
    use constant OK           => TRUE;     # true
    use constant NO           => FALSE;    # false

    our $Debug      = FALSE;               # use Debug mode or not

    use Type::Utils ();
    use Type::Registry ();

    our $REG = __initialize_registry();
    sub __initialize_registry {
        my $r = 'Type::Registry'->new;
        $r->add_types('Params::Dry::Types');
        return $r;
    }

    #=------------------------------------------------------------------------ { export }

    # import strict params

    use Exporter;    # to export _ rq and opt
    our @ISA = qw(Exporter);

    our @EXPORT_OK = qw(__ rq op typedef no_more DEFAULT_TYPE param_rq param_op);

    our %EXPORT_TAGS = (
        short => [qw(__ rq op typedef no_more DEFAULT_TYPE)],
        long  => [qw(__ param_rq param_op typedef no_more DEFAULT_TYPE)]
    );


    #=------------------------------------------------------------------------ { module private functions }

    #=---------
    #  _error
    #=---------
    #* printing error message
    # RETURN: dies (in case of Debug is making confess)
    sub _error {
        ($Params::Dry::Debug) ? confess(@_) : die(@_);
    }

    #=--------------------
    #  __check_parameter
    #=--------------------
    #* checks validity of the parameter
    #* RETURN: param value
    sub __check_parameter {
        my ( $p_name, $p_type, $p_default, $p_is_required) = @_;

        # --- check internal syntax ---
        _error("Name of the parameter has to be defined") unless $p_name;

        # --- getting final parameter value ---
        my $param_value = ( $Params::Dry::Internal::current_params->{"$p_name"} ) // $p_default // undef;

        # --- required / optional
        if ( !defined($param_value) ) {
            ($p_is_required) ? _error("Parameter '$p_name' is required)") : return;
        }

        return $param_value if !ref($p_type) && $p_type eq DEFAULT_TYPE;

        # --- get type
        state %_cache;
        my $type_function = ref($p_type)
            ? $p_type->compiled_check
            : ( $_cache{$p_type} //= $REG->lookup($p_type)->compiled_check );

        # --- check if is valid
        $type_function->($param_value)
            or _error("Parameter '$p_name' is not '$p_type' type");

        $param_value;
    }

    #=------------------------------------------------------------------------ { module public functions }

    #=-----
    #  rq
    #=-----
    #* check if required parameter exists, if yes check it, if not report error
    #* RETURN: param value
    sub rq($;$$) {
        my ( $p_name, $p_type, $p_default ) = @_;

        return __check_parameter( $p_name, $p_type, $p_default, TRUE, scalar caller );
    }

    #=-----
    #  op
    #=-----
    #* check if required parameter exists, if yes check it, if not return undef
    #* RETURN: param value
    sub op($;$$) {
        my ( $p_name, $p_type, $p_default ) = @_;

        return __check_parameter( $p_name, $p_type, $p_default, FALSE, scalar caller );
    }

    #=---------
    # typedef
    #=---------
    #* make relation between name and definition, which can be used to check param types
    #* RETURN: name of the type
    sub typedef($$) {
        my ($newname, $oldname) = @_;
        my $type = $REG->lookup($oldname)
            or _error("could not find type: $oldname");
        if (exists $REG->{$newname} and not $REG->{$newname}==$type) {
            _error("Error parameter $newname already defined")
        }
        $REG->{$newname} = $type;
        return $newname;
    }

    #=-----
    #  __
    #=-----
    #* gets the parameters to internal use
    # RETURN: first param if params like (object, %params) or undef otherwise
    sub __ {
        my $self = ( ( scalar @_ % 2 ) ? shift : undef );
        push @Params::Dry::Internal::params_stack, {@_};
        $Params::Dry::Internal::current_params = $Params::Dry::Internal::params_stack[-1];

        return $self;
    }

    #=----------
    #  no_more
    #=----------
    #* mark end of param processing part
    #* required in case param call during param checking
    # RETURN: current params
    sub no_more() {

        pop @Params::Dry::Internal::params_stack;
        $Params::Dry::Internal::current_params = $Params::Dry::Internal::params_stack[-1];
    }

    # --- add additional names for funtions (long)

    *param_rq = *rq;
    *param_op = *op;



0115&&0x4d;

# ABSTRACT: Simple Global Params Management System

#+ End of Params::Dry
__END__
=head1 NAME

Params::Dry - Simple Global Params Management System which helps you to keep DRY rule

=head1 VERSION

version 1.05

=head1 SYNOPSIS

=head2 Fast start!

=over 4

=item * B<typedef> - defines global types for variables

=item * B<__@_> - starts parameter fetching

=item * B<rq/param_rq> - get required parameter

=item * B<op/param_op> - get optional parameter

=item * B<no_more> - marks that all parametrs has been fetched (required only in some cases)

=back 

=head2 Example:

    package ParamsTest;

    use strict;
    use warnings;

    our $VERSION = 1.0;

    #=------------------------------------------------------------------------( use, constants )

    use Params::Dry qw(:short);

    #=------------------------------------------------------------------------( typedef definitions )

    # --- how to define types?  - its Easy :)
    typedef 'name', 'String[20]';   
  
    typedef 'subname', 'name';  # even Easier :)  

    #=------------------------------------------------------------------------( functions )


    sub new {
        
        # --- using parameters :)
        
        my $self = __@_;    # inteligent __ function will return $self on '$self->new' call or undef on 'new' call
        
        # --- geting parameters data 

        #+ required parameter name (in 'name' (autodetected) type (see typedefs above) with no default value)
        my $p_name          = rq 'name'; # this is using default type for required parameter name without default value

        #+ optional parameter second_name (in 'name' type (see typedefs above) with default value 'unknown')
        my $p_second_name   = op 'second_name', 'name', 'unknown'; # this is using name typee for optional parameter name with default value set to 'unknown'

        #+ optional parameter details (in build-in 'String' type  with default value '')
        my $p_details       = op 'details', 'String', ''; # unlimited string for optional parameter details
        
        return bless { 
                    name        => $p_name,
                    second_name => $p_second_name,
                    details     => $p_details, 
                }, 'ParamsTest';
    }

    my $lucja = new(name => 'Lucja', second_name => 'Marta');

B<More you can find in examples>

=head1 DESCRIPTION

=head2 Understand main concepts 

First. If you can use any function as in natural languague - you will use and understand it even after few months.

Second. Your lazy life will be easy, and you will reduce a lot of errors if you will have guarancy that your parameter 
in whole project means the same ( ex. when you see 'client' you know that it is always String[32] ).

Third. You want to set the type in one and only in one place.

Yes, DRY principle in its pure form!

So all your dreams you can now find in this module. 

B<That's all. Easy to use. Easy to manage. Easy to understand.>

=head1 EXPORT

=over 4

=item * B<:short> - imports: 'op', 'rq' and common ones

=item * B<:long> - imports: 'param_op', 'param_rq' and common ones

=back

Common ones mean: '__', 'typedef', 'no_more', DEFAULT_TYPE


=head1 CONSTANTS AND VARIABLES

=over 4

=item * B<TRUE> - set to 1

=item * B<FALSE> - set to 0

=item * B<OK> - set to TRUE (1)

=item * B<NO> - set to FALSE (0)

=item * B<DEFAULT_TYPE> - to mark that you want to use default type

=item * B<$Debug> - if set to TRUE (default: FALSE) will show more debug

=back 

=head1 SUBROUTINES/METHODS


=head2 B<__> - turtle operator

Start getting the parameters. Used on the begin of the function

    sub pleple {
        my $self = __@_;    

RETURN: first param if was called like $obj->pleple(%params) or undef on pleple(%params) call 


=head2 B<rq> or B<param_rq> - required parameter

Check if required parameter exists, if yes check if its valid, if not, report error
    
B<rq> C<in param name> [C<in param type>, [C<default value>]]

    sub pleple {
        my $self = __@_;

        my $p_param1 = rq 'param1'; # assuming that param1 is defined before by typedef
        my $p_param2 = rq 'param2', 'String';
        my $p_param3 = rq 'param3', 'String', 'Default value';
        my $p_param4 = rq 'param4', DEFAULT_TYPE, 'Default value'; # assuming that param4 is defined before but wanted to give default value

    ...

    pleple(param1 => 'test', param2 => 'bleble');

RETURN: parameter value

=head2 B<op> or B<param_op> - optional parameter

Check if required parameter exists, if yes check it, if not return undef
    
B<op> C<in param name> [C<in param type>, [C<default value>]]

C<see above>

    my $p_param1 = op 'param1'; # .. see above

RETURN: parameter value

=head2 B<no_more> - marks that no more parameters will be readed

It can be useful in some cases, for example whan default value of the param is the 
function call and this function is using parameters as well. 

The function is getting from internal stack previous parameters

Example.

    sub get_val {
        my $self = __@_;
        
        my $p_name = rq 'name';
        
        no_more; # to give back old parameters
        
    }
    
    sub main {
        my $self = __@_;
        
        my $p_nick = rq 'nick', 'String', $self->get_val(name => 'somename');
        
    }

It is good practice to use no_more at the end of geting parameters
Also the strict parameter checking implementation is planed in next releases
(so using no_more you will be able to die if apear more parameters that was fetched - to avoid misspelings)

=head1 BUILD IN TYPES

=over 4

=item * B<String> - can be used with parameters (like: String[20]) which mean max 20 chars string

=item * B<Int> - can be used with parameters (like: Int[3]) which mean max 3 chars int not counting signs

=item * B<Float> - number with decimal part

=item * B<Bool> - boolean value (can be 0 or 1)

=item * B<Object> - check if is an object. Optional parameter extend check of exact object checking ex. Object[DBI::db]

=item * B<Ref> - any reference, Optional parameter defines type of the reference

=item * B<Scalar> - short cut of Ref[Scalar] 

=item * B<Array> - short cut of Ref[Array] 

=item * B<Hash> - short cut of Ref[Hash] 

=item * B<Code> - short cut of Ref[Code] 

=back

=head2 Extending internal types

You can always write your module to check parameters.

Example.

    package MyTypes;
    
    use Type::Library -base;
    use Type::Utils;
    use Params::Dry::Types 'String';
    
    declare 'SuperString',
        as String,
        where { /Super/ };
    
    ...

    package main;
    
    sub test {
        my $self = __@_;
        
        my $p_super_name = rq 'super_name', 'MyTypes::SuperString'; # that's all folks!
        
        ...
    }

=head1 ADDITIONAL INFORMATION

B<1. I didn't wrote here any special extensions (callbacks, ordered parameter list, evals etc). Params::Dry module has to be fast.>

If there will be any extension in future. It will be in separate module.

B<2. Ordered parameters list or named parameter list? Named parameter list. For sure.>

Majority of the time you are spending on READING code, not writing it. So for sure named parameter list is better.

=head1 AUTHOR

Pawel Guspiel (neo77), C<< <neo at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-params at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Params-Dry>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Params::Dry
    perldoc Params::Dry::Types


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Params-Dry>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Params-Dry>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Params-Dry>

=item * Search CPAN

L<http://search.cpan.org/dist/Params-Dry/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Pawel Guspiel (neo77).

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


