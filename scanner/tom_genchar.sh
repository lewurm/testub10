#!/bin/bash

#good: 40,41,42,44,45,46,58-61,
for i in `seq 0 8` `seq 11 31` `seq 33 39` 43 47 62 63 64 91 92 93 94 96 `seq 123 128`
	do printf "%x" $i | ( read a; echo -en "\x$a" ) > cc$i.1
done
