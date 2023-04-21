#!/bin/bash

cd /var/lib/asterisk/sounds


for str in `awk -F '|' '{print $1 "," tolower($2)}' /var/log/asterisk/astdb.txt | grep '\|' | grep -v blank | grep -v hub | grep -v network | grep -v _ | grep -v '('| grep -v '\.' `
do 
	#echo $str
	node=`echo $str |cut -f1 -d,`
	call=`echo $str |cut -f2 -d,`
	first=`echo "${call:0:1}"`
	firstn=`echo "${node:0:1}"`
	#echo "first is:" $first
	if [[ ! -f "rpt/nodenames/$node.ulaw" && "$first" =~ [a,k,n,w] && "$firstn" =~ [0-9] ]]
	# no node file, so make one
	then
	echo "node is" $node $call
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
		echo "skipping " $node $call
	fi


done
