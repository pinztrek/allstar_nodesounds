#!/bin/bash
# 2023 Alan Barrow KM4BA

# Save our options
while getopts "vsdD" opts
do
    case "${opts}" in
        v) verbose=1; echo "Verbose mode";;
        s) silent=1;;
        d) debug=1; echo "Debug on";;
        D) dryrun=1; echo "Dry-run mode";; 
        \? ) echo "Usage: $0 [-v] [-s] [-d] [-D]" ; exit 1;;
    esac
done


# Setup some dirs
nodelist="/var/log/asterisk/astdb.txt"
sounddir="/var/lib/asterisk/sounds"
#sounddir="/tmp/sounds"
nodesounddir="$sounddir/rpt/nodenames"

# only calls beginning with these letters are processed
callprefix="a,k,n,w"

# regex to match a legit callsign with optional / or - suffix
#callmatch='[a-z]+[0-9]{1,2}[a-z]+' # more liberal match
callmatch='^[2349]?[a-z]{1,2}[0-9]{1,2}[a-z]{1,3}[-/]?[[a-zA-Z0-9]*$'
if [ "$debug" ] ; then echo "Callsign regex is:$callmatch"; fi

# check to make sure key dirs exist and are read/writable as needed
if [ ! -r "$nodelist" ]
then
    echo "$nodelist file does not exist or not readable!"
    exit 1
fi

if [ ! -d "$sounddir" -o ! -r "$sounddir" ]
then
    echo "$sounddir does not exist or not writable!"
    exit 1
fi

if [ ! -d "$nodesounddir" -o ! -w "$nodesounddir" ]
then
    echo "$nodesounddir does not exist or not writable!"
    exit 1
fi

# we will work from where the sound library is
cd $sounddir

# work through the nodes excluding invalid entries or those not of interest
for str in `awk -F '|' '{print $1 "," tolower($2)}' $nodelist |
grep '\|' | grep -v blank | grep -v hub | grep -v network |
grep -v _ | grep -v '('| grep -v '\.' `

# main loop 
do 
	if [ "$debug" == 1 ] ; then echo "checking: " $str ; fi
	node=`echo $str |cut -f1 -d,`
	call=`echo $str |cut -f2 -d,`
	call=`echo $call | tr -d '[:space:]'`
	first=`echo "${call:0:1}"`
	firstn=`echo "${node:0:1}"`
	#echo "first is:" $first

	if [[ "$call" =~ $callmatch ]]
	then
		if [ "$debug" ] ; then echo "Is a callsign:" $node $call ; fi
	else
		if [ "$verbose" ] ; then echo "not a callsign:" $node $call ; fi
		continue
	fi

	if [[ ! -f "rpt/nodenames/$node.ulaw" && "$first" =~ [$callprefix] && "$firstn" =~ [0-9] ]]
	# no node file, so make one
	then
	if [ "$silent" != 1 ] ; then echo "new node is" $node $call ; fi
		for (( i=0; i<${#call}; i++ )); do
			X=`echo "${call:$i:1}"`
			case $X in
			[a-z])
				#echo "letter " $X
				if [ ! "$dryrun" ]
				then
				cat letters/"$X".ulaw >> rpt/nodenames/"$node".ulaw
				fi
				;;
			[0-9])
				if [ ! "$dryrun" ]
				then
				#echo "num " $X
				cat digits/"$X".ulaw >> rpt/nodenames/"$node".ulaw
				fi
				;;
			-)
				if [ ! "$dryrun" ]
				then
				#echo "dash " $X
				cat letters/dash.ulaw >> rpt/nodenames/"$node".ulaw
				fi
				;;
			/)
				if [ ! "$dryrun" ]
				then
				#echo "slash " $X
				cat letters/slash.ulaw >> rpt/nodenames/"$node".ulaw
				fi
				;;
			*)
				echo "unknown" $node $call
			esac
		done
	else
		if [ "$verbose" == 1 ]; then echo "skipping " $node $call ; fi
	fi


done
