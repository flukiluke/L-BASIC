#!/usr/bin/perl
# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# prep.perl - Preprocess and prepare
# This is basically a macro expander. It also removes comments.

# A macro is a text-based replacement that for more concise and self-describing code.
# To define a macro, the $macro directive is used. The general syntax is
# $macro: INPUTFORMAT | OUTPUTFORMAT
# Whenever a match is found for INPUTFORMAT, it is replaced by OUTPUTFORMAT. The double-at
# operator @@ may appear multiple times in the INPUTFORMAT. These are matched with a word
# (a word is a string matching [A-Za-z0-9_]+) and can be referred to in the OUTPUTFORMAT
# as @1, @2 etc. counted in order of appearance.
# Content in string literals is not modified.
use strict;
use warnings;

use Data::Dumper;
use String::Substitution qw( gsub_copy );

our %macros;

sub trim {
    my $s = shift;
    $s =~ s/^[ \t]+|[ \t\r]+$//g;
    return $s;
}

sub new_macro {
    my ($pattern, $result) = @_;
    # Escape special characters
    $pattern =~ s/([\\}{\]()\^\$.|*+?])/\\$1/g;
    # Setup matching groups
    $pattern =~ s/@@/([a-zA-Z0-9_]+)/g;
    $result =~ s/@(\d)/\$$1/g;
    $macros{$pattern} = $result;
}

while (<>) {
    if (/^[ \t]*\$macro[ \t]*:([^|]+)\|(.+)/i) {
        new_macro trim($1), trim($2);
    }
    else {
        # Leave double-commented and DATA lines entirely alone
        if (/^[ \t]*(''|data)/i) {
            print;
            next;
        }

        # Temporarily replace any quoted strings to protect their contents
        my @literals = m/\"[^"]*\"/g;
        s/\"[^"]*\"/@@/g;

        # Remove comments
        s/[ \t]*'[^'].*$//;
        chomp;
        next unless length;

        # Fix up the silliness that is $dynamic
        s/[ \t]*\$dynamic/'\$dynamic/i;

        # Apply macros
        foreach my $pattern (keys %macros) {
            $_ = gsub_copy($_, $pattern, $macros{$pattern});
        }
        # Put back strings
        foreach my $s (@literals) {
            s/@@/$s/
        }
        print;
        print "\n";
    }
}
