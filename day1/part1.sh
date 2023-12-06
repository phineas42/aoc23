#!/usr/bin/bash

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

ACCUMULATOR=0
while read LINE; do
	if [[ "$LINE" =~ ([[:digit:]]) ]]; then
		DIGITS=${BASH_REMATCH[1]}
		[[ "$LINE" =~ ([[:digit:]])[^[:digit:]]*$ ]]
		DIGITS+=${BASH_REMATCH[1]}
		ACCUMULATOR=$((ACCUMULATOR+DIGITS))
	else
		die "Failed to find a digit"
	fi
done <<<"$INPUT_DATA"
echo $ACCUMULATOR
