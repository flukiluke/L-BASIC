#!/usr/bin/env python3
# Copyright Luke Ceddia
# SPDX-License-Identifier: Apache-2.0
# prep.py - Preprocess and prepare
# This is basically a macro expander. It also removes comments.

# A macro is a text-based replacement that allows for more concise and self-describing code.
# To define a macro, the $macro directive is used. The general syntax is
# $macro: INPUTFORMAT | OUTPUTFORMAT
# Alternatively, macros may be defined as command line arguments with the -D option:
# -D 'INPUTFORMAT | OUTPUTFORMAT'
#
# Whenever a match is found for INPUTFORMAT, it is replaced by OUTPUTFORMAT. The double-at
# operator @@ may appear multiple times in the INPUTFORMAT. These are matched with a word
# (a word is a string matching [A-Za-z0-9_]+) and can be referred to in the OUTPUTFORMAT
# as @1, @2 etc. counted in order of appearance. A '\n' in OUTPUTFORMAT is translated to
# a newline in the final result.
# Content in string literals is not modified.

import re
import argparse

RE_MACRO_DEF = re.compile(r'^[ \t]*\$macro[ \t]*:([^|]+)\|(.+)', flags=re.I)
RE_COMMENT = re.compile(r"^[ \t]*(rem |')", flags=re.I)
RE_IGNORE_LINE = re.compile(r"^[ \t]*(?:''|data)", flags=re.I)
RE_STRINGS = re.compile(r'"[^"]*"')

macros = {}

def process_line(line):
    global macros
    def_match = re.match(RE_MACRO_DEF, line)
    if def_match:
        output_format = def_match.group(2).strip()
        output_format = output_format.replace('\\n', '\n')
        define_macro(def_match.group(1).strip(), output_format)
        return ''
    elif re.match(RE_IGNORE_LINE, line):
        # Leave double-commented and DATA lines entirely alone
        return line
    elif re.match(RE_COMMENT, line):
        # Remove comments
        return ''
    elif re.match(r'[ \t]*\$dynamic', line):
        # Fix up the silliness that is $dynamic
        return "'$dynamic\n"
    else:
        # Temporarily replace any quoted strings to protect their contents
        literals = re.findall(RE_STRINGS, line)
        line = re.sub(RE_STRINGS, '@@', line)

        # Apply macros
        for (pattern, result) in macros.items():
            line = re.sub(pattern, result, line)

        # Put back strings
        line = re.sub('@@', lambda _ : literals.pop(0), line)
        return line

def define_macro(pattern, result):
    global macros
    # Protect special characters
    pattern = re.escape(pattern)
    # Setup matching groups
    pattern = pattern.replace('@@', r'(\w+)')
    result = re.sub('@(\d)', lambda m : '\\' + m.group(1), result)
    macros[pattern] = result

def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-D', '--define', metavar="'INPUTFORMAT | OUTPUTFORMAT'", action='append')
    argparser.add_argument('infile')
    argparser.add_argument('outfile')
    args = argparser.parse_args()

    if args.define is not None:
        for pattern, result in map(lambda x: x.split('|'), args.define):
            define_macro(pattern, result)

    with open(args.infile) as inputfile, open(args.outfile, 'w') as outputfile:
        for line in inputfile.readlines():
            result = process_line(line)
            outputfile.write(result)

if __name__ == '__main__':
    main()
