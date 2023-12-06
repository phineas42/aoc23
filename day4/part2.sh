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
declare -a EXTRA_COPIES
while read LINE; do
	VALUE=0
	[[ "$LINE" =~ ([[:digit:]]+)\:([\ [:digit:]]+)\|([\ [:digit:]]+)$ ]]
	CARD_NUMBER=${BASH_REMATCH[1]}
	WINNING_NUMBERS=(${BASH_REMATCH[2]})
	YOUR_NUMBERS=(${BASH_REMATCH[3]})
	for YOUR_NUMBER in ${YOUR_NUMBERS[@]}; do
		if list_contains WINNING_NUMBERS $YOUR_NUMBER; then
			VALUE=$((VALUE+1))
		fi
	done
	COPIES_OF_SELF=$((1+${EXTRA_COPIES[CARD_NUMBER]:-0}))
	for ((I=1;I<=$VALUE;I++)); do
		EXTRA_COPIES[$((I+CARD_NUMBER))]=$((EXTRA_COPIES[I+CARD_NUMBER]+COPIES_OF_SELF))
	done
	ACCUMULATOR=$((ACCUMULATOR+COPIES_OF_SELF))
done <<<"$INPUT_DATA"
echo "$ACCUMULATOR"
