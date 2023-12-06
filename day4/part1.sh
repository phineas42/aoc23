#!/usr/bin/bash

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

list_contains() {
	local -n LIST=$1
	local ELEMENT=$2
	local LIST_ELEMENT
	for LIST_ELEMENT in "${LIST[@]}"; do
		if [[ "$ELEMENT" == "$LIST_ELEMENT" ]]; then
			return 0
		fi
	done
	return 1
}

ACCUMULATOR=0
while read LINE; do
	VALUE=0
	[[ "$LINE" =~ \:([\ [:digit:]]+)\|([\ [:digit:]]+)$ ]]
	WINNING_NUMBERS=(${BASH_REMATCH[1]})
	YOUR_NUMBERS=(${BASH_REMATCH[2]})
	for YOUR_NUMBER in ${YOUR_NUMBERS[@]}; do
		if list_contains WINNING_NUMBERS $YOUR_NUMBER; then
			if [[ $VALUE == 0 ]]; then
				VALUE=1
			else
				VALUE=$((VALUE*2))
			fi
		fi
	done
	ACCUMULATOR=$((ACCUMULATOR+VALUE))
done <<<"$INPUT_DATA"
echo "$ACCUMULATOR"
