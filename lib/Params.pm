#!/usr/bin/perl
#* Name: Params
#* Info: Simple Global Params Management System
#* Author: Pawel Guspiel (neo77), <merlin@panth-net.com>
#*
#* First. If you can use any function as in natural languague - you will use and understand even after few months
#* Second. Your lazy life will be easy, and you will reduce a lot of errors if you will have guarancy that your parameter
#*   for example ,,client'', in whole project will be defined as string(32).
#* Third. You are lazy, so to have this guarancy you want to set it in one, and only in one place.
#* DRY principle in its pure form!
#*
#* That's all. Easy to use. Easy to manage. Easy to understand.
#*
#* Additional informations
#* 1. I didn't wrote here any special extensions (callbacks, ordered parameter list, evals etc). Params module has to be fast.
#* If there will be any extension in future. It will be in separate module.
#* 2. Ordered parameters list or named parameter list? Named parameter list. For sure.
#* Majority of the time you are spending on READING code, not writing it. So for sure named parameter list is better.
#*

package Params;
    
    use strict;
    use warnings;

    use 5.10.0;

    # --- version ---
    our $VERSION = 1.0_0;

    #=------------------------------------------------------------------------ { use, constants }

    use Carp;             # confess
    use Params::Types;    # to mark that will reserving this namespace (build in types)

    use constant DEFAULT_TYPE => 1;        # default check (for param_op)
    use constant TRUE         => 1;        # true
    use constant FALSE        => 0;        # and false
    use constant OK           => TRUE;     # true
    use constant NO           => FALSE;    # false

    our $Debug = FALSE;                    # use Debug mode or not

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
    # RETURN: dies
    sub _error {
        ($Params::Debug) ? confess(@_) : die(@_);
    }

    #=-----------------------
    #  __get_effective_type
    #=-----------------------
    #* counts effective type of type (ex. for super_client base type is client and for client base type is String[20]
    #* so for super_client final type will be String[20])
    #* RETURN: final type string
    sub __get_effective_type {
        my $param_type = $Params::Internal::typedefs{"$_[0]"};
        $param_type ? __get_effective_type($param_type) : $_[0];
    }

    #=--------------------
    #  __check_parameter
    #=--------------------
    #* checks validity of the parameter
    #* RETURN: param value
    sub __check_parameter {
        my ( $p_name, $p_type, $p_default, $p_is_required ) = @_;

        # --- check internal syntax ---
        _error("Name of the parameter has to be defined") unless $p_name;

        # --- detect type (set explicite or get it from name?)
        my $counted_param_type = ( !defined($p_type) or ( $p_type =~ /^\d+$/ and $p_type == DEFAULT_TYPE ) ) ? $p_name : $p_type;

        # --- check effective parameter definition
        my $effective_param_type = __get_effective_type($counted_param_type);

        # --- check effective parameter definition for used name (if exists) and if user is not trying to replace name-type with new one (to keep clean naminigs)
        if ( $Params::Internal::typedefs{"$p_name"} ) {
            my $effective_name_type = __get_effective_type($p_name);
            _error("This variable $p_name is used before in code as $p_name type ($effective_name_type) and here you are trying to redefine it to $counted_param_type ($effective_param_type)")
              if $effective_name_type ne $effective_param_type;
        }

        # --- get package, function and parameters
        my ( $type_package, $type_function, $parameters ) = $effective_param_type =~ /^(?:(.+)::)?([^\[]+)(?:\[(.+?)\])?/;

        my $final_type_package = ($type_package) ? 'Params::Types::' . $type_package : 'Params::Types';

        my @type_parameters = split /\s*,\s*/, $parameters // '';

        # --- set default type unless type ---
        _error("Type $counted_param_type ($effective_param_type) is not defined") unless $final_type_package->can("$type_function");

        # --- getting final parameter value ---
        my $param_value = ( $Params::Internal::current_params->{"$p_name"} ) // $p_default // undef;

        my $check_function = $final_type_package . '::' . $type_function;

        # --- required / optional
        if ( !defined($param_value) ) {
            ($p_is_required) ? _error("Parameter '$p_name' is required)") : return;
        }

        # --- check if is valid
        {
            no strict 'refs';
            &$check_function( $param_value, @type_parameters ) or _error("Parameter '$p_name' is not '$counted_param_type' type (effective: $effective_param_type)");
        }

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

        return __check_parameter( $p_name, $p_type, $p_default, TRUE );
    }

    #=-----
    #  op
    #=-----
    #* check if required parameter exists, if yes check it, if not return undef
    #* RETURN: param value
    sub op($;$$) {
        my ( $p_name, $p_type, $p_default ) = @_;

        return __check_parameter( $p_name, $p_type, $p_default, FALSE );
    }

    #=---------
    # typedef
    #=---------
    #* make relation between name and definition, which can be used to check param types
    #* RETURN: name of the type
    sub typedef($$) {
        my ( $p_name, $p_definition ) = @_;

        if ( exists $Params::Internal::typedefs{$p_name} ) {
            _error("Error parameter $p_name already defined as $p_definition") if
                __get_effective_type($Params::Internal::typedefs{$p_name}) ne __get_effective_type($p_definition);
        }

        # --- just add new definition
        $Params::Internal::typedefs{$p_name} = $p_definition;

        return $p_name;

    }

    #=-----
    #  __
    #=-----
    #* gets the parameters to internal use
    # RETURN: first param if params like (object, %params) or undef otherwise
    sub __ {
        my $self = ( ( scalar @_ % 2 ) ? shift : undef );
        push @Params::Internal::params_stack, {@_};
        $Params::Internal::current_params = $Params::Internal::params_stack[-1];

        return $self;
    }

    # MARK strict mode
    #=----------
    #  no_more
    #=----------
    #* mark end of param processing part
    #* required in case param call during param checking
    # RETURN: current params
    sub no_more() {
        pop @Params::Internal::params_stack;
        $Params::Internal::current_params = $Params::Internal::params_stack[-1];
    }

# --- add additional names for funtions (long)
    
    *param_rq = *rq;
    *param_op = *op;


7&&7;

#+ End of Params
