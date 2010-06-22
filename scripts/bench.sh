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
    gcc -static -DCALL=\"${i%.0}.call\" -o $TMPNAME $TMPNAME.s $TESTMAIN $CALLCONV
    
    
    # extract the exported symbols from the .s file
    #LABEL=`grep '.globl' $TMPNAME.s | sed 's/^.*\\.globl *\\([a-zA-Z0-9_]\\+\\).*$/\1/g'`

	 # funktionsnamen der funktionen die gecall't werden (z.b. library
	 # funktionen wie malloc)
	 grep 'call ' $TMPNAME.s | sed 's/call //g;s/ //g;s/\t//g' > $TMPNAME.uniq

    # this won't work, we need all actual labels
     grep '[a-zA-Z0-9_.$]\+:' $TMPNAME.s | sed 's/^\(.*[^a-zA-Z0-9_.$]\)\?\([a-zA-Z0-9_.$]\+\):.*$/\2/g' >> $TMPNAME.uniq

	 cat $TMPNAME.uniq | sort | uniq  > $TMPNAME.tmp123
	 cat $TMPNAME.tmp123 > $TMPNAME.uniq
	 rm $TMPNAME.tmp123
     LABEL_ASM=`cat $TMPNAME.uniq`

     # functionidentifiers from CALL-file
     grep '[a-zA-Z_][a-zA-Z0-9_]*(.*)' ${i%.0}.call | sed 's/.*[^a-zA-Z_]\([a-zA-Z_][a-zA-Z0-9_]*\)(.*)\;/\1/g' | sort | uniq >> $TMPNAME.uniq

     LABEL=`sort $TMPNAME.uniq | uniq -d`
     rm $TMPNAME.uniq

    rm -f $TMPNAME.trace
    for j in $LABEL; do
		# count instructions
		$DUMPINSTR $TMPNAME $j > /dev/null
		if [ $? != 0 ]; then
			echo "$bi FEHLGESCHLAGEN"
			continue
		fi
    done

    MATCHES=0
	for j in $LABEL_ASM; do
		MATCHES="$MATCHES\\|$j"
	done

    # filter trace
    grep "<\\($MATCHES\\)\\(+[0-9]*\\)\\?>:" $TMPNAME.trace > $TRACEDIR/$bi.trace

    ni=`cat $TRACEDIR/$bi.trace | wc -l`
	if [ -f $TEST/${bi}.instr ]; then
		ti=`cat $TEST/$bi.instr`
	else
		echo "err: fuer den testfall \"$bi\" existiert noch keine referenzdatei. instruktionen werden verworfen."
		ti=0
	fi

	if [ $ni -gt $ti ]; then
		# cnt = ti * 1.2 and rounded
		cnt=`echo $ti*1.2 | bc -l | xargs printf "%1.0f"`
		if [ $ni -gt $cnt ]; then
			#dark red
			bcolor="\033[00;31m"
		else
			#red
			bcolor="\033[01;31m"
		fi
	else
		if [ $ni -eq $ti ]; then
			#gray
			bcolor="\033[01;30m"
		else
			#green
			bcolor="\033[01;32m"
		fi
	fi

    echo -e "$bcolor $bi: $ni (referenz: $ti) \033[0m"
    echo "$bi $ni" >> $RESULT

	if [ -f $TEST/${bi}.instr ]; then
		let gni=gni+$ni
		let gti=gti+$ti
	fi

    # remove waste
    rm -f $TMPNAME $TMPNAME.s $TMPNAME.trace
done

echo ""
echo "Statistik:"
echo "=========="
echo "  $gni  Instruktionen"
echo "  $gti  Referenzinstruktionen"
