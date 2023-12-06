#!/usr/bin/bash

INPUT_FILE=$1
INPUT_DATA=$(<"$INPUT_FILE")

die() {
	echo "$1"
	exit 1
}

ACCUMULATOR=0
while read LINE; do
	[[ "$LINE" =~ ^Game\ ([[:digit:]]*):\ (.*)$ ]]
	GAME_NUMBER=${BASH_REMATCH[1]}
	POSSIBLE=1
	IFS=\;
	read -a SETS <<<"${BASH_REMATCH[2]}"
	for SET in "${SETS[@]}"; do
		IFS=\,
		read -a SUBSETS <<<"$SET"
		for SUBSET in "${SUBSETS[@]}"; do
			[[ "$SUBSET" =~ ([[:digit:]]*)\ (red|blue|green) ]]
			COUNT=${BASH_REMATCH[1]}
			COLOR=${BASH_REMATCH[2]}
			if [[ "$COLOR" == "red" && "$COUNT" -gt 12 || \
			      "$COLOR" == "green" && "$COUNT" -gt 13 || \
			      "$COLOR" == "blue" && "$COUNT" -gt 14 ]]; then
				POSSIBLE=0
				break 2
			fi
		done
	done
	if [[ "$POSSIBLE" == 1 ]]; then
		ACCUMULATOR=$((ACCUMULATOR+GAME_NUMBER))
	fi
done <<<"$INPUT_DATA"
echo $ACCUMULATOR
