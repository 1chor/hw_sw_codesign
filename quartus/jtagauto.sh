#!/bin/bash

while :
do
	output=$(timeout 0.5 jtagconfig 2>/dev/null)
	status=$?
	#echo "$output"
	if [ $status -eq 124 ]; then
		#jtagconfig timed out
		echo -n "."
		#echo "jtagconfig timed out --> error connecting to board"
		sleep 0.1
		#killall jtagd
	else	
		#echo "$output"
		if [[ "$output" = "" ]]; then
			#board not connected, no output on stdout
			#echo "No board connected"
			echo -n "."
		elif [[ $output = *"lock"* ]]; then
			#some other error
			#echo "Error connecting to board"
			echo -n "."
		elif [[ $output = *"Unable"* ]]; then
			#echo "Error connecting to board"
			echo -n "."
		else
			echo "Connection established"
			echo "$output"
			break;
		fi
	fi
done


