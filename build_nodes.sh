#!/bin/bash
# 2023 Alan Barrow KM4BA

# Save our options
while getopts "vsd" opts
do
    case "${opts}" in
        v) verbose=1; echo "Verbose mode";;
        s) silent=1;;
        d) debug=1;;
        \? ) echo "Usage: $0 -v verbose -s silent -d debugging" ; exit 1;;
    esac
done


# Setup some dirs
nodelist="/var/log/asterisk/astdb.txt"
#sounddir="/var/lib/asterisk/sounds"
sounddir="/tmp/sounds"
nodesounddir="$sounddir/rpt/nodenames"

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
	first=`echo "${call:0:1}"`
	firstn=`echo "${node:0:1}"`
	#echo "first is:" $first
	if [[ ! -f "rpt/nodenames/$node.ulaw" && "$first" =~ [a,k,n,w] && "$firstn" =~ [0-9] ]]
	# no node file, so make one
	then
	if [ "$silent" != 1 ] ; then echo "new node is" $node $call ; fi
		for (( i=0; i<${#call}; i++ )); do
			X=`echo "${call:$i:1}"`
			case $X in
			#if [[ "$X" =~ [a-z] ]]
			[a-z])
				#echo "letter " $X
				cat letters/"$X".ulaw >> rpt/nodenames/"$node".ulaw
				;;
			[0-9])
				#echo "num " $X
				cat digits/"$X".ulaw >> rpt/nodenames/"$node".ulaw
				;;
			-)
				#echo "dash " $X
				cat letters/dash.ulaw >> rpt/nodenames/"$node".ulaw
				;;
			/)
				#echo "slash " $X
				cat letters/slash.ulaw >> rpt/nodenames/"$node".ulaw
				;;
			*)
				echo "unknown" $node $call
			esac
		done
	else
		if [ "$verbose" == 1 ]; then echo "skipping " $node $call ; fi
	fi


done
