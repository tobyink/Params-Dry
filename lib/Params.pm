#!/usr/bin/perl
#* Name: Params
#* Info: Simple Global Params Management System
#* Author: Pawel Guspiel (neo77), <merlin@panth-net.com>
#*
#* First. If you can use any function as in natural languague - you will use and understand even after few months
#* Second. Your lazy life will be easy, and you will reduce a lot of errors if you will have guarancy that your parameter
#*   for example ,,client'', in whole project will be defined as string(32).
#* Third. You are lazy, so to have this guarancy you want to set in in one, and only in one place.
#*
#* That's all. Easy to use. Easy to manage. Easy to understand.
#*
#* What is not implemented
#* 1. I didn't wrote here any special extensions (callbacks, ordered parameter list, evals etc). Params module has to be fast.
#* If there will be any extension in future. It will be in separate module.
#* 2. Ordered parameters list or named parameter list? Named parameter list. For sure.
#* Majority of the time you are spending on READING code, not writing it. So for sure named parameter list is better.
#*

package Params;
use strict;
use warnings;

    use 5.10.1;

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


#=------------------------------------------------------------------------ { export }

# import strict params

    use Exporter;	# to export _ rq and opt
    our @ISA = qw(Exporter);

    our @EXPORT_OK = qw(__ rq op typedef no_more DEFAULT_TYPE param_rq param_op);

    our %EXPORT_TAGS = (
        short => [ qw(__ rq op typedef no_more DEFAULT_TYPE) ],
        long  => [ qw(__ param_rq param_op typedef no_more DEFAULT_TYPE) ]
    );

