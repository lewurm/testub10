#!/bin/bash
cd `dirname "$_"`
CURDIR="$PWD"

if [ "$1" == "" ]; then
    echo "Verwendung: $0 <abgabe>"
    echo "z.B. $0 codea"
    exit 1
fi

TESTMAIN="$CURDIR/testmain.c"
DUMPINSTR="$CURDIR/dumpinstr.sh"
TRACEDIR="$CURDIR/traces"
RESULT="$TRACEDIR/result.txt"
CALLCONV="$CURDIR/callingconvention.o"

ABG=~/abgabe/$1
TEST=~/test/$1

if [ ! -d $ABG ]; then
    echo "Abgabeverzeichnis $ABG nicht gefunden!"
fi

if [ ! -d $TEST ]; then
    echo "Testverzeichnis $TEST nicht gefunden!"
fi

cd $ABG
make clean; make

TMPNAME=tmp$$

if [ ! -d $TRACEDIR ]; then
    echo "creating $TRACEDIR"
    mkdir $TRACEDIR
fi

rm -f $RESULT

let gni=0
let gti=0
for i in $TEST/*.0; do
    bi=`basename $i`
    bi=${bi%.0}

    # generate .s file and ignore output on stderr
    ./$1 < $i > $TMPNAME.s 2> /dev/null
    # create executable
    gcc -DCALL=\"${i%.0}.call\" -o $TMPNAME $TMPNAME.s $TESTMAIN $CALLCONV
    
    
    # extract the exported symbols from the .s file
    #LABEL=`grep '.globl' $TMPNAME.s | sed 's/^.*\\.globl *\\([a-zA-Z0-9_]\\+\\).*$/\1/g'`

    # this won't work, we need all actual labels
    LABEL=`grep '[a-zA-Z0-9_.$]\\+:' $TMPNAME.s | sed 's/^\\(.*[^a-zA-Z0-9_.$]\\)\\?\\([a-zA-Z0-9_.$]\\+\\):.*$/\2/g'`

    rm -f $TMPNAME.trace
    MATCHES=0
    for j in $LABEL; do
		MATCHES="$MATCHES\\|$j"
		# count instructions
		$DUMPINSTR $TMPNAME $j > /dev/null
		if [ $? != 0 ]; then
			echo "$bi FEHLGESCHLAGEN"
			continue
		fi
    done

    # filter trace
    grep "<\\($MATCHES\\)\\(+[0-9]*\\)\\?>:" $TMPNAME.trace > $TRACEDIR/$bi.trace

    ni=`cat $TRACEDIR/$bi.trace | wc -l`
	if [ -f $TEST/${bi}.instr ]; then
		ti=`cat $TEST/$bi.instr`
	else
		echo "err: fuer den testfall \"$bi\" existiert noch keine referenzdatei"
		ti=0
	fi
    echo "$bi: $ni (referenz: $ti)"
    echo "$bi $ni" >> $RESULT

	let gni=gni+$ni
	let gti=gti+$ti

    # remove waste
    rm -f $TMPNAME $TMPNAME.s $TMPNAME.trace
done

echo ""
echo "Statistik:"
echo "=========="
echo "  $gni  Instruktionen"
echo "  $gti  Referenzinstruktionen"
