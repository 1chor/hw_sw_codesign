#!/bin/bash

ARGC=$#

if [ $ARGC -ne "2" ]; then 
	echo "usage: checkwav.sh WAV_FILE_1 WAV_FILE_2"; 
	exit;
fi;


DIRECTORY=$(dirname "$BASH_SOURCE")

FILE_1=$1
FILE_2=$2

octave --silent --eval "addpath ('$DIRECTORY/octave'); correlation_wav_files('$FILE_1','$FILE_2')"