#=------------------------------------------------------------------------ { module functions }

    #=---------
    #  _error
    #=---------
    #* printing error message
    # RETURN: dies
    sub _error {

        die(@_);
        confess(@_);
    };

    #=----------------------
    #  __get_efective_type
    #=----------------------
    #* counts efective type of type (ex. for super_client base type is client and for client base type is String[20]
    #* so for super_client final type will be String[20])
    #* RETURN: final type string
    sub __get_efective_type {
        my $param_type = $Params::Internal::typedefs{ "$_[0]" };
        $param_type ? __get_efective_type($param_type) : $_[0];
    }


    #=--------------------
    #  __check_parameter
    #=--------------------
    #* checks validity of the parameter
    #* RETURN: param value
    sub __check_parameter {
        my ($p_name,$p_type,$p_default, $p_is_required) = @_;

        # --- check internal syntax ---
        _error("Name of the parameter has to be defined") unless $p_name;

        # --- detect type (set explicite or get it from name?)
        my $counted_param_type =  (!defined($p_type) or ($p_type =~ /^\d+$/ and $p_type == DEFAULT_TYPE)) ? $p_name : $p_type;

        # --- check efective parameter definition
        my $efective_param_type = __get_efective_type($counted_param_type);

        # --- check efective parameter definition for used name (if exists) and if user is not trying to replace name-type with new one (to keep clean naminigs)
        if ($Params::Internal::typedefs{"$p_name"}) {
            my $efective_name_type = __get_efective_type($p_name);
            _error("This variable $p_name is used before in code as $p_name type ($efective_name_type) and here you are trying to redefine it to $counted_param_type ($efective_param_type)")
                if $efective_name_type ne $efective_param_type;

        }

        # --- get package, function and parameters
        my ($type_package, $type_function, $parameters) = $efective_param_type =~ /^(?:(.+)::)?([^\[]+)(?:\[(.+?)\])?/;

        my $final_type_package = ($type_package) ? 'Params::Types::'.$type_package : 'Params::Types';

        my @type_parameters = split /\s*,\s*/, $parameters // '';


        # --- set default type unless type ---
        _error("Type $counted_param_type ($efective_param_type) is not defined") unless $final_type_package->can("$type_function");

        # --- getting final parameter value ---
        my $param_value = ($Params::Internal::current_params->{"$p_name"}) // $p_default // undef;

        my $check_function = $final_type_package.'::'.$type_function;

        # --- required / optional
        if (!defined($param_value)) {
            ($p_is_required) ? _error("Parameter '$p_name' is required)") : return;
        } 

        # --- check if is valid
        {
            no strict 'refs';
            &$check_function($param_value, @type_parameters) or _error("Parameter '$p_name' is not '$counted_param_type' type (efective: $efective_param_type)");
        }

        $param_value;
    }

    #=-----
    #  rq
    #=-----
    #* check if required parameter exists, if yes check it, if not report error
    #* RETURN: param value
    sub rq($;$$) {
        my ($p_name,$p_type,$p_default) = @_;

        return __check_parameter($p_name, $p_type, $p_default, TRUE)
    }
    
    #=-----
    #  op
    #=-----
    #* check if required parameter exists, if yes check it, if not return undef
    #* RETURN: param value
    sub op($;$$) {
        my ($p_name,$p_type,$p_default) = @_;

        return __check_parameter($p_name, $p_type, $p_default, FALSE)
    }

    #=---------
    # typedef
    #=---------
    #* make relation between name and definition, which can be used to check param types
    #* RETURN: name of the type
    sub typedef($$) {
        my ($p_name, $p_definition) = @_;

        if ( exists $Params::Internal::typedefs{$p_name} ) {
            _error("Error parameter $p_name already defined as $p_definition") if $Params::Internal::typedefs{ $p_name } ne $p_definition;
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
        my $self = ((scalar @_ % 2) ? shift : undef);
        push @Params::Internal::params_stack, { @_ };
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
    sub no_more {
        pop @Params::Internal::params_stack;
        $Params::Internal::current_params = $Params::Internal::params_stack[-1];
    }


__END__
    #=-----
    #  op
    #=-----
    #* check if optional parameter exists, if yes checks it
    #* RETURN: param value
    sub op($;$$) {
        my ($p_name,$p_type,$p_default) = @_;

        my ($param_value, $param_type) = _get_param_value(@_);

        # --- param is optional ---		# can be undef
        return if (!defined($param_value));

        # --- check if is valid
        {
            no strict 'refs';
            &{"Params::Types::$param_type"}($param_value, @{$Params::Types::_parameters{$param_type}}) or _error("Parameter $p_name is not $param_type type");
        }

        $param_value;
    }


    no warnings;
    *param_rq = *rq;
    *param_op = *op;
    *__turtle = *__;	# required in tests
    use warnings;

77&&77



__END__
    #=---------------
    #  _typedef_try
    #=---------------
    #* checking if new type can be defined
    #* RETURN: pair (definition, params) of the type or _error
    sub _typedef_try {
        my ($p_name, $p_definition) = @_;

        _error('Bad type name: '.($p_name||'(empty)').', only \w is allowed in type names') if ((not $p_name or ref $p_name) or ("$p_name" =~ /[\W]/));

        my $type = ref($p_definition);
        my $definition;
        my $parameters;
my $parent_params;
        # --- type is defined as string
        if (!$type) {
            my ($name, $params) = $p_definition =~ /(\w+)(?:\((.+?)\))?/;
            _error("Invalid type definition $p_name") unless $name;
            _error("Parent type $name not defined") unless Params::Types->can("$name");
            {
                no strict 'refs';
                $definition = \&{"Params::Types::$name"};
$parent_params = $Params::Types::_parameters{$p_definition};
            }

            my @params =  ($params) ? (split /\s*,\s*/,  $params) : (@{$parent_params || []});

            # --- check if parameter list is the same (if not trying to redefine parameter type /parameter part/)
            if ((exists $Params::Types::_parameters{$p_name}) and not (@{$Params::Types::_parameters{$p_name}} ~~ @params)) {
                _error("Parameter list for '$p_name' different than previously defined (now: (@params), before: (@{$Params::Types::_parameters{$p_name}}))");
            }
            $parameters = [ @params ];

        # --- type is not defined nor as string nor as code ref - so illegal
        } elsif ($type ne 'CODE') {
            _error('type definition can be or string or code ref');

        # --- directly code
        } else {
            $definition = $p_definition;
        }


        # --- check if no trying to redefine parameter type /source part/
        _error("Can't redifine '$p_name'") if (Params::Types->can("$p_name")) and ($definition ne  \&{"Params::Types::$p_name"});

        return ($definition, $parameters);
    }

    #=----------
    #  typedef
    #=----------
    #* real defining new types (using buildins or already defined)
    #* RETURN: name of the type or _error
    sub typedef($$) {
        my ($p_name, $p_definition) = @_;

        my ($definition, $params) = _typedef_try(@_);

        # --- just add new definition
        {
            no strict 'refs';
            *{"Params::Types::$p_name"} = $definition;
        }

        # --- and parameters
        $Params::Types::_parameters{$p_name} = $params;

        return $p_name;
    }


    {
        state %params;
        state @params_stack;

        #=-----
        #  __
        #=-----
        #* gets the parameters to internal use
        # RETURN: first param if params like (object, %params) or undef otherwise
        sub __ {
            my $self = ((scalar @_ % 2) ? shift : undef);
            push @params_stack, { %params } if %params;
            %params = @_;
            return $self;
        }

        #=-----------------------
        #  __get_current_params
        #=-----------------------
        #* return current params hash (is used only in tests)
        #* RETURN: hashref
        sub __get_current_params {
            \%params;
        }

        #=-----------------------------
        #  __get_current_params_stack
        #=-----------------------------
        #* return current params stack (is used only in tests)
        #* RETURN: arrayref
        sub __get_current_params_stack {
            \@params_stack;
        }

        #=-------------------
        #  _get_param_value
        #=-------------------
        #* geting param value
        #* RETURN: final value of the param
        sub _get_param_value {
            my ($p_name,$p_type,$p_default) = @_;

            # --- check syntax ---
            _error("Name of the parameter has to be defined") unless $p_name;

            # --- set default type unless type ---
            my $param_type =  (!defined($p_type) or ($p_type =~ /^\d+$/ and $p_type == DEFAULT_TYPE)) ? $p_name : $p_type;
            _error("Type $param_type is not defined") unless Params::Types->can("$param_type");

            # --- check if not trying to redefine type
            _typedef_try($p_name, $param_type);

            # --- getting final parameter value ---
            my $param_value = ($params{"$p_name"}) // $p_default // undef;
            delete( $params{$p_name} );     # for no_more;

            return $param_value => $param_type;
        }

        #=----------
        #  no_more
        #=----------
        #* marks that no more parameters should be provided
        # RETURN: OK or _error if not all was taken
        sub no_more {
            _error('Found additional parameters: '.(join ', ', sort keys %params)) if (keys %params);
            %params = %{ pop @params_stack } if @params_stack;

            OK;

        }
    }

# MARK I M HERE FIXME

    #=-----
    #  rq
    #=-----
    #* check if required parameter exists, if yes check it, if not report error
    #* RETURN: param value
    sub rq($;$$) {
        my ($p_name,$p_type,$p_default) = @_;

        my ($param_value, $param_type) = _get_param_value(@_);

        if (!defined($param_value)) {
            _error("Parameter $p_name is required)");
        }

        # --- check if is valid
        {
            no strict 'refs';
            &{"Params::Types::$param_type"}($param_value, @{$Params::Types::_parameters{$param_type}}) or _error("Parameter $p_name is not $param_type type");
        }

        $param_value;
    }

    #=-----
    #  op
    #=-----
    #* check if optional parameter exists, if yes checks it
    #* RETURN: param value
    sub op($;$$) {
        my ($p_name,$p_type,$p_default) = @_;

        my ($param_value, $param_type) = _get_param_value(@_);

        # --- param is optional ---		# can be undef
        return if (!defined($param_value));

        # --- check if is valid
        {
            no strict 'refs';
            &{"Params::Types::$param_type"}($param_value, @{$Params::Types::_parameters{$param_type}}) or _error("Parameter $p_name is not $param_type type");
        }

        $param_value;
    }



=pod







# typedef  - definiuje konkretny typ parametru jako relacje nazwa => definicja
#
    typedef 'aaa', 'Int';
# TODO (autoACR): add description for type ,aaa'
    typedef 'aaa', 'Int(3)';
# TODO (autoACR): add description for type ,aaa'
    typedef 'aaa', 'ccc';
# TODO (autoACR): add description for type ,aaa'
    typedef 'aaa', {
            parent INT(3),
            less_then 3,
            max_length 4,

    }; # additional module

    typedef 'aaa', {
            def => 'ooo',
            less_then => 3,
    };
    typedef 'aaa', {
            def => 'ooo',
            less_then => 3,
            validator => sub { }
    };


=cut


#=----
#  a
#=----
#* put_description_here
#* RETURN: put_return_value_here
sub a {
    1;
}
# TODO (autoACR): update function/group documentation at header (put_description_here)
# TODO (autoACR): update function documentation at header (put_return_value_here)


0115&&0x4d;
use Params::Types; # client definition
typedef client => 'String(30)';
typedef client => 'String(30)';
#    typedef 'client', \&a;
#    typedef 'client', \&a;

__END__
    typedef 'client', \&a;
# TODO (autoACR): add description for type ,client'
    typedef 'subcl', 'client(20,10)';
# TODO (autoACR): add description for type ,subcl'
    typedef 'customer', 'String(5)';
# TODO (autoACR): add description for type ,customer'


print Params::Types::customer('ali', @{$parameters->{'customer'}})+0;
use Data::Dumper;
# FIXME (autoACR): write why are you using Data::Dumper (do you realy need it?)
warn Data::Dumper->Dump([\$parameters ], ['parameters ']);


__END__


#+--------------------------------------------------------------- {public functions}


String(5)
Int(3)
Float(2,3);
Object(Type)
ArrayRef
HashRef
Scalar
Coderef
Glob
Globref
Scalarref
Undef
Boolean
Handle




    #=-------------------
    #  DEBUG_dump_types
    #=-------------------
    #* print all defined types
    #* RETURN: 1
    sub DEBUG_dump_types {
        \%types_definitions;
    }

    #=-----------
    #  param_rq
    #=-----------
    #* required params
    # RETURN: param value
    sub param_rq($;$$) {
        my ($p_name,$p_type,$p_default) = @_;

        # --- check syntax ---
        _error("Syntax Error: name of the parameter has to be defined") unless $p_name;

        # --- set default type unless type ---
        $p_type = DEF unless $p_type;

        # --- set function name if allready not set ---
        $funct = (caller(1))[3];

        # --- param has to be defined ---
        my $param_value = $params{"$p_name"} // $p_default // undef;
        delete( $params{$p_name} );     # for all_params_taken;

        if (!defined($param_value)) {
            _error("Runtime Error: parameter $p_name is required ($funct)");
        }

        # --- get the final type ---
        my ($final_type_name, $final_type) = __PACKAGE__->_get_final_type(type=>$p_type, name=>$p_name);

        # --- check param type ---
        __PACKAGE__->_check_type(param_name=>$p_name, param_value=>$param_value, final_type=>$final_type, final_type_name=>$final_type_name);

        return $param_value;
    }





} # MARK --- END OF BLOCK ---


# MARK a na chuj mnie ten kaktus?

{	# MARK --- START OF BLOCK ---

    my %types_definitions = (
        'INT' => qr/-?\d+/,
        'FLOAT' => qr/-?\d+(\.\d+)?/,
        'ANYTHING' => qr/.+/ms,
        'ANYTHING_OR_EMPTY' => qr/.*/ms,
        'STRING' => qr/.+/,
        'PERL' => qr/\w+/,
        'PERLMODULE' => qr/[\w:]+/,
        'ARRAYREF' => 'ARRAY',
        'HASHREF' => 'HASH',
        'SCALARREF' => 'SCALAR',
        'CODEREF' => 'CODE',
        'REGEXP' => 'Regexp',
        'ARRAY' => 'ARRAY',
        'HASH' => 'HASH',
        'SCALAR' => 'SCALAR',
        'CODE' => 'CODE',
        'GLOB' => 'GLOB',
        'OBJECT' => sub {
            return ref $_[0] ? YES : NO;
        },
        'HANDLE' => sub {
            my ($p_value) = @_;
            my $ref = ref($p_value);
            return (($ref eq 'GLOBREF') or ($ref eq 'GLOB'));
        },
        'BOOL' => sub {
            my ($p_value) = @_;
            return($p_value == TRUE or $p_value == FALSE)
        },
    );

    my %params;		# list of function params
    my $funct;		# name of caller function




