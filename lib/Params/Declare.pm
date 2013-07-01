#!/usr/bin/perl
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
            while (my ($orig_sub, $sub_name, $sub_vars) = $_ =~  /(sub\s+(\w+)\s*\(\s*(.+?)\s*\))/s) { 
            
                my $variables = 'my $self = __@_; ';
                $sub_vars =~ s/\n//;

                for my $param (split /\s*;\s*/, $sub_vars) {
                    warn "$param\n";
                    $param =~ /^(?<is_rq>[!?]) \s* (?<param_name>\w+) \s* : \s* (?<param_type>\w+ (?:\[.+?\])? )? \s* (?:= \s* (?<default>.+))?$/x ;
                    my $is_rq = $+{'is_rq'} eq '!';
                    my ($param_name, $param_type, $default) = ($+{'param_name'}, $+{'param_type'}, $+{'default'});
                    $param_type ||= $param_name;

                warn "i: $is_rq, pn: $param_name, t: $param_type, d: $default\n";
                }
=pod
                my ($rq, $name, $type, $default) = ('')x4;
                    $vars =~ s/^([!\?])(\w+)// and ($rq, $name) = ($1, $2);
                    $vars =~ s/^\s*[:]\s*([^=;]+)// and ($type) = ($1);
                    $vars =~ s/^\s*[=]\s*([^;]+)// and ($default) = ($1);
                    $type =~ s/\s*$//;
                    $vars =~ s/^\s*;\s*//;
                    $variables .= "my \$p_$name = ".(($rq eq '!')?'rq':'op')." '$name', '$type', $default; ";
                warn $variables;
                }
=cut
            # --- for errors in correct lines 
            my $new_lines = "\n"x($orig_sub =~ s/\n/\n/gs);
            s/\Q$orig_sub/$sub_name $new_lines/;
           } 
        }


