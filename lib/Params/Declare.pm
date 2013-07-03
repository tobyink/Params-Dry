#!/usr/bin/env perl
#*
#* Name: Params::Declare
#* Info: Extension to Params, which make possible declaration of the parameters
#* Author: Pawel Guspiel (neo77), <merlin@panth-net.com>
#* Details:
#*      The module allow parameters declaration in following form:
#*
#*          sub table (!test : String(3) = *zorba*; ?ala : Int(3) = 3; ?luk = 2  ) {
#*
#*      instead of using:
#*
#*          sub table {
#*              my $self = __@_;
#*
#*              my $p_test = rq 'test', 'String(3), 'zorba';
#*              ...
#*
#*      As a consequence of using this module you can use parameters in the function body as follows:
#*          print "test: ".p_test;
#*
#*      I'm suggesting you to use coloring in your text editor for p_\w+ to see variables every where

package Params::Declare;
use strict;
use warnings;


# --- version ---
   # use vars($VERSION);         # VERSION as global variable
    our $VERSION = 1.0_0;

#=------------------------------------------------------------------------ { use, constants }

    use Filter::Simple;          # extends subroutine definition

#=------------------------------------------------------------------------ { module magic }


    FILTER_ONLY
        code_no_comments => sub {
            while (my ($orig_sub, $sub_name, $sub_declared_vars) = $_ =~  /(sub\s+(\w+)\s*\(\s*(?:(.+?)\s*)?\)\s*{)/s) { 
                 
                # --- clean 
                $sub_declared_vars //= '';
                $sub_declared_vars =~ s/\n//;

                # --- prepare variables string
                my $variables_string = 'my $self = __@_;';

                # --- parse variables
                for my $param (split /\s*;\s*/, $sub_declared_vars) {

                    #+ remove comments
                    $param =~ s/---.+?([?!]|$)/$1/s;

                    next unless $param;

                    #+ parse
                    $param =~ /^(?<is_rq>[!?]) \s* (?<param_name>\w+) \s* : \s* (?<param_type>\w+ (?:\[.+?\])? )? \s* (?:= \s* (?<default>.+))? (?:[#].*)?$/x ;
                    
                    my ($is_rq, $param_name, $param_type, $default) = ('')x4;
                    
                    $is_rq = $+{'is_rq'} eq '!';
                    ($param_name, $param_type, $default) = ($+{'param_name'}, $+{'param_type'}, $+{'default'});
                    $param_type ||= $param_name;

                    $variables_string .= "my \$p_$param_name = ".(($is_rq)?'rq':'op')." '$param_name'";
                    $variables_string .= ", '$param_type'" if $param_type;
                    $variables_string .= ", $default" if $default;
                    $variables_string .= '; ';
                }
                
                # --- for errors in correct lines 
                my $new_lines = "\n"x($orig_sub =~ s/\n/\n/gs);
                s/\Q$orig_sub/sub $sub_name { $new_lines $variables_string no_more;/;

            } 
            $_;
        }

