#!/bin/sh

# Location of QB64 compiler
QB64=/home/luke/comp/git_qb64/qb64

root=`pwd`

mkdir -p build

if [ "$1" ]
then $QB64 -x $root/tools/tsgen.bas -o $root/build/tsgen
$QB64 -x $root/tools/tokgen.bas -o $root/build/tokgen

$root/build/tsgen $root/src/ts.rules
$root/build/tokgen $root/src/tokens.list $root/build/token_data.bi $root/build/ts_mappings.bm
fi

$QB64 -x $root/src/65.bas -o $root/build/65


