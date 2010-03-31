#! /bin/bash

TCG=./georg_testcase-generator.sh
DIR=~/abgabe/scanner
ELF=~/abgabe/scanner/scanner
LOC=/usr/ftp/pub/ubvl/test/scanner

if ! make -C $DIR/
then
	echo >&2 "ERROR: make failed"
	exit 1
fi

while read DIGITS i
do
	# generate testcases using charset in hex
	if ! PROGRAM=$ELF DIGITS=$DIGITS $TCG $i > /dev/null
	then
		echo >&2 "ERROR: TCG failed"
		rm -f $i.*.*
		exit 1
	fi

	# positive tests only
	mv -f $i.0.0 georg_$i.0
	mv -f $i.0.1 georg_$i.out

	# cleanup
	rm -f $i.*.*

done << EOF
3	$(echo -ne ' :='	| xxd -ps)
6	$(echo -ne ' /*1'	| xxd -ps)
5	$(echo -ne ' if1'	| xxd -ps)
4	$(echo -ne ' 0x1'	| xxd -ps)
2	$(echo -ne ' \t\r\f\b'	| xxd -ps)
EOF
# skip that below
cat > /dev/null << EOF
3	$(echo -ne '0123'	| xxd -ps)
6	$(echo -ne ' if39'	| xxd -ps)
7	$(echo -ne ' if0x1'	| xxd -ps)
EOF

# testbench
$LOC/test 2>&1

## Georg Schiesser <e0307201/AT/student.tuwien.ac.at> @ UBVL 2010S # GPLv2
## vim: filetype=sh shiftwidth=8 tabstop=8 noexpandtab nopaste:
## EOF
