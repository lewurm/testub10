#! /bin/bash

[ "$SCRIPT" ]	|| SCRIPT="$(basename $0)"
[ "$PROGRAM" ]	|| PROGRAM='scanner'
[ "$DIGITS" ]	|| DIGITS='3'

if ! test $# -eq 1
then
	cat >&2 << EOF
Usage:
	[ PATH="\$PATH:/a/b" ] [ PROGRAM='$PROGRAM' ] [ DIGITS='$DIGITS' ] \\
	$SCRIPT hexcharset

Example:
	PROGRAM='~/abgabe/scanner/scanner' DIGITS='6' \\
	$SCRIPT 202f2a31 ## \$(echo -n ' /*1' | xxd -ps)
	$SCRIPT 2009     ## \$(echo -ne ' \\t' | xxd -ps)
	$SCRIPT 203a3d   ##  :=  ##  if0x1  #  \\t\\r
	$SCRIPT 202f2a   ##  /*  ##  if39  ##  \\f\\b
	$SCRIPT 202f2a31 ##  /*1  #  0x1  ### 0123
	| sha1sum --check

	scanner < 202f2a31.0.0 \\
	| diff -u 202f2a31.0.1 - \\
	|| (echo >&2 ERROR ; false)

Result:
	sha1sum hexcharset.retval.fileno

Warning: first character in hexcharset behaves slightly differently.
EOF
	exit 1
fi

HEX="$1"
HEX=$(echo "$HEX" | xxd -r -ps | xxd -ps | head -1)
NUM=$(echo "$HEX" | xxd -r -ps | wc -c)

if ! test $NUM -ge 2
then
	echo >&2 "ERROR: charset too small"
	exit 1
fi

if ! test $NUM -le 16
then
	echo >&2 "ERROR: charset too big"
	exit 1
fi

if ! ( echo | $PROGRAM )
then
	echo >&2 "ERROR: program failed"
	exit 1
fi

MAX=$((NUM**(DIGITS)-1))
SRC=$(seq 0 $((NUM-1)) | sed -e "1iobase=$NUM" | bc | tr -d '\n')

rm -f $HEX.i.*
rm -f $HEX.*.*

for i in $(seq $MAX | sed -e "1iobase=$NUM" | bc)
do
	echo $i | tr "$SRC" "$(echo $HEX | xxd -r -ps)" > $HEX.i.0

	cat $HEX.i.0 | $PROGRAM >$HEX.i.1 2>$HEX.i.2
	RET=$?

	cat $HEX.i.0 >> $HEX.$RET.0
	cat $HEX.i.1 >> $HEX.$RET.1
	cat $HEX.i.2 >> $HEX.$RET.2
done

rm -f $HEX.i.*
sha1sum $HEX.*.*

# WISHLIST
# set -o pipefail
# MD5 SHA1
# *.[^0].* keep split
# find -iname "$HEX.*.*" -ls
# head $HEX.*.*
# SCRIPT
# multiple string args

## Georg Schiesser <e0307201/AT/student.tuwien.ac.at> @ UBVL 2010S # GPLv2
## vim: filetype=sh shiftwidth=8 tabstop=8 noexpandtab nopaste:
## EOF
