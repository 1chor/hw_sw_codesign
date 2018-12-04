#!/bin/bash

ARGC=$#

if [ $ARGC -ne "3" ]; then 
	echo "usage: reverb_reference INFILE OUTFILE IRFILE"; 
	exit;
fi;

DIRECTORY=$(dirname "$BASH_SOURCE")

FILE_1=$1
FILE_2=$2
FILE_3=$3

octave  --eval "addpath ('$DIRECTORY/octave'); reverb_reference('$FILE_1','$FILE_2', '$FILE_3')"

